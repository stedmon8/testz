# IaC demo / Example-1

An example of infrastructure as code: deploying a Kubernetes cluster to Microsoft Azure with Terraform.

# Prerequisites

To run this code you  need the following installed:
- [Terraform](https://www.terraform.io/downloads.html)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)


Verify your tools are installed like this:

```bash
terraform --version
az --version
kubectl version
```


# Using Vagrant (optional)

If you have Vagrant and VirtualBox installed you can use the Vagrantfile in the repo to create a Ubuntu virtual machine that has Terraform, Kubectl and the Azure CLI already installed.

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

# One time Terraform setup

Before you deploy the first time you must initialise Terraform:

```bash
cd iac-example-1
terraform init
```

# Deploy Kubernetes

Now we can deploy a Kubernetes cluster to Azure:

```bash
terraform apply
```

You must now enter a value for the `app_name` variable. You must enter a unique name for your application. This is used for the name of the private container register so it must be globally unique and it can only contain alpha numeric character (no symbols, hyphens or underscores).

Enter the values for `client_id` and `client_secret` that you noted down above.

Type `yes` to approve the deployment and press enter.

Now go make a coffee. This could take a little while.

# Authenticate Kubectl

The Azure CLI makes it really easy to setup authenticated access to our cluster via Kubectl.

This command will download credentials and add them to your Kubectl config:

```bash
az aks get-credentials --resource-group <your-app-name> --name <your-app-name>
```

Replace `your-app-name` with the name that you selected for your application in the previous section.


# Test your cluster

Once the deployment process has finished and we have authenticated Kubectl, run this command to test that you can access your cluster:

```bash
kubectl get nodes
```

This should print out the nodes in your cluster.

Looking for next steps? Example-2 is coming soon.