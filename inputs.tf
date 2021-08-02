#
variable "account_name" {
  description = "account alias"
  type        = string
}

variable "tags" {
  type        = map(string)
}

variable "create_vpc" {
  description = "virtual private cloud: go or no?"
  type        = bool
}

variable "create_igw" {
  description = "internet gateway: go or no?"
  type        = bool
}

variable "vpc_suffix" {
  description = "name of deployment (used as part of some Name tags)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR spec for VPC"
  type        = string
  default     = "10.0.0.0/16"
  # later, spec 0.0.0.0/0 to force user input - legal cidr, bit not to AWS
}

#   variable "map_public_ip_on_launch" {
#     description = "auto-assign public IP on launch?"
#     type        = bool
#     default     = true
#   }
#   
variable "public_custom_network_acl" {
  description = "use (non-default) custom network ACL and rules for public subnets?"
  type        = bool
  default     = false
}

#   variable "private_custom_network_acl" {
#     description = "use custom (non-default) network ACL and rules for private subnets?"
#     type        = bool
#     default     = false
#   }

variable "av_zones" {
  description = "region-specific availability zone list"
  type        = list(string)
  default     = []
}

variable "source_cidr" {
  description = "CIDR spec to limit ingress"
  type        = string
}

#   variable "default_network_acl_ingress" {
#     description = "List of maps of ingress rules to set on the Default Network ACL"
#     type        = list(map(string))
#   
#     default = [
#       {
#         rule_no    = 100
#         action     = "allow"
#         from_port  = 0
#         to_port    = 0
#         protocol   = "-1"
#         cidr_block = "0.0.0.0/0"
#       },
#     ]
#   }
#   
#   variable "default_network_acl_egress" {
#     description = "List of maps of egress rules to set on the Default Network ACL"
#     type        = list(map(string))
#   
#     default = [
#       {
#         rule_no    = 100
#         action     = "allow"
#         from_port  = 0
#         to_port    = 0
#         protocol   = "-1"
#         cidr_block = "0.0.0.0/0"
#       },
#     ]
#   }
#   
variable "public_inbound_acl_rules" {
  description = "Public subnets inbound network ACLs"
  type        = list(map(string))

  # cidr_block added via command line
}

variable "public_outbound_acl_rules" {
  description = "Public subnets outbound network ACLs"
  type        = list(map(string))

}

variable "public_acl_tags" {
  description = "addl tags for public subnets network ACL"
  type        = map(string)
  default     = {}
}

#   variable "private_acl_tags" {
#     description = "addl tags for private subnets network ACL"
#     type        = map(string)
#     default     = {}
#   }
#   
variable "public_subnets" {
  description = "list of public subnets inside VPC"
  type        = list(string)
  default     = []
}

#   variable "private_subnets" {
#     description = "list of private subnets inside VPC"
#     type        = list(string)
#     default     = []
#   }
#   
#   variable "custom_nacl_ingress" {
#     description = "(map) list of ingress rules"
#     type        = list(map(string))
#   
#     default = [
#       {
#         rule_no    = 100
#         action     = "allow"
#         from_port  = 0
#         to_port    = 0
#         protocol   = "-1"
#         cidr_block = "0.0.0.0/0"
#       },
#     ]
#   }
#   
#   variable "custom_nacl_egress" {
#     description = "(map) list of egress rules"
#     type        = list(map(string))
#   
#     default = [
#       {
#         rule_no    = 100
#         action     = "allow"
#         from_port  = 0
#         to_port    = 0
#         protocol   = "-1"
#         cidr_block = "0.0.0.0/0"
#       },
#     ]
#   }
