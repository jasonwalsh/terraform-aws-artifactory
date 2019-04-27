output "autoscaling_group_name" {
  description = "The name of the Auto Scaling group"
  value       = "${module.autoscaling.this_autoscaling_group_name}"
}

output "dns_name" {
  description = "The public DNS name of the load balancer"
  value       = "${module.alb.dns_name}"
}
