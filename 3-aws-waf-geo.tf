#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

#-----use this resource to create your geo location rule ----------------------------
# Not part of AWS FM WAF policy by default
resource "aws_wafv2_rule_group" "GeoRuleGroup" {
  count    = var.create_waf_geo_rule_group ? 1 : 0
  provider = aws.regional
  name     = "${var.regional_policy_name}-GeoRuleGroup"
  scope    = "REGIONAL"
  capacity = 60

  rule {
    name     = "GeoLocation-Based-BlockList"
    priority = 1

    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = var.waf_rule_geo_country_list
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "GeoLocation-BlockList-metric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAFCUSTGeoRuleGroupMetric"
    sampled_requests_enabled   = true
  }
}
