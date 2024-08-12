variable "project_id" {
  default = "gd-gcp-internship-devops"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "network_name" {
  default = "terraform-network-vz"
}

variable "subnet_name" {
  default = "terraform-subnet-vz"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "instance_name" {
  default = "vz-temp-instance"
}

variable "machine_type" {
  default = "f1-micro"
}
