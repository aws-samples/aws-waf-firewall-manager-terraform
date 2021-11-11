#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

#-----use this resource to create your own Rate based rules ----------------------------
#rate-based-statement rules are not supported by terraform at the moment in rule groups, issue opened https://github.com/hashicorp/terraform-provider-aws/issues/21631

resource "aws_cloudformation_stack" "aws_waf_rulegroup_ratebased" {
  provider = aws.global
  name     = "ratebBasedRuleGroup"

  template_body = file("3-aws-waf-rate-based.yaml")
  capabilities  = ["CAPABILITY_IAM", ]
  tags = merge(
    local.common_tags,
    {
      "Purpose" = "Cloudformation stack for aws_waf_rulegroup_ratebased"
    },
  )
}

