# MLOps Final Project: End-to-End Image Analysis Pipeline on AWS

## Overview

This project deploys a full-stack machine learning pipeline on AWS using Flask (for YOLOv5 and depth estimation), React (frontend), and Terraform (for infrastructure automation). The pipeline is built for object detection and depth prediction in images uploaded through a web interface.

---

## 📁 Project Structure

```
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

## 🔐 Note

The ALB listener rules forward to the appropriate target groups based on `/yolo/*` or `/depth/*` path pattern.

---