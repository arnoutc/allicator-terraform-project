provider aws {
  region                  = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket                  = "allicator-tf-state"
    key                     = "dev/services/webserver-cluster/terraform.tfstate"
    region                  = "eu-west-2"
    use_lockfile            = true
    encrypt                 = true
    dynamodb_table = "allicator-tf-locks"
  }
}

data "aws_vpc" "default" {
  default                 = true
}

data "aws_subnets" "default" {
  filter {
    name                  = "vpc-id"
    values                = [data.aws_vpc.default.id]
  }
}

# Use SSM (best practice) to always get latest AL2023 x86_64
data "aws_ssm_parameter" "al2023_x86" {
  name                    = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_launch_template" "test-spot-ec2-lt" {
  name_prefix = "test-spot-ec2-tl-"
  image_id                = data.aws_ssm_parameter.al2023_x86.value
  instance_type           = "t3.micro"

  vpc_security_group_ids  = [aws_security_group.test-spot-sg.id]
  user_data               = filebase64("user_data.sh")

  # Required when using a launch configuration with an auto scaling group.associate_public_ip_address = lifecycle {
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "test-spot-asg" {
  launch_template {
    id                  = aws_launch_template.test-spot-ec2-lt.id
    version             = "$Latest"
  }
  
  vpc_zone_identifier   = data.aws_subnets.default.ids
  target_group_arns     = [aws_lb_target_group.test-spot-tg.arn]
  health_check_type     = "ELB"
  min_size              = 2
  max_size              = 10

  tag {
    key                 = "Name"
    value               = "test-spot-asg"
    propagate_at_launch = true
  }
}

resource "aws_lb" "test-spot-lb" {
  name                 = "test-spot-lb"
  load_balancer_type   = "application"
  subnets              = data.aws_subnets.default.ids
  security_groups      = [aws_security_group.test-spot-sg-alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn    = aws_lb.test-spot-lb.arn
  port                 = 80
  protocol             = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type               = "fixed-response"

    fixed_response {
      content_type     = "text/plain"
      message_body     = "404: page not found"
      status_code      = 404
    }
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.test-spot-tg.arn
  }
}

resource "aws_security_group" "test-spot-sg-alb" {
  name                 = "test-spot-sg-alb"

  # Allow inbound HTTP requests
  ingress {
    from_port          = var.server_port
    to_port            = var.server_port
    protocol           = "tcp"
    cidr_blocks        = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port          = 0
    to_port            = 0
    protocol           = "-1"
    cidr_blocks        = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "test-spot-tg" {
  name                 = "test-spot-tg"
  port                 = var.server_port
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.default.id

  health_check {
    path               = "/"
    protocol           = "HTTP"
    matcher            = "200"
    interval           = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


resource "aws_security_group" "test-spot-sg" {
  name                  = "test-spot-sg"
}

resource "aws_vpc_security_group_ingress_rule" "web-server" {
  security_group_id     = aws_security_group.test-spot-sg.id

  cidr_ipv4             = "0.0.0.0/0"
  from_port             = var.server_port
  ip_protocol           = "tcp"
  to_port               = var.server_port
}

resource "aws_vpc_security_group_ingress_rule" "web-server-tls" {
  security_group_id     = aws_security_group.test-spot-sg.id

  cidr_ipv4             = "0.0.0.0/0"
  from_port             = var.server_tls_port
  ip_protocol           = "tcp"
  to_port               = var.server_tls_port
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id     = aws_security_group.test-spot-sg.id

  cidr_ipv4             = "0.0.0.0/0"
  from_port             = var.server_ssh_port
  ip_protocol           = "tcp"
  to_port               = var.server_ssh_port
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id     = aws_security_group.test-spot-sg.id
  cidr_ipv4             = "0.0.0.0/0"
  from_port             = 0
  ip_protocol           = "-1"
  to_port               = 0
}

# Replaced by aws_launch_configuration to create a group of web-servers

# resource "aws_instance" "test-spot-ec2-instance" {
#   ami                    = data.aws_ssm_parameter.al2023_x86.value
#   vpc_security_group_ids = [aws_security_group.test-spot-sg.id]
#   instance_market_options {
#     market_type          = "spot"
#     spot_options {
#       max_price          = 0.031
#     }
#   }

#   instance_type          = "t3.micro"

#   user_data = <<-EOF
#               #!/bin/bash
#               set -euxo pipefail

#               # Update packages (AL2023 uses dnf)
#               dnf upgrade -y

#               # Install Apache (httpd) and start it
#               dnf install -y httpd

#               # Enable and start the service
#               systemctl enable --now httpd

#               # Create a simple test page
#               cat >/var/www/html/index.html <<'HTML'
#               <html lang="en">
#               <head>
#                 <meta charset="utf-8" />
#                 <title>It works! (AL2023 + Apache)</title>
#               </head>
#               <body>
#                 <h1>Amazon Linux 2023 + Apache httpd</h1>
#                 <p>Provisioned via EC2 user_data.</p>
#               </body>
#               </html>
#               HTML

#               # Optional: tighten default permissions for /var/www
#               usermod -a -G apache ec2-user || true
#               chown -R ec-user:apache /var/www
#               chmod 2775 /var/www
#               find /var/www -type d -exec chmod 2775 {} \;
#               find /var/www -type f -exec chmod 0664 {} \;
#               EOF
  
#   user_data_replace_on_change = true

#   tags = {
#     Name                      = "test-spot-ec2-instance"
#   }
# }