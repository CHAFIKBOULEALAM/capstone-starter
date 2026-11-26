# TP 7 : Terraform sur le Cluster Local

**Objectif** : Provisionner un namespace et un ConfigMap avec Terraform (provider kubernetes), lire le plan, puis detruire proprement.

**Duree** : 90 min (10/45/25/10 min)

**Etape du fil rouge** : S7 : Terraform pour une ressource locale ; Ansible en courte demonstration.

## Prerequis
- Cluster kind actif (TP 5)
- Terraform ou OpenTofu installe

## Etapes
1. **Projet** : Creer le dossier infra/ avec main.tf, variables.tf et outputs.tf.
2. **Provider et ressources** : Copier le provider et le namespace du cours ; ajouter un kubernetes_config_map.

```hcl
resource "kubernetes_config_map" "app" {
  metadata {
    name      = "api-config"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  data = {
    LOG_LEVEL = "info"
  }
}
```

3. **Valider** : Verifier le format, la validite et le plan.

```bash
cd infra
terraform init
terraform fmt -check && terraform validate
terraform plan -out=tfplan
```

4. **Appliquer** : Appliquer le plan et verifier dans le cluster.

```bash
terraform apply tfplan
kubectl get ns capstone
kubectl -n capstone get configmap
```

5. **Detruire** : Toujours detruire a la fin du TP.

```bash
terraform destroy
```


## Resultat minimal viable
`terraform apply` cree le namespace ; `destroy` le supprime.

## Plan B
Utiliser `starter/infra/` et ne faire que plan, apply et destroy.

## Livrables
- Dossier infra/ dans le depot
- Sortie de terraform plan
- Compte rendu du test de drift

## Pieges
- Ne jamais committer terraform.tfstate ni terraform.tfvars avec des secrets
- Etat verrouille : attendre ; `terraform force-unlock` en dernier recours
- Un plan non lu peut detruire des ressources

> L'IA propose, l'humain valide -- toujours executer lint, tests et plan.

---

## Compte rendu (realisation)

### Installation de Terraform (Windows)
`winget` n'etant pas disponible, installation manuelle du binaire (v1.17.2) depuis `releases.hashicorp.com`, ajoute au `PATH` utilisateur. Verification : `terraform -version`.

### Structure `capstone-starter/infra/`
```text
infra/
  main.tf        # provider kubernetes ~> 2.30, module namespace, ConfigMap api-config
  variables.tf   # namespace, kube_context, log_level
  outputs.tf     # namespace, configmap_name
  modules/namespace/{main,variables,outputs}.tf   # module reutilisable
```
`kube_context` vaut `docker-desktop` par defaut (utiliser `-var kube_context=kind-devops` avec kind). `.gitignore` exclut `.env`, `.terraform/`, `*.tfstate*`, `tfplan`, `*.tfvars`.

### Validation et plan
```bash
cd infra
terraform init
terraform fmt -check -recursive && terraform validate   # Success! The configuration is valid.
terraform plan -out=tfplan
```
Resume du plan : **Plan: 2 to add, 0 to change, 0 to destroy.**
- `module.namespace.kubernetes_namespace.this` : namespace `capstone`
- `kubernetes_config_map.app` : `api-config` dans `capstone`, `LOG_LEVEL = "info"`

### Application, drift, destruction
Etapes executees sur le contexte `docker-desktop`.

```bash
terraform apply tfplan
```
```text
module.namespace.kubernetes_namespace.this: Creation complete after 0s [id=capstone]
kubernetes_config_map.app: Creation complete after 0s [id=capstone/api-config]
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
Outputs:
configmap_name = "api-config"
namespace = "capstone"
```

Verification : `kubectl get ns capstone` -> `capstone   Active`; `kubectl -n capstone get configmap api-config -o yaml` -> `data: LOG_LEVEL: info`.

#### Test de drift
Modification manuelle (hors Terraform) :
```bash
kubectl patch configmap api-config -n capstone -p '{"data":{"LOG_LEVEL":"debug"}}'
terraform plan
```
```text
  # kubernetes_config_map.app will be updated in-place
  ~ resource "kubernetes_config_map" "app" {
      ~ data        = {
          ~ "LOG_LEVEL" = "debug" -> "info"
        }
        id          = "capstone/api-config"
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```
Reconciliation :
```bash
terraform apply -auto-approve
# Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
kubectl -n capstone get configmap api-config -o jsonpath='{.data.LOG_LEVEL}'   # info
terraform plan                                                                  # No changes.
```

**Compte rendu du drift** : lors du `plan`, Terraform rafraichit l'etat depuis le cluster reel, voit `debug` alors que le code declare `info`, et propose une mise a jour en place (`~`). `apply` ramene la ressource a l'etat desire ; le `plan` suivant ne montre plus aucun changement. Le code est la source de verite : toute modification manuelle est detectee puis ecrasee.

### Destruction
```bash
terraform destroy -auto-approve
kubectl get ns capstone   # Error from server (NotFound)
```
