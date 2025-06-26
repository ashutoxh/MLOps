# MLOps Final Project: End-to-End Image Analysis Pipeline on AWS

## Overview

This project deploys a full-stack machine learning pipeline on AWS using Flask (for YOLOv5 and depth estimation), React (frontend), and Terraform (for infrastructure automation). The pipeline is built for object detection and depth prediction in images uploaded through a web interface.

---

## 🧱 Architecture Overview

This infrastructure is built entirely using **Terraform**, ensuring 100% Infrastructure as Code (IaC) with reproducibility and version control.

### 🚀 Key Components

- **VPC & Networking**: Custom VPC with public and private subnets, route tables, internet gateway, and NAT gateway, all managed via `network.tf`.
- **ECS Cluster**: Elastic Container Service (ECS) configured using `ecs.tf`, supporting Fargate for containerized workloads.
- **Task Definitions & Services**: ECS task definitions and services defined in `tasks.tf`, enabling scalable application deployment.
- **Application Load Balancer (ALB)**: Defined in `loadbalancer.tf`, includes target groups and listeners for traffic routing to ECS services.
- **S3 Bucket**: Provisioned via `s3bucket.tf` for object storage needs.
- **Outputs and Variables**: Dynamically managed using `outputs.tf` and `variables.tf` for reusability and modularity.

### 🔄 CI/CD Integration

A `buildspec.yml` file is used with **AWS CodeBuild** to automate the production build process. On each commit or tag push, CodeBuild triggers a build pipeline that:

- Builds the application Docker image
- Tags it appropriately for production
- Pushes it to **Amazon ECR**
- The ECS service then pulls the latest image from ECR via the app task definition

This ensures a smooth, automated path from code to containerized deployment in a scalable cloud-native environment.

---

## 📁 Project Structure

```text
final-project/
├── depth-anything-flask-app/        # Flask app for MiDaS-based depth estimation
├── mlops-deployment/                # All Terraform IaC files (VPC, ECS, ALB, S3, etc.)
├── object-detection-react-app/      # React frontend
├── yolo-v5-flask-app/               # Flask app for YOLOv5 object detection
├── buildspec.yml                    # CodeBuild spec for CI/CD
├── docker-compose.yml              # For local multi-container testing
└── README.md
```

---

## 🚀 Deployment Flow

1. **Build & Push Docker Images**
   - YOLO and depth Flask apps
   - React frontend
   - Push to Amazon ECR

2. **Terraform Infrastructure Setup**
   - Run `terraform apply` from `mlops-deployment/` to provision:
     - VPC, subnets, security groups
     - ECS cluster and task definitions
     - ALB and target groups with listener rules
     - S3 bucket for config

3. **Application Access**
   - React app runs on root `/`
   - YOLOv5 app is routed via `/yolo/*`
   - Depth estimation is routed via `/depth/*`

4. **CI/CD**
   - AWS CodeBuild automates image building and pushing

---

## 📦 APIs

| Endpoint                    | Method | Description                      |
|----------------------------|--------|----------------------------------|
| `/yolo/health`             | GET    | YOLOv5 health check              |
| `/yolo/detect`             | POST   | Runs object detection            |
| `/depth/health`            | GET    | Depth API health check           |
| `/depth/predict_depth`     | POST   | Performs depth estimation        |

---

## ✅ Health Check Verification

You can verify that your services are running by curling from inside the EC2 instance:

```bash
curl http://localhost:5001/yolo/health
curl http://localhost:5050/depth/health
```

---

## 🔧 Local DockerHub Build & Push

```bash
# Build and push object-detection-react-app
cd object-detection-react-app
docker build . -t ashutoxh/object-detection-react-app
docker push ashutoxh/object-detection-react-app

# Build and push yolo-v5-flask-app
cd ../yolo-v5-flask-app
docker build . -t ashutoxh/yolo-v5-flask-app
docker push ashutoxh/yolo-v5-flask-app

# Build and push depth-anything-flask-app
cd ../depth-anything-flask-app
docker build . -t ashutoxh/depth-anything-flask-app
docker push ashutoxh/depth-anything-flask-app
```

---

## 🧪 Development Build (AWS ECR)

### ✅ Login to AWS ECR

```bash
aws ecr get-login-password --region us-east-1 \
| docker login --username AWS \
--password-stdin <AWSID>.dkr.ecr.us-east-1.amazonaws.com
```

### 🐳 Build dev images

```bash
docker build -f depth-anything-flask-app/Dockerfile \
  -t <AWSID>.dkr.ecr.us-east-1.amazonaws.com/mlops/depth-anything-flask-app:dev \
  ./depth-anything-flask-app

docker build -f object-detection-react-app/Dockerfile \
  -t <AWSID>.dkr.ecr.us-east-1.amazonaws.com/mlops/object-detection-react-app:dev \
  ./object-detection-react-app

docker build -f yolo-v5-flask-app/Dockerfile \
  -t <AWSID>.dkr.ecr.us-east-1.amazonaws.com/mlops/yolo-v5-flask-app:dev \
  ./yolo-v5-flask-app
```

### 📤 Push dev images

```bash
docker push <AWSID>.dkr.ecr.us-east-1.amazonaws.com/mlops/depth-anything-flask-app:dev
docker push <AWSID>.dkr.ecr.us-east-1.amazonaws.com/mlops/object-detection-react-app:dev
docker push <AWSID>.dkr.ecr.us-east-1.amazonaws.com/mlops/yolo-v5-flask-app:dev
```

---

## 🚀 Production Build & Push (AWS ECR)

> Make sure `$AWS_ACCOUNT_ID` and `$AWS_REGION` are exported in your environment.

```bash
docker build -f depth-anything-flask-app/Dockerfile \
  -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/mlops/depth-anything-flask-app:prod \
  ./depth-anything-flask-app

docker build -f object-detection-react-app/Dockerfile \
  -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/mlops/object-detection-react-app:prod \
  ./object-detection-react-app

docker build -f yolo-v5-flask-app/Dockerfile \
  -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/mlops/yolo-v5-flask-app:prod \
  ./yolo-v5-flask-app
```

```bash
# Push the prod images
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/mlops/depth-anything-flask-app:prod
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/mlops/object-detection-react-app:prod
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/mlops/yolo-v5-flask-app:prod
```

---

## ⚠️ Notes

- `yolo-v5-flask-app` required changing `127.0.0.1` to `0.0.0.0` in app code to allow Docker network access.
- AWS CodeBuild timeout was increased from **10 minutes** to **30 minutes** to support large image builds.
- The ALB listener rules forward to the appropriate target groups based on `/yolo/*` or `/depth/*` path pattern.

---
