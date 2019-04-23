provider "aws" {
  version = "~> 2.0"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ami" {
  filter {
    name   = "name"
    values = ["*ubuntu-xenial-16.04-amd64-server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  most_recent = true
  owners      = ["aws-marketplace"]
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048

  count = "${var.create_key_pair ? 1 : 0}"
}

resource "aws_key_pair" "key_pair" {
  public_key = "${join("", tls_private_key.private_key.*.public_key_openssh)}"

  count = "${var.create_key_pair ? 1 : 0}"
}

module "allow_ssh" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "2.16.0"

  create              = "${var.allow_ssh}"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  name                = "SSH"
  vpc_id              = "${local.vpc_id}"
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "2.9.1"

  associate_public_ip_address = "${var.associate_public_ip_address}"
  desired_capacity            = "${local.desired_capacity}"
  health_check_type           = "${var.health_check_type}"
  image_id                    = "${data.aws_ami.ami.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${local.key_name}"
  max_size                    = "${var.max_size}"
  min_size                    = "${var.min_size}"
  name                        = "${var.autoscaling_group_name}"

  security_groups = [
    "${module.allow_ssh.this_security_group_id}",
  ]

  user_data           = "${file("${path.module}/templates/user-data.txt.tpl")}"
  vpc_zone_identifier = "${local.vpc_zone_identifier}"
}

module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "1.21.0"

  ami                         = "${data.aws_ami.ami.id}"
  associate_public_ip_address = true
  instance_count              = "${var.enable_bastion ? 1 : 0}"
  instance_type               = "t2.micro"
  key_name                    = "${local.key_name}"
  name                        = "${format("%s-bastion", var.autoscaling_group_name)}"
  subnet_ids                  = ["${module.vpc.public_subnets}"]

  vpc_security_group_ids = [
    "${module.allow_ssh.this_security_group_id}",
  ]
}

resource "null_resource" "bastion" {
  connection {
    host        = "${module.bastion.public_dns}"
    private_key = "${local.private_key}"
    user        = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = ["chmod 0600 ~/.ssh/id_rsa"]

    on_failure = "continue"
  }

  provisioner "file" {
    content     = "${local.private_key}"
    destination = "~/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = ["chmod 0400 ~/.ssh/id_rsa"]
  }

  count = "${var.enable_bastion ? 1 : 0}"
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
