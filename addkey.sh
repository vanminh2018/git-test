#!/usr/bin/env bash

set -euo pipefail

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

SSHD_CONFIG_FILE="/etc/ssh/sshd_config"
ROOT_HOME="/root"
MINHBV_HOME="/home/minhbv"

SSH_PUBLIC_KEY=$(cat <<'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA5K0K348mAkw8exBBGof/UHySKrEpFIaDCLHTMQF8Xugs6E8Mk8OWVrXyh3BYRMINZbyjvJmTT8D1/IJSw00RQ/zR0rfLYVFDCPCddypyuwOLgFW2iIkfQq6KYcIOn7q48WZddjz6h4xawJahZGOfLU0LZWk4odnB00SsGy8GppN2upEsCPDa301vu6QsHoT+hYmE6NeEipS4zT6E9M0OUL9OmIZuZgyrTWVQok2+11r008qUibQGUuKD+oQF4W8tKpV/k48nlltvHibKpK8B3rtwIWv9Crd36F97hVjU65T9tSlnZDFSSB+v6vRAOx4u+FU8HucZVWLlBs2qqggjDw== minhbv
EOF
)

add_or_update_config() {
    local file=$1
    local key=$2
    local value=$3
    if grep -q "^${key}" "$file"; then
        sed -i "s|^${key}.*|${key} ${value}|" "$file"
    else
        echo "${key} ${value}" >> "$file"
    fi
}

setup_ssh_for_user() {
    local user=$1
    local home_dir=$2
    local ssh_dir="${home_dir}/.ssh"
    local config_file="${ssh_dir}/config"
    local auth_file="${ssh_dir}/authorized_keys"

    mkdir -p "$ssh_dir"
    touch "$config_file" "$auth_file"

    if ! grep -q "$SSH_PUBLIC_KEY" "$auth_file" 2>/dev/null; then
        echo "$SSH_PUBLIC_KEY" >> "$auth_file"
        echo "---> SSH key added for $user"
    else
        echo "---> SSH key already exists for $user"
    fi

    add_or_update_config "$config_file" "UserKnownHostsFile" "/dev/null"
    add_or_update_config "$config_file" "StrictHostKeyChecking" "no"

    chmod 700 "$ssh_dir"
    chmod 600 "$ssh_dir"/*
    [[ $user != "root" ]] && chown -R "${user}:" "$ssh_dir"
}

setup_ssh_for_user "root" "$ROOT_HOME"

if id "minhbv" &>/dev/null; then
    echo "User minhbv exists. Setting up SSH."
    setup_ssh_for_user "minhbv" "$MINHBV_HOME"
else
    echo "User minhbv does not exist. Skipping SSH setup for this user."
fi

add_or_update_config "$SSHD_CONFIG_FILE" "PasswordAuthentication" "yes"

systemctl reload sshd

echo "SSH configuration completed successfully."
