#------------Deployment
master_region = "eu-west-1"
application_region = "eu-west-1"
create_global_fms_waf_policy = true
create_regional_fms_waf_policy = true
create_waf_geo_rule_group = true
create_waf_regex_rule_group = false
create_waf_sqli_rule_group = false
create_waf_xss_rule_group = false
create_waf_ip_rule_group = false
logging_option = "option1"

#------------Firewall manager - policies
global_policy_name = "PoCCFrontPolicy_global"
global_policy_exclude_resource_tags = false
global_policy_remediation_enabled = true
global_policy_orgunit_list = ["ou-xxxxx", "ou-xxxx"] #please customize
global_policy_resource_tags = {
     "AWS_WAF"     = "Enabled",
     "Environment" = "poc",
     "Type"        = "edge"   
}
global_policy_overrideCustomerWebACLAssociation = true
global_policy_default_action = "ALLOW"
regional_policy_name = "ApplicationPoCPolicy"
regional_policy_exclude_resource_tags = false
regional_policy_remediation_enabled = false
regional_policy_orgunit_list = ["ou-xxxxx", "ou-xxxx"] #please customize
regional_policy_resource_tags = {
     "AWS_WAF"     = "Enabled",
     "Environment" = "poc",
     "Type"        = "edge"   
}
regional_policy_overrideCustomerWebACLAssociation = true 
regional_policy_default_action = "ALLOW"

#------------Firewall manager - logging
kinesis_firehose_name =  "aws-waf-logs-poc"
kinesis_destination_s3_name = "test-waf-logs-xxxx"
kinesis_prefix = "waf-logs"
s3_delivery_buffer_interval = 60
s3_delivery_buffer_size = 5
DataNodeEBSVolumeSize = 500
ESConfigBucket = "waf-dash-xxxxxx"
ESUserEmail = "adf@amazon.com"
ES_SSH_tunnel_allowed_CIDR = ["192.168.0.21/32"] #please customize