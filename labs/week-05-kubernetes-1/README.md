# TP 5 : Premier Deploiement sur kind

**Objectif** : Creer un cluster kind, charger l'image du fil rouge et deployer Deployment et Service, puis diagnostiquer un Pod en echec.

**Duree** : 90 min (10/50/20/10 min)

**Etape du fil rouge** : S5 : deployer le conteneur sur kind (Deployment + Service).

## Prerequis
- TP 4 termine (image capstone-api:0.1)
- kind et kubectl installes (ou Codespaces)

## Etapes
1. **Cluster** : Creer le cluster et verifier.

```bash
kind create cluster --name devops
kubectl cluster-info --context kind-devops
kubectl get nodes
```

2. **Image** : Construire l'image et la charger dans kind.

```bash
docker build -t capstone-api:0.1 .
kind load docker-image capstone-api:0.1 --name devops
```

3. **Manifestes** : Creer k8s/deployment.yaml et k8s/service.yaml (voir cours), puis appliquer.

```bash
kubectl apply -f k8s/
kubectl rollout status deploy/capstone-api
kubectl port-forward svc/capstone-api 8080:80 &
curl -s localhost:8080/health
```

4. **Erreur volontaire** : Changer l'image en capstone-api:9.9, diagnostiquer ImagePullBackOff, corriger.

```bash
kubectl set image deploy/capstone-api api=capstone-api:9.9
kubectl get pods
kubectl describe pod <pod>
kubectl rollout undo deploy/capstone-api
```

5. **Nettoyage** : Supprimer les ressources ; garder le cluster pour S6.

```bash
kubectl delete -f k8s/
```


## Resultat minimal viable
2 Pods Running ; `curl` via port-forward renvoie status ok.

## Plan B
Utiliser les manifestes de `starter/k8s/` et passer directement au diagnostic.

## Livrables
- Manifestes dans k8s/
- Capture de kubectl get pods
- Compte rendu du diagnostic (5 lignes)

## Pieges
- Tag latest : Kubernetes tente de telecharger l'image
- Selector et labels doivent correspondre
- Image locale non chargee dans kind : ImagePullBackOff

> L'IA propose, l'humain valide -- toujours executer lint, tests et plan.

---

## Compte rendu (realisation)

**Environnement** : cluster Kubernetes de Docker Desktop (contexte `docker-desktop`, 1 noeud `desktop-control-plane`). Avec ce cluster, l'image construite localement est directement visible : pas de `kind load` necessaire.

```bash
docker build -t capstone-api:0.1 .
kubectl apply -f k8s/deployment.yaml -f k8s/service.yaml
kubectl rollout status deploy/capstone-api
kubectl get pods
```

```text
NAME                            READY   STATUS    RESTARTS   AGE
capstone-api-595d65588d-dpljv   1/1     Running   0          61s
capstone-api-595d65588d-knjhp   1/1     Running   0          61s
```

Manifestes (dans `capstone-starter/k8s/`) : `deployment.yaml` (2 replicas, labels/selector `app: capstone-api`, `containerPort: 8000`) et `service.yaml` (`ClusterIP`, port 80 -> targetPort 8000).

**Verification** : `kubectl port-forward svc/capstone-api 8080:80` puis `curl localhost:8080/health` renvoie `{"status":"ok"}`.

**Diagnostic (5 lignes)** : `kubectl set image deploy/capstone-api api=capstone-api:9.9` cree un Pod en `ErrImagePull` / `ImagePullBackOff` car le tag `9.9` n'existe dans aucun registre ni dans le cache local. `kubectl describe pod` (section Events) l'indique. Les anciens Pods restent `Running` : la mise a jour progressive n'a pas coupe le service. `kubectl rollout undo deploy/capstone-api` restaure la revision saine. Le piege : tag inexistant ou image locale non chargee dans le cluster.

> Note : `k8s/rbac-agent.yaml` cible le namespace `capstone` (cree par Terraform au TP 7) ; l'appliquer fichier par fichier tant que ce namespace n'existe pas.
