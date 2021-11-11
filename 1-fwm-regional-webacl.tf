#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

#Application layer policy
#check https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-list.html
#For web app: AWS managed SQL injection, Linux, PHP + custom rules like regex
#------------------------Please customize with YOUR rules--------------------
resource "aws_fms_policy" "NonProdApplicationPolicy_regional" {
  count                 = var.create_regional_fms_waf_policy ? 1 : 0
  provider              = aws.regional
  name                  = var.regional_policy_name
  exclude_resource_tags = var.regional_policy_exclude_resource_tags
  remediation_enabled   = var.regional_policy_remediation_enabled
  resource_type_list    = ["AWS::ElasticLoadBalancingV2::LoadBalancer", "AWS::ApiGateway::Stage"]
  include_map {
    orgunit = var.regional_policy_orgunit_list
  }

  resource_tags = length(var.regional_policy_resource_tags) == 0 ? null : var.regional_policy_resource_tags
  security_service_policy_data {
    type = "WAFV2"

    managed_service_data = jsonencode({
      type = "WAFV2",
      preProcessRuleGroups = [
        {
          managedRuleGroupIdentifier = {
            vendorName           = "AWS",
            managedRuleGroupName = "AWSManagedRulesSQLiRuleSet"
          },
          ruleGroupType = "ManagedRuleGroup",
          ruleGroupArn  = null,
          overrideAction = {
            type = "NONE"
        } },
        {
          managedRuleGroupIdentifier = {
            vendorName           = "AWS",
            managedRuleGroupName = "AWSManagedRulesLinuxRuleSet"
          },
          ruleGroupType = "ManagedRuleGroup",
          ruleGroupArn  = null,
          overrideAction = {
            type = "NONE"
        } },
        {
          managedRuleGroupIdentifier = {
            vendorName           = "AWS",
            managedRuleGroupName = "AWSManagedRulesUnixRuleSet"
          },
          ruleGroupType = "ManagedRuleGroup",
          ruleGroupArn  = null,
          overrideAction = {
            type = "NONE"
        } },
        {
          managedRuleGroupIdentifier = {
            vendorName           = "AWS",
            managedRuleGroupName = "AWSManagedRulesPHPRuleSet"
          },
          ruleGroupType = "ManagedRuleGroup",
          ruleGroupArn  = null,
          overrideAction = {
            type = "NONE"
        } },
        {
          managedRuleGroupIdentifier = {
            vendorName           = "AWS",
            managedRuleGroupName = "AWSManagedRulesWordPressRuleSet"
          },
          ruleGroupType = "ManagedRuleGroup",
          ruleGroupArn  = null,
          overrideAction = {
            type = "NONE"
        } },
        {
          ruleGroupType = "RuleGroup",
          ruleGroupArn  = aws_wafv2_rule_group.allowCloudfrontIP.arn,
          overrideAction = {
            type = "NONE"
      } }],
      postProcessRuleGroups             = [],
      overrideCustomerWebACLAssociation = var.regional_policy_overrideCustomerWebACLAssociation,
      defaultAction = {
        type = var.regional_policy_default_action
      },
      ruleGroups = [],
      loggingConfiguration = {
        logDestinationConfigs = var.logging_option == "option1" ? [aws_kinesis_firehose_delivery_stream.WAFKinesisFirehose_regional[0].arn] : var.logging_option == "option2" ? aws_cloudformation_stack.dashboards_private_kinesis[0].outputs["KinesisFirehoseDeliveryStreamArn"] : var.logging_option == "option3" ? aws_cloudformation_stack.dashboards-option3-regional[0].outputs["KinesisFirehoseDeliveryStreamArn"] : null
      }
    })
  }
}
