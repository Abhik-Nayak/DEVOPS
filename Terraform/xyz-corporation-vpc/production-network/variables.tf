variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the Production VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "web_subnet_cidr" {
  description = "CIDR block for the web (public) subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app1_subnet_cidr" {
  description = "CIDR block for the app1 (private) subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "app2_subnet_cidr" {
  description = "CIDR block for the app2 (private) subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "dbcache_subnet_cidr" {
  description = "CIDR block for the dbcache (private) subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "db_subnet_cidr" {
  description = "CIDR block for the db (private) subnet"
  type        = string
  default     = "10.0.5.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (Amazon Linux 2 in ap-south-1)"
  type        = string
  default     = "ami-0f58b397bc5c1f2e8"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "06022026"
}
