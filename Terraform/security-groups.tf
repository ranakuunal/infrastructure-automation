#----------------
# MongoDB SG
#----------------

resource "aws_security_group" "mongodb" {
  name        = "${var.project_name}-mongodb-sg"
  description = "Security Group for MongoDB EC2 instance"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-mongodb-sg"
  })
}

#------------------------------
# Application Load Balancer SG
#------------------------------

resource "aws_security_group" "app_lb" {
  name        = "${var.project_name}-app-lb-sg"
  description = "Security Group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-app-lb-sg"
  })
}

#------------------------------------
# Application Load Balancer SG Rules
#------------------------------------

resource "aws_vpc_security_group_ingress_rule" "app_lb_http" {
  security_group_id = aws_security_group.app_lb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_lb_https" {
  security_group_id = aws_security_group.app_lb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_lb_all" {
  security_group_id = aws_security_group.app_lb.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

#---------------
# EKS SG Rules
#---------------

resource "aws_vpc_security_group_ingress_rule" "eks_from_app_lb" {
  security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id

  referenced_security_group_id = aws_security_group.app_lb.id

  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"
}

#------------------
# MongoDB SG Rules
#------------------

resource "aws_vpc_security_group_ingress_rule" "mongodb_from_eks" {
  security_group_id = aws_security_group.mongodb.id

  referenced_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id

  from_port   = 27017
  to_port     = 27017
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "mongodb_ssh" {
  security_group_id = aws_security_group.mongodb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "mongodb_all" {
  security_group_id = aws_security_group.mongodb.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}