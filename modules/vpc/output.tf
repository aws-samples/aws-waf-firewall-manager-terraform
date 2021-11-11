output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_priv_ids" {
  value = aws_subnet.subnet_priv.*.id
}

output "subnet_public_ids" {
  value = aws_subnet.subnet_public.*.id
}

output "subnet_priv_tgw_ids" {
  value = aws_subnet.subnet_priv_tgw.*.id
}

output "subnet_fw_ids" {
  value = aws_subnet.subnet_fw.*.id
}

output "subnet_web_ids" {
  value = aws_subnet.subnet_web_tier.*.id
}

output "subnet_presentation_ids" {
  value = aws_subnet.subnet_pres_tier.*.id
}

output "subnet_database_ids" {
  value = aws_subnet.subnet_database_tier.*.id
}

output "subnet_outposts_ids" {
  value = aws_subnet.subnet_outposts.*.id
}


output "subnet_public_route_table_ids" {
  value = aws_route_table.subnet_public_route_table.*.id
}

output "subnet_priv_route_table_ids" {
  value = aws_route_table.subnet_priv_route_table.*.id
}

output "subnet_priv_tgw_route_table_ids" {
  value = aws_route_table.subnet_priv_tgw_route_table.*.id
}

output "subnet_fw_route_table_ids" {
  value = aws_route_table.subnet_fw_route_table.*.id
}

output "subnet_web_tier_route_table_ids" {
  value = aws_route_table.subnet_web_tier_route_table.*.id
}

output "subnet_pres_tier_route_table_ids" {
  value = aws_route_table.subnet_pres_tier_route_table.*.id
}

output "subnet_database_tier_route_table_ids" {
  value = aws_route_table.subnet_database_tier_route_table.*.id
}

output "subnet_outposts_route_table_ids" {
  value = aws_route_table.subnet_outposts_route_table.*.id
}

output "iam_role_ec2_ssm_id"{
  value = var.enable_ssm && var.create_iam_role_ssm ? aws_iam_role.ssm_ec2_iam_role[0].id : ""
  depends_on = [
    aws_iam_role.ssm_ec2_iam_role,
  ]
}

output "iam_instance_profile_ec2_ssm_id"{
  value = var.enable_ssm && var.create_iam_role_ssm ? aws_iam_instance_profile.ec2_ssm[0].id : ""
  depends_on = [
    aws_iam_role.ssm_ec2_iam_role,
  ]
}

output "ssm_security_group_id"{
  value = var.enable_ssm ? aws_security_group.ssm_endpoint_sg[0].id : ""
}

output "igw_id"{
  value =  var.enable_internet_gateway && length(var.public_subnets_cidr_list) > 0 ? aws_internet_gateway.igw[0].id : ""
}

output "s3_vpc_endpoint"{
  value = var.enable_ssm || var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].id : ""
}
