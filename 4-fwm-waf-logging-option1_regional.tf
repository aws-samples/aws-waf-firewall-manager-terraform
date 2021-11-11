#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

# LOGGING CONFIGURATION OPTION 1 - Kinesis -> S3 bucket in the same account + KMS encryption----------------
#Please add your lambda processors for Kinesis and S3 bucket access log configuration
resource "aws_kinesis_firehose_delivery_stream" "WAFKinesisFirehose_regional" {
  count       = var.logging_option == "option1" ? 1 : 0
  provider    = aws.regional
  name        = "${var.kinesis_firehose_name}-regional"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn        = aws_iam_role.firehose_role_regional[0].arn
    bucket_arn      = aws_s3_bucket.logging_bucket_regional[0].arn
    prefix          = var.kinesis_prefix
    buffer_interval = var.s3_delivery_buffer_interval
    buffer_size     = var.s3_delivery_buffer_size
    kms_key_arn     = aws_kms_key.waf_logs_regional[0].arn

    # processing_configuration { #add your lambda function
    #   enabled = "true"

    #   processors {
    #     type = "Lambda"

    #     parameters {
    #       parameter_name  = "LambdaArn"
    #       parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
    #     }
    #   }
    # }
  }

}

resource "aws_s3_bucket" "logging_bucket_regional" {
  count    = var.logging_option == "option1" ? 1 : 0
  provider = aws.regional
  bucket   = "${var.kinesis_destination_s3_name}-regional"
  acl      = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.waf_logs_regional[0].arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  /* logging { #add your loggin s3 bucket
    target_bucket = local.s3_bucket_logging
    target_prefix = "s3-access-logs/${var.kinesis_destination_s3_name}/"
  } */

  lifecycle_rule {
    id      = "manage-old-objects"
    enabled = true

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "logging_bucket_regional" {
  count    = var.logging_option == "option1" ? 1 : 0
  provider = aws.regional
  bucket   = aws_s3_bucket.logging_bucket_regional[0].id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyInsecureAccess",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "${aws_s3_bucket.logging_bucket_regional[0].arn}",
                "${aws_s3_bucket.logging_bucket_regional[0].arn}/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        },
        {
            "Sid": "EnforceEncryption",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": [
                "${aws_s3_bucket.logging_bucket_regional[0].arn}/*"
            ],
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": "aws:kms"
                }
            }
        }
    ]
}
POLICY

}


resource "aws_iam_role" "firehose_role_regional" {
  count    = var.logging_option == "option1" ? 1 : 0
  provider = aws.regional
  name     = "${var.kinesis_firehose_name}-regional"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#cycle dependency between iam role and KMS key
resource "aws_iam_role_policy" "firehose_regional" {
  count    = var.logging_option == "option1" ? 1 : 0
  provider = aws.regional
  depends_on = [
    aws_s3_bucket.logging_bucket_regional,
    aws_kms_key.waf_logs_regional
  ]
  name   = "${var.kinesis_firehose_name}-regional"
  role   = aws_iam_role.firehose_role_regional[0].id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:GetShardIterator",
        "kinesis:GetRecords",
        "kinesis:ListShards"
      ],
      "Resource": "arn:aws:kinesis:${data.aws_region.security.name}:${data.aws_caller_identity.security.account_id}:stream/*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:DescribeVpcs",
            "ec2:DescribeVpcAttribute",
            "ec2:DescribeSubnets",
            "ec2:DescribeNetworkInterfaces",
            "ec2:CreateNetworkInterface",
            "ec2:CreateNetworkInterfacePermission",
            "ec2:DeleteNetworkInterface",
            "logs:PutLogEvents"
          ],
          "Resource": [
            "*"
          ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject",
                "s3:PutObjectAcl"
          ],
          "Resource": [
            "${aws_s3_bucket.logging_bucket_regional[0].arn}",
            "${aws_s3_bucket.logging_bucket_regional[0].arn}/*"
          ]
        },
        {
          "Effect": "Allow",
            "Action": [
                "kms:decrypt",
                "kms:GenerateDataKey",
                "kms:List*",
                "kms:Describe*",
                "kms:Get*"
          ],
          "Resource": [
            "${aws_kms_key.waf_logs_regional[0].arn}"
          ]
        }
  ]
}
EOF
}


resource "aws_kms_key" "waf_logs_regional" {
  count    = var.logging_option == "option1" ? 1 : 0
  provider = aws.regional
  depends_on = [
    aws_iam_role.firehose_role_regional
  ]
  description             = "Use to encrypt WAF S3 logs (regional)"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  is_enabled              = true
  tags                    = local.common_tags


  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Allow account admin of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": 
                  [
                    "arn:aws:iam::${data.aws_caller_identity.security.account_id}:root",
                    "${aws_iam_role.firehose_role_regional[0].arn}"
                  ]
            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
}
POLICY

}

resource "aws_kms_alias" "waf_logs_regional" {
  count         = var.logging_option == "option1" ? 1 : 0
  provider      = aws.regional
  name          = "alias/${var.kinesis_firehose_name}-regional"
  target_key_id = aws_kms_key.waf_logs_regional[0].key_id
}