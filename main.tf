module "networking" {
    source = "./networking"
    vpc_cidr = var.vpc_cidr
    max_subnets = 20
    private_sn_count = 3
    public_sn_count = 2
    public_cidrs = [for i in range(1, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
    private_cidrs = [for i in range(2, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
}

module "loadbalancing" {
  source = "./loadbalancing"
  public_subnets = module.networking.public_subnet
  public_sg = module.networking.lb_sg
  tg_port = 5000 
  tg_protocol = "HTTP"
  vpc_id = module.networking.vpc_id
  elb_healthy_threshold = 2 
  elb_unhealthy_threshold = 2
  elb_timeout = 3
  elb_interval = 30
  listener_port = 80
  listener_protocol = "HTTP"
}

module "compute" {
  source = "./compute"
  ecs_sg = [module.networking.task_sg]
  public_subnet = module.networking.public_subnet
  tg_arn = module.loadbalancing.lb_tg_arn
  lb = module.loadbalancing.lb
}