output "leader_public_ip" {
  value       = linode_instance.leader.ip_address
  description = "The public IP address of the leader server instance."
}

output "nodes_public_ip" {
  value       = linode_instance.nodes.*.ip_address
  description = "The public IP address of the nodes instances."
}