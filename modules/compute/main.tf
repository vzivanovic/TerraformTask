resource "google_compute_instance" "vm_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
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
    sudo systemctl start apache2
    echo '<h1>Welcome to the Apache server</h1>' | sudo tee /var/www/html/index.html
  EOF
}

resource "null_resource" "stop_instance" {
  provisioner "local-exec" {
    command = "gcloud compute instances stop ${google_compute_instance.vm_instance.name} --zone ${var.zone}"
  }

  triggers = {
    always_run = "${timestamp()}"
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
    always_run = "${timestamp()}"
  }

  depends_on = [google_compute_image.vm_image]
}