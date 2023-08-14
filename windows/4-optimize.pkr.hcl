variable "iso_name" {}

source "virtualbox-vm" "packer-windows-optimize" {
  attach_snapshot = "packages"
  cd_files = [
    "cd/${var.iso_name}/*",
    "cd/all/*",
  ]
  force_delete_snapshot     = true
  guest_additions_interface = "sata"
  guest_additions_mode      = "disable"
  headless                  = true
  keep_registered           = true
  shutdown_command          = "shutdown /s /t 0 /f /d p:4:1 /c \"Packer Shutdown\""
  skip_export               = true
  ssh_password              = "vagrant"
  ssh_timeout               = "4h"
  ssh_username              = "vagrant"
  output_directory          = "output/${var.iso_name}/optimize"
  target_snapshot           = "optimize"
  vm_name                   = var.iso_name
}

build {

  sources = [
    "source.virtualbox-vm.packer-windows-optimize",
  ]

  provisioner "powershell" {
    script = "provision/tweaks.ps1"
  }

  provisioner "powershell" {
    script = "provision/eject-media.ps1"
  }

  provisioner "powershell" {
    script = "provision/optimize_part1.ps1"
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    script = "provision/optimize_part2.ps1"
  }

}
