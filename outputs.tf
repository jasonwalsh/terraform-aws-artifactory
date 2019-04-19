output "autoscaling_group_name" {
  description = "The name of the Auto Scaling group"
  value       = "${module.autoscaling.this_autoscaling_group_name}"
}
