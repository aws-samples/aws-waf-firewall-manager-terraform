###################
# VPC 
###################

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_main_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}${var.vpc_suffix}"
    },
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  count = length(var.secondary_cidr_blocks)
  vpc_id = aws_vpc.vpc.id
  cidr_block = element(var.secondary_cidr_blocks, count.index)
}

###################
# DHCP Options Set
###################
resource "aws_vpc_dhcp_options" "this" {
  count = var.enable_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-DHCP-OPTIONS"
    },
  )
}


resource "aws_vpc_dhcp_options_association" "this" {
  count = var.enable_dhcp_options ? 1 : 0

  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

################
# Publiс Subnets
################
resource "aws_subnet" "subnet_public" {
  count             = length(var.public_subnets_cidr_list)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnets_cidr_list[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index%var.number_AZ]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.public_subnets_suffix}-subnet-${count.index}"
    },
  )
}


################
# Private Subnets
################

resource "aws_subnet" "subnet_priv" {
  count             = length(var.private_subnets_cidr_list)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets_cidr_list[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index%var.number_AZ]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.private_subnets_suffix}-subnet-${count.index}"
    },
  )
}

################
# Private TGW Endpoint Subnets
################

resource "aws_subnet" "subnet_priv_tgw" {
  count             = length(var.tgw_subnets_cidr_list)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.tgw_subnets_cidr_list[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index%var.number_AZ]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.tgw_subnets_suffix}-subnet-${count.index}"
    },
  )
}


################
# Network Firewall Endpoint Subnets
################

resource "aws_subnet" "subnet_fw" {
  count             = length(var.fw_subnets_cidr_list)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.fw_subnets_cidr_list[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index%var.number_AZ]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.fw_subnets_suffix}-subnet-${count.index}"
    },
  )
}

################
# Web Tier Subnets
################

resource "aws_subnet" "subnet_web_tier" {
  count             = length(var.web_tier_subnets_cidr_list)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.web_tier_subnets_cidr_list[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index%var.number_AZ]

  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.web_subnets_suffix}-subnet-${count.index}"
    },
  )
}

################
# Presentation Tier Subnets
################

resource "aws_subnet" "subnet_pres_tier" {
  count             = length(var.pres_tier_subnets_cidr_list)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pres_tier_subnets_cidr_list[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index%var.number_AZ]

  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.pres_subnets_suffix}-subnet-${count.index}"
    },
  )
}

################
# Database Tier Subnets
################

resource "aws_subnet" "subnet_database_tier" {
  count             = length(var.database_tier_subnets_cidr_list)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.database_tier_subnets_cidr_list[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index%var.number_AZ]

  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.database_subnets_suffix}-subnet-${count.index}"
    },
  )
}

################
# Outposts Subnets
################

#Question: do we need to have the option to create one? how to see in the console the one associated with lgw? 
data "aws_ec2_coip_pool" "coip" {
  count = var.outposts_arn != "" ? 1 : 0
  filter {
     name   = "coip-pool.local-gateway-route-table-id"  
     values = [data.aws_ec2_local_gateway_route_table.outposts_lgw_route_table[0].local_gateway_route_table_id]
  }
}

data "aws_outposts_outpost" "target_outpost" {
  count = var.outposts_arn != "" ? 1 : 0
  arn = var.outposts_arn
}
 
resource "aws_subnet" "subnet_outposts" {
  count             = var.outposts_arn != "" ? length(var.outposts_subnets_cidr_list) : 0
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.outposts_subnets_cidr_list[count.index]
  availability_zone_id = data.aws_outposts_outpost.target_outpost[0].availability_zone_id
  
  map_customer_owned_ip_on_launch = var.coip_auto_assign ? true : null 
  customer_owned_ipv4_pool = var.coip_auto_assign ? data.aws_ec2_coip_pool.coip[0].id : null 

  outpost_arn       = var.outposts_arn

  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-${var.outposts_subnets_suffix}-subnet-${count.index}"
    },
  )
}


###################
# Internet Gateway
###################

resource "aws_internet_gateway" "igw" {
  count = var.enable_internet_gateway && length(var.public_subnets_cidr_list) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-IGW"
    },
  )
}

################
# NAT GW
################
resource "aws_egress_only_internet_gateway" "egress_gw" {
  count = var.enable_nat_gateway && var.enable_ipv6 && length(var.public_subnets_cidr_list) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
}

# HIGH AVAILABILITY
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway && length(var.public_subnets_cidr_list) >= var.number_AZ ? var.number_AZ : 0
  vpc = true
  
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-NAT-EIP-${count.index}"
    },
  )
  
}

resource "aws_nat_gateway" "natgw" {
  count =  var.enable_nat_gateway && length(var.public_subnets_cidr_list) >= var.number_AZ ? var.number_AZ : 0
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.subnet_public[count.index].id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-NAT-GW-${count.index}"
    },
  )

}

#IF just one public subnet - not highly available

resource "aws_eip" "nat-one-az" {
  count = var.enable_nat_gateway && length(var.public_subnets_cidr_list) < var.number_AZ  ? 1 : 0
  vpc = true
  
  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-NAT-EIP-one-AZ"
    },
  )
  
}

resource "aws_nat_gateway" "natgw-one-az" {
  count =  var.enable_nat_gateway && length(var.public_subnets_cidr_list) < var.number_AZ ? 1 : 0
  
  allocation_id = aws_eip.nat-one-az[count.index].id
  subnet_id = aws_subnet.subnet_public[count.index].id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.vpc_name}-NAT-GW-one-AZ"
    },
  )

}


################
# Publiс routes
################
resource "aws_route_table" "subnet_public_route_table" {
  depends_on = [aws_internet_gateway.igw]
  count  = length(var.public_subnets_cidr_list) > 0 ? length(var.public_subnets_cidr_list) : 0
  vpc_id = aws_vpc.vpc.id
  
  tags = merge(
    var.tags,
    {
      "Purpose" = "Route to internet for public subnets"
      "Name"    = "${var.vpc_name}-PublicRouteTable-${count.index}"
    },
  )
}

resource "aws_route" "public_internet_gateway" {
  count = var.enable_internet_gateway && length(var.public_subnets_cidr_list)> 0 && var.public_subnets_internet_access_igw ? length(var.public_subnets_cidr_list) : 0

  route_table_id              = aws_route_table.subnet_public_route_table[count.index].id
  destination_cidr_block      = "0.0.0.0/0"
  gateway_id                  = aws_internet_gateway.igw[0].id
}

resource "aws_route" "public_internet_gateway_ipv6" {
  count = var.enable_ipv6 && length(var.public_subnets_cidr_list) > 0 ? length(var.public_subnets_cidr_list) : 0

  route_table_id              = aws_route_table.subnet_public_route_table[count.index].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.igw[0].id
}

resource "aws_route_table_association" "public_route_assoc" {
  count = length(var.public_subnets_cidr_list)
  subnet_id      = aws_subnet.subnet_public[count.index].id
  route_table_id = aws_route_table.subnet_public_route_table[count.index].id
}


#################
# Private routes
#################

resource "aws_route_table" "subnet_priv_route_table" {
  count  = length(var.private_subnets_cidr_list)
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Purpose" = "Route table for private subnets"
      "Name"    = "${var.vpc_name}-PrivateRoutable-${count.index}"
    },
  )
}

resource "aws_route" "private_nat_gateway" {
  depends_on = [aws_nat_gateway.natgw]
  count = var.enable_nat_gateway && length(var.public_subnets_cidr_list) > 0 && var.private_subnets_internet_access_nat_gw ? length(var.private_subnets_cidr_list) : 0

  route_table_id         = aws_route_table.subnet_priv_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = length(var.public_subnets_cidr_list) == 1 ? aws_nat_gateway.natgw-one-az[0].id : aws_nat_gateway.natgw[count.index%var.number_AZ].id 

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "private_ipv6_egress" {
  count = var.enable_nat_gateway && var.enable_ipv6 && var.private_subnets_internet_access_nat_gw  ? length(var.private_subnets_cidr_list) : 0
  route_table_id              = aws_route_table.subnet_priv_route_table[count.index].id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.egress_gw[0].id
}

resource "aws_route_table_association" "priv_route_assoc" {
  count = length(var.private_subnets_cidr_list)
  subnet_id      = aws_subnet.subnet_priv[count.index].id
  route_table_id = aws_route_table.subnet_priv_route_table[count.index].id
}

#################
# Transit GW route table
#################

resource "aws_route_table" "subnet_priv_tgw_route_table" {
  count  = length(var.tgw_subnets_cidr_list)
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Purpose" = "Route table for TGW endpoint subnets"
      "Name"    = "${var.vpc_name}-TGWPrivateRoutable-${count.index}"
    },
  )
}

resource "aws_route" "private_gw_nat_gateway" {
  depends_on = [aws_nat_gateway.natgw]
  count = var.enable_nat_gateway && length(var.public_subnets_cidr_list) > 0 && var.tgw_subnets_internet_access_nat_gw? length(var.tgw_subnets_cidr_list) : 0

  route_table_id         = aws_route_table.subnet_priv_tgw_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = length(var.public_subnets_cidr_list) == 1 ? aws_nat_gateway.natgw-one-az[0].id : aws_nat_gateway.natgw[count.index%var.number_AZ].id 

  timeouts {
    create = "5m"
  }
}


resource "aws_route_table_association" "priv_tgw_route_assoc" {
  count = length(var.tgw_subnets_cidr_list)
  subnet_id      = aws_subnet.subnet_priv_tgw[count.index].id
  route_table_id = aws_route_table.subnet_priv_tgw_route_table[count.index].id
}

#################
# Network FW route table
#################

resource "aws_route_table" "subnet_fw_route_table" {
  count  = length(var.fw_subnets_cidr_list)
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Purpose" = "Route table for network FW subnets"
      "Name"    = "${var.vpc_name}-NetworkFWRoutable-${count.index}"
    },
  )
}

resource "aws_route" "fw_nat_gateway" {
  depends_on = [aws_nat_gateway.natgw]
  count = var.enable_nat_gateway && length(var.public_subnets_cidr_list) > 0 && var.tgw_subnets_internet_access_nat_gw ? length(var.fw_subnets_cidr_list) : 0

  route_table_id         = aws_route_table.subnet_fw_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = length(var.public_subnets_cidr_list) == 1 ? aws_nat_gateway.natgw-one-az[0].id : aws_nat_gateway.natgw[count.index%var.number_AZ].id 

  timeouts {
    create = "5m"
  }
}


resource "aws_route_table_association" "fw_route_assoc" {
  count = length(var.fw_subnets_cidr_list)
  subnet_id      = aws_subnet.subnet_fw[count.index].id
  route_table_id = aws_route_table.subnet_fw_route_table[count.index].id
}


#WEB TIER 
resource "aws_route_table" "subnet_web_tier_route_table" {
  count  = length(var.web_tier_subnets_cidr_list)
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Purpose" = "Route table for web tier subnets"
      "Name"    = "${var.vpc_name}-WebTierRoutable-${count.index}"
    },
  )
}

resource "aws_route" "web_nat_gateway" {
  depends_on = [aws_nat_gateway.natgw]
  count = var.enable_nat_gateway && length(var.public_subnets_cidr_list) > 0 && var.web_subnets_internet_access_nat_gw ? length(var.web_tier_subnets_cidr_list) : 0

  route_table_id         = aws_route_table.subnet_web_tier_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = length(var.public_subnets_cidr_list) == 1 ? aws_nat_gateway.natgw-one-az[0].id : aws_nat_gateway.natgw[count.index%var.number_AZ].id 

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "web_ipv6_egress" {
  count = var.enable_nat_gateway && var.enable_ipv6 && var.web_subnets_internet_access_nat_gw  ? length(var.web_tier_subnets_cidr_list) : 0
  route_table_id              = aws_route_table.subnet_web_tier_route_table[count.index].id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.egress_gw[0].id
}

resource "aws_route_table_association" "web_tier_route_assoc" {
  count = length(var.web_tier_subnets_cidr_list)
  subnet_id      = aws_subnet.subnet_web_tier[count.index].id
  route_table_id = aws_route_table.subnet_web_tier_route_table[count.index].id
}

#PRESENTATION TIER 
resource "aws_route_table" "subnet_pres_tier_route_table" {
  count  = length(var.pres_tier_subnets_cidr_list)
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Purpose" = "Route table for presentation tier subnets"
      "Name"    = "${var.vpc_name}-PresTierRoutable-${count.index}"
    },
  )
}

resource "aws_route_table_association" "pres_tier_route_assoc" {
  count = length(var.pres_tier_subnets_cidr_list)
  subnet_id      = aws_subnet.subnet_pres_tier[count.index].id
  route_table_id = aws_route_table.subnet_pres_tier_route_table[count.index].id
}

#DATABASE TIER 
resource "aws_route_table" "subnet_database_tier_route_table" {
  count  = length(var.database_tier_subnets_cidr_list)
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Purpose" = "Route table for database tier subnets"
      "Name"    = "${var.vpc_name}-DatabaseTierRoutable-${count.index}"
    },
  )
}

resource "aws_route_table_association" "database_tier_route_assoc" {
  count = length(var.database_tier_subnets_cidr_list)
  subnet_id      = aws_subnet.subnet_database_tier[count.index].id
  route_table_id = aws_route_table.subnet_database_tier_route_table[count.index].id
}


#OUTPOSTS
resource "aws_route_table" "subnet_outposts_route_table" {
  count             = var.outposts_arn != "" ? length(var.outposts_subnets_cidr_list) : 0
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Purpose" = "Route table for outpost subnets"
      "Name"    = "${var.vpc_name}-outpostsRoutable-${count.index}"
    },
  )
}

resource "aws_route_table_association" "outposts_route_assoc" {
  count             = var.outposts_arn != "" ? length(var.outposts_subnets_cidr_list) : 0
  subnet_id      = aws_subnet.subnet_outposts[count.index].id
  route_table_id = aws_route_table.subnet_outposts_route_table[count.index].id
}

data "aws_ec2_local_gateway_route_table" "outposts_lgw_route_table" {
  count = var.outposts_arn != "" ? 1 : 0
  outpost_arn = var.outposts_arn
}

resource "aws_ec2_local_gateway_route_table_vpc_association" "outposts_lgw_route_table_assoc" {
  count = var.outposts_arn != "" ? 1 : 0
  local_gateway_route_table_id = data.aws_ec2_local_gateway_route_table.outposts_lgw_route_table[0].id
  vpc_id                       = aws_vpc.vpc.id
}

data "aws_ec2_local_gateway" "outposts_lgw" {
  count = var.outposts_arn != "" ? 1 : 0
  filter {
    name = "outpost-arn"
    values = [var.outposts_arn]
  }
}


#route to local gw
resource "aws_route" "outposts_route_to_LGW" {
  depends_on = [
    aws_ec2_local_gateway_route_table_vpc_association.outposts_lgw_route_table_assoc
  ]
  count             = var.outposts_arn != "" && var.outposts_route_to_LGW_destination != "" ? length(var.outposts_subnets_cidr_list) : 0
  route_table_id              = aws_route_table.subnet_outposts_route_table[count.index].id
  destination_cidr_block = var.outposts_route_to_LGW_destination
  local_gateway_id      = data.aws_ec2_local_gateway.outposts_lgw[0].id
}

