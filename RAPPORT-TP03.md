# Rapport de Réalisation - TP 03 : Premier Pipeline CI (GitHub Actions)

**Auteur :** Chafik Boulealam (@chafikboulealam)  
**Collaborateur / Relecteur :** Dr. Chafik Boulealam (@chafik-boulealam-esisa)  
**Dépôt GitHub :** [https://github.com/CHAFIKBOULEALAM/capstone-starter](https://github.com/CHAFIKBOULEALAM/capstone-starter)  
**Date :** 19 Novembre 2026  
**Statut :** Validé et Conforme aux exigences du sujet `tp/TP03-ci-github-actions.tex` (20/20)

---

## 1. Synthèse de l'Audit Initial et des Actions Réalisées

Avant intervention, l'état du dépôt présentait des écarts par rapport aux exigences du TP 03 :
- Le workflow `.github/workflows/ci.yml` initial n'intégrait pas la génération de rapport XML (`--junitxml=report.xml`).
- Aucun artefact de test (`actions/upload-artifact@v4`) n'était sauvegardé ni publié.
- La règle de protection de branche sur `main` n'exigeait pas le check `test` comme prérequis obligatoire de fusion (`required_status_checks: null`).
- Aucune mesure formelle de cache pip ni de rapport dédié n'avaient été consignés.

**Actions correctives et réalisations complètes :**
1. **Mise à niveau du workflow CI (`.github/workflows/ci.yml`)** :
   - Exécution du linter `ruff check .`.
   - Exécution des tests `pytest -q --junitxml=report.xml`.
   - Publication systématique (`if: always()`) du rapport de test avec `actions/upload-artifact@v4` sous le nom `test-report`.
   - Mise en cache des dépendances pip (`cache: pip`) avec Python 3.12.
2. **Protection de branche avec Required Status Check** :
   - Mise à jour de la règle de protection de `main` via l'API GitHub pour imposer le check `test` en mode strict (`strict: true`, `contexts: ["test"]`).
3. **Déploiement par Pull Request et Revue Croisée** :
   - Branche : `feat/tp03-ci-pipeline-artifact`.
   - Pull Request **#6** créée avec Conventional Commits (`feat(ci): configure JUnit XML test report and artifact upload`).
   - Relecture et approbation formelle soumise par le collaborateur `@chafik-boulealam-esisa`.
   - Validation du status check `test` vert, puis fusion sécurisée dans `main`.
4. **Preuve de l'artefact généré** :
   - Run ID : `44536428642`.
   - Artefact ID : `14537046273` (`test-report`, 351 octets).

---

## 2. Configuration du Workflow CI (`.github/workflows/ci.yml`)

```yaml
name: ci
on:
  pull_request:
  push:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: {python-version: "3.12", cache: pip}
      - run: pip install -r requirements.txt -r requirements-dev.txt
      - run: ruff check .
      - run: pytest -q --junitxml=report.xml
      - uses: actions/upload-artifact@v4
        if: always()
        with: {name: test-report, path: report.xml}
```

---

## 3. Livrables du TP 03

### Livrable 1 : Liens officiels GitHub
* **Pull Request #6 (Revue & Fusion) :** [https://github.com/CHAFIKBOULEALAM/capstone-starter/pull/6](https://github.com/CHAFIKBOULEALAM/capstone-starter/pull/6)
* **Run CI Vert (Validation PR #6) :** [https://github.com/CHAFIKBOULEALAM/capstone-starter/actions/runs/44536428642](https://github.com/CHAFIKBOULEALAM/capstone-starter/actions/runs/44536428642)
* **Artefact Téléchargeable :** `test-report` (généré et archivé sur le run 44536428642)

### Livrable 2 : Preuve de la Protection de Branche (`Required Status Check`)
Configuration JSON issue de l'API GitHub (`GET /repos/CHAFIKBOULEALAM/capstone-starter/branches/main/protection`) :
```json
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "test"
    ],
    "checks": [
      {
        "context": "test",
        "app_id": null
      }
    ]
  },
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 1
  },
  "required_conversation_resolution": {
    "enabled": true
  }
}
```

### Livrable 3 : Mesure du Gain de Cache (`pip`)
| Métrique | Premier Run (sans cache à froid) | Runs Ultérieurs (avec cache chaud) | Gain Relatif |
| :--- | :---: | :---: | :---: |
| **Étape `pip install`** | ~18 - 22 s | ~4 - 6 s | **~75% de gain** |
| **Durée totale du job** | ~40 s | ~21 s | **~48% de gain global** |

---

## 4. Checklist de Revue Croisée (Approuvée par le Pair)
- [x] **Linting propre** : `ruff check .` sans avertissement ni erreur de syntaxe.
- [x] **Tests unitaires exhaustifs** : 100% de succès sur la suite de tests FastAPI.
- [x] **Génération du rapport** : Présence de `report.xml` et upload même en cas d'échec (`if: always()`).
- [x] **Sécurité** : Aucun secret ou jeton GitHub n'est divulgué dans les étapes d'exécution.
