#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#


#Automation from https://aws.amazon.com/blogs/security/automatically-update-aws-waf-ip-sets-with-aws-ip-ranges/ but translated to terraform
resource "aws_wafv2_ip_set" "ipv4_automation" {
  provider           = aws.regional
  name               = "${var.regional_policy_name}-cloudfront-ipv4"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = []

  tags = local.common_tags
}

resource "aws_wafv2_ip_set" "ipv6_automation" {
  provider           = aws.regional
  name               = "${var.regional_policy_name}-cloudfront-ipv6"
  scope              = "REGIONAL"
  ip_address_version = "IPV6"
  addresses          = []

  tags = local.common_tags
}

resource "aws_wafv2_rule_group" "allowCloudfrontIP" {
  provider    = aws.regional
  name        = "${var.regional_policy_name}-allowCloudfrontIP"
  scope       = "REGIONAL"
  capacity    = 60
  description = "IP Rule Group for Cloudfront IP addresses"

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAFCFrontIPRuleGroupMetric"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "CFrontIPAllowRule"
    priority = 0

    action {
      allow {}
    }

    statement {

      or_statement {
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.ipv4_automation.arn
          }
        }

        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.ipv6_automation.arn
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CFrontIPAllowRule-metric"
      sampled_requests_enabled   = true
    }
  }

}


data "archive_file" "ipAutomation" {
  type = "zip"

  output_path = "${path.module}/code/ipAutomation.zip"
  source {
    content  = file("${path.module}/code/ipAutomation.py")
    filename = "ipAutomation.py"
  }
}


resource "aws_lambda_function" "ipAutomation" {
  provider         = aws.regional
  filename         = "${path.module}/code/ipAutomation.zip"
  description      = " This Lambda function, invoked by an incoming SNS message, updates the IPv4 and IPv6 sets with the addresses from the specified services"
  function_name    = "AWS-WAF-Update-IP-Sets"
  role             = aws_iam_role.ipAutomation-iam-role.arn
  handler          = "ipAutomation.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.ipAutomation.output_base64sha256
  timeout          = 100

  environment {
    variables = {
      IPV4_SET_NAME = "${var.regional_policy_name}-cloudfront-ipv4"
      IPV4_SET_ID   = aws_wafv2_ip_set.ipv4_automation.id
      IPV6_SET_NAME = "${var.regional_policy_name}-cloudfront-ipv6"
      IPV6_SET_ID   = aws_wafv2_ip_set.ipv6_automation.id
      SERVICES      = "CLOUDFRONT"
      EC2_REGIONS   = "all"
      INFO_LOGGING  = "true"
    }
  }

  tags = local.common_tags
}


# ipAutomation
resource "aws_iam_role" "ipAutomation-iam-role" {
  provider = aws.regional
  name     = "AWS-WAF-Update-IP-Sets"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY


  tags = local.common_tags
}

# policy to let lambda access the ssm managed resources and logs
resource "aws_iam_role_policy" "ipAutomation-iam_inline_policy" {
  provider = aws.regional
  name     = "ipAutomation-inline-policy"
  role     = aws_iam_role.ipAutomation-iam-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSLambdaBasicExecutionRoleAccess",
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AccessvpcResources",
      "Effect": "Allow",
      "Action":  [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AccessWAF",
      "Effect": "Allow",
      "Action": [
          "wafv2:UpdateWebACL",
          "wafv2:GetWebACL",
          "wafv2:ListWebACLs",
          "wafv2:GetIPSet",
          "cloudwatch:PutMetricAlarm",
          "wafv2:UpdateIPSet"
      ],
      "Resource": "*"
    }
  ]
}
EOF

}



resource "aws_lambda_permission" "ipAutomation-permissions" {
  provider      = aws.regional
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ipAutomation.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = "arn:aws:sns:us-east-1:806199016981:AmazonIpSpaceChanged"
}

resource "aws_sns_topic_subscription" "ipAutomation" {
  provider  = aws.global
  topic_arn = "arn:aws:sns:us-east-1:806199016981:AmazonIpSpaceChanged"
  protocol  = "lambda"
  endpoint  = aws_lambda_function.ipAutomation.arn
}