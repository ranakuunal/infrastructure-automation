#--------
# VPC.TF
#--------

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_subnet1.id,
    aws_subnet.public_subnet2.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_subnet1.id,
    aws_subnet.private_subnet2.id
  ]
}

output "nat_gateway_id" {
  value = aws_nat_gateway.main.id
}

#-------------------
# Security-Group.tf
#-------------------

output "mongodb_security_group_id" {
  description = "Security group ID for MongoDB"
  value       = aws_security_group.mongodb.id
}

output "eks_nodes_security_group_id" {
  description = "Security group ID for EKS worker nodes"
  value       = aws_security_group.eks_nodes.id
}

output "app_lb_security_group_id" {
  description = "Security group Id for application load balancer"
  value       = aws_security_group.app_lb.id
}

#---------
# EC2.TF
#---------

output "mongodb_instance_id" {
  description = "MongoDB EC2 instance ID"
  value       = aws_instance.mongodb.id
}

output "mongodb_public_ip" {
  description = "Public IP address of MongoDB EC2 instance"
  value       = aws_instance.mongodb.public_ip
}

output "mongodb_private_ip" {
  description = "Private IP address of MongoDB EC2 instance"
  value       = aws_instance.mongodb.private_ip
}