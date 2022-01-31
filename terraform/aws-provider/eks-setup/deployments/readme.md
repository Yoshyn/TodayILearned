
# Install nginx controller :
# Documentation here : 
https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/

kubectl apply -f nginx/common/ns-and-sa.yaml
kubectl apply -f nginx/rbac/rbac.yaml

# Setcret for tls. (TO UPDATE!)
kubectl apply -f nginx/common/default-server-secret.yaml 

# Change some config 
# Full list here :
# https://docs.nginx.com/nginx-ingress-controller/configuration/global-configuration/configmap-resource/
kubectl apply -f nginx/common/nginx-config.yaml

kubectl apply -f nginx/common/ingress-class.yaml

kubectl apply -f nginx/common/crds/k8s.nginx.org_virtualservers.yaml
kubectl apply -f nginx/common/crds/k8s.nginx.org_virtualserverroutes.yaml
kubectl apply -f nginx/common/crds/k8s.nginx.org_transportservers.yaml
kubectl apply -f nginx/common/crds/k8s.nginx.org_policies.yaml
kubectl apply -f nginx/common/crds/k8s.nginx.org_globalconfigurations.yaml

# Daemon-set to ensure one per node
kubectl apply -f nginx/daemon-set/nginx-ingress.yaml

# Apply the application
kubectl apply -f application.yaml
