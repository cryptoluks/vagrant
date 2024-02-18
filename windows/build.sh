#!/usr/bin/env bash

# Ensure an argument is provided
if [ -z "$1" ]; then
  echo "Please provide a pkrvars.hcl filename as an argument"
  exit 1
fi

# Extract VM_NAME from the argument
FILENAME=$(basename -- "$1")
VM_NAME="${FILENAME%.pkrvars.hcl}"

# Derive varfile and boxfile from iso filename
VARFILE=pkrvars/${VM_NAME}.pkrvars.hcl
BOXFILE=vagrant/${VM_NAME}.box

# Function to delete box file
delete_boxfile() {
    if [ -f "$BOXFILE" ]; then
        rm "$BOXFILE" > /dev/null 2>&1 && echo "Box file deleted" || echo "Failed to delete box file"
    else
        echo "Box file not found"
    fi
}

# Function to delete VM
delete_vm() {
    VM_INFO=$(VBoxManage list vms | grep "$VM_NAME")
    if [ -n "$VM_INFO" ]; then
        VBoxManage unregistervm --delete "$VM_NAME" > /dev/null 2>&1 && echo "VM deleted" || echo "Failed to delete VM"
    else
        echo "VM not found"
    fi
}

# Function to build VM
build_vm() {

    # Set shell options for robustness and debugging:
    # 'o pipefail': fail on pipeline errors
    # 'e': exit on command errors
    # 'u': treat unset variables as errors
    # 'x': print each executed command for debugging
    set -oeux pipefail

    declare -a steps=("base" "updates" "packages" "optimize" "sysprep")

    for i in "${!steps[@]}"; do
        step_number=$(($i + 1))
        step_name=${steps[$i]}
        packer init -upgrade "${step_number}-${step_name}.pkr.hcl"
        packer build -var-file="${VARFILE}" -force "${step_number}-${step_name}.pkr.hcl"
    done
}

# Call functions
delete_boxfile
delete_vm
build_vm
