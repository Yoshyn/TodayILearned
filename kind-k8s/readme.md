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

# Test using kubectl port forward :

kubectl port-forward -n kube-system kube-controller-manager-dokimi-cluster-control-plane 8888:$ISTIO_HTTP_NPORT

Verification : curl http://localhost:8888


# Test using localhost on the host (mac laptop) :

/!\ Mac doesn’t expose the “docker network” to the underlying host. Due to this restriction so you still need to proxy request from your host to docker.

## Using Socat
/!\ It would be awesome to add a route from the host to the kind docker network. Sadly it does not work on mac
https://github.com/docker/for-mac/issues/2716
https://docs.docker.com/desktop/mac/networking/

docker ps --all | grep alpine/socat | awk '{print $1}' | xargs docker stop
set -x KIND_CTRL_PLANE_IP (docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dokimi-cluster-control-plane)
for row in $(kubectl get service -n istio-system istio-ingressgateway -o=jsonpath="{.spec.ports}" | jq -r '.[] | @base64');
  set -l NAME (echo $row | base64 --decode | jq -r $1 '.name')
  set -l PORT (echo $row | base64 --decode | jq -r $1 '.port')
  set -l NPORT (echo $row | base64 --decode | jq -r $1 '.nodePort')
  echo "Redirect localhost:$PORT to alpine/socat $PORT that bidirectional byte streams with $SERVICE_IP:$PORT"
  docker run -d --rm --name kind-dokimi-cluster-metallb-proxy-$NAME-$PORT --publish 127.0.0.1:$PORT:$PORT --net kind alpine/socat -ddd TCP-LISTEN:$PORT,fork,reuseaddr TCP-CONNECT:$KIND_CTRL_PLANE_IP:$NPORT
end

docker logs -f kind-dokimi-cluster-metallb-proxy-http2-80

Verification : curl http://localhost:80


## Using haproxy :

/!\ the configuration is made only for HTTP here. A little bit too anoying make something dynamic. The use of socat seem more relevant.


set -x ISTIO_HTTP_NPORT (kubectl get service -n istio-system istio-ingressgateway -o=jsonpath="{.spec.ports[?(@.port == 80)].nodePort}")
rm -f haproxy.cfg && envsubst < haproxy.cfg.tlp > haproxy.cfg

docker run --rm --name haproxy-kind --net kind -v (pwd)/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro -p 80:80 haproxy:2.5-alpine


Verification : curl http://localhost:80

# Clean :

kind delete clusters dokimi-cluster
