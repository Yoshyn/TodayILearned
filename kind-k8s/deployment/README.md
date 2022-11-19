Just a sample setup for postgres.

kubectl apply -f postgres-configmap.yml
kubectl apply -f postgres-storage.yml
kubectl apply -f postgres-deployment.yml
kubectl apply -f postgres-service.yml