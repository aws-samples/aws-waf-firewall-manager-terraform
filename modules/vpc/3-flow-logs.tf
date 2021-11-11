locals {
  # Only create flow log if user selected to create a VPC as well
  enable_flow_log =  var.enable_flow_log

  create_flow_log_cloudwatch_iam_role  = local.enable_flow_log && var.flow_log_destination_type != "s3" && var.create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group = local.enable_flow_log && var.flow_log_destination_type != "s3" && var.create_flow_log_cloudwatch_log_group

  flow_log_destination_arn = local.create_flow_log_cloudwatch_log_group ? aws_cloudwatch_log_group.flow_log[0].arn : var.flow_log_destination_arn
  flow_log_iam_role_arn    = var.flow_log_destination_type != "s3" && local.create_flow_log_cloudwatch_iam_role ? aws_iam_role.vpc_flow_log_iam_role[0].arn : var.flow_log_cloudwatch_iam_role_arn
}

###################
# Flow Log
###################
resource "aws_flow_log" "this" {
  count = local.enable_flow_log ? 1 : 0

  log_destination_type = var.flow_log_destination_type
  log_destination      = local.flow_log_destination_arn
  log_format           = var.flow_log_log_format
  iam_role_arn         = local.flow_log_iam_role_arn
  traffic_type         = var.flow_log_traffic_type
  vpc_id               = aws_vpc.vpc.id

}

#####################
# Flow Log CloudWatch
#####################
resource "aws_cloudwatch_log_group" "flow_log" {
  count = local.create_flow_log_cloudwatch_log_group ? 1 : 0
  name              = "${var.vpc_name}-vpc-flow-logs"
  retention_in_days = var.flow_log_cloudwatch_log_group_retention_in_days

  tags = merge(
    var.tags,
    map(
      "Purpose", "VPC Flow Log CloudWatch Log Group for ${var.vpc_name}"
    )
  )
}

#########################
# Flow Log CloudWatch IAM
#########################
resource "aws_iam_role" "vpc_flow_log_iam_role" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0
  name = "${var.vpc_name}-vpcflowlogs-cw-role"
  
  assume_role_policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "FlowLogsAssumeRole",
          "Effect": "Allow",
          "Principal": {
            "Service": "vpc-flow-logs.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
  )
  
  tags = merge(
    var.tags,
    map(
      "Purpose", "IAM role to allow VPC Flow Logs to publish to CloudWatch Logs"
    )
  )
}



resource "aws_iam_role_policy" "vpc_flow_log_iam_policy" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0
  name   = "${var.vpc_name}-vpcflowlogs-cloudwatch-log-policy"
  role   = aws_iam_role.vpc_flow_log_iam_role[0].id
  
  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "CreateAndPutLogs",
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams"
          ],
          "Resource": "*"
        }
      ]
    }
  )
}