variable "access_token" {}
variable "next_minor_version" {}

variable "iso_checksum" {
  type    = string
  default = "sha256:a308f7743a75d862561c35b3bfd8b401ebd447cc90c0aa7335c51889b99169c9"
}

variable "iso_name" {
  type    = string
  default = "kali-linux-2023.4-installer-netinst-amd64"
}

variable "iso_filename" {
  type    = string
  default = "kali-linux-2023.4-installer-netinst-amd64.iso"
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.kali.org/kali-2023.4/kali-linux-2023.4-installer-netinst-amd64.iso"
}

packer {
  required_plugins {
    virtualbox = {
      version = "~> 1"
      source  = "github.com/hashicorp/virtualbox"
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
  cpus                     = 2
  disk_size                = 61440
  firmware                 = "efi"
  gfx_controller           = "vmsvga"
  gfx_vram_size            = 128
  guest_additions_mode     = "disable"
  guest_os_type            = "Debian_64"
  hard_drive_interface     = "sata"
  hard_drive_nonrotational = true
  headless                 = true
  http_directory           = "http"
  iso_checksum             = var.iso_checksum
  iso_interface            = "sata"
  iso_target_path          = "iso/${var.iso_name}"
  iso_url                  = var.iso_url
  memory                   = 4096
  output_directory         = "output/${var.iso_name}"
  shutdown_command         = "echo 'packer' | sudo -S shutdown -P now"
  ssh_password             = "vagrant"
  ssh_timeout              = "2h"
  ssh_username             = "vagrant"
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
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
    ]
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -S bash -euxo pipefail '{{ .Path }}'"
    inline = [
      "dd if=/dev/zero of=/ZEROFILL bs=1M || true", "rm /ZEROFILL", "sync",
      "dd if=/dev/zero of=/boot/efi/ZEROFILL bs=1M || true", "rm /boot/efi/ZEROFILL", "sync",
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
