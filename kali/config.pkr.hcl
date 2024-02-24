variable "access_token" {}
variable "iso_checksum" {}
variable "iso_filename" {}
variable "iso_name" {}
variable "iso_url" {}
variable "next_minor_version" {}

packer {
  required_plugins {
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

source "virtualbox-iso" "kali" {
  boot_command = [
    "<wait><wait><wait>c<wait><wait><wait>",
    "linux /install.amd/vmlinuz ",
    "auto=true ",
    "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "biosdevname=0 ",
    "net.ifnames=0 ",
    "hostname=kali ",
    "domain='' ",
    "interface=auto ",
    "fb=false ",
    "vga=788 noprompt quiet --<enter>",
    "initrd /install.amd/initrd.gz<enter>",
    "boot<enter>"
  ]
  cpus                      = 2
  disk_size                 = 61440
  firmware                  = "efi"
  gfx_controller            = "vmsvga"
  gfx_vram_size             = 128
  guest_additions_interface = "sata"
  guest_additions_mode      = "disable"
  guest_os_type             = "Debian_64"
  hard_drive_interface      = "sata"
  hard_drive_nonrotational  = true
  headless                  = true
  http_directory            = "http"
  iso_checksum              = var.iso_checksum
  iso_interface             = "sata"
  iso_target_path           = "iso/${var.iso_filename}"
  iso_url                   = var.iso_url
  memory                    = 4096
  output_directory          = "output/${var.iso_name}"
  shutdown_command          = "echo 'packer' | sudo -S shutdown -P now"
  ssh_password              = "vagrant"
  ssh_timeout               = "2h"
  ssh_username              = "vagrant"
  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--nat-localhostreachable1", "on"],
    ["modifyvm", "{{ .Name }}", "--clipboard-mode", "bidirectional"],
    ["modifyvm", "{{ .Name }}", "--draganddrop", "bidirectional"],
    ["storagectl", "{{ .Name }}", "--name", "IDE Controller", "--remove"],
  ]
  vboxmanage_post = [
    ["modifyvm", "{{ .Name }}", "--vrdeport", "default"],
    ["modifyvm", "{{ .Name }}", "--vrde", "off"],
  ]
  vm_name = "kali"
}

build {

  sources = [
    "source.virtualbox-iso.kali",
  ]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -S bash -euxo pipefail '{{ .Path }}'"
    scripts = [
      "provision/provision.sh",
      "provision/minimize.sh",
    ]
  }

  post-processors {

    post-processor "vagrant" {
      vagrantfile_template = "provision/Vagrantfile.template"
      output               = "vagrant/${var.iso_name}.box"
    }

    post-processor "vagrant-cloud" {
      access_token = var.access_token
      box_tag      = "cryptoluks/kali"
      version      = "${formatdate("YYYY-MM-DD", timestamp())}.0.${var.next_minor_version}"
    }

  }

}
