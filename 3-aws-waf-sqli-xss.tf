
#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

#-----use this resource to create your own SQLi rules ----------------------------
# Not part of AWS FM WAF policy by default
resource "aws_wafv2_rule_group" "SQLiInjectionRG" {
  count    = var.create_waf_sqli_rule_group ? 1 : 0
  provider = aws.regional
  name     = "${var.regional_policy_name}-SQLiInjectionRG"
  scope    = "REGIONAL"
  capacity = 250

  rule {
    name     = "SQLInjectionQueryArguments"
    priority = 1

    action {
      block {}
    }

    statement {
      sqli_match_statement {

        field_to_match {
          all_query_arguments {
          }
        }

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }

        text_transformation {
          priority = 2
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLInjectionQueryArguments"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "SQLInjectionCookie"
    priority = 2

    action {
      block {}
    }

    statement {
      sqli_match_statement {

        field_to_match {
          single_header {
            name = "cookie"
          }
        }

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }

        text_transformation {
          priority = 2
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLInjectionCookie"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "SQLInjectionBody"
    priority = 3

    action {
      block {}
    }

    statement {
      sqli_match_statement {

        field_to_match {
          body {}
        }

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }

        text_transformation {
          priority = 2
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLInjectionBody"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "SQLInjectionURIPath"
    priority = 4

    action {
      block {}
    }

    statement {
      sqli_match_statement {

        field_to_match {
          uri_path {}
        }

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }

        text_transformation {
          priority = 2
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLInjectionURIPath"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "SQLInjectionAuth"
    priority = 5

    action {
      block {}
    }

    statement {
      sqli_match_statement {

        field_to_match {
          single_header {
            name = "authorization"
          }
        }

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }

        text_transformation {
          priority = 2
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLInjectionAuth"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "SQLInjectionRuleGroup"
    sampled_requests_enabled   = true
  }
}


#-----use this resource to create your own Xss rules ----------------------------
# Not part of AWS FM WAF policy by default
resource "aws_wafv2_rule_group" "XssMatchRG" {
  count    = var.create_waf_xss_rule_group ? 1 : 0
  provider = aws.regional
  name     = "${var.regional_policy_name}-XssMatchRG"
  scope    = "REGIONAL"
  capacity = 350

  rule {
    name     = "XSSQueryArguments"
    priority = 1

    action {
      block {}
    }

    statement {
      xss_match_statement {

        field_to_match {
          all_query_arguments {
          }
        }

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }

        text_transformation {
          priority = 2
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "XSSQueryArguments"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "XSSCookie"
    priority = 2

    action {
      block {}
    }

    statement {
      xss_match_statement {

        field_to_match {
          single_header {
            name = "cookie"
          }
        }

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }

        text_transformation {
          priority = 2
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "XSSCookie"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "XSSBody"
    priority = 3

    action {
      block {}
    }

    statement {
      xss_match_statement {

        field_to_match {
          body {}
        }

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }

        text_transformation {
          priority = 2
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "XSSBody"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "XSSURIPath"
    priority = 4

    action {
      block {}
    }

    statement {
      xss_match_statement {

        field_to_match {
          uri_path {}
        }

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }

        text_transformation {
          priority = 2
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "XSSURIPath"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "XSSAuth"
    priority = 5

    action {
      block {}
    }

    statement {
      xss_match_statement {

        field_to_match {
          single_header {
            name = "authorization"
          }
        }

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }

        text_transformation {
          priority = 2
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "XSSAuth"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "XssRuleGroup"
    sampled_requests_enabled   = true
  }
}