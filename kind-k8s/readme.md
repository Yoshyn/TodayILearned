# Kind installation  : 

Check : https://istio.io/latest/docs/setup/platform-setup/kind/

kind create cluster --name dokimi-cluster --config kind-config.yml
kubectl config get-contexts
kubectl config use-context kind-dokimi-cluster


# Istio installation : 

Check : https://istio.io/latest/docs/setup/getting-started/

istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled


# Deploy the application

kubectl create ns foo
bash -c "kubectl apply -f <(istioctl kube-inject -f istio/samples/httpbin/httpbin.yaml) -n foo"
bash -c "kubectl apply -f <(istioctl kube-inject -f istio/samples/sleep/sleep.yaml) -n foo"
bash -c "kubectl apply -f <(istioctl kube-inject -f istio/samples/httpbin/httpbin-gateway.yaml) -n foo"

# Test using a container on the same network :

set ISTIO_HTTP_NPORT (kubectl get service -n istio-system istio-ingressgateway -o=jsonpath="{.spec.ports[?(@.port == 80)].nodePort}")

Verification : docker run --net kind -e NPORT=$ISTIO_HTTP_NPORT --rm -ti alpine /bin/sh -c 'apk update && apk add curl bash && curl -v dokimi-cluster-control-plane:$NPORT'

# Test using kubectl port forward 

sudo kubectl port-forward -n kube-system kube-controller-manager-dokimi-cluster-control-plane 80:$ISTIO_HTTP_NPORT

Verification : curl http://localhost:80


# Test using localhost on the host (mac laptop) :

## Using haproxy :

set -x ISTIO_HTTP_NPORT (kubectl get service -n istio-system istio-ingressgateway -o=jsonpath="{.spec.ports[?(@.port == 80)].nodePort}")
rm -f haproxy.cfg && envsubst < haproxy.cfg.tlp > haproxy.cfg

docker run --rm --name haproxy-kind --net kind -v (pwd)/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro -p 80:80 haproxy:2.5-alpine

Verification : curl http://localhost:80

## Using Socat
/!\ It would be awesome to add a route from the host to the kind docker network. Sadly it does not work on mac 
https://github.com/docker/for-mac/issues/2716
https://docs.docker.com/desktop/mac/networking/

docker ps --all | grep alpine/socat | awk '{print $1}' | xargs docker stop
for port in 80 443; 
  set KIND_CTRL_PLANE_IP (docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dokimi-cluster-control-plane)
  set NPORT (kubectl get service -n istio-system istio-ingressgateway -o=jsonpath="{.spec.ports[?(@.port == $port)].nodePort}")
  echo "Redirect localhost:$port to alpine/socat $port that bidirectional byte streams with $KIND_CTRL_PLANE_IP:$NPORT"
  docker run --rm -d --name dokimi-cluster-kind-proxy-$port \
    --publish 127.0.0.1:$port:$port \
    --net kind \
    alpine/socat -ddd -D TCP-LISTEN:$port,fork,reuseaddr TCP-CONNECT:$KIND_CTRL_PLANE_IP:$NPORT
end
docker logs -f dokimi-cluster-kind-proxy-80

Verification : curl http://localhost:80


# Clean :

kind delete clusters dokimi-cluster