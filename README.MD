# IaC demo / Example-1

An example of infrastructure as code: deploying a Kubernetes cluster to Microsoft Azure with Terraform.

# Prerequisites

You need Terraform installed to run this code.

You need Kubectl to test that your cluster is working after deployment.

# Using Vagrant (optional)

The Vagrantfile in the repo creates an Ubuntu virtual machine with Terraform, Kubectl and the Azure CLI installed.

If you have Vagrant and VirtualBox installed you can create the VM like this:

```bash
cd example-1
vagrant up
```

Now shell into the VM and check that Terraform and the Azure CLI are installed:

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

# Setup

Before you deploy the first time you must initialise Terraform:

```bash
terraform init
```

# Deploy Kubernetes

Now we can deploy a Kubernetes cluster to Azure:

```bash
terraform apply
```

Enter the values for `client_id` and `client_secret` that you noted down above.

Type `yes` to approve the deployment and press enter.

Now go make a coffee. This could take a little while.

# Test your cluster

Once the deployment process has finished

```bash
kubectl get nodes
```

This should print out the nodes in your cluster.