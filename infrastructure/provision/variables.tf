variable "environment" {
    type = string
    description = "(required)"
}


#### Network Vars ####
variable "vpc_name" {
    type = string
    description = "(optional)"
}

variable "vpc_cidr" {
    type = string
    description = "(required)"
}

variable "public_subnets" {
    type = list(string)
    description = "(required)"
}

variable "private_subnets" {
    type = list(string)
    description = "(required)"
}


#### EKS Vars ####
variable "cluster_name" {
    type = string
    description = "(optional)"
}

variable "cluster_version" {
    type = string
    default = "1.21"
    description = "(optional)"
}