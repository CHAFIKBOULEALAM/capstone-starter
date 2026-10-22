# Charte d'Équipe, Rôles et Definition of Done (DoD)

Projet Fil Rouge : **Capstone DevOps & IA (ESISA 2026-2027)**  
Dépôt GitHub : `https://github.com/CHAFIKBOULEALAM/capstone-starter`

---

## 1. Attribution des 4 Rôles de l'Équipe

Les rôles sont tournants au fil des sprints pour assurer la polyvalence de l'équipe :

| Rôle | Responsable | Responsabilités principales |
| :--- | :--- | :--- |
| **Dev Lead** | Chafik Boulealam | Développement de l'API FastAPI, implémentation des routes (`/health`, `/ready`, `/predict`), logique applicative et tests unitaires. |
| **Ops / Infra Lead** | Binôme Ops | Conteneurisation (Docker, Docker Compose), déploiement Kubernetes, scripts d'environnement, configuration reproductible. |
| **Security / QA Lead** | Binôme Sécurité / QA | Qualité du code (`ruff check`), tests automatisés (`pytest`), détection de fuites de secrets (`.env`, `.gitignore`), revues de code (PR). |
| **Scrum Master / AI Lead** | Binôme Scrum / IA | Gestion du tableau Kanban sur Notion, priorisation du backlog, respect des cérémonies agiles, intégration et encadrement des outils IA. |

---

## 2. Definition of Done (DoD)

Une User Story / tâche est considérée comme **Terminée (Done)** uniquement si l'ensemble des critères suivants est validé :

1. **Code & Fonctionnalité :**
   - Le code répond strictement aux critères d'acceptation de la User Story.
   - Le code est lisible, commenté si nécessaire et respecte les conventions PEP 8.

2. **Qualité & Linting :**
   - Le linter s'exécute sans aucune erreur : `ruff check .`
   - Le formatage du code est validé : `ruff format --check .`

3. **Tests automatisés :**
   - La suite de tests unitaires et d'intégration passe à 100% au vert : `pytest -q`
   - Toute nouvelle fonctionnalité ou route est couverte par un test unitaire associé.

4. **Sécurité & Gestion des Secrets :**
   - Aucun secret, mot de passe ou jeton API n'est committé.
   - Le fichier `.env` est strictement ignoré par Git via le `.gitignore`.

5. **Revue de Code (Peer Review) :**
   - Le travail fait l'objet d'une Pull Request (PR) documentée.
   - Au moins un relecteur (Peer Reviewer) a validé et approuvé la PR avant le merge sur `main`.

6. **Documentation :**
   - Le `README.md` et les fichiers de configuration sont mis à jour si l'étape introduit de nouvelles commandes ou dépendances.

---

## 3. Métriques et Suivi Agile (DORA & Kanban)

- **Lead Time for Changes :** Mesuré de la prise en charge de la carte (colonne *En cours*) jusqu'au merge de la PR (colonne *Terminé*).
  - *Objectif première carte (W1 - Starter & Environnement)* : Lead time mesuré < 90 minutes.
- **Règle IA dans le DevOps :**  
  > *« L'IA propose, l'humain valide — toujours exécuter lint, tests et plan. »*
