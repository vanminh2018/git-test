#!/usr/bin/env bash

# sudo curl -s https://raw.githubusercontent.com/vanminh2018/git-test/addkey/addkey.sh | bash

SSHD_CONFIG_FILE="/etc/ssh/sshd_config"
ROOT_SSH_CONFIG_FILE="/root/.ssh/config"
ROOT_SSH_AUTHORIZED_FILE="/root/.ssh/authorized_keys"
MINHBV_HOME="/home/minhbv"
MINHBV_SSH_CONFIG_FILE="$MINHBV_HOME/.ssh/config"
MINHBV_SSH_AUTHORIZED_FILE="$MINHBV_HOME/.ssh/authorized_keys"

add_ssh_config_and_key() {
    local user=$1
    local home_dir=$2
    local ssh_config_file=$3
    local ssh_authorized_file=$4

    if [ ! -d "$home_dir/.ssh/" ]; then
        echo "---> Create the .ssh folder for $user"
        mkdir -p "$home_dir/.ssh/"
    fi

    if grep -q "minhbv" "$ssh_authorized_file"; then
        echo "---> Key minhbv EXISTS for $user!!!"
    else
        echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA5K0K348mAkw8exBBGof/UHySKrEpFIaDCLHTMQF8Xugs6E8Mk8OWVrXyh3BYRMINZbyjvJmTT8D1/IJSw00RQ/zR0rfLYVFDCPCddypyuwOLgFW2iIkfQq6KYcIOn7q48WZddjz6h4xawJahZGOfLU0LZWk4odnB00SsGy8GppN2upEsCPDa301vu6QsHoT+hYmE6NeEipS4zT6E9M0OUL9OmIZuZgyrTWVQok2+11r008qUibQGUuKD+oQF4W8tKpV/k48nlltvHibKpK8B3rtwIWv9Crd36F97hVjU65T9tSlnZDFSSB+v6vRAOx4u+FU8HucZVWLlBs2qqggjDw== minhbv" >> "$ssh_authorized_file"
        echo "---> Key added by minhbv for $user"
    fi

    if grep -q "^UserKnownHostsFile" "$ssh_config_file"; then
        sed -i 's|^UserKnownHostsFile.*|UserKnownHostsFile /dev/null|' "$ssh_config_file"
    else
        echo "UserKnownHostsFile /dev/null" >> "$ssh_config_file"
    fi

    if grep -q "^StrictHostKeyChecking" "$ssh_config_file"; then
        sed -i 's|^StrictHostKeyChecking.*|StrictHostKeyChecking no|' "$ssh_config_file"
    else
        echo "StrictHostKeyChecking no" >> "$ssh_config_file"
    fi

    chmod 700 "$home_dir/.ssh/"
    chmod 600 "$home_dir/.ssh/"*
}

add_ssh_config_and_key "root" "/root" "$ROOT_SSH_CONFIG_FILE" "$ROOT_SSH_AUTHORIZED_FILE"

if id "minhbv" &>/dev/null; then
    echo "User minhbv exists. Adding SSH config and key."
    add_ssh_config_and_key "minhbv" "$MINHBV_HOME" "$MINHBV_SSH_CONFIG_FILE" "$MINHBV_SSH_AUTHORIZED_FILE"
else
    echo "User minhbv does not exist. Skipping SSH config and key addition for this user."
fi

if grep -q "^PasswordAuthentication" $SSHD_CONFIG_FILE; then
    sed -i 's|^PasswordAuthentication.*|PasswordAuthentication yes|' $SSHD_CONFIG_FILE
else
    echo "PasswordAuthentication yes" >> $SSHD_CONFIG_FILE
fi

# if grep -q "^PermitRootLogin" $SSHD_CONFIG_FILE; then
#     sed -i 's|^PermitRootLogin.*|PermitRootLogin prohibit-password|' $SSHD_CONFIG_FILE
# else
#     echo "PermitRootLogin prohibit-password" >> $SSHD_CONFIG_FILE
# fi

systemctl reload sshd
