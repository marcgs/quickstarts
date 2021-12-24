#! /bin/bash

set -euo pipefail

run_terraform() {
    terraform init
    terraform plan
    terraform apply --auto-approve
}

echo
echo "Provisioning AKS cluster..."
(cd terraform/aks; run_terraform)
echo "DONE"

echo
echo "Building CSharp Substract App..."
image_tag=$RANDOM
acr_name=$(cd terraform/aks; terraform output -raw container_registry_name)
(cd csharp; docker build . -t $acr_name.azurecr.io/dapriosamples/distributed-calculator-csharp:$image_tag)

echo
echo "Pushing CSharp Substract App to ACR..."
az acr login --name $acr_name
docker push $acr_name.azurecr.io/dapriosamples/distributed-calculator-csharp:$image_tag

echo
echo "Deploying dapr and distributed calculator application..."
export TF_VAR_subtract_image_tag=$image_tag
export TF_VAR_acr_name=$acr_name
(cd terraform/helm; run_terraform)
echo "DONE"