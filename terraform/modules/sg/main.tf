########################### Create Security Group ###########################
resource "aws_security_group" "alb_sg" {
  name        = "${var.environment_name}-alb-sg"
  description = "Security group for the ALB"
  vpc_id      = var.vpc_id 

    ingress {
        description      = "Allow HTTP traffic"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }
    
    egress {
        description      = "Allow all outbound traffic"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
}



resource "aws_security_group" "backend_sg" {
    name        = "${var.environment_name}-backend-sg"
    description = "Security group for the backend servers"
    vpc_id      = var.vpc_id

    ingress {
        description      = "Allow traffic from frontend servers"
        from_port        = 8000
        to_port          = 8000
        protocol         = "tcp"
        security_groups  = [aws_security_group.frontend_sg.id]
    }

    egress {
        description      = "Allow all outbound traffic"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
}



resource "aws_security_group" "database_sg" {
    name = "${var.environment_name}-database-sg"
    description = "Security group for the database servers"
    vpc_id      = var.vpc_id

    ingress {
        description      = "Allow traffic from backend servers"
        from_port        = 5432
        to_port          = 5432
        protocol         = "tcp"
        security_groups  = [aws_security_group.backend_sg.id]
    }

    egress {
        description      = "Allow all outbound traffic"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
}