# Let's install metallb to get a LoadBalancer

You typically probably want to expose your ingress manager (nginx ?) using a loadbalancer.

Check : https://metallb.universe.tf/installation/

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

kubectl get pods -n metallb-system --watch

set DOCKER_NET_RANGE (docker network inspect -f '{{range .IPAM.Config}}{{.Subnet}} {{end}}' kind | awk '{print $1}')
set METALLB_IPS (python3 -c "import ipaddress; n = ipaddress.IPv4Network('$DOCKER_NET_RANGE'); print(str(n[-56]) + '-' + str(n[-6]));")
gsed -i -E "s/([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}/$METALLB_IPS/g" metallb/ipaddress_pools.yml
kubectl apply -f metallb/ipaddress_pools.yml


kubectl apply -f metallb/web-app-demo.yml

kubectl get svc -n web

We can now reach the service using the external ip (and real port, not the nodePort) return by the services instead of `dokimi-cluster-control-plane` (or worker).

# /!\ Mac doesn’t expose the “docker network” to the underlying host. Due to this restriction so you still need to proxy request from your host to docker.

docker ps --all | grep alpine/socat | awk '{print $1}' | xargs docker stop
set -x SERVICE_IP (kubectl get service -n web web-server-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
for row in $(kubectl get service -n web web-server-service -o=jsonpath="{.spec.ports}" | jq -r '.[] | @base64');
  set -l PORT (echo $row | base64 --decode | jq -r $1 '.port')
  echo "Redirect localhost:$PORT to alpine/socat $PORT that bidirectional byte streams with $SERVICE_IP:$PORT"
  docker run -d --rm --name kind-dokimi-cluster-metallb-proxy-$PORT --publish 127.0.0.1:$PORT:$PORT --net kind alpine/socat -ddd TCP-LISTEN:$PORT,fork,reuseaddr TCP-CONNECT:$SERVICE_IP:$PORT
end


# Then you can curl localhost (or directly the external ip if you don't use mac) :

curl http://localhost
