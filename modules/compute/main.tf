locals {
  boot_image = var.boot_image != null ? var.boot_image : "debian-cloud/debian-11"
}
resource "google_compute_instance" "vm_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = local.boot_image
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet
    access_config {}
  }

  metadata_startup_script = file("${path.module}/startup-script.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "stop_instance" {
  provisioner "local-exec" {
    command = "gcloud compute instances stop ${google_compute_instance.vm_instance.name} --zone ${var.zone}"
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [google_compute_instance.vm_instance]
}

resource "google_compute_image" "vm_image" {
  name        = "${var.instance_name}-image"
  source_disk = google_compute_instance.vm_instance.boot_disk[0].source
  depends_on  = [null_resource.stop_instance]
}

resource "null_resource" "start_instance" {
  provisioner "local-exec" {
    command = "gcloud compute instances start ${google_compute_instance.vm_instance.name} --zone ${var.zone}"
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [google_compute_image.vm_image]
}

resource "google_compute_instance_template" "vm_template" {
  name         = "${var.instance_name}-template"
  machine_type = var.machine_type

  disk {
    source_image = google_compute_image.vm_image.self_link
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet
    access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2
    echo '<h1>Welcome to $(hostname)</h1>' | sudo tee /var/www/html/index.html
    sudo systemctl start apache2
  EOF
}

resource "google_compute_instance_group_manager" "vm_igm" {
  name               = "${var.instance_name}-igm"
  zone               = var.zone
  base_instance_name = var.instance_name
  target_size        = 3
  version {
    instance_template = google_compute_instance_template.vm_template.self_link
  }
}

output "instance_group" {
  value = google_compute_instance_group_manager.vm_igm.instance_group
}