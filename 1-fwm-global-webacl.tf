#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

#Edge Network WAF
#check https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-list.html
# AWS managed rules Core Rule Set, geographical location (custom), AWS Managed IP reputation, AWS managed anonymous IP*, knwon bad inputs set, ip block/allow set (custom)
#------------------------Please customize with YOUR rules--------------------
resource "aws_fms_policy" "NonProdCFrontPolicy_global" {
  count                 = var.create_global_fms_waf_policy ? 1 : 0
  provider              = aws.global
  name                  = var.global_policy_name
  exclude_resource_tags = var.global_policy_exclude_resource_tags
  remediation_enabled   = var.global_policy_remediation_enabled
  resource_type         = "AWS::CloudFront::Distribution"
  include_map {
    orgunit = var.global_policy_orgunit_list
  }

  resource_tags = length(var.global_policy_resource_tags) == 0 ? null : var.global_policy_resource_tags

  security_service_policy_data {
    type = "WAFV2"

    managed_service_data = jsonencode({
      type = "WAFV2",
      preProcessRuleGroups = [
        {
          managedRuleGroupIdentifier = {
            vendorName           = "AWS",
            managedRuleGroupName = "AWSManagedRulesAmazonIpReputationList"
          },
          ruleGroupType = "ManagedRuleGroup",
          ruleGroupArn  = null,
          overrideAction = {
            type = "NONE"
        } },
        {
          managedRuleGroupIdentifier = {
            vendorName           = "AWS",
            managedRuleGroupName = "AWSManagedRulesCommonRuleSet"
          },
          ruleGroupType = "ManagedRuleGroup",
          ruleGroupArn  = null,
          overrideAction = {
            type = "NONE"
        } },
        {
          managedRuleGroupIdentifier = {
            vendorName           = "AWS",
            managedRuleGroupName = "AWSManagedRulesKnownBadInputsRuleSet"
          },
          ruleGroupType = "ManagedRuleGroup",
          ruleGroupArn  = null,
          overrideAction = {
            type = "NONE"
        } },
        {
          managedRuleGroupIdentifier = {
            vendorName           = "AWS",
            managedRuleGroupName = "AWSManagedRulesAdminProtectionRuleSet"
          },
          ruleGroupType = "ManagedRuleGroup",
          ruleGroupArn  = null,
          overrideAction = {
            type = "NONE"
        } },
        {
          managedRuleGroupIdentifier = {
            vendorName           = "AWS",
            managedRuleGroupName = "AWSManagedRulesBotControlRuleSet"
          },
          ruleGroupType = "ManagedRuleGroup",
          ruleGroupArn  = null,
          overrideAction = {
            type = "COUNT"
        } },
        {
          ruleGroupType = "RuleGroup",
          ruleGroupArn  = aws_cloudformation_stack.aws_waf_rulegroup_ratebased.outputs["RuleGorupARN"],
          overrideAction = {
            type = "NONE"
      } }],
      postProcessRuleGroups             = [],
      overrideCustomerWebACLAssociation = var.global_policy_overrideCustomerWebACLAssociation,
      defaultAction = {
        type = var.global_policy_default_action
      },
      ruleGroups = [],
      loggingConfiguration = {
        logDestinationConfigs = var.logging_option == "option1" ? [aws_kinesis_firehose_delivery_stream.WAFKinesisFirehose_global[0].arn] : var.logging_option == "option2" ? aws_cloudformation_stack.dashboards_private_kinesis_global[0].outputs["KinesisFirehoseDeliveryStreamArn"] : var.logging_option == "option3" ? aws_cloudformation_stack.dashboards-option3-global[0].outputs["KinesisFirehoseDeliveryStreamArn"] : null
      }
    })
  }
}

