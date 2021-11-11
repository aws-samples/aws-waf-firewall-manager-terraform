#-----------Identifiers and tags

variable "vpc_name" {
  description = "[Required] Name to be used for the vpc and all the resources as identifier"
  type        = string
}

variable "vpc_suffix" {
  description = "[optional] suffix to append to the VPC name"
  type        = string
  default = ""
}

variable "tags" {
  description = "[optional] A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

#-----------VPC CIDR blocks

variable "vpc_main_cidr" {
  description = "[Required] The main CIDR block for the VPC"
  type        = string
}


variable "enable_ipv6" {
  description = "[optional] Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block."
  type        = bool
  default     = false
}

variable "secondary_cidr_blocks" {
  description = "[optional] List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
  type        = list(string)
  default     = []
}


#-----------VPC characteristics


variable "enable_dns_hostnames" {
  description = "[optional] Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "[optional] Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}


variable "instance_tenancy" {
  description = "[optional] A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "enable_internet_gateway" {
  description = "[optional] Should be true if you want to provision Internet Gateways for your public subnets"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "[optional] Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

#-----------subnet characteristics

variable "number_AZ" {
  description = "[optional] This field is used if you need to create more than one subnet per AZ. Specify the number of AZ's (default 2). In the variable *_subnets_cidr_list, the order should be [CIDR subnet 1 AZ A, CIDR subnet 2 AZ B, CIDR subnet 3 AZ A...]"
  type        = number
  default     = 2
}

variable "private_subnets_cidr_list" {
  description = "[optional] A list of private subnet CIDR blocks inside the VPC (for endpoints, eni, etc.)."
  type        = list(string)
  default     = []
}

variable "private_subnets_suffix" {
  description = "[optional] Suffix to append to private subnets name"
  type        = string
  default     = "private"
}

variable "private_subnets_internet_access_nat_gw" {
  description = "[optional] connectivity with nat gw. Boolean. False by default."
  type        = bool
  default     = false
}

variable "tgw_subnets_cidr_list" {
  description = "[optional] A list of transit gateway private subnets CIDR blocks inside the VPC (for endpoints, eni, etc.)"
  type        = list(string)
  default     = []
}

variable "tgw_subnets_suffix" {
  description = "[optional] Suffix to append to transit gateway private subnets name"
  type        = string
  default     = "tgw-private"
}

variable "tgw_subnets_internet_access_nat_gw" {
  description = "[optional] connectivity with nat gw. Boolean. False by default."
  type        = bool
  default     = false
}

variable "fw_subnets_cidr_list" {
  description = "[optional] A list of network firewall subnets CIDR blocks inside the VPC (for endpoints, eni, etc.)"
  type        = list(string)
  default     = []
}

variable "fw_subnets_suffix" {
  description = "[optional] Suffix to append to network firewall subnets name"
  type        = string
  default     = "network-fw"
}

variable "fw_subnets_internet_access_nat_gw" {
  description = "[optional] connectivity with nat gw. Boolean. False by default."
  type        = bool
  default     = false
}


variable "public_subnets_cidr_list" {
  description = "[optional] A list of public subnet CIDR blocks inside the VPC"
  type        = list(string)
  default     = []
}

variable "public_subnets_internet_access_igw" {
  description = "[optional] connectivity with igw. Boolean. True by default."
  type        = bool
  default     = true
}

variable "public_subnets_suffix" {
  description = "[optional] Suffix to append to public subnets name"
  type        = string
  default     = "public"
}


variable "map_public_ip_on_launch" {
  description = "[optional] pecify true to indicate that instances launched into the subnet should be assigned a public IP address."
  type        = string
  default     = false
}

variable "web_tier_subnets_cidr_list" {
  description = "[optional] A list of web tier subnet CIDR blocks inside the VPC"
  type        = list(string)
  default     = []
}

variable "web_subnets_suffix" {
  description = "[optional] Suffix to append to web subnets name"
  type        = string
  default     = "web"
}

variable "web_subnets_internet_access_nat_gw" {
  description = "[optional] connectivity with nat gw. Boolean. False by default."
  type        = bool
  default     = false
}

variable "pres_tier_subnets_cidr_list" {
  description = "[optional] A list of presentation tier subnet CIDR blocks inside the VPC"
  type        = list(string)
  default     = []
}

variable "pres_subnets_suffix" {
  description = "[optional] Suffix to append to presentation subnets name"
  type        = string
  default     = "presentation"
}


variable "database_tier_subnets_cidr_list" {
  description = "[optional] A list of database tier subnet CIDR blocks inside the VPC"
  type        = list(string)
  default     = []
}

variable "database_subnets_suffix" {
  description = "[optional] Suffix to append to database subnets name"
  type        = string
  default     = "database"
}

variable "outposts_subnets_cidr_list" {
  description = "[optional] A list of outposts subnet CIDR blocks inside the VPC"
  type        = list(string)
  default     = []
}

variable "coip_auto_assign" {
  description = "[optional] true if customer owned ip address pool has to be associated with outpost subnets"
  type        = bool
  default     = false
}

variable "outposts_subnets_suffix" {
  description = "[optional] Suffix to append to outposts subnets name"
  type        = string
  default     = "outposts"
}

variable "outposts_arn" {
  description = "[optional] Arn of the outposts where the subnets will be launched"
  type        = string
  default     = ""
}

#variable "associate_vpc_with_local_gw_route_table" {
#  description = "[optional] create an association between outposts local gateway route table and vpc"
#  type        = bool
#  default     = false
#}

variable "outposts_route_to_LGW_destination" {
  description = "[optional] IPv4 CIDR block destination to route to LGW in outposts subnet"
  type        = string
  default     = ""
}

variable "outposts_local_gateway_id" {
  description = "[optional] Outposts local gateway ID"
  type        = string
  default     = ""
}



#---------SSM


variable "enable_ssm" {
  description = "[optional] Enable SSM for EC2 instances. If true, IAM role and endpoints will be deployed."
  type        = bool
  default     = false
}

variable "enable_s3_endpoint" {
  description = "[optional] True to create an S3 VPC gateway endpoint."
  type        = bool
  default     = true
}

variable "create_iam_role_ssm" {
  description = "[optional] Enable or disable the creation of an IAM role for EC2 instances to connect using SSM"
  type        = bool
  default     = true
}

#---------DHCP OPTIONS

variable "enable_dhcp_options" {
  description = "[optional] Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
  type        = bool
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "[optional] Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "[optional] Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  description = "[optional] Specify a list of NTP servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "[optional] Specify a list of netbios servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_node_type" {
  description = "[optional] Specify netbios node_type for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

#-----------FLOW LOGS
variable "enable_flow_log" {
  description = "[optional] Whether or not to enable CW VPC Flow Logs"
  type        = bool
  default     = false
}

variable "create_flow_log_cloudwatch_log_group" {
  description = "[optional] Whether to create CloudWatch log group for VPC Flow Logs"
  type        = bool
  default     = false
}

variable "create_flow_log_cloudwatch_iam_role" {
  description = "[optional] Whether to create IAM role for VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_log_traffic_type" {
  description = "[optional] The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL."
  type        = string
  default     = "ALL"
}

variable "flow_log_destination_type" {
  description = "[optional] Type of flow log destination. Can be s3 or cloud-watch-logs."
  type        = string
  default     = "cloud-watch-logs"
}

variable "flow_log_log_format" {
  description = "[optional] The fields to include in the flow log record, in the order in which they should appear."
  type        = string
  default     = null
}

variable "flow_log_destination_arn" {
  description = "[optional] The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket the appropriate permissions need to be set on that bucket's policy. When create_flow_log_cloudwatch_log_group is set to false this argument must be provided."
  type        = string
  default     = ""
}

variable "flow_log_cloudwatch_iam_role_arn" {
  description = "[optional] The ARN for the IAM role that's used to post flow logs to a CloudWatch Logs log group. When flow_log_destination_arn is set to ARN of Cloudwatch Logs, this argument needs to be provided."
  type        = string
  default     = ""
}

variable "flow_log_cloudwatch_log_group_name_prefix" {
  description = "[optional] Specifies the name prefix of CloudWatch Log Group for VPC flow logs."
  type        = string
  default     = "/aws/vpc-flow-log/"
}

variable "flow_log_cloudwatch_log_group_retention_in_days" {
  description = "[optional] Specifies the number of days you want to retain log events in the specified log group for VPC flow logs."
  type        = number
  default     = null
}

