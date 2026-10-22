# Capstone DevOps & IA — API & Infrastructure Starter

Projet fil rouge du cours **DevOps et IA** (ESISA 2026-2027) : Du Code à la Production (CI/CD, Cloud, MLOps et Agents IA).

---

## 🚀 Démarrage Rapide

### 1. Prérequis
- Python 3.11+ (Python 3.12 ou 3.13 recommandé)
- Git
- Compte GitHub avec accès au dépôt
- (Optionnel pour TP1) Docker / GitHub Codespaces

---

### 2. Installation & Lancement

#### Sous Linux / macOS / GitHub Codespaces :
```bash
# 1. Créer et activer l'environnement virtuel
python -m venv .venv
source .venv/bin/activate

# 2. Installer les dépendances
pip install -r requirements.txt -r requirements-dev.txt

# 3. Démarrer l'API en mode développement
uvicorn app.main:app --reload
```

#### Sous Windows (PowerShell) :
```powershell
# 1. Créer et activer l'environnement virtuel
python -m venv .venv
.\.venv\Scripts\Activate.ps1

# 2. Installer les dépendances
pip install -r requirements.txt -r requirements-dev.txt

# 3. Démarrer l'API
uvicorn app.main:app --reload
```

---

### 3. Vérification des Endpoints

Une fois le serveur démarré sur `http://localhost:8000` :
- **Santé (Health check)** :
  ```bash
  curl -s http://localhost:8000/health
  # Réponse attendue : {"status":"ok"}
  ```
- **Disponibilité (Readiness)** :
  ```bash
  curl -s http://localhost:8000/ready
  # Réponse attendue : {"ready":true}
  ```
- **Métriques Prometheus** :
  `http://localhost:8000/metrics`

---

### 4. Tests et Qualité de Code

Conformément à la [Definition of Done](ROLES.md) :
- **Linter & Formatage :**
  ```bash
  ruff check .
  ```
- **Tests unitaires :**
  ```bash
  pytest -q
  ```

---

### 5. Organisation de l'Équipe & Gouvernance
Consulter le fichier [`ROLES.md`](ROLES.md) pour la répartition des 4 rôles (Dev Lead, Ops/Infra Lead, Security/QA Lead, Scrum Master/AI Lead) et les critères d'acceptation de la Definition of Done.
