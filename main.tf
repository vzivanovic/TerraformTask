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
  firewall_rules = {
    "allow-http-ssh" = {
      protocol      = "tcp"
      ports         = ["80", "22"]
      source_ranges = ["109.111.235.230/32"]
    },
    "allow-https" = {
      protocol      = "tcp"
      ports         = ["443"]
      source_ranges = ["0.0.0.0/0"]
    }
  }
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
  boot_image    = "debian-cloud/debian-11"
}

module "loadbalancer" {
  source               = "./modules/loadbalancer"
  health_check_name    = "http-health-check"
  backend_service_name = "backend-service"
  url_map_name         = "url-map"
  http_proxy_name      = "http-lb-proxy"
  forwarding_rule_name = "http-lb-rule"
  global_address_name  = "lb-ip"
  instance_group       = module.compute.instance_group
}