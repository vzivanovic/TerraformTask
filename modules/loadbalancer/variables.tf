variable "health_check_name" {}
variable "backend_service_name" {}
variable "url_map_name" {}
variable "http_proxy_name" {}
variable "forwarding_rule_name" {}
variable "global_address_name" {}
variable "instance_group" {
  description = "The self-link of the instance group to be attached to the load balancer"
}
