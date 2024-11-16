# 1. Install utilities

Karpenter is installed in clusters with a Helm chart.

Karpenter requires cloud provider permissions to provision nodes, for AWS IAM Roles for Service Accounts (IRSA) should be used. IRSA permits Karpenter (within the cluster) to make privileged requests to AWS (as the cloud provider) via a ServiceAccount.

Install these tools before proceeding:

    AWS CLI
    kubectl - the Kubernetes CLI
    eksctl (>= v0.191.0) - the CLI for AWS EKS
    helm - the package manager for Kubernetes

Configure the AWS CLI with a user that has sufficient privileges to create an EKS cluster. Verify that the CLI can authenticate properly by running `aws sts get-caller-identity`.


## 2. Set environment variables
After setting up the tools, set the Karpenter and Kubernetes version:

```sh
export KARPENTER_NAMESPACE="kube-system"
export KARPENTER_VERSION="1.0.8"
export K8S_VERSION="1.31"
```

Then set the following environment variable:

```sh 
export AWS_PARTITION="aws" # if you are not using standard partitions, you may need to configure to aws-cn / aws-us-gov
export CLUSTER_NAME="demo-cluster"
export AWS_DEFAULT_REGION="ap-northeast-2"
export AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
export TEMPOUT="$(mktemp)"
export ARM_AMI_ID="$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2-arm64/recommended/image_id --query Parameter.Value --output text)"
export AMD_AMI_ID="$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2/recommended/image_id --query Parameter.Value --output text)"
export GPU_AMI_ID="$(aws ssm get-parameter --name /aws/service/eks/optimized-ami/${K8S_VERSION}/amazon-linux-2-gpu/recommended/image_id --query Parameter.Value --output text)"
```

Warning  
  
If you open a new shell to run steps in this procedure, you need to set some or all of the environment variables again. To remind yourself of these values, type:

```sh
echo "${KARPENTER_NAMESPACE}" "${KARPENTER_VERSION}" "${K8S_VERSION}" "${CLUSTER_NAME}" "${AWS_DEFAULT_REGION}" "${AWS_ACCOUNT_ID}" "${TEMPOUT}" "${ARM_AMI_ID}" "${AMD_AMI_ID}" "${GPU_AMI_ID}"
```

## 3. Create a Cluster

Create a basic cluster with `eksctl`. The following cluster configuration will:
Use CloudFormation to set up the infrastructure needed by the EKS cluster. See CloudFormation for a complete description of what `cloudformation.yaml` does for Karpenter.
Create a Kubernetes service account and AWS IAM Role, and associate them using IRSA to let Karpenter launch instances.
Add the Karpenter node role to the aws-auth configmap to allow nodes to connect.
Use AWS EKS managed node groups for the kube-system and karpenter namespaces. Uncomment fargateProfiles settings (and comment out managedNodeGroups settings) to use Fargate for both namespaces instead.
Set KARPENTER_IAM_ROLE_ARN variables.
Create a role to allow spot instances.
Run Helm to install Karpenter

```sh
curl -fsSL https://raw.githubusercontent.com/aws/karpenter-provider-aws/v"${KARPENTER_VERSION}"/website/content/en/preview/getting-started/getting-started-with-karpenter/cloudformation.yaml  > "${TEMPOUT}" \
&& aws cloudformation deploy \
  --stack-name "Karpenter-${CLUSTER_NAME}" \
  --template-file "${TEMPOUT}" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides "ClusterName=${CLUSTER_NAME}"
```