# 🏦 DigitalBank - Plateforme de Gestion et Monitoring

## 📋 Description du Projet

DigitalBank est une plateforme complète de gestion des données bancaires et de monitoring de sécurité développée avec des outils no-code/low-code. Le projet fait suite à une cyberattaque majeure et vise à restaurer, sécuriser et moderniser l'infrastructure bancaire.

### Objectifs Principaux
- ✅ Visualiser les données clients et transactions en temps réel
- ✅ Détecter et alerter sur les activités frauduleuses via IA
- ✅ Gérer les accès utilisateurs avec RBAC (Role-Based Access Control)
- ✅ Monitorer la sécurité et les performances du système
- ✅ Générer des rapports automatisés

---

## 👥 Membres du Groupe

| Nom & Prénom |
|--------------|
| **GUETAT Youssef** |
| **MASMOUDI Hadil** |
| **FEKI Ameni** |

---

## 🏗️ Architecture Technique

```
┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND / DASHBOARDS                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Metabase    │  │   Grafana    │  │  Supabase UI │      │
│  │  Analytics   │  │  Monitoring  │  │   Dashboard  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      API LAYER & BACKEND                     │
│  ┌──────────────────────────────────────────────────────┐   │
│  │            Supabase (PostgreSQL + API REST)          │   │
│  │  • Authentification JWT + MFA                        │   │
│  │  • Row Level Security (RLS)                          │   │
│  │  • API REST auto-générée                             │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │        Flask API - Détection Fraude ML               │   │
│  │  • Modèle Random Forest / Isolation Forest           │   │
│  │  • Prédiction temps réel                             │   │
│  │  • Score de risque (0-100%)                          │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   AUTOMATISATION & WORKFLOWS                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                    Make.com                          │   │
│  │  • Alertes email automatiques                        │   │
│  │  • Workflow détection fraude                         │   │
│  │  • Rapports quotidiens                               │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  MONITORING & LOGS                           │
│  ┌────────────────────┐  ┌─────────────────────┐           │
│  │   Prometheus       │  │      Grafana        │           │
│  │  • Métriques       │  │  • Visualisation    │           │
│  │  • Alertes         │  │  • Dashboards       │           │
│  └────────────────────┘  └─────────────────────┘           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     BASE DE DONNÉES                          │
│              PostgreSQL (via Supabase)                       │
│  • customers (clients)                                       │
│  • accounts (comptes)                                        │
│  • transactions (transactions)                               │
│  • cards (cartes)                                            │
│  • audit_logs (traçabilité)                                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Technologies Utilisées

### Backend & Base de Données
- **Supabase** - Backend as a Service (PostgreSQL + API REST + Auth)
- **PostgreSQL** - Base de données relationnelle
- **Flask** - API Python pour le modèle ML

### Dashboards & Visualisation
- **Metabase** - Business Intelligence et analytics
- **Grafana** - Monitoring et métriques temps réel
- **Supabase Dashboard** - Interface d'administration

### Monitoring & Métriques
- **Prometheus** - Collecte de métriques système
- **Grafana** - Visualisation des métriques
- **Docker** - Containerisation

### Automatisation
- **Make.com** - Workflows et automatisations (alertes, rapports)

### Machine Learning
- **scikit-learn** - Modèles de détection de fraude
- **pandas** - Manipulation de données
- **joblib** - Sérialisation du modèle

### Tests & Sécurité
- **Postman** - Tests API
- **pgcrypto** - Chiffrement PostgreSQL
- **JWT** - Authentification sécurisée

---

## 📦 Prérequis

### Logiciels Requis
```bash
- Docker Desktop (v20.10+)
- Docker Compose (v2.0+)
- Python 3.10+
- Git
- Compte Supabase (gratuit)
- Compte Make.com (gratuit)
```

### Ports Utilisés
```
- 3000: Metabase
- 3001: Grafana
- 5000: Flask API
- 9090: Prometheus
- 54321: Supabase (local, optionnel)
```

---

## ⚙️ Installation

### 1. Cloner le Projet
```bash
git clone https://github.com/YoussefGuetat/Groupe_DevForce_Examen.git
cd Groupe_DevForce_Examen
```

### 2. Configuration Supabase

#### A. Créer un Projet Supabase
1. Aller sur [supabase.com](https://supabase.com)
2. Créer un nouveau projet : `digitalbank-prod`
3. Noter l'URL du projet et la clé API (anon key)

#### B. Restaurer la Base de Données
```bash
# Se connecter à Supabase via psql
psql -h db.xxxxxx.supabase.co -U postgres -d postgres

# Restaurer le dump
\i supabase_config/schema.sql
\i supabase_config/policies.sql
```

#### C. Configurer Row Level Security (RLS)
```sql
-- Les policies RLS sont dans supabase_config/policies.sql
-- Elles sont automatiquement appliquées lors de la restauration
```

### 3. Configuration de l'API Flask ML

```bash
cd fraud_detection_api

# Créer un environnement virtuel
python -m venv venv
source venv/bin/activate  # Sur Windows: venv\Scripts\activate

# Installer les dépendances
pip install -r requirements.txt

# Lancer l'API
python app.py
```

L'API sera accessible sur `http://localhost:5000`

### 4. Lancer les Services Docker

```bash
# Lancer Prometheus, Grafana et Metabase
docker-compose up -d

# Vérifier que tous les containers sont actifs
docker ps
```

### 5. Configuration Metabase

1. Accéder à `http://localhost:3000`
2. Créer un compte administrateur
3. Ajouter une connexion PostgreSQL :
   - **Host** : db.xxxxxx.supabase.co
   - **Port** : 5432
   - **Database** : postgres
   - **User** : postgres
   - **Password** : [votre mot de passe Supabase]

### 6. Configuration Grafana

1. Accéder à `http://localhost:3001`
2. Login par défaut : `admin / admin`
3. Ajouter Prometheus comme data source :
   - **URL** : `http://prometheus:9090`
4. Importer les dashboards depuis `monitoring/grafana_dashboards/`

### 7. Configuration Make.com

1. Créer un compte sur [make.com](https://make.com)
2. Importer les scénarios depuis `workflows/make_scenarios/`
3. Configurer les connexions :
   - Supabase (API Key)
   - Email (Gmail/SMTP)
   - Webhook Flask API

---

## 📖 Guide Utilisateur

### Pour l'Administrateur Système

1. **Connexion** : Accéder à Supabase Dashboard
2. **Gestion des utilisateurs** : Table `auth.users` + RBAC
3. **Monitoring** : Grafana → Dashboard "System Overview"
4. **Logs d'audit** : Metabase → Dashboard "Audit Logs"

### Pour l'Analyste de Sécurité

1. **Connexion** : Metabase
2. **Dashboard fraude** : "Security Analytics"
   - Alertes temps réel
   - Score de risque
   - Carte géographique
3. **Alertes** : Configurées via Make.com (email automatique)

### Pour l'Agent Service Client

1. **Connexion** : Metabase
2. **Recherche client** : Barre de recherche en haut
3. **Consultation** : Historique transactions, soldes
4. **Action** : Bloquer/débloquer carte (via API)

---

## 🔒 Sécurité

- ✅ Authentification JWT + MFA
- ✅ Row Level Security (RLS) PostgreSQL
- ✅ Chiffrement des données sensibles (pgcrypto)
- ✅ RBAC avec 4 rôles (admin, analyst, customer_service, customer)
- ✅ Audit logs complets
- ✅ Tests de sécurité OWASP

---

## 📝 Licence

Ce projet est développé dans le cadre de l'examen ESIS-2-2025-2026 / CPDIA-2-2025-2026.

---

## 📧 Contact

**Groupe DevForce**
- Youssef GUETAT - [guyoussef@etudiant-esic.fr](mailto:guyoussef@etudiant-esic.fr)
- Hadil MASMOUDI - [mahadil@etudiant-esic.fr](mailto:mahadil@etudiant-esic.fr)
- Ameni FEKI - [feameni@etudiant-esic.fr](mailto:feameni@etudiant-esic.fr)

---

**Dernière mise à jour** : Janvier 2026  
**Version** : 1.0.0
