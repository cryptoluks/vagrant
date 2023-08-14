variable "iso_name" {}

source "virtualbox-vm" "packer-windows-packages" {
  attach_snapshot           = "updates"
  force_delete_snapshot     = true
  guest_additions_interface = "sata"
  guest_additions_mode      = "attach"
  guest_additions_url       = "https://download.virtualbox.org/virtualbox/7.0.8/VBoxGuestAdditions_7.0.8.iso"
  guest_additions_sha256    = "8d73e2361afbf696e6128ffa5e96d9f6a78ff32cb2cb54c727a5be7992be0b31"
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
