# Secure Multi-User LLM Infrastructure (Ollama + OpenWebUI) on AWS EC2 with SSM Port Forwarding

This project implements a secure, containerized multi-user LLM infrastructure running on AWS EC2.
The system is designed with an enterprise-level security focus, avoiding public exposure by using AWS Systems Manager (SSM) for controlled access instead of traditional SSH or open ports.

Ollama is deployed inside Docker alongside OpenWebUI, enabling scalable, isolated, and reproducible AI workloads.
The architecture follows cloud-native principles and can be extended toward GPU instances, private VPC setups, or production-ready AI platforms.

## Requirements

### Required Tools

- Git
- Terraform – https://developer.hashicorp.com/terraform/downloads
- AWS CLI – https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- AWS Session Manager Plugin – https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

### Infrastructure Deployment (Terraform)

The infrastructure can be provisioned automatically using Terraform.

Terraform creates:

- EC2 instance (Amazon Linux 2023)
- 30 GB storage
- IAM role attachment for AWS Systems Manager (SSM)
- Security group with **no inbound rules**
- Docker, Docker Compose, and Git installation via EC2 user data

### Initialize Terraform
```bash
git clone https://github.com/Srakawichi/multi-user-ai-infrastructure.git
cd multi-user-ai-infrastructure/terraform
 
terraform init
terraform plan
terraform apply
```
After the deployment completes, Terraform will output the EC2 instance ID.
This ID is required to connect to the instance using AWS Systems Manager.

## Setup & Run
### 1. Connect to EC2 via SSM 
> Connect to your EC2 instance using **AWS Systems Manager**  
> No SSH access and no open inbound ports are required.
```bash
aws ssm start-session --target <INSTANCE_ID>
```

### 2. Deploy the AI Infrastructure (Executed on EC2)
Clone the repository and start the containers:
```bash 
git clone https://github.com/Srakawichi/multi-user-ai-infrastructure.git
cd multi-user-ai-infrastructure
./start.sh
```
If you don't have permission to run Docker, execute the following commands and reconnect to your session.
```bash
sudo usermod -aG docker ssm-user
```
This process starts all required containers, automatically provisions the LLM model, and initializes persistent storage.
### 3. Create Secure Port Forwarding Session (Executed on Local Machine)
From your local system (e.g. Windows with AWS CLI installed), establish the secure tunnel:
```bash
aws ssm start-session --target <INSTANCE_ID> --document-name AWS-StartPortForwardingSession --parameters "portNumber=8080,localPortNumber=9000"
```
### 4. Access Web Interface
```bash
http://localhost:9000
```
### Notes
- If running the system locally (Linux recommended), only step 2 is required.
- If port 8080 is already in use, adjust the port mapping in the docker-compose.yml file.

## Architecture

![Architecture Diagram](/docs/multi-user-ai-graph.png)

The architecture follows a zero-trust design, avoiding any public exposure. 
Access is exclusively managed through AWS Systems Manager (SSM) with IAM-based authentication.

## Features

- Secure access via AWS Systems Manager (no SSH, no public ports)
- Containerized LLM deployment using Docker Compose
- Multi-user web interface via OpenWebUI
- Automatic model provisioning at startup
- Persistent storage for models and application data
- Localhost-only container binding (127.0.0.1)
- IAM-based access control via AWS Systems Manager

## Used Technologies

- AWS EC2
- AWS Systems Manager (SSM)
- AWS IAM
- Amazon Linux 2023
- Docker
- Docker Compose
- Ollama
- OpenWebUI
- Bash
- AWS CLI
- Terraform

## Outlook

This project serves as a foundation for a secure enterprise-grade AI platform.

The following roadmap outlines planned improvements and current implementation status.

| Feature / Improvement | Description | Status |
|---|---|---|
| Terraform-based infrastructure provisioning | Reproducible infrastructure deployment using Terraform | ✅ Implemented |
| GPU-based scaling | Support for GPU-enabled instances for faster LLM inference | ⬜ Planned |
| Kubernetes orchestration | Container orchestration for scalable deployments | ⬜ Planned |
| Infrastructure-as-Code automation | Extended automation for infrastructure management | ⬜ Planned |
| CI/CD pipelines with integration testing | Automated testing and deployment workflows | ⬜ Planned |

The long-term vision is to evolve this setup into a scalable, production-ready, zero-trust AI infrastructure architecture.



