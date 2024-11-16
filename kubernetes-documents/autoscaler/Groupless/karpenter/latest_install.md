# 1. Install utilities

Karpenter is installed in clusters with a Helm chart.

Karpenter requires cloud provider permissions to provision nodes, for AWS IAM Roles for Service Accounts (IRSA) should be used. IRSA permits Karpenter (within the cluster) to make privileged requests to AWS (as the cloud provider) via a ServiceAccount.

Install these tools before proceeding:

    AWS CLI
    kubectl - the Kubernetes CLI
    eksctl (>= v0.191.0) - the CLI for AWS EKS
    helm - [the package manager for Kubernetes](https://helm.sh/docs/intro/install/)

Configure the AWS CLI with a user that has sufficient privileges to create an EKS cluster. Verify that the CLI can authenticate properly by running aws sts get-caller-identity.