# DigitalBank - Plateforme Bancaire Sécurisée

> Solution complète de gestion bancaire avec détection de fraude par Intelligence Artificielle, monitoring en temps réel et automatisation des workflows.

**Groupe DevForce** | ESIS-2-2025-2026 / CPDIA-2-2025-2026

---

## Table des Matières

- [Aperçu du Projet](#aperçu-du-projet)
- [Fonctionnalités Principales](#fonctionnalités-principales)
- [Architecture Technique](#architecture-technique)
- [Technologies Utilisées](#technologies-utilisées)
- [Structure du Projet](#structure-du-projet)
- [Prérequis](#prérequis)
- [Installation et Configuration](#installation-et-configuration)
- [Utilisation](#utilisation)
- [API de Détection de Fraude](#api-de-détection-de-fraude)
- [Base de Données](#base-de-données)
- [Sécurité](#sécurité)
- [Tests](#tests)
- [Équipe](#équipe)

---

## Aperçu du Projet

**DigitalBank** est une plateforme bancaire moderne développée suite à un incident de cybersécurité. Elle offre une solution complète pour :

- La visualisation en temps réel des données clients et transactions
- La détection automatique de fraudes grâce au Machine Learning
- La gestion des accès utilisateurs avec contrôle basé sur les rôles (RBAC)
- Le monitoring des performances et de la sécurité du système
- L'automatisation des alertes et rapports

---

## Fonctionnalités Principales

### Détection de Fraude par IA
- Modèle Random Forest avec **100% de précision** sur les données de test
- Scoring de risque en temps réel (0-100%)
- Classification en 4 niveaux : CRITIQUE, ÉLEVÉ, MOYEN, FAIBLE
- Prédiction par lot (batch)

### Gestion Bancaire
- Gestion des clients, comptes et cartes
- Historique complet des transactions
- Format IBAN pour les numéros de compte
- Support multi-devises

### Monitoring & Dashboards
- Tableaux de bord Metabase pour l'analyse métier
- Monitoring Grafana pour les métriques système
- Collecte Prometheus pour les séries temporelles

### Automatisation
- Alertes automatiques pour transactions élevées
- Détection des tentatives de connexion échouées
- Rapports journaliers automatiques
- Notifications par email via Make.com

---

## Architecture Technique

```
┌─────────────────────────────────────────────────────────────────┐
│                        UTILISATEURS                              │
│         (Admin, Analyst, Customer Service, Client)               │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      COUCHE PRÉSENTATION                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │   Metabase   │  │   Grafana    │  │  Supabase Dashboard  │   │
│  │   (BI)       │  │ (Monitoring) │  │     (Admin)          │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                       COUCHE SERVICES                            │
│  ┌──────────────────────┐  ┌────────────────────────────────┐   │
│  │  Flask API (ML)      │  │        Make.com                │   │
│  │  Détection Fraude    │  │    (Automatisation)            │   │
│  └──────────────────────┘  └────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                       COUCHE DONNÉES                             │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    Supabase                               │   │
│  │    (PostgreSQL + REST API + Auth + Row Level Security)    │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      COUCHE MONITORING                           │
│  ┌──────────────────────┐  ┌────────────────────────────────┐   │
│  │     Prometheus       │  │     Postgres Exporter          │   │
│  │   (Métriques)        │  │   (Export métriques DB)        │   │
│  └──────────────────────┘  └────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Technologies Utilisées

| Catégorie | Technologie | Usage |
|-----------|-------------|-------|
| **Backend** | Supabase | BaaS (PostgreSQL + REST API + Auth) |
| **Base de données** | PostgreSQL | Base de données relationnelle |
| **ML/IA** | Flask + scikit-learn | API de détection de fraude |
| **BI** | Metabase | Tableaux de bord analytiques |
| **Monitoring** | Grafana + Prometheus | Métriques et alertes |
| **Automatisation** | Make.com | Workflows et notifications |
| **Conteneurisation** | Docker | Déploiement des services |
| **Sécurité** | JWT + RBAC + pgcrypto | Authentification et chiffrement |

---

## Structure du Projet

```
Groupe_DevForce_Examen/
│
├── 1_Specifications/              # Cahier des charges et user stories
│   ├── Document_Specifications.pdf
│   └── User_Stories.xlsx
│
├── 2_Architecture/                # Documents d'architecture technique
│   ├── Document_Conception_Technique.pdf
│   ├── Justification_Choix_Technologiques.pdf
│   ├── Modele_Donnees_ERD.png
│   └── Schema_Architecture_Technique.png
│
├── 3_Code_Source/                 # Code source de l'application
│   ├── fraud_detection_api/       # API ML de détection de fraude
│   │   ├── fraud_detection_api.py
│   │   ├── train_fraud.py
│   │   ├── requirements.txt
│   │   └── fraud_model.pkl
│   ├── supabase_config/           # Configuration base de données
│   │   ├── Schema DigitalBank CREATION.sql
│   │   └── rls_policies_complete.sql
│   ├── monitoring/                # Configuration Prometheus & Grafana
│   │   └── docker-compose.yml
│   ├── workflows/                 # Blueprints Make.com
│   └── dashboards/                # Configurations Metabase & Grafana
│
├── 4_Documentation/               # Documentation technique
│   ├── README.md
│   └── Documentation_API_Complete.pdf
│
├── 5_Securite/                    # Rapports de sécurité
│   ├── Rapport_Tests_Securite.pdf
│   ├── Resultats_Tests_Securite.pdf
│   └── Documentation_Roles_Permissions.pdf
│
├── 6_Tests/                       # Collections de tests
│   ├── Postman_Collection.json
│   └── Security_Tests/
│
├── 7_Gestion_Projet/              # Gestion de projet
│   └── Gantt_Chart.xlsx
│
└── 8_Presentation/                # Présentation finale
    ├── Slides_Presentation.pdf
    └── Video_Demonstration.mp4
```

---

## Prérequis

- **Docker Desktop** v20.10+
- **Docker Compose** v2.0+
- **Python** 3.10+
- **Git**
- **Compte Supabase** (gratuit)
- **Compte Make.com** (gratuit)

---

## Installation et Configuration

### 1. Cloner le dépôt

```bash
git clone https://github.com/YoussefGuetat/Groupe_DevForce_Examen.git
cd Groupe_DevForce_Examen
```

### 2. Configurer Supabase

1. Créer un projet sur [supabase.com](https://supabase.com)
2. Exécuter le script de création de schéma :
   ```sql
   -- Fichier: 3_Code_Source/supabase_config/Schema DigitalBank CREATION.sql
   ```
3. Appliquer les politiques RLS :
   ```sql
   -- Fichier: 3_Code_Source/supabase_config/rls_policies_complete.sql
   ```
4. Créer 4 utilisateurs avec les rôles : `admin`, `analyst`, `customer_service`, `client`

### 3. Lancer l'API de Détection de Fraude

```bash
cd 3_Code_Source/fraud_detection_api

# Créer l'environnement virtuel
python -m venv venv

# Activer l'environnement
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Installer les dépendances
pip install -r requirements.txt

# Lancer l'API
python fraud_detection_api.py
```

L'API sera accessible sur `http://localhost:5000`

### 4. Lancer les services Docker

```bash
cd 3_Code_Source/monitoring
docker-compose up -d
```

### 5. Ports des Services

| Service | Port | URL |
|---------|------|-----|
| Flask API (Fraude) | 5000 | http://localhost:5000 |
| Metabase | 3000 | http://localhost:3000 |
| Grafana | 3001 | http://localhost:3001 |
| Prometheus | 9090 | http://localhost:9090 |

---

## Utilisation

### Accéder aux Dashboards

**Metabase** (Analyse métier)
- URL : http://localhost:3000
- Configurer la connexion PostgreSQL vers Supabase

**Grafana** (Monitoring)
- URL : http://localhost:3001
- Login par défaut : admin / admin

### Configurer les Workflows Make.com

1. Importer les blueprints JSON depuis `3_Code_Source/workflows/`
2. Configurer la clé API Supabase
3. Configurer les identifiants email/SMTP

---

## API de Détection de Fraude

### Endpoints

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/health` | Vérifier l'état de l'API |
| POST | `/predict` | Prédire une transaction unique |
| POST | `/predict/batch` | Prédire plusieurs transactions |
| GET | `/model/info` | Informations sur le modèle |

### Exemple de Requête

```bash
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 5000,
    "hour_of_day": 23,
    "day_of_week": 6,
    "merchant_category": "Cryptocurrency",
    "location": "Nigeria"
  }'
```

### Exemple de Réponse

```json
{
  "is_fraud": true,
  "fraud_probability": 0.95,
  "risk_score": 95,
  "risk_level": "CRITIQUE",
  "recommendation": "Bloquer immédiatement"
}
```

### Niveaux de Risque

| Score | Niveau | Action |
|-------|--------|--------|
| 75-100% | CRITIQUE | Bloquer immédiatement |
| 50-74% | ÉLEVÉ | Vérification manuelle requise |
| 25-49% | MOYEN | Surveillance recommandée |
| 0-24% | FAIBLE | Transaction normale |

---

## Base de Données

### Schéma Principal

| Table | Description |
|-------|-------------|
| `customers` | Informations clients (10 enregistrements) |
| `accounts` | Comptes bancaires IBAN (13 comptes) |
| `cards` | Cartes de débit/crédit |
| `transactions` | Historique des transactions (30 transactions) |
| `login_attempts` | Audit des connexions |
| `audit_logs` | Journal d'audit RGPD |
| `profiles` | Rôles et permissions utilisateurs |

### Données de Test

- **Clients** : Jean Dupont, Marie Martin, Pierre Bernard, etc.
- **Soldes** : 950€ - 45 000€
- **Transactions** : 20 normales, 10 frauduleuses

---

## Sécurité

### Contrôle d'Accès (RBAC)

| Rôle | Permissions |
|------|-------------|
| `admin` | Accès complet à toutes les ressources |
| `analyst` | Lecture des transactions et rapports |
| `customer_service` | Gestion des clients et comptes |
| `client` | Accès à ses propres données uniquement |

### Mesures de Sécurité

- **Row Level Security (RLS)** : Isolation des données par utilisateur
- **Chiffrement** : pgcrypto pour les données sensibles
- **JWT** : Authentification sécurisée
- **MFA** : Authentification multi-facteurs supportée
- **Audit Logs** : Traçabilité complète (conformité RGPD)

---

## Tests

### Collection Postman

Importer `6_Tests/Postman_Collection.json` dans Postman pour tester :
- Endpoints de l'API de fraude
- Authentification Supabase
- Opérations CRUD

### Tests de Sécurité

Consulter les rapports dans `5_Securite/` :
- Tests d'injection SQL
- Tests XSS
- Tests d'authentification
- Analyse des vulnérabilités

---

## Documentation

| Document | Emplacement |
|----------|-------------|
| Documentation API | `4_Documentation/Documentation_API_Complete.pdf` |
| Conception Technique | `2_Architecture/Document_Conception_Technique.pdf` |
| Spécifications | `1_Specifications/Document_Specifications.pdf` |
| User Stories | `1_Specifications/User_Stories.xlsx` |
| Rôles et Permissions | `5_Securite/Documentation_Roles_Permissions.pdf` |

---

## Équipe

**Groupe DevForce**

| Membre | Email |
|--------|-------|
| Youssef GUETAT | guyoussef@etudiant-esic.fr |
| Hadil MASMOUDI | mahadil@etudiant-esic.fr |
| Ameni FEKI | feameni@etudiant-esic.fr |

---

## Démonstration

- **Vidéo de démonstration** : `8_Presentation/Video_Demonstration.mp4`
- **Slides de présentation** : `8_Presentation/Slides_Presentation.pdf`

---

## Licence

Projet académique - ESIS-2-2025-2026 / CPDIA-2-2025-2026

---

<p align="center">
  <strong>DigitalBank</strong> - Sécurité et Innovation Bancaire
</p>
