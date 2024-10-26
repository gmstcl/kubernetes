# --- kubectl alias --- #

sudo echo "alias k=kubectl" >> ~/.bashrc

# --- eksctl install --- #

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/bin/
eksctl version

# --- kubectl 1.29 install --- #

curl -O --silent --location https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.0/2024-01-04/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/bin/
kubectl version --client

# --- kubectl 1.30 install --- #

curl -LO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/bin/
kubectl version
