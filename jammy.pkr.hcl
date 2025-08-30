variable "cpu" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "40000"
}

variable "headless" {
  type    = string
  default = "true"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:834af9cd766d1fd86eca156db7dff34c3713fbbc7f5507a3269be2a72d2d1820"
}

variable "iso_url" {
  type    = string
  default = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
}

variable "name" {
  type    = string
  default = "jammy"
}

variable "ram" {
  type    = string
  default = "2048"
}

variable "ssh_password" {
  type    = string
  default = "ubuntu"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "version" {
  type    = string
  default = ""
}

variable "format" {
  type    = string
  default = "qcow2"
}

packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

source "qemu" "jammy" {
  accelerator      = "kvm"
  boot_command     = []
  disk_compression = true
  disk_interface   = "virtio"
  disk_image       = true
  disk_size        = var.disk_size
  format           = var.format
  headless         = var.headless
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  net_device       = "virtio-net"
  output_directory = "artifacts/qemu/${var.name}${var.version}"
  qemuargs = [
    ["-m", "${var.ram}M"],
    ["-smp", "${var.cpu}"],
    ["-cdrom", "cidata.iso"]
  ]
  communicator           = "ssh"
  shutdown_command       = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  ssh_password           = var.ssh_password
  ssh_username           = var.ssh_username
  ssh_timeout            = "10m"
}

build {
  sources = ["source.qemu.jammy"]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E bash '{{ .Path }}'"
    inline          = ["sudo apt update", "sudo apt install python3"]
  }

  post-processor "shell-local" {
    environment_vars = ["IMAGE_NAME=${var.name}", "IMAGE_VERSION=${var.version}", "IMAGE_FORMAT=${var.format}"]
    script           = "scripts/prepare-image.sh"
  }
}
