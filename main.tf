provider "aws" {
  version = "~> 2.0"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ami" {
  filter {
    name   = "name"
    values = ["*ubuntu-bionic-18.04-amd64-server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  most_recent = true
  owners      = ["aws-marketplace"]
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "2.9.1"

  associate_public_ip_address = "${var.associate_public_ip_address}"
  desired_capacity            = "${local.desired_capacity}"
  health_check_type           = "${var.health_check_type}"
  image_id                    = "${data.aws_ami.ami.id}"
  instance_type               = "${var.instance_type}"
  max_size                    = "${var.max_size}"
  min_size                    = "${var.min_size}"
  name                        = "${var.autoscaling_group_name}"
  vpc_zone_identifier         = "${local.vpc_zone_identifier}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.60.0"

  azs                     = ["${data.aws_availability_zones.available.names}"]
  cidr                    = "${var.cidr_block}"
  create_vpc              = "${var.create_vpc}"
  enable_dns_hostnames    = "${var.enable_dns_hostnames}"
  enable_nat_gateway      = "${var.create_nat_gateway}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
  name                    = "${var.autoscaling_group_name}"

  private_subnets = [
    "${cidrsubnet(var.cidr_block, 8, 2)}",
    "${cidrsubnet(var.cidr_block, 8, 3)}",
  ]

  public_subnets = [
    "${cidrsubnet(var.cidr_block, 8, 4)}",
    "${cidrsubnet(var.cidr_block, 8, 5)}",
  ]
}
