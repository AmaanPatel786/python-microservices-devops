#!/bin/bash
set -e

# Update packages and install Docker
dnf update -y
dnf install -y docker docker-compose-plugin
systemctl enable --now docker

# Allow ec2-user to run docker
usermod -aG docker ec2-user || true

# Create app directory
mkdir -p /opt/app && cd /opt/app

# Write docker-compose.yml
cat > docker-compose.yml <<YAML
services:
  frontend:
    image: ${dockerhub_username}/python-microservices-frontend:${frontend_tag}
    ports: ["80:80"]
    environment:
      BACKEND_URL: http://backend:5000/api/data
    depends_on:
      - backend

  backend:
    image: ${dockerhub_username}/python-microservices-backend:${backend_tag}
    ports: ["5000:5000"]
    environment:
      DB_HOST: db
      DB_PORT: "3306"
      DB_NAME: appdb
      DB_USER: appuser
      DB_PASSWORD: apppassword
      LOGGER_URL: http://logger:9000/log
    depends_on:
      - db
      - logger

  logger:
    image: ${dockerhub_username}/python-microservices-logger:${logger_tag}
    ports: ["9000:9000"]
    volumes:
      - logs:/logs

  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: appdb
      MYSQL_USER: appuser
      MYSQL_PASSWORD: apppassword
      MYSQL_ROOT_PASSWORD: rootpassword
    volumes:
      - mysqldata:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 5s
      timeout: 3s
      retries: 20

volumes:
  mysqldata:
  logs:
YAML

# Start services
docker compose up -d
