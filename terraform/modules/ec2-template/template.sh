#!/bin/bash

#Log all output
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1
set -euxo pipefail

REGION="eu-central-1"

#########################################
# Update system
#########################################

apt-get update -y
apt-get upgrade -y

#########################################
# Install AWS CLI (if missing)
#########################################

if ! command -v aws >/dev/null 2>&1; then
    apt-get install -y unzip curl
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
    unzip -q awscliv2.zip
    ./aws/install
fi


######################################################
# Fetch values from SSM Parameter Store at boot
######################################################
DB_HOST=$(aws ssm get-parameter --name "/fittrack/staging/db_host" --query "Parameter.Value" --output text --region eu-central-1)
DB_SECRET_ARN=$(aws ssm get-parameter --name "/fittrack/staging/db_secret_arn" --query "Parameter.Value" --output text --region eu-central-1)
S3_BUCKET=$(aws ssm get-parameter --name "/fittrack/staging/media_bucket" --query "Parameter.Value" --output text --region eu-central-1)
ECR_REGISTRY=$(aws ssm get-parameter --name "/fittrack/staging/ecr_registry" --query "Parameter.Value" --output text --region eu-central-1)
REPO_NAME=$(aws ssm get-parameter --name "/fittrack/staging/backend_repo_name" --query "Parameter.Value" --output text --region eu-central-1)
FRONTEND_BUCKET=$(aws ssm get-parameter --name "/fittrack/staging/frontend_bucket" --query "Parameter.Value" --output text --region eu-central-1)


############################################
# Install Docker
###############################################
if ! command -v docker >/dev/null 2>&1; then

    apt-get install -y ca-certificates curl gnupg

    install -m 0755 -d /etc/apt/keyrings

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      | tee /etc/apt/sources.list.d/docker.list >/dev/null

    apt-get update -y

    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

fi
# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -a -G docker ubuntu


#!/bin/bash

# Log all output
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1
set -euxo pipefail

REGION="eu-central-1"

#########################################
# Update system
#########################################

apt-get update -y
apt-get upgrade -y

#########################################
# Install AWS CLI (if missing)
#########################################

if ! command -v aws >/dev/null 2>&1; then
    apt-get install -y unzip curl
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
    unzip -q awscliv2.zip
    ./aws/install
fi

#########################################
# Fetch SSM Parameters
#########################################

DB_HOST=$(aws ssm get-parameter --name "/fittrack/staging/db_host" --query "Parameter.Value" --output text --region "$REGION")
DB_SECRET_ARN=$(aws ssm get-parameter --name "/fittrack/staging/db_secret_arn" --query "Parameter.Value" --output text --region "$REGION")
S3_BUCKET=$(aws ssm get-parameter --name "/fittrack/staging/media_bucket" --query "Parameter.Value" --output text --region "$REGION")
ECR_REGISTRY=$(aws ssm get-parameter --name "/fittrack/staging/ecr_registry" --query "Parameter.Value" --output text --region "$REGION")
REPO_NAME=$(aws ssm get-parameter --name "/fittrack/staging/backend_repo_name" --query "Parameter.Value" --output text --region "$REGION")
FRONTEND_BUCKET=$(aws ssm get-parameter --name "/fittrack/staging/frontend_bucket" --query "Parameter.Value" --output text --region "$REGION")

#########################################
# Install Docker (if missing)
#########################################

if ! command -v docker >/dev/null 2>&1; then

    apt-get install -y ca-certificates curl gnupg

    install -m 0755 -d /etc/apt/keyrings

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      | tee /etc/apt/sources.list.d/docker.list >/dev/null

    apt-get update -y

    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

fi

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

#########################################
# Install SSM Agent
#########################################

if ! systemctl list-unit-files | grep -q amazon-ssm-agent; then
    snap install amazon-ssm-agent --classic
fi

systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent

#########################################
# Install CloudWatch Agent
#########################################

if ! dpkg -l | grep -q amazon-cloudwatch-agent; then
    wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    dpkg -i amazon-cloudwatch-agent.deb
fi

systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent


#########################################
# Install Nginx (if missing)
#########################################

if ! command -v nginx >/dev/null 2>&1; then
    apt-get install -y nginx
fi



# Create Nginx config directly (no file copy needed)
cat > /etc/nginx/sites-available/default << 'NGINXCONF'
server {
    listen 80;

    # Serve React frontend
    location / {
        root /var/www/html;
        try_files $uri $uri/ /index.html;
    }

    # Proxy API calls to FastAPI
    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    location /health {
        proxy_pass http://localhost:8000/health;
    }
}
NGINXCONF

# Create web root for React frontend
mkdir -p /var/www/html
chown -R ubuntu:ubuntu /var/www/html

# Remove default symlink and create new one
ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default


sudo systemctl restart nginx
sudo systemctl enable nginx


#########################################
# Sync Frontend
#########################################

aws s3 sync "s3://$FRONTEND_BUCKET/" /var/www/html/ --delete



#########################################
# Deploy Backend
#########################################

aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin $ECR_REGISTRY

docker pull "$ECR_REGISTRY/$REPO_NAME:latest"

docker stop fittrack-backend || true
docker rm fittrack-backend || true

docker run -d \
  --name fittrack-backend \
  --restart always \
  -p 8000:8000 \
  -e DB_HOST=$DB_HOST \
  -e DB_SECRET_ARN=$DB_SECRET_ARN \
  -e S3_BUCKET_NAME=$S3_BUCKET \
  -e DB_PORT=5432 \
  -e DB_NAME=fittrack \
  -e AWS_REGION=eu-central-1 \
  $ECR_REGISTRY/$REPO_NAME:latest
  # Restart Nginx to serve files
systemctl restart nginx