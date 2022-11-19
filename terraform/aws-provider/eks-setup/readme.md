
> terraform init

> terraform apply -auto-approve   (TF_LOG=TRACE)

First run there's an error : 'Error: Provider produced inconsistent final plan'
This is due to a bad management of tag_all in the eks module. Just relaunch

> kubectl apply -f deployments/application.yaml

Check the outputs and check that the application 'foo' and 'bar' deployed on K8s are reachable with the alb DNS.

> terraform destroy -auto-approve

# TODO : 
 * Check bastion connection ingress ?
 * Check route53 https://hceris.com/provisioning-an-application-load-balancer-with-terraform/