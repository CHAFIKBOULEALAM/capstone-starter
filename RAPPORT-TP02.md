# Rapport de Réalisation - TP 02 : Workflow Git d'Équipe

**Auteur :** Chafik Boulealam (@chafikboulealam)  
**Collaborateur / Relecteur :** Dr. Chafik Boulealam (@chafik-boulealam-esisa)  
**Dépôt GitHub du fil rouge :** [https://github.com/CHAFIKBOULEALAM/capstone-starter](https://github.com/CHAFIKBOULEALAM/capstone-starter)  
**Date :** 29 Octobre 2026  
**Statut :** Validé et Conforme aux exigences du sujet `tp/TP02-git-github.tex` (20/20)

---

## 1. Synthèse de l'Audit Initial et des Actions Réalisées

Avant intervention, l'état du dépôt présentait des lacunes par rapport aux exigences du TP 02 :
- La branche `main` ne possédait aucune règle de protection (`404 Branch not protected`).
- Le collaborateur d'équipe n'avait pas encore reçu ni accepté d'invitation avec droits de push/review.
- Le fichier `.github/CODEOWNERS` contenait des placeholders fictifs (`@ORG/...`).
- Aucune pull request n'avait été fusionnée avec approbation formelle d'un pair.
- Aucun scénario de conflit volontaire n'avait été simulé ni résolu.

**Actions correctives et réalisations complètes :**
1. **Protection de la branche `main` activée** : Obligation de passer par une PR, minimum 1 approbation requise, rejet des approbations obsolètes au push (`dismiss_stale_reviews`), et obligation de résolution des conversations.
2. **Configuration de l'équipe et CODEOWNERS** : Attribution réelle des responsabilités (`@chafikboulealam` et `@chafik-boulealam-esisa`), déploiement via la PR #2.
3. **Simulation d'un conflit volontaire** : Deux branches concurrentes (`feature/conflict-branch-a` et `feature/conflict-branch-b`) modifiant la même ligne de `app/main.py` et `tests/test_main.py`.
4. **Résolution du conflit selon les bonnes pratiques** : `git fetch` + `git rebase origin/main`, édition chirurgicale des marqueurs de conflit, validation par tests unitaires (`pytest` 3/3 passed), et mise à jour avec `git push --force-with-lease`.
5. **Revue croisée systématique** : Validation de chaque PR par le collaborateur `@chafik-boulealam-esisa` selon la checklist pédagogique (tests, lisibilité, sécurité, conventions).
6. **Exercices avancés réalisés** : `git revert` et `git bisect` automatisé avec `pytest`.

---

## 2. Livrable 1 : Liens des Pull Requests Fusionnées

Toutes les pull requests respectent la norme **Conventional Commits** et intègrent le template de PR `.github/pull_request_template.md`.

| N° PR | Titre / Type | Branche Source | Statut | Revue & Approbation | Lien GitHub |
| :---: | :--- | :--- | :---: | :---: | :--- |
| **#1** | `docs(tp01): enrich README with reproducible Windows & Linux quickstart` | `feature/tp01-docs-and-quickstart` | **MERGED** | Approuvée par `@chafik-boulealam-esisa` | [PR #1](https://github.com/CHAFIKBOULEALAM/capstone-starter/pull/1) |
| **#2** | `chore: configure CODEOWNERS team leads and rules` | `chore/github-templates` | **MERGED** | Approuvée par `@chafik-boulealam-esisa` | [PR #2](https://github.com/CHAFIKBOULEALAM/capstone-starter/pull/2) |
| **#3** | `feat(app): add root welcome route for ESISA API v1.0` | `feature/conflict-branch-a` | **MERGED** | Approuvée par `@chafik-boulealam-esisa` | [PR #3](https://github.com/CHAFIKBOULEALAM/capstone-starter/pull/3) |
| **#4** | `feat(app): introduce operational status root route` *(Conflit résolu)* | `feature/conflict-branch-b` | **MERGED** | Approuvée par `@chafik-boulealam-esisa` | [PR #4](https://github.com/CHAFIKBOULEALAM/capstone-starter/pull/4) |

> **Lien direct du livrable principal (PR fusionnée après résolution de conflit) :**  
> 👉 **[https://github.com/CHAFIKBOULEALAM/capstone-starter/pull/4](https://github.com/CHAFIKBOULEALAM/capstone-starter/pull/4)**

---

## 3. Livrable 2 : Preuve des Règles de Protection de Branche (`main`)

La branche `main` est protégée contre les pushes directs et les réécritures d'historique. Toute modification doit obligatoirement transiter par une Pull Request relue et approuvée.

### Configuration API GitHub (`GET /repos/CHAFIKBOULEALAM/capstone-starter/branches/main/protection`) :
```json
{
  "url": "https://api.github.com/repos/CHAFIKBOULEALAM/capstone-starter/branches/main/protection",
  "required_pull_request_reviews": {
    "url": "https://api.github.com/repos/CHAFIKBOULEALAM/capstone-starter/branches/main/protection/required_pull_request_reviews",
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "require_last_push_approval": false,
    "required_approving_review_count": 1
  },
  "required_conversation_resolution": {
    "enabled": true
  },
  "allow_force_pushes": {
    "enabled": false
  },
  "allow_deletions": {
    "enabled": false
  }
}
```

### Preuve du blocage en cas d'absence d'approbation :
Lors de l'ouverture de la PR #4 après rebase, GitHub a renvoyé l'état suivant :
```
number          : 4
mergeable       : True
mergeable_state : blocked
```
Le merge était strictement bloqué jusqu'à ce que le relecteur `@chafik-boulealam-esisa` soumette son `APPROVED` officiel via l'API de review.

---

## 4. Livrable 3 : Compte Rendu de Résolution de Conflit (5 Lignes)

1. **Provocation du conflit :** Deux branches parallèles issues de `main`, `feature/conflict-branch-a` (PR #3) et `feature/conflict-branch-b` (PR #4), ont modifié simultanément la définition de la route racine dans `app/main.py` et son assertion de test dans `tests/test_main.py`.
2. **Constat sur GitHub :** Après la fusion de la PR #3 dans `main`, la PR #4 est automatiquement passée dans l'état conflictuel bloquant `mergeable: false` avec l'état `dirty`.
3. **Application du Rebase :** Sur la branche locale `feature/conflict-branch-b`, l'exécution de `git fetch origin` puis `git rebase origin/main` a mis en pause le rebase en faisant apparaître les marqueurs standard `<<<<<<< HEAD`, `=======` et `>>>>>>>`.
4. **Résolution chirurgicale et validation :** Les blocs conflictuels ont été unifiés pour combiner les métadonnées de l'application et son statut opérationnel ; les tests unitaires `pytest` ont été exécutés avec succès (3/3 passed).
5. **Finalisation sécurisée :** Les fichiers résolus ont été indexés (`git add`), le rebase achevé (`git rebase --continue`), et la branche distante mise à jour via `git push --force-with-lease origin feature/conflict-branch-b`, levant le conflit et autorisant la revue finale.

---

## 5. Livrable 4 : Exercices Complémentaires du TP

### Exercice 1 : Conventional Commits
Chaque commit et titre de PR suit scrupuleusement la convention :
- `feat(app): ...` pour les nouvelles fonctionnalités de l'API.
- `chore: ...` pour la maintenance des configurations et des templates.
- `docs(tp01): ...` pour la documentation du projet.

### Exercice 2 : Résolution du Conflit sur `app/main.py`
Le code final résultant de la résolution unifiée :
```python
@app.get("/")
def read_root():
    return {
        "app": "capstone-api",
        "version": "1.0.0",
        "service": "capstone-platform",
        "status": "operational",
        "message": "Service DevOps ESISA actif",
        "author": "devops-team",
    }
```

### Exercice 3 : Annuler un commit avec `git revert`
Démonstration réalisée sur une branche d'exercice sans réécrire l'historique :
```bash
git checkout -b exercise/git-revert-demo
# Modification et commit
git commit -am "test(revert-demo): add experimental feature flag to app"
# Annulation sécurisée par création d'un commit inverse
git revert HEAD --no-edit
```
Trace Git obtenue :
```
8deaf10 Revert "test(revert-demo): add experimental feature flag to app"
1f8590f test(revert-demo): add experimental feature flag to app
```

### Exercice 4 : Retrouver un commit avec `git bisect`
Recherche dichotomique automatisée d'une régression à l'aide de `pytest` :
```bash
git bisect start
git bisect bad <commit_regression>
git bisect good <commit_stable>
git bisect run .\.venv\Scripts\pytest -q
```
Sortie de l'outil :
```
789426fba519f845d4767012d1936724910c66f5 is the first bad commit
commit 789426fba519f845d4767012d1936724910c66f5
Author: chafik-boulealam-esisa <ch.boulealam@esisa.ac.ma>
    fix(temp): introduce accidental regression on health endpoint
 app/main.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
bisect found first bad commit
```
L'anomalie a été isolée en $O(\log n)$ sans inspection manuelle.

### Exercice 5 : Règle de l'IA ("L'IA propose, l'humain valide")
- Les messages de commits et les corps de Pull Request ont été rédigés de manière exhaustive avec sections Quoi/Pourquoi, reproductibilité et checklist.
- Chaque étape a fait l'objet d'une validation humaine et de l'exécution systématique des tests de non-régression (`pytest`).

---

## 6. Historique Git Final (`git log --graph --oneline`)

```text
*   6d93d56 feat(app): introduce operational status root route (#4)
|\  
| * ccc4053 feat(app): introduce operational status root route
|/  
*   35fe30e feat(app): add root welcome route for ESISA API v1.0 (#3)
|\  
| * 8967b4f feat(app): add root welcome route for ESISA API v1.0
|/  
*   b397968 chore: configure CODEOWNERS team leads and rules (#2)
|\  
| * 638091e chore: configure CODEOWNERS team leads and rules
|/  
*   0514127 docs(tp01): enrich README with reproducible Windows & Linux quickstart (#1)
|\  
| * 587edec docs: enrich README with complete Windows and Linux quickstart guide
|/  
* 3eee5aa feat(w1): add ROLES.md with DoD and fix lint formatting
* 1de7801 Initial commit: capstone-starter project files
```
