# TP 6 : Configuration, Sondes et HPA

**Objectif** : Externaliser la configuration, ajouter sondes et limites, observer un rollback, puis packager avec Helm.

**Duree** : 90 min (10/50/20/10 min)

**Etape du fil rouge** : S6 : ConfigMap/Secret, sondes, limites, HPA ; chart Helm (demo).

## Prerequis
- TP 5 termine (cluster kind, deployment)

## Etapes
1. **Configuration** : Creer k8s/config.yaml (ConfigMap + Secret) et injecter avec envFrom.

```bash
kubectl apply -f k8s/config.yaml
kubectl set env deploy/capstone-api --list
```

2. **Sondes et limites** : Ajouter livenessProbe, readinessProbe, requests et limits dans le Deployment, appliquer.

```bash
kubectl apply -f k8s/deployment.yaml
kubectl describe pod -l app=capstone-api | grep -A3 -i probe
```

3. **metrics-server** : Installer metrics-server sur kind (doc officielle) ; sur kind il faut souvent ajouter --kubelet-insecure-tls (TP uniquement).

```bash
kubectl top pods
```

4. **HPA et charge** : Appliquer le HPA puis generer de la charge.

```bash
kubectl apply -f k8s/hpa.yaml
kubectl get hpa -w
kubectl run load --rm -it --image=busybox -- sh -c \
  "while true; do wget -q -O- http://capstone-api/health; done"
```

5. **Helm (demo)** : Creer un chart, personnaliser values.yaml (image, replicas), installer en dry-run puis reellement.

```bash
helm create capstone-chart
helm lint capstone-chart
helm install api ./capstone-chart --dry-run
```


## Resultat minimal viable
Deployment avec sondes et limites, HPA cree, rollback reussi.

## Plan B
Sauter Helm (LIGHT) : utiliser le chart de `starter/` et ne modifier que values.yaml.

## Livrables
- Manifestes (config, deployment, hpa)
- Capture kubectl get hpa
- Chart Helm lint OK

## Pieges
- Sonde trop stricte : redemarrages en boucle
- Sans requests CPU, le HPA ne calcule pas l'utilisation
- Ne pas committer de vrais secrets dans config.yaml

> L'IA propose, l'humain valide -- toujours executer lint, tests et plan.

---

## Compte rendu (realisation)

Manifestes dans `capstone-starter/k8s/` :
- `config.yaml` : ConfigMap `api-config` (`LOG_LEVEL: "info"`) et Secret `api-secret` (`API_KEY`, valeur factice de TP), injectes via `envFrom`.
- `deployment.yaml` : `livenessProbe` (`/health`:8000), `readinessProbe` (`/ready`:8000), `requests` (100m CPU / 128Mi) et `limits` (500m CPU / 256Mi).
- `hpa.yaml` : `minReplicas: 2`, `maxReplicas: 5`, CPU cible 70 %.

```bash
kubectl apply -f k8s/config.yaml -f k8s/deployment.yaml -f k8s/service.yaml -f k8s/hpa.yaml
# metrics-server (TP uniquement : --kubelet-insecure-tls)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl -n kube-system patch deploy metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl top pods
kubectl get hpa
```

```text
NAME           REFERENCE                 TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
capstone-api   Deployment/capstone-api   cpu: 4%/70%   2         5         2          87s
```

Verification : les 2 Pods sont `1/1 Running` (sondes OK) ; dans un Pod, `LOG_LEVEL=info` et `API_KEY` sont definies (injection `envFrom` confirmee).

**Helm** : chart `capstone-starter/capstone-chart/` (`Chart.yaml`, `values.yaml`, `templates/deployment.yaml`, `templates/service.yaml`) pour `capstone-api:0.1`, port 8000, sondes `/health` et `/ready`, requests/limits. Helm v4.3.2 installe manuellement (`get.helm.sh`).

```bash
helm lint capstone-chart
# ==> Linting capstone-chart
# [INFO] Chart.yaml: icon is recommended
# 1 chart(s) linted, 0 chart(s) failed
helm template capstone-api ./capstone-chart      # Service + Deployment rendus (replicas 2, image capstone-api:0.1)
helm install capstone-helm ./capstone-chart --dry-run
# NAME: capstone-helm / STATUS: pending-install / REVISION: 1 / DESCRIPTION: Dry run complete
```

**Test de charge HPA** : deux Pods busybox bouclent sur `http://capstone-api/health`.
```text
capstone-api   Deployment/capstone-api   cpu: 3%/70%     2   5   2   (avant)
capstone-api   Deployment/capstone-api   cpu: 296%/70%   2   5   2
capstone-api   Deployment/capstone-api   cpu: 331%/70%   2   5   5   (mise a l'echelle jusqu'a maxReplicas)
```
Les Pods de charge ont ensuite ete supprimes (`kubectl delete pod load load2`).

> Pas de vrai secret dans `config.yaml` : en production, utiliser un gestionnaire de secrets.
