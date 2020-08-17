#
# Destroys a Kubernetes cluster.
#

set -u # or set -o nounset
: "$APP_NAME"
: "$ARM_CLIENT_ID"
: "$ARM_CLIENT_SECRET"

terraform destroy -auto-approve \
    -var "app_name=$APP_NAME" \
    -var "client_id=$ARM_CLIENT_ID" \
    -var "client_secret=$ARM_CLIENT_SECRET"