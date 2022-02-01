# Setup a network with a bastion, a budget, an rds and an ecs cluster

> terraform init

> terraform apply -auto-approve

> terraform destroy -auto-approve

# Check outputs & populate the ecs cluster : check ecs_services/deploy.fish

# Handle variables :

# Set a variable directly
> terraform apply -var 'region=us-west-2'

# Or avoid previous by creating a file name :
> touch terraform.tfvars
# (or .auto.tfvars)

# Or use exports (only string) :
> EXPORT TF_VAR_region='eu-west-3'

# Launch manually other files (for password & username not under version control) :
> terraform apply -auto-approve -var-file 'sensitive.tfvars'

