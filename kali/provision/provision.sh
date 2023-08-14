#!/usr/bin/env bash
# Ref: https://www.vagrantup.com/docs/boxes/base.html

# Add the vagrant insecure pub key
mkdir /home/vagrant/.ssh
wget -O /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub
chmod 0700 /home/vagrant/.ssh/
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh/

# Password-less sudo for vagrant user
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

# SSH tweak
echo 'UseDNS no' >>/etc/ssh/sshd_config

# Fix the DHCP NAT
echo -e "auto eth0\niface eth0 inet dhcp" >>/etc/network/interfaces

# Fix VirtualBox EFI mode not honoring seperate debian efi directory
mkdir -p /boot/efi/EFI/boot
cp /boot/efi/EFI/kali/grubx64.efi /boot/efi/EFI/boot/bootx64.efi

# Prevent password prompt for color management settings on login
mkdir -p /etc/polkit-1/localauthority.conf.d
tee /etc/polkit-1/localauthority.conf.d/02-allow-colord.conf <<"EOF"
polkit.addRule(function (action, subject) {
    if ((action.id == "org.freedesktop.color-manager.create-device" ||
        action.id == "org.freedesktop.color-manager.create-profile" ||
        action.id == "org.freedesktop.color-manager.delete-device" ||
        action.id == "org.freedesktop.color-manager.delete-profile" ||
        action.id == "org.freedesktop.color-manager.modify-device" ||
        action.id == "org.freedesktop.color-manager.modify-profile") &&
        subject.isInGroup("{users}")) {
        return polkit.Result.YES;
    }
});
EOF

# GUI Autologin
mkdir -p /etc/lightdm/lightdm.conf.d
tee /etc/lightdm/lightdm.conf.d/50-autologin.conf <<"EOF"
[SeatDefaults]
autologin-user=vagrant
EOF

# Add firefox policies
mkdir -p /usr/lib/firefox-esr/distribution
tee /usr/lib/firefox-esr/distribution/policies.json <<"EOF"
{
  "policies": {
    "DisableFeedbackCommands": true,
    "DisableFirefoxStudies": true,
    "DisablePocket": true,
    "DisableProfileImport": true,
    "DisableProfileRefresh": true,
    "DisableTelemetry": true,
    "DisplayBookmarksToolbar": true,
    "DisplayMenuBar": true,
    "DontCheckDefaultBrowser": true,
    "EnableTrackingProtection": {
      "Cryptomining": true,
      "Fingerprinting": true,
      "Value": true
    },
    "ExtensionSettings": {
      "@testpilot-containers": {
        "install_url": "https://addons.mozilla.org/firefox/downloads/file/3932862",
        "installation_mode": "normal_installed"
      },
      "foxyproxy@eric.h.jung": {
        "install_url": "https://addons.mozilla.org/firefox/downloads/file/3616824",
        "installation_mode": "normal_installed"
      },
      "uBlock0@raymondhill.net": {
        "install_url": "https://addons.mozilla.org/firefox/downloads/file/3961087",
        "installation_mode": "normal_installed"
      },
      "enterprise-policy-generator@agenedia.com": {
        "install_url": "https://addons.mozilla.org/firefox/downloads/file/3515849",
        "installation_mode": "normal_installed"
      },
      "{446900e4-71c2-419f-a6a7-df9c091e268b}": {
        "install_url": "https://addons.mozilla.org/firefox/downloads/file/4018008",
        "installation_mode": "normal_installed"
      },
      "keepassxc-browser@keepassxc.org": {
        "install_url": "https://addons.mozilla.org/firefox/downloads/file/4023682",
        "installation_mode": "normal_installed"
      },
      "{1c5e4c6f-5530-49a3-b216-31ce7d744db0}": {
        "install_url": "https://addons.mozilla.org/firefox/downloads/file/4007848",
        "installation_mode": "normal_installed"
      },
      "{3c078156-979c-498b-8990-85f7987dd929}": {
        "install_url": "https://addons.mozilla.org/firefox/downloads/file/3994928",
        "installation_mode": "normal_installed"
      },
      "{60f82f00-9ad5-4de5-b31c-b16a47c51558}": {
        "install_url": "https://addons.mozilla.org/firefox/downloads/file/3343599",
        "installation_mode": "normal_installed"
      }
    },
    "Homepage": {
      "StartPage": "none"
    },
    "NewTabPage": false,
    "NoDefaultBookmarks": true,
    "OverrideFirstRunPage": "",
    "OverridePostUpdatePage": "",
    "Preferences": {
      "browser.urlbar.suggest.openpage": false,
      "extensions.getAddons.showPane": false,
      "network.IDN_show_punycode": true
    },
    "SearchSuggestEnabled": false
  }
}
EOF

# Disable xfce power management and do not lock screen if system is going to sleep
su vagrant <<"EOF"
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus xfconf-query -c xfce4-power-manager --create -p /xfce4-power-manager/presentation-mode -t bool -s true
EOF
