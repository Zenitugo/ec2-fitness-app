#!/bin/bash


# Fetch values from SSM Parameter Store at boot
DB_HOST=$(aws ssm get-parameter --name "/fittrack/staging/db_host" --query "Parameter.Value" --output text --region eu-central-1)
DB_SECRET_ARN=$(aws ssm get-parameter --name "/fittrack/staging/db_secret_arn" --query "Parameter.Value" --output text --region eu-central-1)
S3_BUCKET=$(aws ssm get-parameter --name "/fittrack/staging/media_bucket" --query "Parameter.Value" --output text --region eu-central-1)
ECR_REGISTRY=$(aws ssm get-parameter --name "/fittrack/staging/ecr_registry" --query "Parameter.Value" --output text --region eu-central-1)
REPO_NAME=$(aws ssm get-parameter --name "/fittrack/staging/backend_repo_name" --query "Parameter.Value" --output text --region eu-central-1)
FRONTEND_BUCKET=$(aws ssm get-parameter --name "/fittrack/staging/frontend_bucket" --query "Parameter.Value" --output text --region eu-central-1)


# Update system
apt-get update -y
apt-get upgrade -y

# Install Docker
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -a -G docker ubuntu

# Install AWS CLI
apt-get install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install SSM agent
snap install amazon-ssm-agent --classic
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb
systemctl start amazon-cloudwatch-agent
systemctl enable amazon-cloudwatch-agent

chown ubuntu:ubuntu /home/ubuntu/docker-compose.yml


# Install Nginx on EC2
sudo apt-get install -y nginx


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


# Add to end of template.sh after Nginx setup

# Pull frontend build from S3
sudo aws s3 sync s3://YOUR_FRONTEND_BUCKET/ /var/www/html/ --delete



# Deploy backend
aws ecr get-login-password --region eu-central-1 | \
  docker login --username AWS --password-stdin $ECR_REGISTRY

docker pull $ECR_REGISTRY/$REPO_NAME:latest

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