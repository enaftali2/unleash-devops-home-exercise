# Unleash Devops Home Exercise

This repository contains an node Express server written in TypeScript that hosts an endpoint to check if a file exists in a specified S3 bucket. 

`GET /check-file?fileName=myfile.txt`

## Configuration

The following environment variables needs to be configured in the server:
- BUCKET_NAME
- PORT - (Default to 3000 if not specified)

## Tasks

### 1. Dockerization

Dockerize the server using best practices.

### 2. Continuous Integration (CI)

Set up a CI process using your preferred CI tool (e.g., GitHub Actions, GitLab CI, Azure Pipelines):

- Configure the CI pipeline to build and push a Docker image to a Docker registry on every commit to the main branch.

### 3. Continuous Deployment (CD)

Enhance the CI pipeline to include a CD stage:

- Automate the deployment of the Docker image to a cloud environment.
- Ensure the CD process deploys the service and its dependencies (e.g., the S3 bucket) in a robust, reproducible, and scalable manner.
- Apply infrastructure as code principles where appropriate.

**Note**: The infrastructure of the service (where this service runs) doesn't have to be managed as infrastructure as code within this repository.

---
# Home Exercise Overview
## Infrastructure

### Terraform Setup
The Terraform tfstat file stored in manually created bucket(my-app-tfstat).

We use **Terraform** to provision the infrastructure, including:
- **EKS Cluster**: Amazon Kubernetes service for running the application.
- **S3 Bucket**: Stores application-related data.
- **AWS ECR**: Private Docker registry for storing the containerized application.
- **Security Groups**: Configured for network security.
- **Public Subnets**: Automatically created for EKS using Terraform.

#### **Deploying the Infrastructure**
1. **Install Terraform** (if not installed):
    ```sh
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform -y
    ```
2. **Initialize Terraform**:
    ```sh
    terraform init
    ```
3. **Plan Deployment**:
    ```sh
    terraform plan
    ```
4. **Apply Deployment**:
    ```sh
    terraform apply -auto-approve
    ```

---

## CI/CD Pipeline

The **GitHub Actions** workflow automates:
1. **Building and pushing the Docker image** to **AWS ECR**.
2. **Deploying the application** to **AWS EKS** using Helm.

### **GitHub Actions Pipeline Overview**
- **CI Stage**:
    - Builds the Docker image.
    - Pushes it to **AWS ECR**.
- **CD Stage**:
    - Deploys the Helm chart to EKS.

---

## Dockerization

The application is containerized using Docker. The **Dockerfile** follows best practices and is structured to:
- Use a **lightweight Node.js base image**.
- Install dependencies efficiently.
- Run the built TypeScript application.

### **Building & Running the Docker Image Locally**
```sh
# Build the image
docker build -t home-exercise:latest .

# Run the container
docker run -p 3000:3000 -e BUCKET_NAME=my-bucket home-exercise:latest
```

---

## Helm Deployment
A **Helm chart** is used for managing deployments on **EKS**.

### **Deploying the Helm Chart**
1. **Ensure Helm is installed**:
    ```sh
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    ```
2. **Deploy the application**:
    ```sh
    helm upgrade --install home-exercise ./helm_chart \
      --set image.repository=${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/home-exercise \
      --set image.tag=latest \
      --set bucketName=${{ secrets.BUCKET_NAME }}
    ```

---

## Testing
After deployment, you can test the API:
```sh
curl http://<load-balancer-url>/check-file?fileName=test.txt
```
Replace `<load-balancer-url>` with the actual **AWS LoadBalancer** URL from `kubectl get svc`.

---

### **Next Steps**
- Implement logging and monitoring.
- Improve security and IAM policies.
- Automate rollbacks in case of failure.