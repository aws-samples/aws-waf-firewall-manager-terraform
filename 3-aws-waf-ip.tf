#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

#-----use this resource to create your own IP Set and AWS WAF IP Rule ----------------------------
# Not part of AWS FM WAF policy by default
resource "aws_wafv2_ip_set" "AllowListsSet" {
  provider           = aws.regional
  for_each           = var.allow_lists_set
  name               = "${var.regional_policy_name}-Allowt_${var.allow_lists_set[each.key]["ip_address_version"]}"
  scope              = "REGIONAL"
  ip_address_version = var.allow_lists_set[each.key]["ip_address_version"]
  addresses          = var.allow_lists_set[each.key]["addresses"]

  tags = local.common_tags
}

resource "aws_wafv2_ip_set" "BlockListsSet" {
  provider           = aws.regional
  for_each           = var.block_lists_set
  name               = "${var.regional_policy_name}-Block_${var.block_lists_set[each.key]["ip_address_version"]}"
  scope              = "REGIONAL"
  ip_address_version = var.block_lists_set[each.key]["ip_address_version"]
  addresses          = var.block_lists_set[each.key]["addresses"]

  tags = local.common_tags
}

# Not part of AWS FM WAF policy by default
resource "aws_wafv2_rule_group" "IPRuleGroup" {
  count       = var.create_waf_ip_rule_group ? 1 : 0
  provider    = aws.regional
  name        = "${var.regional_policy_name}-IP"
  scope       = "REGIONAL"
  capacity    = 60
  description = "IP Rule Group"

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAFCUSTIPRuleGroupMetric"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "IPAllowListsRule"
    priority = 3

    action {
      allow {}
    }

    statement {

      or_statement {
        dynamic "statement" {
          for_each = aws_wafv2_ip_set.AllowListsSet
          content {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.AllowListsSet[statement.key].arn
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPAllowListsRule-metric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "IPBlockListsRule"
    priority = 1

    action {
      block {}
    }

    statement {

      or_statement {
        dynamic "statement" {
          for_each = aws_wafv2_ip_set.BlockListsSet
          content {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.BlockListsSet[statement.key].arn
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPBlockListsRule-metric"
      sampled_requests_enabled   = true
    }
  }
}
