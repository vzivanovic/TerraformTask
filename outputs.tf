output "instance_ip" {
  value = module.compute.instance_ip
}
output "load_balancer_ip" {
  value = module.loadbalancer.load_balancer_ip
}
