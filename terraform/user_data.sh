#!/bin/bash
set -e

dnf update -y
dnf install -y docker docker-compose-plugin
systemctl enable --now docker

usermod -aG docker ec2-user || true

mkdir -p /opt/app && cd /opt/app

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
      DB_PORT: "5432"
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
    image: postgres:15
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: apppassword
    volumes:
      - pgdata:/var/lib/postgresql/data
volumes:
  pgdata:
  logs:
YAML

docker compose up -d
