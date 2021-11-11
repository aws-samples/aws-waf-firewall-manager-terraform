################
# IAM ROLE FOR EC2
################
resource "aws_iam_role" "ssm_ec2_iam_role" {
  count = var.enable_ssm && var.create_iam_role_ssm ? 1 : 0
  name = "SSM-EC2-${var.vpc_name}-IAM-ROLE"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY


  tags                = merge(
                        var.tags,
                        {
                          "Name" = "SSM-EC2-${var.vpc_name}-IAM-ROLE"
                        },
                      )
}

#policies: ssm, s3, cloudwatch logs, kms
resource "aws_iam_role_policy_attachment" "ssm_ec2_role_managed_policy_1" {
  count = var.enable_ssm && var.create_iam_role_ssm ? 1 : 0
  role       = aws_iam_role.ssm_ec2_iam_role[0].id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm_ec2_role_managed_policy_2" {
  count = var.enable_ssm && var.create_iam_role_ssm ? 1 : 0
  role       = aws_iam_role.ssm_ec2_iam_role[0].id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy_attachment" "ssm_ec2_role_managed_policy_3" {
  count = var.enable_ssm && var.create_iam_role_ssm ? 1 : 0
  role       = aws_iam_role.ssm_ec2_iam_role[0].id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_iam_role_policy" "ssm_ec2_inline_policy" {
  count = var.enable_ssm && var.create_iam_role_ssm ? 1 : 0
  name = "s3-inline-policy"
  role = aws_iam_role.ssm_ec2_iam_role[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
              "arn:aws:s3:::patch-baseline-snapshot-${data.aws_region.current.name}/*",
              "arn:aws:s3:::aws-ssm-${data.aws_region.current.name}/*",
              "arn:aws:s3:::amazon-ssm-${data.aws_region.current.name}/*",
              "arn:aws:s3:::aws-ssm-distributor-file-${data.aws_region.current.name}/*",
              "arn:aws:s3:::${data.aws_region.current.name}-birdwatcher-prod/*",
              "arn:aws:s3:::aws-ssm-document-attachments-${data.aws_region.current.name}/*",
              "arn:aws:s3:::patch-baseline-snapshot-${data.aws_region.current.name}/*"
            ]
    }
  ]

}
EOF

}

resource "aws_iam_instance_profile" "ec2_ssm" {
  count = var.enable_ssm && var.create_iam_role_ssm ? 1 : 0
  name = "SSM-EC2-${var.vpc_name}-IAM-INSTANCE-PROFILE"
  role = aws_iam_role.ssm_ec2_iam_role[0].id

}

################
# EC2 SECURITY GROUPS
################

resource "aws_security_group" "ssm_endpoint_sg" {
  count = var.enable_ssm ? 1 : 0
  name_prefix        = "SSM-endpoint-${var.vpc_name}-sec-group"
  description = "Security group for SSM endpoint."
  vpc_id = aws_vpc.vpc.id
  tags = var.tags
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ssm_endpoint_sg_ing" {
  count = var.enable_ssm ? 1 : 0
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  cidr_blocks = [var.vpc_main_cidr]
  description = "allow inbound within vpc."
  security_group_id = aws_security_group.ssm_endpoint_sg[0].id
}

################
# ENDPOINTS
################

#FOR SSM
data "aws_vpc_endpoint_service" "ssm" {
  count = var.enable_ssm ? 1 : 0
  service = "ssm"
}

resource "aws_vpc_endpoint" "ssm" {
  count = length(var.private_subnets_cidr_list)>0 && var.enable_ssm ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  service_name      = data.aws_vpc_endpoint_service.ssm[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.ssm_endpoint_sg[0].id]
  subnet_ids          = [aws_subnet.subnet_priv[0].id]
  private_dns_enabled = true
  tags                = merge(
                        var.tags,
                        {
                          "Name" = "${var.vpc_name}-SSM-ENDPOINT"
                        },
                      )
}

#FOR SSM MESSAGES
data "aws_vpc_endpoint_service" "ssmmessages" {
  count = var.enable_ssm ? 1 : 0
  service = "ssmmessages"
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count = length(var.private_subnets_cidr_list)>0 && var.enable_ssm ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  service_name      = data.aws_vpc_endpoint_service.ssmmessages[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.ssm_endpoint_sg[0].id]
  subnet_ids          = [aws_subnet.subnet_priv[0].id]
  private_dns_enabled = true
  tags                = merge(
                        var.tags,
                        {
                          "Name" = "${var.vpc_name}-SSMMESSAGES-ENDPOINT"
                        },
                      )
}

#FOR EC2
data "aws_vpc_endpoint_service" "ec2" {
  count = var.enable_ssm ? 1 : 0
  service = "ec2"
}

resource "aws_vpc_endpoint" "ec2" {
  count = length(var.private_subnets_cidr_list)>0 && var.enable_ssm ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  service_name      = data.aws_vpc_endpoint_service.ec2[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.ssm_endpoint_sg[0].id]
  subnet_ids          = [aws_subnet.subnet_priv[0].id]
  private_dns_enabled = true
  tags                = merge(
                        var.tags,
                        {
                          "Name" = "${var.vpc_name}--EC2-ENDPOINT"
                        },
                      )
}

#FOR EC2 MESSAGES
data "aws_vpc_endpoint_service" "ec2messages" {
  count = var.enable_ssm ? 1 : 0
  service = "ec2messages"
}

resource "aws_vpc_endpoint" "ec2messages" {
  count = length(var.private_subnets_cidr_list)>0 && var.enable_ssm ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  service_name      = data.aws_vpc_endpoint_service.ec2messages[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.ssm_endpoint_sg[0].id]
  subnet_ids          = [aws_subnet.subnet_priv[0].id]
  private_dns_enabled = true
  tags                = merge(
                        var.tags,
                        {
                          "Name" = "${var.vpc_name}-EC2MESSAGES-ENDPOINT"
                        },
                      )
}

#FOR KMS
data "aws_vpc_endpoint_service" "kms" {
  count = var.enable_ssm ? 1 : 0
  service = "kms"
}

resource "aws_vpc_endpoint" "kms" {
  count = length(var.private_subnets_cidr_list)>0 && var.enable_ssm ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  service_name      = data.aws_vpc_endpoint_service.kms[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.ssm_endpoint_sg[0].id]
  subnet_ids          = [aws_subnet.subnet_priv[0].id]
  private_dns_enabled = true
  tags                = merge(
                        var.tags,
                        {
                          "Name" = "${var.vpc_name}-KMS-ENDPOINT"
                        },
                      )
}