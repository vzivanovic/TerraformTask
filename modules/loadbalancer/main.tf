resource "google_compute_health_check" "default" {
  name                = var.health_check_name
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
  http_health_check {
    port = 80
  }
}

resource "google_compute_backend_service" "default" {
  name          = var.backend_service_name
  health_checks = [google_compute_health_check.default.self_link]
  backend {
    group = var.instance_group
  }
}

resource "google_compute_url_map" "default" {
  name            = var.url_map_name
  default_service = google_compute_backend_service.default.self_link
}

resource "google_compute_target_http_proxy" "default" {
  name    = var.http_proxy_name
  url_map = google_compute_url_map.default.self_link
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = var.forwarding_rule_name
  target     = google_compute_target_http_proxy.default.self_link
  port_range = "80"
  ip_address = google_compute_global_address.default.address
}

resource "google_compute_global_address" "default" {
  name = var.global_address_name
}

output "load_balancer_ip" {
  value = google_compute_global_address.default.address
}
