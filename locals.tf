locals {
  # If you do not specify a desired capacity, the default is the minimum size of the group
  desired_capacity = "${coalesce(var.desired_capacity, var.min_size)}"

  vpc_zone_identifier = "${
    coalescelist(
      var.vpc_zone_identifier,
      concat(module.vpc.private_subnets, module.vpc.public_subnets)
    )
  }"
}
