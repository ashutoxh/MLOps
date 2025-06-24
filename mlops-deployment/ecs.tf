resource "aws_ecs_cluster" "mlops_cluster" {
  name = "mlops-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_capacity_provider" "mlops_capacity_provider" {
  name = "mlops-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.mlops_asg.arn
  }
}

resource "aws_ecs_cluster_capacity_providers" "mlops_cluster_providers" {
  cluster_name = aws_ecs_cluster.mlops_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.mlops_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.mlops_capacity_provider.name
  }
}

resource "aws_launch_template" "mlops_launch_template" {
  name_prefix   = "mlops-ecs-"
  image_id      = var.ecs_ami
  instance_type = var.instance_type
  key_name      = "key-devops-class"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ecs_instance_sg.id]
    delete_on_termination       = true
  }

  vpc_security_group_ids = [aws_security_group.ecs_instance_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.mlops_cluster.name} >> /etc/ecs/ecs.config
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "mlops_asg" {
  name_prefix         = "mlops-asg-"
  max_size            = var.max_size
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = aws_subnet.mlops_subnets[*].id
  health_check_type   = "EC2"
  launch_template {
    id      = aws_launch_template.mlops_launch_template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "mlops-ecs-instance"
    propagate_at_launch = true
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "react_log_group" {
  name = "/ecs/react-app"
}

resource "aws_cloudwatch_log_group" "yolo_log_group" {
  name = "/ecs/yolo-app"
}

resource "aws_cloudwatch_log_group" "depth_log_group" {
  name = "/ecs/depth-app"
}
