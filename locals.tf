locals {
  # If you do not specify a desired capacity, the default is the minimum size of the group
  desired_capacity = "${coalesce(var.desired_capacity, var.min_size)}"

  key_name = "${coalesce(var.key_name, join("", aws_key_pair.key_pair.*.key_name))}"

  private_key = "${join("", tls_private_key.private_key.*.private_key_pem)}"

  vpc_id = "${coalesce(var.vpc_id, module.vpc.vpc_id)}"

  vpc_zone_identifier = "${
    split(
      ",",
      coalesce(
        join(",", var.vpc_zone_identifier),
        var.associate_public_ip_address ? join(",", module.vpc.public_subnets) : join(",", module.vpc.private_subnets)
      )
    )
  }"
}
