resource "aws_lb" "mlops_alb" {
  name               = "mlops-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.mlops_subnets[*].id

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "react_tg" {
  name        = "react-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.mlops_vpc.id
  target_type = "instance"

  health_check {
    path                = "/healthcheck.txt" 
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}


resource "aws_lb_target_group" "yolo_tg" {
  name        = "yolo-tg"
  port        = 5001
  protocol    = "HTTP"
  vpc_id      = aws_vpc.mlops_vpc.id
  target_type = "instance"
  health_check {
    path                = "/yolo/health"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "depth_tg" {
  name        = "depth-tg"
  port        = 5050
  protocol    = "HTTP"
  vpc_id      = aws_vpc.mlops_vpc.id
  target_type = "instance"
  health_check {
    path                = "/depth/health"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "mlops_listener" {
  load_balancer_arn = aws_lb.mlops_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.react_tg.arn
  }
}

resource "aws_lb_listener_rule" "yolo_rule" {
  listener_arn = aws_lb_listener.mlops_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.yolo_tg.arn
  }

  condition {
    path_pattern {
      values = ["/yolo/*"]
    }
  }
}

resource "aws_lb_listener_rule" "depth_rule" {
  listener_arn = aws_lb_listener.mlops_listener.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.depth_tg.arn
  }

  condition {
    path_pattern {
      values = ["/depth/*"]
    }
  }
}