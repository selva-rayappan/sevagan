#!/bin/bash

# Sevagan AWS Deployment Script
# This script deploys the Sevagan platform to AWS

set -e

echo "🚀 Starting Sevagan deployment to AWS..."

# Configuration
APP_NAME="sevagan"
REGION="${AWS_REGION:-us-east-1}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t3.medium}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"
command -v aws >/dev/null 2>&1 || { echo "AWS CLI is required but not installed. Aborting." >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "Docker is required but not installed. Aborting." >&2; exit 1; }

# Build Docker images
echo -e "${BLUE}Building Docker images...${NC}"
cd backend && docker build -t $APP_NAME-backend:latest .
cd ../admin-panel && docker build -t $APP_NAME-admin:latest -f Dockerfile.prod .

# Tag and push to ECR (if configured)
if [ ! -z "$ECR_REPOSITORY" ]; then
    echo -e "${BLUE}Pushing images to ECR...${NC}"
    aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY
    docker tag $APP_NAME-backend:latest $ECR_REPOSITORY/$APP_NAME-backend:latest
    docker tag $APP_NAME-admin:latest $ECR_REPOSITORY/$APP_NAME-admin:latest
    docker push $ECR_REPOSITORY/$APP_NAME-backend:latest
    docker push $ECR_REPOSITORY/$APP_NAME-admin:latest
fi

echo -e "${GREEN}✅ Deployment preparation complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Configure RDS PostgreSQL database"
echo "2. Configure ElastiCache Redis"
echo "3. Configure S3 bucket for file uploads"
echo "4. Update environment variables on EC2 instance"
echo "5. Run docker-compose on EC2 instance"
echo ""
echo "For detailed instructions, see docs/DEPLOYMENT.md"
