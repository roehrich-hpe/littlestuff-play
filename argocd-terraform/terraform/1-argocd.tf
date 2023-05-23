# helm install argocd -n argocd --create-namespace repo/argo-cd --version 3.35.4 -f terraform/values/argocd.yaml

resource "helm_release" "argocd" {
    name = "argocd"

    repository = "https://argoproj.github.io/argo-helm"
    chart = "argo-cd"
    namespace = "argocd"
    create_namespace = true
    version = "3.35.4"

    values = [file("argocd.yaml")]
}


