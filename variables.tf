# Virtual Private Cloud Variables
variable "enable_dns_hostnames" {
  default     = true
  description = "Indicates whether the instances launched in the VPC get DNS hostnames"
}

variable "cidr_block" {
  description = "The IPv4 network range for the VPC, in CIDR notation"
}

variable "create_nat_gateway" {
  default     = true
  description = "Creates a NAT gateway in the specified public subnet"
}

variable "create_vpc" {
  default     = true
  description = "Creates a VPC with the specified IPv4 CIDR block"
}

variable "map_public_ip_on_launch" {
  default     = false
  description = "Indicates whether instances launched in this subnet receive a public IPv4 address"
}

# Auto Scaling Group Variables
variable "autoscaling_group_name" {
  default     = "artifactory"
  description = "The name of the Auto Scaling group"
}

variable "associate_public_ip_address" {
  default     = false
  description = "Specifies whether to assign a public IP address to each instance"
}

variable "desired_capacity" {
  default     = ""
  description = "The number of EC2 instances that should be running in the group"
}

variable "health_check_type" {
  default     = "EC2"
  description = "The service to use for the health checks"
}

variable "instance_type" {
  description = "The instance type of the EC2 instance"
}

variable "max_size" {
  description = "The maximum size of the group"
}

variable "min_size" {
  description = "The minimum size of the group"
}

variable "vpc_zone_identifier" {
  default     = []
  description = "A comma-separated list of subnet IDs for your virtual private cloud (VPC)"
  type        = "list"
}
