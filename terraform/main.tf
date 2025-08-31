data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "svc" {
  name        = "devops-assignment-sg"
  description = "Allow HTTP/8080/5000/9000 and SSH"
  ingress = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      self = false
      prefix_list_ids = null
      security_groups = null
    },
    {
      description = "Frontend 8080"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      self = false
      prefix_list_ids = null
      security_groups = null
    },
    {
      description = "Backend 5000"
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      self = false
      prefix_list_ids = null
      security_groups = null
    },
    {
      description = "Logger 9000"
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      self = false
      prefix_list_ids = null
      security_groups = null
    },
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      self = false
      prefix_list_ids = null
      security_groups = null
    }
  ]
  egress = [{
    description = "all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    self = false
    prefix_list_ids = null
    security_groups = null
  }]
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.svc.id]
  user_data                   = templatefile("${path.module}/user_data.sh", {
    dockerhub_username = var.dockerhub_username,
    backend_tag        = var.backend_tag,
    frontend_tag       = var.frontend_tag,
    logger_tag         = var.logger_tag
  })

  tags = {
    Name = "devops-assignment-app"
  }
}

output "public_ip" {
  value = aws_instance.app.public_ip
}

output "public_dns" {
  value = aws_instance.app.public_dns
}
