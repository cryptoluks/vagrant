variable "iso_name" {}

packer {
  required_plugins {
    windows-update = {
      version = "0.14.3"
      source  = "github.com/rgl/windows-update"
    }
  }
}

source "virtualbox-vm" "packer-windows-updates" {
  attach_snapshot       = "base"
  force_delete_snapshot = true
  guest_additions_mode  = "disable"
  headless              = true
  keep_registered       = true
  shutdown_command      = "shutdown /s /t 0 /f /d p:4:1 /c \"Packer Shutdown\""
  skip_export           = true
  ssh_password          = "vagrant"
  ssh_timeout           = "4h"
  ssh_username          = "vagrant"
  target_snapshot       = "updates"
  vm_name               = var.iso_name
  output_directory      = "output/${var.iso_name}/updates"
}

build {

  sources = [
    "source.virtualbox-vm.packer-windows-updates",
  ]

  provisioner "windows-update" {
  }

}
