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

output "app_lb_security_group_id" {
  description = "Security group ID for application load balancer"
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

output "mongodb_data_volume_id" {
  description = "Persistent EBS volume storing MongoDB data"
  value       = aws_ebs_volume.mongodb_data.id
}

#--------
# S3.TF
#--------

output "mongodb_backup_bucket_name" {
  description = "Public S3 bucket containing MongoDB backups"
  value       = aws_s3_bucket.mongodb_backups.bucket
}

output "mongodb_backup_bucket_url" {
  description = "Public URL for the MongoDB backup bucket"
  value       = "https://${aws_s3_bucket.mongodb_backups.bucket}.s3.amazonaws.com"
}

#---------
# ECR.TF
#---------

output "tasky_ecr_repository_url" {
  description = "ECR repository URL for the Tasky application"
  value       = aws_ecr_repository.tasky.repository_url
}

#---------
# EKS.TF
#---------

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "API endpoint of the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "eks_node_group_name" {
  description = "EKS managed node group name"
  value       = aws_eks_node_group.main.node_group_name
}