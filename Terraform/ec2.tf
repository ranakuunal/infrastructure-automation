#---------------
# EC2 Key-Pair
#---------------

resource "aws_key_pair" "mongodb_ec2" {
  key_name   = "${var.project_name}-mongodb-key"
  public_key = file("${path.module}/keys/wiz-exercise-mongodb.pub")

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-mongodb-key"
  })
}

#---------------
# EC2 IAM Role
#---------------

resource "aws_iam_role" "mongodb_ec2" {
  name = "${var.project_name}-mongodb-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-mongodb-ec2-role"
  })
}

resource "aws_iam_role_policy_attachment" "mongodb_admin" {
  role       = aws_iam_role.mongodb_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

#-------------------------------
# MongoDB EC2 Instance Profile
#-------------------------------

resource "aws_iam_instance_profile" "mongodb" {
  name = "${var.project_name}-mongodb-instance-profile"
  role = aws_iam_role.mongodb_ec2.name

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-mongodb-instance-profile"
  })
}

#------
# AMI
#------

data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-kernel-default-hvm-x86_64-gp2"
}

#-----------------------
# MongoDB EC2 Instance
#-----------------------

resource "aws_instance" "mongodb" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = "t3.small"

  subnet_id                   = aws_subnet.public_subnet1.id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.mongodb.id
  ]

  key_name             = aws_key_pair.mongodb_ec2.key_name
  iam_instance_profile = aws_iam_instance_profile.mongodb.name

  # User data normally only runs during the initial boot.
  user_data = file("${path.module}/../Scripts/mongodb-setup.sh")

  # Replace the instance if bootstrap configuration changes.
  user_data_replace_on_change = true

  depends_on = [
    aws_iam_role_policy_attachment.mongodb_admin
  ]

  root_block_device {
    volume_size           = 15
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-mongodb"
  })
}

#---------------------
# MongoDB EBS Volume
#---------------------

resource "aws_ebs_volume" "mongodb_data" {
  availability_zone = aws_subnet.public_subnet1.availability_zone

  size = 15
  type = "gp3"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-mongodb-data"
  })
}

resource "aws_volume_attachment" "mongodb_data" {
  device_name = "/dev/sdf"

  volume_id   = aws_ebs_volume.mongodb_data.id
  instance_id = aws_instance.mongodb.id

  stop_instance_before_detaching = true
}