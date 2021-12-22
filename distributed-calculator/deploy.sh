#! /bin/bash

set -euo pipefail

run_terraform() {
    terraform init
    terraform plan
    terraform apply --auto-approve
}

echo "Provisioning AKS cluster..."
(cd terraform/aks; run_terraform)
echo "DONE"

echo

echo "Deploying dapr and distributed calculator application..."
(cd terraform/helm; run_terraform)
echo "DONE"