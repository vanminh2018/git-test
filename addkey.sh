#!/usr/bin/env bash

# sudo curl -s https://raw.githubusercontent.com/vanminh2018/git-test/addkey/addkey.sh | bash

SSHD_CONFIG_FILE="/etc/ssh/sshd_config"
SSH_CONFIG_FILE="/root/.ssh/config"
SSH_AUTHORIZED_FILE="/root/.ssh/authorized_keys"

if [ ! -d "/root/.ssh/" ]; then
    echo "---> Create the .ssh folder"
    mkdir -p /root/.ssh/
fi

if grep -q "minhbv" $SSH_AUTHORIZED_FILE; then
    echo "---> Key minhbv EXISTS!!!"
else
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA5K0K348mAkw8exBBGof/UHySKrEpFIaDCLHTMQF8Xugs6E8Mk8OWVrXyh3BYRMINZbyjvJmTT8D1/IJSw00RQ/zR0rfLYVFDCPCddypyuwOLgFW2iIkfQq6KYcIOn7q48WZddjz6h4xawJahZGOfLU0LZWk4odnB00SsGy8GppN2upEsCPDa301vu6QsHoT+hYmE6NeEipS4zT6E9M0OUL9OmIZuZgyrTWVQok2+11r008qUibQGUuKD+oQF4W8tKpV/k48nlltvHibKpK8B3rtwIWv9Crd36F97hVjU65T9tSlnZDFSSB+v6vRAOx4u+FU8HucZVWLlBs2qqggjDw== minhbv" >>$SSH_AUTHORIZED_FILE
    echo "---> Key added by minhbv"
fi

if grep -q "^UserKnownHostsFile" $SSH_CONFIG_FILE; then
    sed -i 's|^UserKnownHostsFile.*|UserKnownHostsFile /dev/null|' $SSH_CONFIG_FILE
else
    echo "UserKnownHostsFile /dev/null" >>$SSH_CONFIG_FILE
fi

if grep -q "^StrictHostKeyChecking" $SSH_CONFIG_FILE; then
    sed -i 's|^StrictHostKeyChecking.*|StrictHostKeyChecking no|' $SSH_CONFIG_FILE
else
    echo "StrictHostKeyChecking no" >>$SSH_CONFIG_FILE
fi

if grep -q "^PasswordAuthentication" $SSHD_CONFIG_FILE; then
    sed -i 's|^PasswordAuthentication.*|PasswordAuthentication yes|' $SSHD_CONFIG_FILE
else
    echo "PasswordAuthentication yes" >>$SSHD_CONFIG_FILE
fi

if grep -q "^PermitRootLogin" $SSHD_CONFIG_FILE; then
    sed -i 's|^PermitRootLogin.*|PermitRootLogin prohibit-password|' $SSHD_CONFIG_FILE
else
    echo "PermitRootLogin prohibit-password" >>$SSHD_CONFIG_FILE
fi

chmod 700 /root/.ssh/
chmod 600 /root/.ssh/*
systemctl reload sshd
