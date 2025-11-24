# Kubernetes Clustrer Setup

This Repo is setting up a Kubernetes Cluster.  
The GITHUB-Action Pipeline needs 5 Secret to be set:  

SSH-Keypair for accessing VMs:  

- `SSH_PRIVATE_KEY`: SSH-Private-Key used to login on VMs
- `SSH_PUBLIC_KEY`: SSH-Private-Key which is distributed to the VMs Admin-Users `.ssh/authorized_keys` file

AWS-Credentials to access the AWS-Account:  

- `AWS_REGION`: AWS-Region to use
- `AWS_ACCESS_KEY_ID`: AWS-Acess-Key in AWS-Learner-Lab
- `AWS_SECRET_ACCESS_KEY`: AWS-Secret-Acess-Key in AWS-Learner-Lab
- `AWS_SESSION_TOKEN`: AWS-Session-Token in AWS-Learner-Lab

The following files are used for configuration:

- `ansible/03amazon.aws_ec2.yml`: Set AWS-Region
- `terraform/backend.conf`: Set AWS-Region, S3-bucket, Dynamo-DB-Table for Terraform-State
- `terraform/terraform.tfvars`: All variables defined in `terraform/variables.tf`. Required are only `join_master_nodes` and `join_worker_nodes` which are the count of additional masters (if set to 2, we will end up with 3 masters) and worker nodes.
  
