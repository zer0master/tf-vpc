#NOTE: config reflects consecutive subnet cidrs assigned programmatically on n-per-az basis

# public/private cidrs: first n items from full list (n = subnets/vpc)

# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "public" {
  # proceeds *if*:
  # - creating vpc
  # - number of public subnets is nonzero and at least as many as availability zones
  count = var.create_vpc && length(var.public_subnets) > 0 && length(var.av_zones) >= length(var.public_subnets) ? length(var.public_subnets) : 0
  # add in NAT gateway condition (one per availability zone) later

  vpc_id                  = local.vpc_id
  cidr_block              = element(var.public_subnets, count.index)
  # ensure only 2-char hyphenated azs are used
  availability_zone       = length(regexall(
                              "^[a-z]{2}-",
                              element(var.av_zones, count.index)
                            )) > 0 ? element(var.av_zones, count.index) : null
# map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.tags,
    {
      Name = "Subnet-${local.name_suffix}-${element(var.av_zones, count.index)}"
    },
  )
}

#   resource "aws_subnet" "private" {
#     # proceeds *if*:
#     # - creating vpc
#     # - number of private subnets is nonzero and at least as many as availability zones
#     count = var.create_vpc && length(var.private_subnets) > 0 && length(var.av_zones) >= length(var.private_subnets) ? length(var.private_subnets) : 0
#     # add in NAT gateway condition (one per availability zone) later
#   
#     vpc_id                  = local.vpc_id
#     cidr_block              = element(var.private_subnets, count.index)
#     # ensure only 2-char hyphenated azs are used
#     availability_zone       = length(regexall(
#                                 "^[a-z]{2}-",
#                                 element(var.av_zones, count.index)
#                               )) > 0 ? element(var.av_zones, count.index) : null
#     #map_private_ip_on_launch = var.map_private_ip_on_launch
#   
#     tags = merge(
#       var.tags,
#       {
#         Name = "Subnet-${var.account_name}-${var.deployed_name}-${element(var.av_zones, count.index)}"
#       },
#     )
#   }

