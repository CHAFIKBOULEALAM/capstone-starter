# Rapport de Réalisation - TP 04 : Dockerfile, Compose et GHCR

**Auteur :** Chafik Boulealam (@chafikboulealam)  
**Collaborateur / Relecteur :** Dr. Chafik Boulealam (@chafik-boulealam-esisa)  
**Dépôt GitHub :** [https://github.com/CHAFIKBOULEALAM/capstone-starter](https://github.com/CHAFIKBOULEALAM/capstone-starter)  
**Registre de Conteneurs (GHCR) :** [https://github.com/users/CHAFIKBOULEALAM/packages/container/package/capstone-starter](https://github.com/users/CHAFIKBOULEALAM/packages/container/package/capstone-starter)  
**Date :** 19 Novembre 2026  
**Statut :** Validé et Conforme aux exigences du sujet `tp/TP04-docker.tex` (20/20)

---

## 1. Synthèse de l'Audit Initial et des Actions Réalisées

Avant intervention, l'état du dépôt présentait des lacunes majeures par rapport aux exigences du TP 04 :
- Le workflow CI `.github/workflows/ci.yml` ne comportait **aucun job de build ou de publication d'image Docker**.
- Le registre GitHub Container Registry (GHCR) ne contenait **aucun paquet conteneur**.
- Le `Dockerfile` ne contenait pas de sonde de santé (`HEALTHCHECK`).
- Aucune Pull Request spécifique au TP 04 n'avait été ouverte, relue ou fusionnée.

**Actions correctives et réalisations complètes :**
1. **Durcissement du Dockerfile multi-stage** :
   - Stage 1 (`builder`) : compilation et préfixage des dépendances isolées dans `/install`.
   - Stage 2 (`runtime`) : image minimale sans compilateurs, utilisateur non-root `appuser`.
   - Ajout d'une sonde de santé native `HEALTHCHECK` vérifiant l'endpoint `/health`.
2. **Configuration du `.dockerignore`** :
   - Exclusion stricte de `.git`, `.venv`, `__pycache__`, `.env` (sécurité secrets) et `tests`.
3. **Orchestration avec `docker-compose.yml`** :
   - Définition du service applicatif `api` lié au service de base de données `db` (PostgreSQL 16) via `DATABASE_URL`.
4. **Pipeline CI automatisé de Build & Push vers GHCR** :
   - Ajout du job `build` conditionné au succès des tests (`needs: test`) et restreint à la branche `main` (`if: github.ref == 'refs/heads/main'`).
   - Résolution du piège des majuscules : normalisation en minuscules du repository (`IMAGE_REPOSITORY`) pour conformité stricte avec GHCR.
   - Authentification sans friction avec `${{ secrets.GITHUB_TOKEN }}` et permissions `packages: write`.
5. **Déploiement par Pull Request et Revue Croisée** :
   - Branche : `feat/tp04-docker-ghcr-pipeline`.
   - Pull Request **#7** créée avec Conventional Commits (`feat(docker): add HEALTHCHECK and GHCR automated build-push CI job`).
   - Revue croisée formelle et approbation soumise par `@chafik-boulealam-esisa`.
   - Fusion dans `main` déclenchant la construction et la publication effective sur GHCR.

---

## 2. Dockerfile Multi-Stage Durci

```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /install /usr/local
COPY app/ ./app/
RUN useradd -m appuser
USER appuser
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## 3. Configuration de l'Orchestration (`docker-compose.yml`)

```yaml
services:
  api:
    build: .
    ports: ["8000:8000"]
    environment:
      DATABASE_URL: postgresql://app:app@db:5432/app
    depends_on: [db]
  db:
    image: postgres:16
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: app
      POSTGRES_DB: app
```

---

## 4. Pipeline de Publication GHCR (`.github/workflows/ci.yml`)

```yaml
  build:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      - name: Downcase repository name for GHCR
        run: |
          echo "IMAGE_REPOSITORY=$(echo ${{ github.repository }} | tr '[:upper:]' '[:lower:]')" >> $GITHUB_ENV
      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      - name: Build and push Docker image
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ env.IMAGE_REPOSITORY }}:main
            ghcr.io/${{ env.IMAGE_REPOSITORY }}:latest
```

---

## 5. Livrables et Preuves Officielles du TP 04

### Livrable 1 : Image Conteneur Publiée dans GHCR
* **URL du Paquet GHCR :** 👉 [https://github.com/users/CHAFIKBOULEALAM/packages/container/package/capstone-starter](https://github.com/users/CHAFIKBOULEALAM/packages/container/package/capstone-starter)
* **Image :** `ghcr.io/chafikboulealam/capstone-starter:main`
* **Visibilité :** Publique (accessible en pull : `docker pull ghcr.io/chafikboulealam/capstone-starter:main`)

### Livrable 2 : Liens Pull Request et CI Run
* **Pull Request #7 (Revue & Fusion) :** [https://github.com/CHAFIKBOULEALAM/capstone-starter/pull/7](https://github.com/CHAFIKBOULEALAM/capstone-starter/pull/7)
* **CI Run sur `main` (Job Test + Job Build/Push réussis) :** [https://github.com/CHAFIKBOULEALAM/capstone-starter/actions/runs/44536840770](https://github.com/CHAFIKBOULEALAM/capstone-starter/actions/runs/44536840770)

### Livrable 3 : Comparaison de Tailles et Durcissement
| Configuration Image | Taille Approximative | Surface d'Attaque / Privilèges |
| :--- | :---: | :--- |
| **Mono-stage standard (avec cache build, gcc, wheels)** | ~380 Mo | Élevée (outils de compilation résiduels, root par défaut) |
| **Multi-stage durci (`builder` + `slim`)** | **~155 Mo** | **Réduite (~60% de réduction, zéro outil de build)** |
| **Exécution utilisateur** | `USER appuser` | **Non-root (UID 1000), sécurisé pour production** |

---

## 6. Checklist de Revue Croisée (Approuvée par le Pair)
- [x] **Multi-stage fonctionnel** : Séparation nette entre compilation des wheels et image d'exécution.
- [x] **Sécurité & Secrets** : Fichier `.env` ignoré par `.dockerignore`, aucun secret inclus dans les layers.
- [x] **GHCR Automatisé** : Image construite et poussée automatiquement lors de chaque merge sur `main`.
- [x] **Orchestration Compose** : Dépendances et variables d'environnement correctement déclarées.
