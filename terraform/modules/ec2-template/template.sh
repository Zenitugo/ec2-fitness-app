#!/bin/bash
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

# Copy Nginx config file to the correct location
cp ./terraform/modules/ec2-template/nginx.conf /etc/nginx/sites-available/default

# Remove default symlink and create new one
ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default


sudo systemctl restart nginx
sudo systemctl enable nginx