#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

resource "aws_cloudformation_stack" "dashboards-option3-regional" {
  count    = var.logging_option == "option3" ? 1 : 0
  provider = aws.regional
  name     = "security-waf-dashboards-regional"

  parameters = {
    UserEmail             = var.ESUserEmail,
    DataNodeEBSVolumeSize = var.DataNodeEBSVolumeSize,
    ESConfigBucket        = var.kinesis_destination_s3_name
  }

  template_body = file("dashboard.yaml")
  capabilities  = ["CAPABILITY_IAM", ]
  tags = merge(
    local.common_tags,
    {
      "Purpose" = "Cloudformation stack for waf dashboards"
    },
  )
}

resource "aws_cloudformation_stack" "dashboards-option3-global" {
  count    = var.logging_option == "option3" ? 1 : 0
  provider = aws.global
  name     = "security-waf-dashboards-global"

  parameters = {
    UserEmail             = var.ESUserEmail,
    DataNodeEBSVolumeSize = var.DataNodeEBSVolumeSize,
    ESConfigBucket        = var.kinesis_destination_s3_name
  }

  template_body = file("dashboard.yaml")
  capabilities  = ["CAPABILITY_IAM", ]
  tags = merge(
    local.common_tags,
    {
      "Purpose" = "Cloudformation stack for waf dashboards"
    },
  )
}
