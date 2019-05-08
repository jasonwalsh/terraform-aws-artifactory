provider "aws" {
  version = "~> 2.0"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ami" {
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  most_recent = true
  owners      = ["amazon"]
}

resource "aws_cloudwatch_log_group" "cloudwatch" {
  name = "${var.autoscaling_group_name}"

  count = "${var.enable_logging ? 1 : 0}"
}

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-cloudwatch-agent-configuration-file.html
data "template_file" "cloudwatch" {
  template = "${file("${path.root}/templates/amazon-cloudwatch-agent.json.tpl")}"

  vars = {
    log_group_name = "${
      coalesce(join("", aws_cloudwatch_log_group.cloudwatch.*.name), var.autoscaling_group_name)
    }"

    namespace = "${var.autoscaling_group_name}"
  }
}

data "template_file" "cloudinit_config" {
  template = "${file("${path.root}/templates/user-data.txt.tpl")}"

  vars = {
    start      = "${var.enable_logging ? "-s" : ""}"
    cloudwatch = "${base64encode(data.template_file.cloudwatch.rendered)}"
  }
}

resource "aws_iam_role" "cloudwatch" {
  assume_role_policy = <<EOF
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Sid": ""
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-iam-roles-for-cloudwatch-agent-commandline.html
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = "${aws_iam_role.cloudwatch.name}"
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  role = "${aws_iam_role.cloudwatch.name}"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048

  count = "${var.create_key_pair ? 1 : 0}"
}

resource "local_file" "private_key" {
  filename          = "${path.root}/id_rsa"
  sensitive_content = "${join("", tls_private_key.private_key.*.private_key_pem)}"

  count = "${var.create_key_pair ? 1 : 0}"

  provisioner "local-exec" {
    command = "chmod 0400 ${self.filename}"
  }

  provisioner "local-exec" {
    command = "rm -f ${self.filename}"

    when = "destroy"
  }
}

resource "aws_key_pair" "key_pair" {
  public_key = "${join("", tls_private_key.private_key.*.public_key_openssh)}"

  count = "${var.create_key_pair ? 1 : 0}"
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.5.0"

  http_tcp_listeners        = ["${local.listeners}"]
  http_tcp_listeners_count  = "${length(local.listeners)}"
  load_balancer_is_internal = false
  load_balancer_name        = "${var.autoscaling_group_name}"
  logging_enabled           = false                                     # TODO: true
  security_groups           = ["${module.http.this_security_group_id}"]
  subnets                   = ["${local.subnets}"]
  target_groups             = ["${local.target_groups}"]
  target_groups_count       = "${length(local.target_groups)}"

  target_groups_defaults = {
    health_check_path = "/artifactory/api/system/ping"
  }

  vpc_id = "${local.vpc_id}"
}

module "allow_ssh" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "2.17.0"

  create              = "${var.allow_ssh}"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  name                = "SSH"
  vpc_id              = "${local.vpc_id}"
}

module "artifactory" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.17.0"

  egress_rules = ["all-all"]

  ingress_with_cidr_blocks = [
    {
      cidr_blocks = "0.0.0.0/0"
      from_port   = 8081
      protocol    = "TCP"
      to_port     = 8081
    },
  ]

  name = "${var.autoscaling_group_name}"

  vpc_id = "${local.vpc_id}"
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "2.9.1"

  associate_public_ip_address  = "${var.associate_public_ip_address}"
  desired_capacity             = "${local.desired_capacity}"
  health_check_type            = "${var.health_check_type}"
  iam_instance_profile         = "${aws_iam_instance_profile.iam_instance_profile.name}"
  image_id                     = "${data.aws_ami.ami.id}"
  instance_type                = "${var.instance_type}"
  key_name                     = "${local.key_name}"
  max_size                     = "${var.max_size}"
  min_size                     = "${var.min_size}"
  name                         = "${var.autoscaling_group_name}"
  recreate_asg_when_lc_changes = true

  security_groups = [
    "${module.artifactory.this_security_group_id}",
    "${module.allow_ssh.this_security_group_id}",
  ]

  target_group_arns   = "${module.alb.target_group_arns}"
  user_data           = "${data.template_file.cloudinit_config.rendered}"
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
  subnet_ids                  = ["${local.subnets}"]

  vpc_security_group_ids = [
    "${module.allow_ssh.this_security_group_id}",
  ]
}

module "http" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "2.17.0"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  name                = "HTTP"
  vpc_id              = "${local.vpc_id}"
}

resource "null_resource" "bastion" {
  connection {
    host        = "${module.bastion.public_dns}"
    private_key = "${local.private_key}"
    user        = "ec2-user"
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
