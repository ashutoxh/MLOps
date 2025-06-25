variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "m4.large"
}

variable "min_size" {
  description = "Minimum number of EC2 instances"
  default     = 3
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  default     = 4
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances"
  default     = 2
}

variable "container_images" {
  description = "Container images from ECR"
  type = map(string)
  default = {
    react = "680604704378.dkr.ecr.us-east-1.amazonaws.com/mlops/object-detection-react-app:prod"
    yolo  = "680604704378.dkr.ecr.us-east-1.amazonaws.com/mlops/yolo-v5-flask-app:prod"
    depth = "680604704378.dkr.ecr.us-east-1.amazonaws.com/mlops/depth-anything-flask-app:prod"
  }
}