# IaC demo / Example-1

An example of infrastructure as code: deploying a Kubernetes cluster and a contain registry to Microsoft Azure with Terraform.

Tihs code repository contains the Terraform scripts to build a container registry and Kubernetes cluster.

This example accompanies a live stream talk that I'm giving in September (2020). My talk will cover two examples:

- Example-1 - Deploying a Kubernetes cluster and container registry (this example).
- [Example-2](https://bitbucket.org/bootstrapping-microservices/iac-example-2) - Deploying a microservice.

[Follow on Twitter](https://twitter.com/ashleydavis75) for updates and announcements.

There are two ways to run this example:

- [Deploy by manually invoking Terraform](#deploy-by-manually-invoking-terraform)
- [Deploy by automated continuous delivery](#deploy-by-automated-continous-delivery)

# Prerequisites

To run this code you  need the following installed:

- [Terraform](https://www.terraform.io/downloads.html)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)


Verify your tools are installed like this:

```bash
terraform --version
kubectl version
az --version
```

# Using Vagrant (optional)

If you have Vagrant and VirtualBox installed you can use the Vagrantfile in this repo to create a Ubuntu virtual machine that has Terraform, Kubectl and the Azure CLI already installed and ready to be used.

Create your VM like this:

```bash
cd iac-example-1
vagrant up
```

Now open a terminal into your VM and check that all the tools are installed:

```bash
vagrant ssh
cd /vagrant
terraform --version
az --version
kubectl version
```

# Azure authenication

You need an authenticated Azure account, use the Azure CLI `az login` command to login to your account.

You need to know your Azure subscription ID. Use the command `az account show` to show you the current account. Take know of the `id` field in the output, this is your subscription ID.

You need to create an Azure service principle for cluster authentication. This is what Kubernetes will use to create Azure resources on your behalf (e.g. whenever it needs to create a load balancer for a service in the cluster).

After authenticating with Azure run this command:

```bash
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<your-subscription-id>"
```

Make sure you plug in your own Azure subscription ID that you note down amoment ago.

Note down the `appId` and `password` fields from the output. These are the `client_id` and `client_secret` values you need below to deploy your Kubernetes cluster.

# Deploy by manually invoking Terraform

## Manual setup

This example is designed to be invoked from a continous delivery (CD) pipeline so it has a Terraform *backend* configured to persist state in Azure.

To run this code locally you must delete `backend.tf`:

```bash
cd iac-example-1
rm backend.tf
```

It's pretty annoying that you have to make changes to the code in order to test it locally. I think I might complain to Hashicorp about this.

## One time Terraform setup

Before you deploy the first time you must initialise Terraform:

```bash
cd iac-example-1
terraform init
```

## Deploy Kubernetes

Now we can deploy a Kubernetes cluster to Azure:

```bash
cd iac-example-1
terraform apply
```

You must now enter a value for the `app_name` variable. You must enter a unique name for your application. This is used for the name of the private container register so it must be globally unique and it can only contain alpha numeric character (no symbols, hyphens or underscores).

Enter the values for `client_id` and `client_secret` that you noted from earlier.

Type `yes` to approve the deployment and press enter.

Now go make a coffee. This could take a little while.

Anytime you make changes to your code you run `terraform apply` again to update your infrastructure.

## Authenticate Kubectl

The Azure CLI makes it really easy to setup authenticated access to our cluster via Kubectl.

This command will download credentials and add them to your Kubectl config:

```bash
az aks get-credentials --resource-group <your-app-name> --name <your-app-name>
```

Replace `your-app-name` with the name that you selected for your application in the previous section.


## Test your cluster

Once the deployment process has finished and we have authenticated Kubectl, run this command to test that you can access your cluster:

```bash
kubectl get nodes
```

This should print out the nodes in your cluster.

Looking for next steps? Example-2 is coming soon.

## Destroy your cluster

If you no longer need your cluster, make sure you destroy it so you aren't spending money on it:

```bash
terraform destroy
```

You need to enter the same detail as when you created the cluster and type `yes` to approve.

# Deploy by automated continous delivery (CD)

We can easily setup this example to deploy by automated [continous delivery](https://martinfowler.com/bliki/ContinuousDelivery.html).

This is what *infrastructure as code* is all about. Just push changes to your code to make changes to your infrasturcture.

This code repository is already setup for that. When I push changes to this repo Terraform is automatically invoked and my Kubernetes cluster is updated.

With some preparation you can fork this repo for yourself and setup your own continous delivery pipeline.

## Testing the deployment script locally

You can test the continous delivery script locally. It's a good idea to do this before trying to have it run in the cloud where it's hard to debug.

Before you do this make sure you revert the file `backend.tf` that you deleted earlier.

This repo includes a shell script `deploy.sh` that is called by the continous delivery system (a CD system is really just a fancy way to automatically run a shell script). This script invokes Terraform to deploy the Kubernetes cluster to Azure.

Before you run the shell script you must set the following environment variables (make sure you replace the placeholder values!):

```bash
export APP_NAME=<your-app-name>
export ARM_SUBSCRIPTION_ID=<your-azure-subscription-id>
export ARM_CLIENT_ID=<id-from-your-azure-service-prinicple>
export ARM_CLIENT_SECRET=<password-from-your-azure-service-prinicple>
export ARM_TENANT_ID=<tenant-id-from-your-azure-service-prinicple>
```

Use the unique name for your app that you selected earlier.

Refer back to the [Azure authentication](#markdown-header-azure-authenication) section above to authenticate with Azure and create a service principle so that you have values for the Azure authentication environment variables.

When running automated continous delivery in the cloud you also need a place to store your Terraform state. You'll need to create an Azure storage account with a container and then tell Terraform which file in the container to use to store its state.

Then you need to provide those details as environment variables (replace the placeholder values!):

```bash
export TFSTATE_BACKEND_RES_GROUP=<azure-resource-group-name>
export TFSTATE_BACKEND_STORAGE_ACC=<azure-storage-account-name>
export TFSTATE_BACKEND_CONTAINER=<azure-storage-container-name>
export TFSTATE_BACKEND_KEY=<file-name-for-the-terraform-state-file>
```

Now you can run the deployment script locally to test it:

```bash
./deploy.sh
```

This invokes Terraform using Azure for storing the Terraform state file. It can take a while, but when done you'll have a Kubernetes cluster deployed.

This was only a local test run. We still need to get this running automatically in our continuous delivery pipeline, so for now let's destroy the cluster:

```bash
./destroy.sh
```

## Activating the automated continous delivery pipeline

The configuration for the CD pipeline is in the file `bitbucket-pipelines.yaml`. This is a really small file that simply invokes our script `deploy.sh`.

To get this working for yourself you must fork [this code respository](https://bitbucket.org/bootstrapping-microservices/iac-example-1) on Bitbucket or create a new repository of your own and import the code.

Before you do this make sure you revert the file `backend.tf` that you deleted earlier.

Before you can trigger a build you need to go to *Repository settings* for your code repo. Go to *PIPELINES > Settings* and click *Enable Pipelines* to enable the CD pipeline for the repository. You can only do this if you have the file `bitbucket-pipelines.yaml` already in your repo.

Now, still under *Repository settings*, go to *Repository variables* and add the environment variables that you used in the previous section.

You are now ready to trigger your first deployment. You can invoke the CD pipeline manually from the Pipelines page of the respository or you can changes some code and push it to the hosted repository.

Once you do that your Kubernetes cluster will be deployed. If there's any problems you'll be able to see what happened in the Pipelines page of the respository. 

Future changes to your infrastructure can now be done through code. Congratulations you are doing infrastructure as code!

[Follow on Twitter](https://twitter.com/ashleydavis75) to stay updated.