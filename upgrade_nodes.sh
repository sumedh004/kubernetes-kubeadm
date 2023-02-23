#!/bin/bash
new_k8s_version=$1


sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm=$new_k8s_version-00 && \
sudo apt-mark hold kubeadm && \
sudo kubeadm upgrade node && \
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet=$new_k8s_version-00 kubectl=$new_k8s_version-00 && \
sudo apt-mark hold kubelet kubectl
