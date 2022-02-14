
# https://istio.io/latest/docs/tasks/security/authorization/authz-jwt/

# JWT token :
istioctl install --set profile=demo -y
kubectl delete ns foo
kubectl create ns foo
bash -c "kubectl apply -f <(istioctl kube-inject -f istio/samples/httpbin/httpbin.yaml) -n foo"
bash -c "kubectl apply -f <(istioctl kube-inject -f istio/samples/sleep/sleep.yaml) -n foo"

# check 200 ok
kubectl exec (kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name}) -c sleep -n foo -- curl http://httpbin.foo:8000/ip -sS -o /dev/null -w "%{http_code}\n"

# JWT authorize on app selector : https://istio.io/latest/docs/tasks/security/authorization/authz-jwt/

bash -c "kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: "jwt-example"
  namespace: foo
spec:
  selector:
    matchLabels:
      app: httpbin
  jwtRules:
  - issuer: "testing@secure.istio.io"
    jwksUri: "https://raw.githubusercontent.com/istio/istio/release-1.12/security/tools/jwt/samples/jwks.json"
EOF"

-> check the doc to add constraints on the jwt

kubectl get RequestAuthentication -n foo jwt-example -o yaml

# Should be forbiden
kubectl exec (kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name}) -c sleep -n foo -- curl "http://httpbin.foo:8000/headers" -sS -o /dev/null -H "Authorization: Bearer invalidToken" -w "%{http_code}\n"

# Should be ok (without a JWT is allowed because there is no authorization policy):
kubectl exec (kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name}) -c sleep -n foo -- curl "http://httpbin.foo:8000/headers" -sS -o /dev/null -w "%{http_code}\n"

bash -c "kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: require-jwt
  namespace: foo
spec:
  selector:
    matchLabels:
      app: httpbin
  action: ALLOW
  rules:
  - from:
    - source:
       requestPrincipals: [\"testing@secure.istio.io/testing@secure.istio.io\"]
EOF"

set TOKEN (curl https://raw.githubusercontent.com/istio/istio/release-1.12/security/tools/jwt/samples/demo.jwt -s)
echo $TOKEN | cut -d '.' -f2 - | base64 -d

# With token => ok
kubectl exec (kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name}) -c sleep -n foo -- curl "http://httpbin.foo:8000/headers" -sS -o /dev/null -H "Authorization: Bearer $TOKEN" -w "%{http_code}\n"

# without ok with bad => ko
kubectl exec (kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name}) -c sleep -n foo -- curl "http://httpbin.foo:8000/headers" -sS -o /dev/null -w "%{http_code}\n"
kubectl exec (kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name}) -c sleep -n foo -- curl "http://httpbin.foo:8000/headers" -sS -o /dev/null -H "Authorization: Bearer invalidToken" -w "%{http_code}\n"
