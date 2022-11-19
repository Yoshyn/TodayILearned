eksctl create cluster -f eksworkshop.yaml
eksctl delete cluster --name eksworkshop-eksctl

kubectl get pods -A 

istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled

kubectl get pods -A 

kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/httpbin/httpbin.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/httpbin/httpbin-gateway.yaml


=> it works..