/*
output "api_url" {
  value = "https://${var.rancher_dns_name}"
}
*/

# output "master_public_dns" {
#   value = [aws_instance.master[0].public_dns]
# }

# output "masters_public_ip" {
#   value = [aws_instance.master[0].public_ip]
# }
output "masters_public_ip" {
  value = aws_instance.master.public_ip
}


# output "instance_private_ip" {
#   value = [aws_instance.master[0].private_ip]
# }

#output "agents_public_ips" {
  #value = [aws_instance.agent.*.public_ip]
#}
#output "server_ssh_key" {
  #value = var.key_pair
#}

#output "lb_dns_name" {
  #value = aws_lb.lb.dns_name
#}



#output "deployment_prefix" {
  #value = var.prefix
#}
