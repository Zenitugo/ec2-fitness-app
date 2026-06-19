############### Creation of application load balancer ###############
resource "aws_lb" "fittrack_load_balancer" {
    name = "${var.environment_name}-fittrack-app-alb"
    internal = false
    security_groups = [var.alb_sg]
    subnets = [var.public_subnet_1_id, var.public_subnet_2_id]
    enable_deletion_protection = false
    load_balancer_type = "application"
    
}


################## Create a Target Group for the ALB ######################
resource "aws_lb_target_group" "fittrack_app_target_group" {
    name = "${var.environment_name}-fittrack-app-tg"
    port = 8000
    protocol = "HTTP"
    vpc_id = var.vpc_id
    target_type = "instance"
    
    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 5
        interval = 30
        path = "/health"
        protocol = "HTTP"
    }
}


###################### Create a Listener for the ALB ######################
resource "aws_lb_listener" "fittrack_app_listener" {
    load_balancer_arn = aws_lb.fittrack_load_balancer.arn
    port = 80
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.fittrack_app_target_group.arn
    }
}