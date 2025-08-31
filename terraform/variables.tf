variable "region" { type = string, default = "ap-south-1" }
variable "instance_type" { type = string, default = "t3.micro" }
variable "key_name" { type = string, default = null }
variable "dockerhub_username" { type = string }
variable "backend_tag" { type = string, default = "latest" }
variable "frontend_tag" { type = string, default = "latest" }
variable "logger_tag" { type = string, default = "latest" }
