# Karmada

## Intro 
xxxxx

command :

sudo curl -s https://raw.githubusercontent.com/karmada-io/karmada/master/hack/install-cli.sh | sudo bash -s kubectl-karmada

(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
kubectl krew install karmada
kubectl karmada init

생성안 될 시 계속 Restart 

kubectl karmada --kubeconfig /etc/karmada/karmada-apiserver.config  join staging --cluster-kubeconfig=$HOME/.kube/config
kubectl karmada --kubeconfig /etc/karmada/karmada-apiserver.config  join prod --cluster-kubeconfig=$HOME/.kube/config

aws eks update-kubeconfig --name prod-cluster --kubeconfig ./prod.config
aws eks update-kubeconfig --name staging-cluster --kubeconfig ./staging.config

cd ~/.kube/
rm -rf config 
ls -n config /etc/karmada/karmada-apiserver.config

apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: staging-rp
spec:
  resourceSelectors:
    - apiVersion: apps/v1
      kind: Deployment
      labelSelector:
        matchLabels:
          stage: staging
    - apiVersion: v1
      kind: Service
      labelSelector:
        matchLabels:
          stage: staging
    - apiVersion: v1
      kind: Pod
      labelSelector:
        matchLabels:
          stage: staging
  placement:
    clusterAffinity:
      clusterNames:
        - staging
---
apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: prod-rp
spec:
  resourceSelectors:
    - apiVersion: apps/v1
      kind: Deployment
      labelSelector:
        matchLabels:
          stage: prod
    - apiVersion: v1
      kind: Service
      labelSelector:
        matchLabels:
          stage: prod
    - apiVersion: v1
      kind: Pod
      labelSelector:
        matchLabels:
          stage: prod
  placement:
    clusterAffinity:
      clusterNames:
        - prod

helm upgrade -i argocd -n argocd argo/argo-cd --set crds.keep=false

VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
ARCH="amd64"
sudo curl --silent --location -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-$ARCH
sudo chmod +x /usr/local/bin/argocd

kp -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

argocd login service address --username admin --password $? --insecure

# 
#
# please ref.
# https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/application.yaml
# 
# 
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: demo-app
  # You'll usually want to add your resources to the argocd namespace.
  namespace: argocd
  # Add a this finalizer ONLY if you want these to cascade delete.
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  # The project the application belongs to.
  project: default

  # Source of the application manifests
  source:
    repoURL: https://github.com/dispiny/demo-argo.git
    targetRevision: HEAD
    path: manifest

  destination:
    server: https://10.0.142.44:32443
    namespace: default

  syncPolicy:
    automated: # automated sync by default retries failed attempts 5 times with following delays between attempts ( 5s, 10s, 20s, 40s, 80s ); retry controlled using `retry` field.
      prune: true # Specifies if resources should be pruned during auto-syncing ( false by default ).
      selfHeal: true # Specifies if partial app sync should be executed when resources are changed only in target Kubernetes cluster and no git change detected ( false by default ).
      allowEmpty: false # Allows deleting all application resources during automatic syncing ( false by default ).
    syncOptions:     # Sync options which modifies sync behavior
    - Validate=false # disables resource validation (equivalent to 'kubectl apply --validate=false') ( true by default ).
    - CreateNamespace=true # Namespace Auto-Creation ensures that namespace specified as the application destination exists in the destination cluster.
    - PrunePropagationPolicy=foreground # Supported policies are background, foreground and orphan.
    - PruneLast=true # Allow the ability for resource pruning to happen as a final, implicit wave of a sync operation
    retry:
      limit: 5 # number of failed sync attempt retries; unlimited number of attempts if less than 0
      backoff:
        duration: 5s # the amount to back off. Default unit is seconds, but could also be a duration (e.g. "2m", "1h")
        factor: 2 # a factor to multiply the base duration after each failed retry
        maxDuration: 3m # the maximum amount of time allowed for the backoff strategy