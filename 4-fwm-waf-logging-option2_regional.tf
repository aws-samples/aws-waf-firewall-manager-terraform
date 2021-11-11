#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

#Kinesis is in your firewall manager account
resource "aws_cloudformation_stack" "dashboards_private_kinesis" {
  count = var.logging_option == "option2" ? 1 : 0
  depends_on = [
    aws_cloudformation_stack.dashboards_es
  ]
  provider = aws.regional
  name     = "security-waf-dashboards-kinesis-regional"

  parameters = {
    DestinationS3bucketARN = aws_cloudformation_stack.dashboards_es[0].outputs.S3bucketARN,
    KinesisDeliveryRoleARN = aws_cloudformation_stack.dashboards_private_kinesis_role[0].outputs.KinesisFirehoseDeliveryRoleArn
  }

  template_body = file("dashboard-crossaccount-kinesis.yaml")
  capabilities  = ["CAPABILITY_IAM", ]
  tags = merge(
    local.common_tags,
    {
      "Purpose" = "Cloudformation stack for kinesis firehose"
    },
  )
}

resource "aws_cloudformation_stack" "dashboards_private_kinesis_role" {
  count    = var.logging_option == "option2" ? 1 : 0
  provider = aws.regional
  name     = "security-waf-dashboards-private-regional"

  parameters = {
    S3Bucket = var.kinesis_destination_s3_name,
  }

  template_body = file("dashboard-crossaccount-kinesis-role.yaml")
  capabilities  = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
  tags = merge(
    local.common_tags,
    {
      "Purpose" = "Cloudformation stack for kinesis firehose role"
    },
  )
}

# Comment these lines if you already have a VPC for ES
module "ES-vpc" {
  count = var.logging_option == "option2" ? 1 : 0
  providers = {
    aws = aws.logging
  }
  source                                 = "./modules/vpc"
  tags                                   = local.common_tags
  vpc_name                               = "logging"
  vpc_suffix                             = "-es"
  vpc_main_cidr                          = "10.2.0.0/16"
  enable_ipv6                            = false
  enable_dns_hostnames                   = true
  enable_dns_support                     = true
  enable_ssm                             = true
  enable_internet_gateway                = true
  enable_nat_gateway                     = true
  private_subnets_internet_access_nat_gw = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true

  number_AZ = 2

  private_subnets_cidr_list = ["10.2.3.0/24", "10.2.4.0/24"]
  public_subnets_cidr_list  = ["10.2.1.0/24", "10.2.2.0/24"]

}

#ES and S3 bucket are in a logging account - ES in private
resource "aws_cloudformation_stack" "dashboards_es" {
  count      = var.logging_option == "option2" ? 1 : 0
  provider   = aws.logging
  depends_on = [module.ES-vpc, aws_cloudformation_stack.dashboards_private_kinesis_role]
  name       = "dashboard-crossaccount-es"

  parameters = {
    VPC                    = module.ES-vpc[0].vpc_id,
    Subnet1                = module.ES-vpc[0].subnet_priv_ids[0],
    Subnet2                = module.ES-vpc[0].subnet_priv_ids[1],
    S3BucketName           = var.kinesis_destination_s3_name,
    UserEmail              = var.ESUserEmail,
    DataNodeEBSVolumeSize  = var.DataNodeEBSVolumeSize,
    ESConfigBucket         = "${var.ESConfigBucket}-regional"
    KinesisDeliveryRoleARN = aws_cloudformation_stack.dashboards_private_kinesis_role[0].outputs.KinesisFirehoseDeliveryRoleArn
  }

  template_body = file("dashboard-crossaccount-es.yaml")
  capabilities  = ["CAPABILITY_IAM", ]
  tags = merge(
    local.common_tags,
    {
      "Purpose" = "Cloudformation stack for regional waf dashboards"
    },
  )
}


# SSH tunnel to Kibana - https://aws.amazon.com/premiumsupport/knowledge-center/opensearch-outside-vpc-ssh/
data "template_file" "ssh_tunnel" {
  template = file("${path.module}/user-data/user-data.sh")

  vars = {
    Region = var.application_region
  }
}

#EC2 instance - https://aws.amazon.com/premiumsupport/knowledge-center/opensearch-outside-vpc-ssh/
resource "aws_instance" "ssh_tunnel" {
  count                       = var.logging_option == "option2" ? 1 : 0
  provider                    = aws.logging
  ami                         = var.ES_SSH_tunnel_amid_id_regional
  instance_type               = var.ES_SSH_tunnel_instance_type
  monitoring                  = true
  user_data                   = data.template_file.ssh_tunnel.rendered
  subnet_id                   = module.ES-vpc[0].subnet_public_ids[0]
  iam_instance_profile        = module.ES-vpc[0].iam_instance_profile_ec2_ssm_id
  key_name                    = var.ES_SSH_tunnel_key_name
  vpc_security_group_ids      = [aws_security_group.ssh_tunnel[0].id]
  associate_public_ip_address = true
  tags = merge(
    local.common_tags,
    {
      "Name" = "ssh_tunnel"
    },
  )
  lifecycle {
    ignore_changes = [user_data]
  }
}



resource "aws_security_group" "ssh_tunnel" {
  count       = var.logging_option == "option2" ? 1 : 0
  provider    = aws.logging
  name        = "ssh_tunnel"
  description = "ssh_tunnel"
  vpc_id      = module.ES-vpc[0].vpc_id
  tags = merge(
    local.common_tags,
    {
      "Name" = "ssh_tunnel"
    },
  )

}

resource "aws_security_group_rule" "ssh_tunnel_i_1" {
  count             = var.logging_option == "option2" ? 1 : 0
  provider          = aws.logging
  type              = "ingress"
  from_port         = 8157
  to_port           = 8157
  protocol          = "tcp"
  cidr_blocks       = var.ES_SSH_tunnel_allowed_CIDR
  security_group_id = aws_security_group.ssh_tunnel[0].id
}

resource "aws_security_group_rule" "ssh_tunnel_i_2" {
  count             = var.logging_option == "option2" ? 1 : 0
  provider          = aws.logging
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ES_SSH_tunnel_allowed_CIDR
  security_group_id = aws_security_group.ssh_tunnel[0].id
}


resource "aws_security_group_rule" "ssh_tunnel_e_1" {
  count             = var.logging_option == "option2" ? 1 : 0
  provider          = aws.logging
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssh_tunnel[0].id
}

resource "aws_security_group_rule" "ssh_tunnel_e_2" {
  count             = var.logging_option == "option2" ? 1 : 0
  provider          = aws.logging
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssh_tunnel[0].id
}