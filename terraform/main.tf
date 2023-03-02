provider "google" {
    credentials = var.google_credentials
    project = "stackql-demo-2"
}

resource "google_compute_instance" "instance" {
  count         = var.instance_count
  name         = "terraform-test-${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = var.network
    access_config {
    }
  }
}