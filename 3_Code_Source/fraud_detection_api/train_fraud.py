"""
Script d'entraînement du modèle - Compatible Windows + Python 3.9
À exécuter sur ton PC pour générer des fichiers .pkl compatibles
"""

import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, roc_auc_score
import joblib
import json
from datetime import datetime
import os

print("=" * 70)
print("🤖 ENTRAÎNEMENT DU MODÈLE DE DÉTECTION DE FRAUDE")
print("=" * 70)

# ==================== CONFIGURATION ====================
# Chemins des fichiers
CSV_FILE = 'sample_transactions.csv'  # Assure-toi que ce fichier est dans le même dossier
OUTPUT_DIR = '.'  # Répertoire courant

# Vérifier que le CSV existe
if not os.path.exists(CSV_FILE):
    print(f"\n❌ ERREUR : Le fichier {CSV_FILE} n'existe pas!")
    print("   Place le fichier sample_transactions.csv dans le même dossier que ce script.")
    input("\nAppuie sur Entrée pour quitter...")
    exit(1)

# ==================== CHARGEMENT DES DONNÉES ====================
print(f"\n📊 Chargement du dataset {CSV_FILE}...")

try:
    df = pd.read_csv(CSV_FILE)
    print(f"✓ Dataset chargé : {len(df)} transactions")
    print(f"   Colonnes : {list(df.columns)}")
except Exception as e:
    print(f"❌ Erreur lors du chargement : {e}")
    input("\nAppuie sur Entrée pour quitter...")
    exit(1)

# ==================== ANALYSE ====================
print(f"\n📈 Distribution des classes :")
print(df['is_fraud'].value_counts())
fraud_rate = df['is_fraud'].mean() * 100
print(f"\n   Taux de fraude : {fraud_rate:.2f}%")

# ==================== ENCODAGE ====================
print("\n🔧 Encodage des features catégorielles...")

le_category = LabelEncoder()
le_location = LabelEncoder()

df['merchant_category_encoded'] = le_category.fit_transform(df['merchant_category'])
df['location_encoded'] = le_location.fit_transform(df['location'])

print(f"✓ {len(le_category.classes_)} catégories encodées")
print(f"✓ {len(le_location.classes_)} localisations encodées")

# ==================== PRÉPARATION ====================
print("\n📋 Préparation des données...")

feature_columns = [
    'amount',
    'merchant_category_encoded',
    'location_encoded',
    'hour_of_day',
    'day_of_week'
]

X = df[feature_columns]
y = df['is_fraud']

X_train, X_test, y_train, y_test = train_test_split(
    X, y, 
    test_size=0.2, 
    random_state=42,
    stratify=y
)

print(f"✓ Train : {len(X_train)} transactions")
print(f"✓ Test : {len(X_test)} transactions")

# ==================== ENTRAÎNEMENT ====================
print("\n🎯 Entraînement du modèle Random Forest...")

model = RandomForestClassifier(
    n_estimators=100,
    max_depth=15,
    min_samples_split=5,
    min_samples_leaf=2,
    random_state=42,
    n_jobs=-1,
    class_weight='balanced'
)

model.fit(X_train, y_train)

print("✓ Modèle entraîné !")

# ==================== ÉVALUATION ====================
print("\n📊 Évaluation...")

y_pred_test = model.predict(X_test)
test_accuracy = accuracy_score(y_test, y_pred_test)

print(f"\n✓ Accuracy : {test_accuracy:.2%}")

# Classification report
print("\n📋 Rapport de classification :")
print(classification_report(y_test, y_pred_test, target_names=['Normal', 'Fraude']))

# AUC-ROC
y_pred_proba = model.predict_proba(X_test)[:, 1]
auc_score = roc_auc_score(y_test, y_pred_proba)
print(f"✓ AUC-ROC : {auc_score:.4f}")

# Feature importance
feature_importance = pd.DataFrame({
    'feature': feature_columns,
    'importance': model.feature_importances_
}).sort_values('importance', ascending=False)

print("\n📈 Importance des features :")
for idx, row in feature_importance.iterrows():
    print(f"   {row['feature']:<30} : {row['importance']:.4f}")

# ==================== EXPORT ====================
print("\n💾 Export des fichiers...")

# Sauvegarder le modèle
model_path = os.path.join(OUTPUT_DIR, 'fraud_detection_model.pkl')
joblib.dump(model, model_path)
print(f"✓ Modèle : {model_path}")

# Sauvegarder les encoders
encoder_cat_path = os.path.join(OUTPUT_DIR, 'label_encoder_category.pkl')
joblib.dump(le_category, encoder_cat_path)
print(f"✓ Encoder catégories : {encoder_cat_path}")

encoder_loc_path = os.path.join(OUTPUT_DIR, 'label_encoder_location.pkl')
joblib.dump(le_location, encoder_loc_path)
print(f"✓ Encoder localisations : {encoder_loc_path}")

# Métadonnées
metadata = {
    'model_type': 'RandomForestClassifier',
    'n_estimators': 100,
    'max_depth': 15,
    'train_samples': len(X_train),
    'test_samples': len(X_test),
    'fraud_samples': int(y.sum()),
    'normal_samples': int((~y.astype(bool)).sum()),
    'features': feature_columns,
    'train_accuracy': float(accuracy_score(y_train, model.predict(X_train))),
    'test_accuracy': float(test_accuracy),
    'auc_roc': float(auc_score),
    'feature_importance': feature_importance.to_dict('records'),
    'created_at': datetime.now().isoformat(),
    'categories': le_category.classes_.tolist(),
    'locations': le_location.classes_.tolist(),
    'dataset_file': CSV_FILE,
    'dataset_size': len(df),
    'fraud_rate': float(fraud_rate / 100)
}

metadata_path = os.path.join(OUTPUT_DIR, 'model_metadata.json')
with open(metadata_path, 'w', encoding='utf-8') as f:
    json.dump(metadata, f, indent=2, ensure_ascii=False)
print(f"✓ Métadonnées : {metadata_path}")

# ==================== TESTS ====================
print("\n🧪 Tests de prédiction...")

# Test normal
test_normal = pd.DataFrame([{
    'amount': 150.0,
    'merchant_category_encoded': le_category.transform(['Groceries'])[0],
    'location_encoded': le_location.transform(['Paris, France'])[0],
    'hour_of_day': 14,
    'day_of_week': 3
}])

pred_n = model.predict(test_normal)[0]
proba_n = model.predict_proba(test_normal)[0][1]

print(f"\n✓ Transaction normale (150€, Groceries, Paris, 14h)")
print(f"   → Prédiction : {'FRAUDE' if pred_n == 1 else 'NORMAL'}")
print(f"   → Score : {proba_n:.4f}")

# Test fraude
test_fraud = pd.DataFrame([{
    'amount': 3500.0,
    'merchant_category_encoded': le_category.transform(['Cryptocurrency'])[0],
    'location_encoded': le_location.transform(['Nigeria'])[0],
    'hour_of_day': 2,
    'day_of_week': 1
}])

pred_f = model.predict(test_fraud)[0]
proba_f = model.predict_proba(test_fraud)[0][1]

print(f"\n✓ Transaction suspecte (3500€, Cryptocurrency, Nigeria, 2h)")
print(f"   → Prédiction : {'FRAUDE' if pred_f == 1 else 'NORMAL'}")
print(f"   → Score : {proba_f:.4f}")

# ==================== FIN ====================
print("\n" + "=" * 70)
print("✅ MODÈLE ENTRAÎNÉ ET EXPORTÉ AVEC SUCCÈS !")
print("=" * 70)

print(f"\n📦 Fichiers générés dans {os.path.abspath(OUTPUT_DIR)} :")
print(f"   1. fraud_detection_model.pkl")
print(f"   2. label_encoder_category.pkl")
print(f"   3. label_encoder_location.pkl")
print(f"   4. model_metadata.json")

print("\n🚀 Prochaine étape :")
print("   Lance l'API Flask : python fraud_detection_api.py")

print("\n✅ Version scikit-learn utilisée :", end=" ")
import sklearn
print(sklearn.__version__)

input("\n\nAppuie sur Entrée pour quitter...")