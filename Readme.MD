# FitTrack – Full-Stack Fitness Tracking Application on AWS with Terraform

## 📖 Overview
FitTrack is a full-stack fitness tracking application deployed on AWS using **EC2 Auto Scaling, FastAPI, React, Amazon RDS PostgreSQL, and Amazon S3**.

This project was inspired by a technical interview that highlighted a gap in my practical cloud experience. Although I had previously deployed containerised applications to Amazon ECS using the EC2 launch type, I realised I had never designed and deployed an application directly on EC2 with an Auto Scaling Group, nor had I built an application that combined RDS for relational data with S3 for user-generated media.

I challenged myself with a simple question:

```
How would I design, deploy, and automate a production-inspired application that stores structured data in RDS, user-uploaded media in S3, and runs on EC2 instances managed by an Auto Scaling Group?
```

To answer that question, I built FitTrack.

The infrastructure is split into Foundation and Compute Terraform layers, deployed through a five-job GitHub Actions CI/CD pipeline, and includes Infrastructure as Code, automated deployments, monitoring with CloudWatch, configuration management using AWS Systems Manager Parameter Store, and secure secret management with AWS Secrets Manager.

---

## 🚀 Features

- Full stack application with React frontend and FastAPI Python backend
- EC2 Auto Scaling Group with CPU based scaling policies
- Docker containerised backend running on EC2 instances
- Nginx serving React frontend and proxying API requests
- RDS PostgreSQL for structured data storage
- S3 for workout media uploads (images and videos) and frontend static files
- JWT authentication for user registration and login
- SSM Parameter Store for runtime configuration management
- Secrets Manager for database password management
- CloudWatch alarms and metrics for observability
- Infrastructure split into foundation and compute Terraform layers
- Remote state management between Terraform layers using S3
- Five job GitHub Actions CI/CD pipeline with automated deployments via SSM

---

## 🛠 Tech Stack

| Category | Technology |
|---|---|
| Cloud Provider | AWS |
| Infrastructure as Code | Terraform |
| CI/CD | GitHub Actions |
| Backend | FastAPI (Python) |
| Frontend | React + Vite + Tailwind CSS |
| Containerisation | Docker |
| Web Server | Nginx |
| Database | Amazon RDS PostgreSQL |
| File Storage | Amazon S3 |
| Container Registry | Amazon ECR |
| Secrets Management | AWS Secrets Manager |
| Configuration | AWS SSM Parameter Store |
| Instance Access | AWS SSM Session Manager |
| Monitoring | Amazon CloudWatch |
| Auto Scaling | EC2 Auto Scaling Group |
| Load Balancer | Application Load Balancer |

---

## 📂 Repo Structure

```
ec2-fitness-app/
.
├── Readme.MD
├── docs
├── fitness
│   ├── backend
│   │   ├── Dockerfile
│   │   ├── app/
│   │   │   ├── database.py
│   │   │   ├── main.py
│   │   │   ├── models/
│   │   │   ├── routes/
│   │   │   ├── schemas/
│   │   │   └── services/
│   │   └── requirements.txt
│   └── frontend/
└── terraform
    ├── compute/
    ├── foundational/
    └── modules
        ├── alb/
        ├── autoscaling/
        ├── cloudwatch/
        ├── ec2-template/
        ├── ecr/
        ├── iam/
        ├── rds/
        ├── s3/
        ├── sg/
        └── vpc/
```

---

## ⚙️ Setup Instructions

### Prerequisites

```
AWS account with appropriate permissions
Terraform installed (v1.5+)
Docker installed
GitHub repository with the following secrets:
  AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY
  AWS_ACCOUNT_ID
```

### Deploy via GitHub Actions (Recommended)

1. Clone the repository:
```bash
git clone https://github.com/your-username/ec2-fitness-app.git
cd ec2-fitness-app
```

2. Push to master branch to trigger the pipeline:
```bash
git push origin master
```

The pipeline runs five jobs automatically:

```
Job 1: Deploy foundation infrastructure (Terraform)
       → VPC, S3, ECR, IAM, RDS, ALB.

Job 2: Build and push backend Docker image to ECR

Job 3: Deploy compute infrastructure (Terraform)
       → Launch Template, Auto Scaling Group, CloudWatch
```

### Deploy Infrastructure Manually

```bash
### Local Development

```bash
# Backend
cd fitness/backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # fill in your values
uvicorn app.main:app --reload --port 8000

# Frontend
cd fitness/frontend
npm install
cp .env.example .env   # set VITE_API_URL=http://localhost:8000
npm run dev
```

---

## 🏗 Architecture


---


### Stress Test Auto Scaling

```bash
# Install stress on EC2 instance
sudo apt-get install -y stress

# Spike CPU to trigger scale up alarm
stress --cpu 2 --timeout 300
```

Watch CloudWatch alarms fire and a new EC2 instance launch in the Auto Scaling Group.

---

## 🎥 Demo

- [Live Demo Link](#) — add when deployed
- [YouTube Walkthrough](#) — optional

---

## 👤 Author

Ugochi Ukaegbu
AWS Builders Community Programme — Containers Track
