environment = "staging"

vpc_name        = "descomplica-network"
vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets = ["10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20"]

cluster_name = "descomplica-cluster"