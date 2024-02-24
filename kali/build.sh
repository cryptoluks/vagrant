#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Please provide a pkrvars.hcl filename as an argument"
  exit 1
fi

FILENAME=$(basename -- "$1")
VM_NAME="${FILENAME%.pkrvars.hcl}"

VARFILE=pkrvars/${VM_NAME}.pkrvars.hcl
BOXFILE=vagrant/${VM_NAME}.box

delete_boxfile() {
    if [ -f "$BOXFILE" ]; then
        rm "$BOXFILE" > /dev/null 2>&1 && echo "Box file deleted" || echo "Failed to delete box file"
    else
        echo "Box file not found"
    fi
}

delete_vm() {
    VM_INFO=$(VBoxManage list vms | grep "$VM_NAME")
    if [ -n "$VM_INFO" ]; then
        VBoxManage unregistervm --delete "$VM_NAME" > /dev/null 2>&1 && echo "VM deleted" || echo "Failed to delete VM"
    else
        echo "VM not found"
    fi
}

build_vm() {
    set -oeux pipefail
    packer init -upgrade config.pkr.hcl
    packer build -var-file="${VARFILE}" -force config.pkr.hcl
}

delete_boxfile
delete_vm
build_vm
