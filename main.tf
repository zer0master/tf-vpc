#

# if additional cidr blocks need to be added to the vpc, aws_vpc_ipv4_cidr_block_association is the mechanism, but
# to aid in destroying resources in the correct order, the normal direct aws_vpc.added.id usage has to be replaced
# with a local.vpc_id variable generated with
# vpc_id = element(
#   concat(
#     aws_vpc_ipv4_cidr_block_association.this.*.vpc_id,  # empty if not created
#     aws_vpc.added.*.id,    # in which case aws_vpc.added.id is returned instead
#     [""],
#   ),
#   0,
# )
# this reminds terraform to destroy the cidr assoc first, if its vpc id isn't null
# > element(concat([], ["vpc-01"], [""],), 0)
# "vpc-01"
# > element(concat([], [""],), 0)
# ""

locals {
  vpc_id = element(
    concat(
      aws_vpc.added.*.id,    # in which case aws_vpc.added.id is returned instead
      [""],
    ),
    0,
  )
  name_suffix = "${var.account_name}-${var.vpc_suffix}"
}

# required vars:
# - account_name : string
# - common_tags : dict(string: string)
# - create_vpc : bool
# - deployed_name : string    # (suffix?)
# - vpc_cidr : string
#
# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "added" {
  count = var.create_vpc ? 1 : 0

  cidr_block        = var.vpc_cidr
  instance_tenancy  = "default"

  # enable_dns_support = true

  # revisit nat_gateway later...
  tags = merge(
    var.tags,
    {
      Name = "VPC-${local.name_suffix}"
    }
  )
}

# this might need rework; probably can't add internet gateway post-vpc-creation
# required vars:
# - account_name : string
# - common_tags : dict(string: string)
# - create_igw : bool
# - create_vpc : bool
# - deployed_name : string
#
# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "public" {
  count   = var.create_vpc && var.create_igw ? 1 : 0

  # only effective way to retrieve id, even though a single vpc is being created in some cases
  vpc_id  = local.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "IGW-${local.name_suffix}"
    }
  )
}

resource "aws_route" "internet" {
  count   = var.create_vpc && var.create_igw ? 1 : 0

  route_table_id          = "${aws_vpc.added[count.index].main_route_table_id}"
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = "${aws_internet_gateway.public[count.index].id}"
}

resource "aws_network_acl" "public" {
  count = var.create_vpc && var.public_custom_network_acl && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id     = element(concat(aws_vpc.added.*.id, [""]), 0)
  subnet_ids = aws_subnet.public.*.id

  tags = merge(
    {
      Name = "NACLSet-${local.name_suffix}"
    },
    var.tags,
    var.public_acl_tags,
  )
}

# required variables:
resource "aws_network_acl_rule" "public_inbound" {
  count = var.create_vpc && var.public_custom_network_acl && length(var.public_subnets) > 0 ? length(var.public_inbound_acl_rules) : 0

  network_acl_id  = aws_network_acl.public[0].id

  egress          = false
  rule_number     = var.public_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.public_inbound_acl_rules[count.index]["rule_action"]
  protocol        = var.public_inbound_acl_rules[count.index]["protocol"]
  from_port       = lookup(var.public_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.public_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.public_inbound_acl_rules[count.index], "icmp_type", null)
  cidr_block      = lookup(var.public_inbound_acl_rules[count.index], "cidr_block", var.source_cidr)  # limit to home lan
  ipv6_cidr_block = lookup(var.public_inbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "public_outbound" {
  count = var.create_vpc && var.public_custom_network_acl && length(var.public_subnets) > 0 ? length(var.public_outbound_acl_rules) : 0

  network_acl_id  = aws_network_acl.public[0].id

  egress          = true
  rule_number     = var.public_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.public_outbound_acl_rules[count.index]["rule_action"]
  protocol        = var.public_outbound_acl_rules[count.index]["protocol"]
  from_port       = lookup(var.public_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.public_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.public_outbound_acl_rules[count.index], "icmp_type", null)
  cidr_block      = lookup(var.public_outbound_acl_rules[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.public_outbound_acl_rules[count.index], "ipv6_cidr_block", null)
}

#NOTE: seek ye the subnets in their own file ;)

## ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
#resource "aws_eip" "gw_ip" {
#  vpc         = true
#  depends_on  = [aws_internet_gateway.public]
#}
