#
# Copyright Amazon.com, Inc. and its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License. See the LICENSE accompanying this file
# for the specific language governing permissions and limitations under
# the License.
#

#------------Deployment

variable "master_region" {
  type        = string
  description = "region for provider of master account"
  default     = "eu-west-1"
}

variable "application_region" {
  type        = string
  description = "region for provider of application account (regional scope)"
  default     = "eu-west-1"
}

variable "create_global_fms_waf_policy" {
  type        = bool
  description = "enable or disable the creation of AWS Firewall Manager WAF policy with GLOBAL scope"
  default     = true
}

variable "create_regional_fms_waf_policy" {
  type        = bool
  description = "enable or disable the creation of AWS Firewall Manager WAF policy with REGIONAL scope"
  default     = true
}

variable "create_waf_geo_rule_group" {
  type        = bool
  description = "enable or disable the creation of AWS WAF rule group with Geolocation (it is not part of AWS Firewall Manager Policy by default)"
  default     = false
}

variable "create_waf_regex_rule_group" {
  type        = bool
  description = "enable or disable the creation of AWS WAF rule group with Regex pattern (it is not part of AWS Firewall Manager Policy by default)"
  default     = false
}

variable "create_waf_sqli_rule_group" {
  type        = bool
  description = "enable or disable the creation of AWS WAF rule group with SQLi rule (it is not part of AWS Firewall Manager Policy by default)"
  default     = false
}

variable "create_waf_xss_rule_group" {
  type        = bool
  description = "enable or disable the creation of AWS WAF rule group with XSS rule (it is not part of AWS Firewall Manager Policy by default)"
  default     = false
}

variable "create_waf_ip_rule_group" {
  type        = bool
  description = "enable or disable the creation of AWS WAF rule group with IP set (it is not part of AWS Firewall Manager Policy by default)"
  default     = false
}

variable "logging_option" {
  type        = string
  description = "variable that defines the logging resources to create"
  default     = "option1"
}


#------------Firewall manager - policies
variable "global_policy_name" {
  type        = string
  description = "Name for WAF policy created by AWS Firewall manager"
  default     = "PoCCFrontPolicy_global"
}

variable "global_policy_exclude_resource_tags" {
  type    = bool
  default = false
}

variable "global_policy_remediation_enabled" {
  type        = bool
  description = "enable or disable auto remediation"
  default     = true
}

variable "global_policy_orgunit_list" {
  type        = list(string)
  description = "org units to apply web acl"
  default     = [""]
}

variable "global_policy_resource_tags" {
  type        = any
  description = "map of resource tags that aws firewall manager will check to associate web acl"
  /* default = {
    "AWS_WAF"     = "Enabled",
    "Environment" = "poc",
    "Type"        = "edge"
  } */

  default = {}
}

variable "global_policy_overrideCustomerWebACLAssociation" {
  type        = bool
  description = "enable or disable override web acl association"
  default     = true
}

variable "global_policy_default_action" {
  type        = string
  description = "Default action of WebACL: ALLOW or DENY"
  default     = "ALLOW"
}

variable "regional_policy_name" {
  type        = string
  description = "Name for WAF policy created by AWS Firewall manager"
  default     = "ApplicationPoCPolicy"
}

variable "regional_policy_exclude_resource_tags" {
  type    = bool
  default = false
}

variable "regional_policy_remediation_enabled" {
  type        = bool
  description = "enable or disable auto remediation"
  default     = true
}

variable "regional_policy_orgunit_list" {
  type        = list(string)
  description = "org units to apply web acl"
  default     = [""]
}

variable "regional_policy_resource_tags" {
  type        = any
  description = "map of resource tags that aws firewall manager will check to associate web acl"
  default = {}
}

variable "regional_policy_overrideCustomerWebACLAssociation" {
  type        = bool
  description = "enable or disable override web acl association"
  default     = true
}

variable "regional_policy_default_action" {
  type        = string
  description = "Default action of WebACL: ALLOW or DENY"
  default     = "ALLOW"
}


# ------------ AWS WAF Custom rules
variable "allow_lists_set" {
  type = map(object({
    ip_address_version = string
    addresses          = list(string)
  }))

  default = {
    set1 = {
      ip_address_version = "IPV4"
      addresses          = ["10.10.0.0/24"]
    },
    set2 = {
      ip_address_version = "IPV6"
      addresses          = ["2001:db8:1234::/48"]
    }
  }

}

variable "block_lists_set" {
  type = map(object({
    ip_address_version = string
    addresses          = list(string)
  }))

  default = {
    set1 = {
      ip_address_version = "IPV4"
      addresses          = ["198.31.0.0/24", "1.1.1.1/32"]
    },
    set2 = {
      ip_address_version = "IPV6"
      addresses          = ["2001:db8:a::/64"]
    }
  }

}

variable "waf_rule_geo_country_list" {
  type        = list(string)
  description = "List of country codes to block with AWS WAF geolocation rule group"
  default     = ["KP"]
}

variable "HTTPPostLoginParam" {
  type        = string
  description = "Enter the URI for a Login page to rate-limit IP addresses from login attemps."
  default     = "login"
}

#------------Firewall manager - logging
variable "kinesis_firehose_name" {
  type        = string
  description = "name for kinesis firehose that is the aws waf logging destination"
  default     = "aws-waf-logs-test"
}

variable "kinesis_destination_s3_name" {
  type        = string
  description = "name for s3 bucket that is the target of kinesis firehose"
  default     = "test-waf-logs-poc-s3"
}

variable "kinesis_prefix" {
  type        = string
  description = "name for log prefix"
  default     = "waf-logs"
}

variable "s3_delivery_buffer_interval" {
  type        = number
  default     = 60
}

variable "s3_delivery_buffer_size" {
  type        = number
  default     = 5
}

variable "DataNodeEBSVolumeSize" {
  type        = number
  description = "Volume side for ES Data Nodes"
  default     = 500
}

variable "ESConfigBucket" {
  type        = string
  description = "Name for ES Config Bucket"
  default     = "waf-dash-ES-config-1111"
}

variable "ESUserEmail" {
  type        = string
  description = "Name for ES Config Bucket"
  default     = "X@amazon.com"
}

variable "ES_SSH_tunnel_instance_type" {
  type        = string
  description = "instance type of SSH instance tunnel"
  default     = "t3.micro"
}

variable "ES_SSH_tunnel_amid_id_regional" {
  type        = string
  description = "instance type of SSH instance tunnel"
  default     = "ami-058b1b7fe545997ae"
}

variable "ES_SSH_tunnel_amid_id_global" {
  type        = string
  description = "instance type of SSH instance tunnel"
  default     = "ami-01cc34ab2709337aa"
}

variable "ES_SSH_tunnel_key_name" {
  type        = string
  description = "key pair name of SSH instance tunnel"
  default     = "kibana"
}

variable "ES_SSH_tunnel_allowed_CIDR" {
  type        = list(string)
  description = "list of CIDR to allow access to SSH tunnel"
  default     = ["192.168.0.21/32"]
}