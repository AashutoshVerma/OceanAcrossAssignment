output "instance_ids" {
  value = { for k, i in aws_instance.svc : k => i.id }
}

output "security_group_ids" {
  value = { for k, s in aws_security_group.svc : k => s.id }
}
