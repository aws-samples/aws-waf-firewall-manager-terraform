#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

#-----use this resource to create your own Regex rules ----------------------------
# Not part of AWS FM WAF policy by default
resource "aws_wafv2_regex_pattern_set" "UnixInjectionRegexPatternSet" {
  count       = var.create_waf_regex_rule_group ? 1 : 0
  provider    = aws.regional
  name        = "${var.regional_policy_name}-RegexPatternSet"
  scope       = "REGIONAL"
  description = "This is the RegexPatternSets"

  regular_expression {
    regex_string = "(?i)(?:(?:(?:;|{|\\()|\\||\\|\\||&|&&|\\$(?:\\(|\\(\\(|{)|`|(?:<|>)\\(|!|\\$|'|\"|\\(\\)\\()\\s*(?:cat\\s+|whoami|id|netstat|ls|system|ping|nslookup|echo\\s+|curl|wget|history|iconfig|hostname|uname|pwd|last))\\b"
  }

  regular_expression {
    regex_string = "(?i)(?:(?:(?:;|{|\\()|\\||\\|\\||&|&&|\\$(?:\\(|\\(\\(|{)|`|(?:<|>)\\(|!|\\$|'|\"|\\(\\)\\()\\s*(?:awk|bash|chmod|chown|cd|chroot|bind|arp|nc|ncat|perl|sleep|phpinfo\\(|command\\s+|eval|locate\\s+|find|cp\\s+))\\b"
  }
  /* 
  regular_expression {
    regex_string = "(?i)(?:(?:(?:;|{|()||||||&|&&|$(?:(|((|{)|`|(?:<|>)(|!|$|'|\"|()()s*(?:greps+|env|locates+|nmap|apt-get|yum|nano|rms+|touchs+|mkdirs+|zsh))b"
  }
  
  regular_expression {
    regex_string = "(?i)(?:w+=(?:[^s]*|$.*|$.*|<.*|>.*|'.*'|\".*\")s+)(?:cats+|whoami|id|netstat|ls|system|ping|nslookup|echos+|curl|wget|history|iconfig|hostname|uname|pwd|last)b"
  }
  
  regular_expression {
    regex_string = "(?i)(?:w+=(?:[^s]*|$.*|$.*|<.*|>.*|'.*'|\".*\")s+)(?:awk|bash|chmod|chown|cd|chroot|bind|arp|nc|ncat|perl|sleep|commands+|eval|locates+|find|cps+)b"
  }

  regular_expression {
    regex_string = "(?i)(?:w+=(?:[^s]*|$.*|$.*|<.*|>.*|'.*'|\".*\")s+)(?:greps+|env|locates+|nmap|apt-get|yum|nano|rms+|touchs+|mkdirs+|zsh)b"
  }

  regular_expression {
    regex_string = "(?i)(?:[?*[]()-|+w'\"./]+/)+?(?:cat|whoami|id|netstat|ls|system|ping|nslookup|echo|curl|wget|history|iconfig|hostname|uname|pwd|last)b"
  } */

  /*   regular_expression {
    regex_string = "(?i)(?:[?*[]()-|+w'\"./]+/)+?(?:awk|bash|chmod|chown|cd|chroot|bind|arp|nc|ncat|perl|sleep)b"
  } */

  /*   regular_expression {
    regex_string = "(?i)(?:[?*[]()-|+w'\"./]+/)+?(?:grep|env|locate|nmap|apt-get|yum|nano|rms+|touchs+|mkdirs+|zsh)b"
  }

  regular_expression {
    regex_string = "ShellExecute()|(?i)(?:runtime.exec|system|exec|eval|os.system|os.popen|subprocess.(?:popen|call)|shell_exec|proc_open|passthru)(.*?)"
  } */


}

# Not part of AWS FM WAF policy by default
resource "aws_wafv2_regex_pattern_set" "HostMatchingRegexPatternSet" {
  count       = var.create_waf_regex_rule_group ? 1 : 0
  provider    = aws.regional
  name        = "${var.regional_policy_name}-HostMatchingRegexPatternSet"
  description = "This is the Regex pattern set for header host match"
  scope       = "REGIONAL"

  regular_expression {
    regex_string = "(?:d{1,3}.){3}d{1,3}"
  }

  regular_expression {
    regex_string = "ec2-(?:d{1,3}-){3}d{1,3}"
  }

  tags = local.common_tags
}

# Not part of AWS FM WAF policy by default
resource "aws_wafv2_rule_group" "UnixOSInjectionRG" {
  count    = var.create_waf_regex_rule_group ? 1 : 0
  provider = aws.regional
  name     = "${var.regional_policy_name}-UnixOSInjectionRG"
  scope    = "REGIONAL"
  capacity = 150

  rule {
    name     = "UnixInjectionQueryArguments"
    priority = 1

    action {
      block {}
    }

    statement {
      regex_pattern_set_reference_statement {
        arn = aws_wafv2_regex_pattern_set.UnixInjectionRegexPatternSet[0].arn

        field_to_match {
          all_query_arguments {
          }
        }

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "UnixInjectionQueryArguments"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "UnixInjectionCookie"
    priority = 2

    action {
      block {}
    }

    statement {
      regex_pattern_set_reference_statement {
        arn = aws_wafv2_regex_pattern_set.UnixInjectionRegexPatternSet[0].arn

        field_to_match {
          single_header {
            name = "cookie"
          }
        }

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "UnixInjectionCookie"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "UnixInjectionBody"
    priority = 3

    action {
      block {}
    }

    statement {
      regex_pattern_set_reference_statement {
        arn = aws_wafv2_regex_pattern_set.UnixInjectionRegexPatternSet[0].arn

        field_to_match {
          body {}
        }

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "UnixInjectionBody"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "UnixInjectionURIPath"
    priority = 4

    action {
      block {}
    }

    statement {
      regex_pattern_set_reference_statement {
        arn = aws_wafv2_regex_pattern_set.UnixInjectionRegexPatternSet[0].arn

        field_to_match {
          uri_path {}
        }

        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "UnixInjectionURIPath"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "UnixInjectionRuleGroup"
    sampled_requests_enabled   = true
  }
}
