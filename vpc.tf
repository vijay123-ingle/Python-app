resource "aws_vpc" "my-new-vpc" {
    cidr_block = var.vpc_cidr

    tags = {
      name = "my-new-vpc"
    }
  
}

resource "aws_subnet" "my-public-subnet" {
    vpc_id = aws_vpc.my-new-vpc.id
    cidr_block = var.public_subnet_cidr_block
    availability_zone = var.public_availability_zone
    map_public_ip_on_launch = true
    

    tags = {
      name = "public-subnet"
    }
  
}

resource "aws_subnet" "my-private-subnet" {
    vpc_id = aws_vpc.my-new-vpc.id
    cidr_block = var.private_subnet_cidr_block
    availability_zone = var.private_availability_zone

    tags = {
      name = "private-subnet"
    }
  
}

resource "aws_internet_gateway" "my-internet-gateway" {
    vpc_id = aws_vpc.my-new-vpc.id
    
    tags = {
        name = "internet-gateway"
    }
  
}
resource "aws_route_table" "public-route-table" {
    vpc_id = aws_vpc.my-new-vpc.id

    tags = {
        name = "route-table"
    }
  
}
resource "aws_route" "internet_access" {
     route_table_id = aws_route_table.public-route-table.id
     destination_cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.my-internet-gateway.id

  
}
resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.my-public-subnet.id
    route_table_id = aws_route_table.public-route-table.id  
}

resource "aws_security_group" "my-sg" {
    vpc_id = aws_vpc.my-new-vpc.id

    ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
      name = "my-security-group"
    }
  
}

resource "aws_ecr_repository" "app" {
    name = "python-app"
  
}

resource "aws_ecs_cluster" "app" {
    name = "python-app-cluster"
  
}

resource "aws_ecs_task_definition" "app" {
  family = "service"
  requires_compatibilities = [ "EC2" ]
  network_mode = "bridge"
  container_definitions = jsonencode([
    {
      name      = "python-app"
      image     = "${aws_ecr_repository.app.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ]
  )
}

resource "aws_ecs_service" "mongo" {
  name            = "python-app-service"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type = "EC2"
  network_configuration {
    subnets = [aws_subnet.my-public-subnet.id]
    security_groups = [aws_security_group.my-sg.id]
  }
}
    


# resource "aws_instance" "my-instance" {
#     ami = var.aws_instance_ami
#     instance_type = var.my_instance_type
#     subnet_id = aws_subnet.my-public-subnet.id
#     vpc_security_group_ids =[aws_security_group.my-sg.id]
#     associate_public_ip_address = true

#     tags = {
#       name = "Jenkins-instance"
#     }

#     user_data = <<-EOF
#               #!/bin/bash
#               sudo yum update -y
#               sudo yum install -y java-1.8.0-openjdk
#               sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
#               sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
#               sudo yum install -y jenkins
#               sudo systemctl start jenkins
#               sudo systemctl enable jenkins
#               EOF
  
# }