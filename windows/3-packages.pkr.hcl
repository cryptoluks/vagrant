variable "iso_name" {}

source "virtualbox-vm" "packer-windows-packages" {
  attach_snapshot           = "updates"
  force_delete_snapshot     = true
  guest_additions_interface = "sata"
  guest_additions_mode      = "attach"
  guest_additions_url       = "https://download.virtualbox.org/virtualbox/7.0.14/VBoxGuestAdditions_7.0.14.iso"
  guest_additions_sha256    = "0efbcb9bf4722cb19292ae00eba29587432e918d3b1f70905deb70f7cf78e8ce"
  headless                  = true
  keep_registered           = true
  shutdown_command          = "shutdown /s /t 0 /f /d p:4:1 /c \"Packer Shutdown\""
  skip_export               = true
  ssh_password              = "vagrant"
  ssh_timeout               = "4h"
  ssh_username              = "vagrant"
  target_snapshot           = "packages"
  output_directory          = "output/${var.iso_name}/packages"
  vm_name                   = var.iso_name
}

build {

  sources = [
    "source.virtualbox-vm.packer-windows-packages",
  ]

  provisioner "powershell" {
    inline = [
      "try { Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) } catch { Write-Host 'Error: ' + $_.Exception.Message }",
    ]
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    script = "provision/packages.ps1"
  }

}
