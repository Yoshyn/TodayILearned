
# https://istio.io/latest/docs/tasks/security/authorization/authz-http/

# Authorize nothing

bash -c "kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-nothing
  namespace: foo
spec:
  {}
EOF"

## Should be ko
kubectl exec (kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name}) -c sleep -n foo -- curl "http://httpbin.foo:8000/headers" -sS  -w " %{http_code}\n"

# Authorize GET for httpbin
bash -c "kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: httpbin-viewer
  namespace: foo
spec:
  selector:
    matchLabels:
      app: httpbin
  action: ALLOW
  rules:
	  - 
	    from:
	    	- source:
	        principals: [\"cluster.local/ns/foo/sa/sleep\"]
	    to:
	    	- operation:
	        methods: [\"GET\"]
EOF"

## Should be ok
kubectl exec (kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name}) -c sleep -n foo -- curl "http://httpbin.foo:8000" -sS  -w " %{http_code}\n"

## Should be ko
kubectl exec (kubectl get pod -l app=sleep -n foo -o jsonpath={.items..metadata.name}) -c sleep -n foo -- curl -X POST "http://httpbin.foo:8000" -sS  -w " %{http_code}\n"

## Should be ko
curl localhost:80
