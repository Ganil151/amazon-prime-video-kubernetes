
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr        = var.vpc_cidr
  vpc_name        = var.vpc_name
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
}

module "sg" {
  source = "../../modules/sg"

  vpc_id                = module.vpc.vpc_id
  sg_name               = "${var.environment}-sg"
  allowed_ingress_ports = var.allowed_ingress_ports
}

module "keys" {
  source = "../../modules/keys"

  key_name = var.key_name
}

module "App-Server" {
  source = "../../modules/ec2"

  instance_name               = var.instance_name
  ami_id                      = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnet_ids[0]
  security_group_ids          = [module.sg.sg_id]
  key_name                    = module.keys.key_name
  root_volume_size            = 15
  root_volume_type            = var.root_volume_type
  user_data                   = file("../../scripts/master-server.sh")
  user_data_replace_on_change = false

}

module "worker-server" {
  source = "../../modules/ec2"

  instance_name               = var.instance_name
  ami_id                      = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnet_ids[0]
  security_group_ids          = [module.sg.sg_id]
  key_name                    = module.keys.key_name
  root_volume_size            = 25
  root_volume_type            = var.root_volume_type
  user_data                   = file("../../scripts/worker-server.sh")
  user_data_replace_on_change = var.user_data_replace_on_change || false

}

module "sonarQube-server" {
  source = "../../modules/ec2"

  instance_name               = var.instance_name
  ami_id                      = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnet_ids[0]
  security_group_ids          = [module.sg.sg_id]
  key_name                    = module.keys.key_name
  root_volume_size            = 25
  root_volume_type            = var.root_volume_type
  user_data                   = file("../../scripts/sonarQube-server.sh")
  user_data_replace_on_change = false

}
