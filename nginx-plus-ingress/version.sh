POD_NAMESPACE=nginx-ingress
POD_NAME=$(kubectl get pods -n $POD_NAMESPACE -o jsonpath='{.items[0].metadata.name}')

kubectl exec -it $POD_NAME -n $POD_NAMESPACE -- /nginx-ingress --version
