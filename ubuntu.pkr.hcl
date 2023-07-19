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
  default = "sha256:d699ae158ec028db69fd850824ee6e14c073b02ad696b4efb8c59d37c8025aaa"
}

variable "iso_url" {
  type    = string
  default = "https://cloud-images.ubuntu.com/jammy/20230719/jammy-server-cloudimg-amd64.img"
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

source "qemu" "jammy" {
  accelerator            = "kvm"
  boot_command      = []
//   boot_wait              = "3s"
  disk_cache             = "none"
  disk_compression       = true
//   disk_discard           = "ignore"
  disk_interface         = "virtio"
  disk_image = true
  disk_size              = var.disk_size
  format                 = "qcow2"
  headless               = var.headless
  iso_checksum           = var.iso_checksum
  iso_url                = var.iso_url
  net_device             = "virtio-net"
  output_directory       = "artifacts/qemu/${var.name}${var.version}"
  qemuargs               = [
    ["-m", "${var.ram}M"],
    ["-smp", "${var.cpu}"],
    // ["-smbios", "type=1,serial=ds='nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'"]
    ["-cdrom", "cidata.iso"]
  ]
  http_directory         = "http"
  communicator = "ssh"
  shutdown_command       = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  ssh_handshake_attempts = 500
  ssh_password           = var.ssh_password
  ssh_timeout            = "45m"
  ssh_username           = var.ssh_username
  ssh_wait_timeout       = "45m"
}

build {
  sources = ["source.qemu.jammy"]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -E bash '{{ .Path }}'"
    inline          = ["sudo apt update", "sudo dist-upgrade", "sudo apt autoremove -y", "sudo apt clean"]
  }
}