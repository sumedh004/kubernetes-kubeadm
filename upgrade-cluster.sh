#!/bin/bash
new_k8s_version=$1


for i in $(kubectl get nodes | awk '{print $1}' | tail -n +2)
do
        if (( $i=="master" )); then


                echo "Upgrading kubeadm on master"
                sudo apt-mark unhold kubeadm && \
                sudo apt-get update && sudo apt-get install -y kubeadm=$new_k8s_version-00 && \
                sudo apt-mark hold kubeadm && \

                sudo kubeadm upgrade apply v$new_k8s_version -y && \

                kubectl drain $i --ignore-daemonsets && \

                sudo apt-mark unhold kubelet kubectl && \
                sudo apt-get update && sudo apt-get install -y kubelet=$new_k8s_version-00 kubectl=$new_k8s_version-00 && \
                sudo apt-mark hold kubelet kubectl && \
                sudo systemctl daemon-reload && \
                sudo systemctl restart kubelet && \
                kubectl uncordon $i


        else

                echo "Upgrading kubeadm on worker $i"
                kubectl cordon $i && \
                kubectl drain $i --ignore-daemonsets && \
                #echo "azureuser@$i"
                #echo "ssh azureuser@$i "bash -s" < upgrade_nodes.sh "$1""
                ssh -o StrictHostKeyChecking=no azureuser@${i} 'bash -s' < upgrade_nodes.sh $1 && \
                #ssh azureuser@${i} 'bash -s' < upgrade_nodes.sh $1 && \
                sudo systemctl daemon-reload && \
                sudo systemctl restart kubelet && \
                kubectl uncordon $i


        fi
done
