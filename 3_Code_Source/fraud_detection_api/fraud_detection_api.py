"""
API Flask pour la Détection de Fraude Bancaire
Sert le modèle RandomForest entraîné
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import numpy as np
import json
from datetime import datetime
import logging

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialisation de l'application Flask
app = Flask(__name__)
CORS(app)  # Activer CORS pour les requêtes cross-origin

# ==================== CHARGEMENT DU MODÈLE ====================
logger.info("🤖 Chargement du modèle et des encoders...")

try:
    # Charger le modèle
    model = joblib.load('fraud_detection_model.pkl')
    
    # Charger les encoders
    le_category = joblib.load('label_encoder_category.pkl')
    le_location = joblib.load('label_encoder_location.pkl')
    
    # Charger les métadonnées
    with open('model_metadata.json', 'r') as f:
        metadata = json.load(f)
    
    logger.info("✓ Modèle chargé avec succès")
    logger.info(f"   - Type: {metadata['model_type']}")
    logger.info(f"   - Accuracy: {metadata.get('test_accuracy', metadata.get('accuracy', 1.0)):.4f}")
    
    MODEL_LOADED = True
    
except Exception as e:
    logger.error(f"❌ Erreur lors du chargement du modèle: {e}")
    MODEL_LOADED = False

# ==================== ROUTES ====================

@app.route('/', methods=['GET'])
def home():
    """Page d'accueil de l'API"""
    return jsonify({
        'service': 'DigitalBank Fraud Detection API',
        'version': '1.0.0',
        'status': 'running' if MODEL_LOADED else 'error',
        'endpoints': {
            '/': 'Informations de lAPI',
            '/health': 'Vérification de la santé de lAPI',
            '/predict': 'Prédiction de fraude (POST)',
            '/predict/batch': 'Prédictions en batch (POST)',
            '/model/info': 'Informations sur le modèle',
            '/test': 'Test avec des exemples'
        }
    }), 200

@app.route('/health', methods=['GET'])
def health():
    """Vérification de la santé de l'API"""
    if MODEL_LOADED:
        return jsonify({
            'status': 'healthy',
            'model': 'loaded',
            'timestamp': datetime.now().isoformat()
        }), 200
    else:
        return jsonify({
            'status': 'unhealthy',
            'model': 'not loaded',
            'timestamp': datetime.now().isoformat()
        }), 503

@app.route('/model/info', methods=['GET'])
def model_info():
    """Informations sur le modèle"""
    if not MODEL_LOADED:
        return jsonify({'error': 'Model not loaded'}), 503
    
    return jsonify({
        'model_type': metadata['model_type'],
        'accuracy': metadata.get('test_accuracy', metadata.get('accuracy', 1.0)),
        'train_samples': metadata['train_samples'],
        'features': metadata['features'],
        'feature_importance': metadata['feature_importance'],
        'created_at': metadata['created_at'],
        'categories': metadata['categories'],
        'locations': metadata['locations']
    }), 200

@app.route('/predict', methods=['POST'])
def predict():
    """
    Prédire si une transaction est frauduleuse
    
    Body JSON attendu:
    {
        "transaction_id": 12345,
        "amount": 2500.0,
        "merchant_category": "Cryptocurrency",
        "location": "Dubai, UAE",
        "hour_of_day": 2,
        "day_of_week": 1
    }
    
    OU version simplifiée avec features déjà encodées:
    {
        "features": [2500.0, 5, 10, 2, 1]
    }
    """
    if not MODEL_LOADED:
        return jsonify({'error': 'Model not loaded'}), 503
    
    try:
        data = request.json
        
        # Vérifier si les features sont déjà encodées
        if 'features' in data:
            features = np.array(data['features']).reshape(1, -1)
        else:
            # Extraire les valeurs
            amount = float(data['amount'])
            merchant_category = str(data['merchant_category'])
            location = str(data['location'])
            hour_of_day = int(data['hour_of_day'])
            day_of_week = int(data['day_of_week'])
            
            # Encoder les features catégorielles
            try:
                category_encoded = le_category.transform([merchant_category])[0]
            except:
                # Si catégorie inconnue, utiliser la première catégorie par défaut
                category_encoded = 0
                logger.warning(f"Catégorie inconnue: {merchant_category}, utilisation de la valeur par défaut")
            
            try:
                location_encoded = le_location.transform([location])[0]
            except:
                # Si localisation inconnue, utiliser la première localisation par défaut
                location_encoded = 0
                logger.warning(f"Localisation inconnue: {location}, utilisation de la valeur par défaut")
            
            # Créer le vecteur de features
            features = np.array([[
                amount,
                category_encoded,
                location_encoded,
                hour_of_day,
                day_of_week
            ]])
        
        # Prédiction
        prediction = model.predict(features)[0]
        probabilities = model.predict_proba(features)[0]
        fraud_score = float(probabilities[1])
        
        # Déterminer le niveau de risque
        if fraud_score >= 0.8:
            risk_level = "CRITIQUE"
            risk_color = "red"
        elif fraud_score >= 0.5:
            risk_level = "ÉLEVÉ"
            risk_color = "orange"
        elif fraud_score >= 0.3:
            risk_level = "MOYEN"
            risk_color = "yellow"
        else:
            risk_level = "FAIBLE"
            risk_color = "green"
        
        # Construire la réponse
        response = {
            'transaction_id': data.get('transaction_id', None),
            'is_fraud': bool(prediction),
            'fraud_score': fraud_score,
            'fraud_probability': f"{fraud_score * 100:.2f}%",
            'risk_level': risk_level,
            'risk_color': risk_color,
            'timestamp': datetime.now().isoformat(),
            'confidence': 'high' if fraud_score > 0.8 or fraud_score < 0.2 else 'medium',
            'recommendation': get_recommendation(fraud_score)
        }
        
        logger.info(f"✓ Prédiction effectuée: {response['is_fraud']} (score: {fraud_score:.4f})")
        
        return jsonify(response), 200
        
    except KeyError as e:
        return jsonify({
            'error': f'Missing required field: {e}',
            'required_fields': ['amount', 'merchant_category', 'location', 'hour_of_day', 'day_of_week']
        }), 400
    except Exception as e:
        logger.error(f"❌ Erreur lors de la prédiction: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/predict/batch', methods=['POST'])
def predict_batch():
    """
    Prédire en batch (plusieurs transactions à la fois)
    
    Body JSON attendu:
    {
        "transactions": [
            {
                "transaction_id": 1,
                "amount": 100,
                "merchant_category": "Groceries",
                ...
            },
            ...
        ]
    }
    """
    if not MODEL_LOADED:
        return jsonify({'error': 'Model not loaded'}), 503
    
    try:
        data = request.json
        transactions = data.get('transactions', [])
        
        if not transactions:
            return jsonify({'error': 'No transactions provided'}), 400
        
        results = []
        for trans in transactions:
            # Utiliser la fonction predict pour chaque transaction
            with app.test_request_context(json=trans):
                result = predict()
                if result[1] == 200:  # Si succès
                    results.append(result[0].get_json())
                else:
                    results.append({'error': 'Prediction failed', 'transaction': trans})
        
        return jsonify({
            'total_predictions': len(results),
            'results': results,
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Erreur lors de la prédiction batch: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/test', methods=['GET'])
def test():
    """Tester l'API avec des exemples"""
    if not MODEL_LOADED:
        return jsonify({'error': 'Model not loaded'}), 503
    
    # Transaction normale
    normal_transaction = {
        'transaction_id': 'TEST_NORMAL',
        'amount': 150.0,
        'merchant_category': 'Groceries',
        'location': 'Paris, France',
        'hour_of_day': 14,
        'day_of_week': 3
    }
    
    # Transaction frauduleuse
    fraud_transaction = {
        'transaction_id': 'TEST_FRAUD',
        'amount': 3500.0,
        'merchant_category': 'Cryptocurrency',
        'location': 'Dubai, UAE',
        'hour_of_day': 2,
        'day_of_week': 1
    }
    
    # Prédictions
    with app.test_request_context(json=normal_transaction):
        normal_result = predict()[0].get_json()
    
    with app.test_request_context(json=fraud_transaction):
        fraud_result = predict()[0].get_json()
    
    return jsonify({
        'test_cases': {
            'normal_transaction': {
                'input': normal_transaction,
                'output': normal_result
            },
            'fraud_transaction': {
                'input': fraud_transaction,
                'output': fraud_result
            }
        },
        'timestamp': datetime.now().isoformat()
    }), 200

# ==================== FONCTIONS UTILITAIRES ====================

def get_recommendation(fraud_score):
    """Retourner une recommandation basée sur le score de fraude"""
    if fraud_score >= 0.8:
        return "BLOQUER LA TRANSACTION - Contacter immédiatement le client et l'équipe sécurité"
    elif fraud_score >= 0.5:
        return "VÉRIFICATION REQUISE - Demander une authentification supplémentaire"
    elif fraud_score >= 0.3:
        return "SURVEILLANCE - Surveiller les prochaines transactions du client"
    else:
        return "AUTORISER - Transaction normale, aucune action requise"

# ==================== LANCEMENT DE L'APPLICATION ====================

if __name__ == '__main__':
    logger.info("=" * 60)
    logger.info("🚀 Démarrage de l'API de Détection de Fraude")
    logger.info("=" * 60)
    logger.info("📍 URL: http://localhost:5000")
    logger.info("📖 Documentation: http://localhost:5000/")
    logger.info("🧪 Test: http://localhost:5000/test")
    logger.info("=" * 60)
    
    # Lancer l'application
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True
    )