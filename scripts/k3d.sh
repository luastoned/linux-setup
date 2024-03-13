#!/bin/bash

## dependencies
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

## kubernetes repository
# curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
# sudo add-apt-repository "deb [arch=amd64] https://pkgs.k8s.io/ kubernetes-xenial main"

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

## install kubectl
sudo apt install kubectl -y

## install k3d
curl -fsSL https://raw.githubusercontent.com/rancher/k3d/main/install.sh | sudo bash

## install krew
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

## install kubectx / kubens / konfig
kubectl krew install ctx
kubectl krew install ns
kubectl krew install konfig

## install helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sudo bash