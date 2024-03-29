variable "iso_checksum" {}
variable "iso_filename" {}
variable "iso_name" {}
variable "iso_url" {}

packer {
  required_plugins {
    windows-update = {
      version = "0.15.0"
      source  = "github.com/rgl/windows-update"
    }
    virtualbox = {
      version = ">= 1.0.5"
      source  = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

source "virtualbox-iso" "packer-windows-base" {
  boot_command = ["<up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait>"]
  boot_wait    = "1s"
  cd_files = [
    "cd/${var.iso_name}/*",
    "cd/all/*",
  ]
  cpus                      = 2
  disk_size                 = 61440
  firmware                  = "efi"
  gfx_controller            = "vboxsvga"
  gfx_vram_size             = 128
  guest_additions_interface = "sata"
  guest_additions_mode      = "disable"
  guest_os_type             = "Windows10_64"
  hard_drive_interface      = "sata"
  hard_drive_nonrotational  = true
  headless                  = true
  iso_checksum              = var.iso_checksum
  iso_interface             = "sata"
  iso_target_path           = "iso/${var.iso_filename}"
  iso_url                   = var.iso_url
  keep_registered           = true
  memory                    = 4096
  output_directory          = "output/${var.iso_name}/base"
  shutdown_command          = "shutdown /s /t 0 /f /d p:4:1 /c \"Packer Shutdown\""
  skip_export               = true
  ssh_password              = "vagrant"
  ssh_timeout               = "30m"
  ssh_username              = "vagrant"
  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--nat-localhostreachable1", "on"],
    ["modifyvm", "{{ .Name }}", "--clipboard-mode", "bidirectional"],
    ["modifyvm", "{{ .Name }}", "--draganddrop", "bidirectional"],
    ["storagectl", "{{ .Name }}", "--name", "IDE Controller", "--remove"],
  ]
  vm_name = var.iso_name
  vboxmanage_post = [
    ["snapshot", "{{ .Name }}", "take", "base"],
  ]

}

build {

  sources = [
    "source.virtualbox-iso.packer-windows-base",
  ]

  provisioner "powershell" {
    script = "provision/disable-services.ps1"
  }

}
