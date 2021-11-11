#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.Project
    Owner       = var.Owner
    managedBy   = "terraform"
  }
  #https://docs.aws.amazon.com/redshift/latest/mgmt/db-auditing.html
  redshift_logging_region_account_id_bucket_policy = {
    "us-east-1" : "193672423079",
    "us-east-2" : "391106570357",
    "us-west-1" : "262260360010",
    "us-west-2" : "902366379725",
    "af-south-1" : "365689465814",
    "ap-east-1" : "313564881002",
    "ap-south-1" : "865932855811",
    "ap-northeast-3" : "090321488786",
    "ap-northeast-2" : "760740231472",
    "ap-southeast-1" : "361669875840",
    "ap-southeast-2" : "762762565011",
    "ap-northeast-1" : "404641285394",
    "ca-central-1" : "907379612154",
    "eu-central-1" : "053454850223",
    "eu-west-1" : "210876761215",
    "eu-west-2" : "307160386991",
    "eu-south-1" : "945612479654",
    "eu-west-3" : "915173422425",
    "eu-north-1" : "729911121831",
    "me-south-1" : "013126148197",
    "sa-east-1" : "075028567923"
  }
  cfront_tags = {
    AWS_WAF     = "Enabled",
    Environment = "poc",
    Type        = "edge"
  }

  app_tags = {
    AWS_WAF     = "Enabled",
    Environment = "poc",
    Type        = "application"
  }

}

data "aws_region" "region" {}
data "aws_caller_identity" "current" {}
data "aws_caller_identity" "security" {
  provider = aws.regional
}
data "aws_availability_zones" "available" {}

data "aws_caller_identity" "us-east-1" {
  provider = aws.global
}

data "aws_region" "us-east-1" {
  provider = aws.global
}

data "aws_region" "security" {
  provider = aws.regional
}
