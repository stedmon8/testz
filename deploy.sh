#
# Provision a Kubernetes cluster.
#

set -e # Any subsequent commands that fail exit the script with an error.
set -u # or set -o nounset
: "$APP_NAME"
: "$ARM_CLIENT_ID"
: "$ARM_CLIENT_SECRET"
: "$TFSTATE_BACKEND_RES_GROUP"
: "$TFSTATE_BACKEND_STORAGE_ACC"
: "$TFSTATE_BACKEND_CONTAINER"
: "$TFSTATE_BACKEND_KEY"

terraform init \
    -backend-config="resource_group_name=$TFSTATE_BACKEND_RES_GROUP" \
    -backend-config="storage_account_name=$TFSTATE_BACKEND_STORAGE_ACC" \
    -backend-config="container_name=$TFSTATE_BACKEND_CONTAINER" \
    -backend-config="key=$TFSTATE_BACKEND_KEY"
terraform apply -auto-approve \
    -var "app_name=$APP_NAME" \
    -var "client_id=$ARM_CLIENT_ID" \
    -var "client_secret=$ARM_CLIENT_SECRET"