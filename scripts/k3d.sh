#!/bin/bash

## dependencies
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

## kubernetes repository
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://apt.kubernetes.io/ kubernetes-xenial main"

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