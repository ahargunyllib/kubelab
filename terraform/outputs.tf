output "master_public_ip" {
  description = "Public IP address of the Kubernetes control-plane node."
  value       = aws_instance.master.public_ip
}

output "worker_public_ips" {
  description = "Public IP addresses of Kubernetes worker nodes."
  value       = aws_instance.worker[*].public_ip
}

output "all_public_ips" {
  description = "All node public IP addresses."
  value       = concat([aws_instance.master.public_ip], aws_instance.worker[*].public_ip)
}

output "ssh_master" {
  description = "SSH command for the control-plane node."
  value       = "ssh -i ${var.private_key_path} ${var.ssh_user}@${aws_instance.master.public_ip}"
}

output "sample_app_url" {
  description = "Sample Nginx application URL."
  value       = "http://${var.worker_count > 0 ? aws_instance.worker[0].public_ip : aws_instance.master.public_ip}:${var.sample_app_nodeport}"
}

output "private_key_path" {
  description = "Private key path configured for Ansible."
  value       = var.private_key_path
}

output "ssh_user" {
  description = "SSH user configured for Ansible."
  value       = var.ssh_user
}
