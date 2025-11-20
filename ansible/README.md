🚀 Install Kubernetes Cluster Using Ansible on Ubuntu 24.04
📝 Introduction

Setting up a Kubernetes cluster on Ubuntu 24.04 manually can be a time-consuming and error-prone task. Ansible—a powerful open-source automation tool—simplifies this process by automating the provisioning and configuration of all required components. This guide will walk you through deploying a production-ready Kubernetes cluster on Ubuntu 24.04 using Ansible roles.

    Note: In our previous guide, we demonstrated manual deployment on Ubuntu 23.10. This version improves on that by using automation with Ansible.

✅ Prerequisites

Before proceeding, ensure the following requirements are met:

    A stable internet connection

    A control node (Ubuntu 24.04) with Ansible installed

    At least two Ubuntu 24.04 nodes (1 Master + 1 Worker)

    SSH access from the control node to all target nodes

    A non-root user with sudo privileges on all nodes

    Basic knowledge of Ansible and Kubernetes

⚙️ System Preparation

Perform these steps on all nodes unless specified otherwise.
Step 1: Update Packages

sudo apt update -y && sudo apt upgrade -y

Step 2: Create Operational User

sudo adduser sysadmin
sudo usermod -aG sudo sysadmin

    Log in as sysadmin or configure Ansible to use this user for SSH connections.

🛠️ Install Ansible (Control Node Only)

sudo apt install ansible -y

Generate SSH Key and Share with Nodes

ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
ssh-copy-id sysadmin@<master_node_ip>
ssh-copy-id sysadmin@<worker_node_ip>

📁 Project Structure and Ansible Roles

Initialize the required roles:

ansible-galaxy init kubernetes_master
ansible-galaxy init kubernetes_worker
ansible-galaxy init kubernetes_network

Create an inventory file (hosts) and a playbook (cluster-setup.yml) to organize and execute your deployment logic.

Example inventory (hosts):

[master]
master-node ansible_host=<master_node_ip> ansible_user=sysadmin

[workers]
worker-node ansible_host=<worker_node_ip> ansible_user=sysadmin

▶️ Run the Ansible Playbook

Execute the playbook to deploy the Kubernetes cluster:

ansible-playbook -i hosts cluster-setup.yml

🔍 Validate the Cluster

Once deployment is complete, use kubectl to verify the setup:

kubectl get nodes
kubectl get pods --all-namespaces
kubectl get services

📌 Conclusion

You’ve successfully deployed a Kubernetes cluster on Ubuntu 24.04 using Ansible. This automated method ensures consistency, reduces manual errors, and accelerates future scaling or changes.

Feel free to contribute or expand this setup by adding roles for monitoring, logging, ingress controllers, or Helm.
