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
variable "allow_ssh" {
  default     = false
  description = "Whether the user can use SSH"
}

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

variable "enable_bastion" {
  default     = false
  description = "Create the bastion host"
}

variable "enable_logging" {
  default     = true
  description = "Enable CloudWatch Logs"
}

variable "health_check_type" {
  default     = "EC2"
  description = "The service to use for the health checks"
}

variable "create_key_pair" {
  default     = false
  description = "Creates a 2048-bit RSA key pair with the specified name"
}

variable "instance_type" {
  description = "The instance type of the EC2 instance"
}

variable "key_name" {
  default     = ""
  description = "The name of the key pair"
}

variable "max_size" {
  description = "The maximum size of the group"
}

variable "min_size" {
  description = "The minimum size of the group"
}

variable "vpc_id" {
  default     = ""
  description = "The ID of the VPC"
}

variable "vpc_zone_identifier" {
  default     = []
  description = "A comma-separated list of subnet IDs for your virtual private cloud (VPC)"
  type        = "list"
}

# Application Load Balancer Variables
variable "subnets" {
  default     = []
  description = "The IDs of the public subnets"
  type        = "list"
}

# Relational Database Service Variables
variable "allocated_storage" {
  default     = 20
  description = "The amount of storage (in gibibytes) to allocate for the DB instance"
}

variable "backup_retention_period" {
  default     = 1
  description = "The number of days for which automated backups are retained. Setting this parameter to a positive number enables backups. Setting this parameter to 0 disables automated backups"
}

variable "db_instance_class" {
  description = "The compute and memory capacity of the DB instance"
}

variable "db_parameter_group_family" {
  default     = "mysql5.7"
  description = "The DB parameter group family name"
}

variable "engine" {
  default     = "mysql"
  description = "The name of the database engine to be used for this instance"
}

variable "engine_version" {
  default     = "5.7.25"
  description = "The version number of the database engine to use"
}

variable "major_engine_version" {
  default     = "5.7"
  description = "Specifies the major version of the engine that this option group should be associated with"
}

variable "master_user_password" {
  default     = ""
  description = "The password for the master user"
}

variable "port" {
  default     = 3306
  description = "The port number on which the database accepts connections"
}

variable "preferred_maintenance_window" {
  default     = ""
  description = "The time range each week during which system maintenance can occur, in Universal Coordinated Time (UTC)"
}
