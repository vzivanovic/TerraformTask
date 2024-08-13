provider "google" {
  project = var.project_id
  region  = var.region
}

module "network" {
  source       = "./modules/network"
  project_id   = var.project_id
  region       = var.region
  network_name = var.network_name
  subnet_name  = var.subnet_name
  subnet_cidr  = var.subnet_cidr
}

module "compute" {
  source        = "./modules/compute"
  project_id    = var.project_id
  region        = var.region
  zone          = var.zone
  instance_name = var.instance_name
  machine_type  = var.machine_type
  network       = module.network.network
  subnet        = module.network.subnet
}

module "loadbalancer" {
  source              = "./modules/loadbalancer"
  health_check_name   = "http-health-check"
  backend_service_name = "backend-service"
  url_map_name        = "url-map"
  http_proxy_name     = "http-lb-proxy"
  forwarding_rule_name = "http-lb-rule"
  global_address_name = "lb-ip"
  instance_group      = module.compute.instance_group
}