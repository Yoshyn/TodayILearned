# Let's install metallb to get a LoadBalancer

Check : https://metallb.universe.tf/installation/

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="(openssl rand -base64 128)"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
kubectl get pods -n metallb-system --watch 

set DOCKER_NET_RANGE (docker network inspect -f '{{range .IPAM.Config}}{{.Subnet}} {{end}}' kind | awk '{print $1}')
set METALLB_IPS (python3 -c "import ipaddress; n = ipaddress.IPv4Network('$DOCKER_NET_RANGE'); print(str(n[-56]) + '-' + str(n[-6]));")
gsed -i -E "s/([0-9]{1,3}\.){3}[0-9]{1,3}-([0-9]{1,3}\.){3}[0-9]{1,3}/$METALLB_IPS/g" metallb-configmap.yml

kubectl apply -f metallb-configmap.yml

You can now make the same test present on the readme.md but using the external ip (and real port, not the nodePort) return by the services instead of `dokimi-cluster-control-plane` (or worker).
