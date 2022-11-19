> helm repo add istio https://istio-release.storage.googleapis.com/charts
> helm repo update

> kubectl create namespace istio-system
> helm install istio-base istio/base -n istio-system
> helm install istiod istio/istiod -n istio-system --wait

> kubectl create namespace istio-ingress
> kubectl label namespace istio-ingress istio-injection=enabled
> helm install istio-ingress istio/gateway -n istio-ingress --wait

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.12/samples/addons/kiali.yaml

kubectl create namespace demo
kubectl label namespace demo istio-injection=enabled


kubectl apply -f deployments/kubernetes-manifests.yaml -n istio-ingress
