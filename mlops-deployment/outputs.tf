output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.mlops_alb.dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.mlops_cluster.name
}

output "react_service_url" {
  description = "URL for the React frontend"
  value       = "http://${aws_lb.mlops_alb.dns_name}"
}

output "yolo_service_url" {
  description = "URL for the YOLO backend"
  value       = "http://${aws_lb.mlops_alb.dns_name}/yolo"
}

output "depth_service_url" {
  description = "URL for the Depth backend"
  value       = "http://${aws_lb.mlops_alb.dns_name}/depth"
}

output "ecs_instance_security_group_id" {
  description = "ECS Instance Security Group ID"
  value       = aws_security_group.mlops_sg.id
}

output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.mlops_sg.id
}