output "leader_public_ip" {
  value       = linode_instance.leader.ip_address
  description = "The public IP address of the leader server instance."
}

output "workers_public_ip" {
  value       = linode_instance.workers.*.ip_address
  description = "The public IP address of the worker instances."
}