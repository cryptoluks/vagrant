variable "access_token" {}
variable "iso_name" {}
variable "next_minor_version" {}

source "virtualbox-vm" "packer-windows-sysprep" {
  cd_files = [
    "cd/${var.iso_name}/*",
    "cd/all/*",
  ]
  attach_snapshot           = "optimize"
  force_delete_snapshot     = true
  guest_additions_interface = "sata"
  guest_additions_mode      = "disable"
  headless                  = true
  keep_registered           = true
  shutdown_command          = "shutdown /s /t 0 /f /d p:4:1 /c \"Packer Shutdown\""
  skip_export               = false
  ssh_password              = "vagrant"
  output_directory          = "output/${var.iso_name}/sysprep"
  ssh_timeout               = "4h"
  ssh_username              = "vagrant"
  target_snapshot           = "sysprep"
  vm_name                   = var.iso_name
  vboxmanage_post = [
    ["modifyvm", "{{ .Name }}", "--vrdeport", "default"],
    ["modifyvm", "{{ .Name }}", "--vrde", "off"]
  ]
}

build {

  sources = [
    "source.virtualbox-vm.packer-windows-sysprep"
  ]

  provisioner "powershell" {
    inline = [
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm /unattend:E:\\unattend.xml",
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }",
    ]
  }

  post-processors {

    post-processor "vagrant" {
      vagrantfile_template = "provision/Vagrantfile.template"
      output               = "vagrant/${var.iso_name}.box"
    }

    post-processor "vagrant-cloud" {
      access_token = var.access_token
      box_tag      = "cryptoluks/windows"
      version      = "${formatdate("YYYY-MM-DD", timestamp())}.0.${var.next_minor_version}"
    }

  }

}
