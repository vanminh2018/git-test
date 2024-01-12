#!/usr/bin/env bash

if [ ! -d "/root/.ssh/" ]; then
    echo "---> Create the .ssh folder"
    mkdir -p /root/.ssh/
fi

if grep -q "minhbv" /root/.ssh/authorized_keys; then
    echo "---> Key minhbv EXISTS!!!"
else
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA5K0K348mAkw8exBBGof/UHySKrEpFIaDCLHTMQF8Xugs6E8Mk8OWVrXyh3BYRMINZbyjvJmTT8D1/IJSw00RQ/zR0rfLYVFDCPCddypyuwOLgFW2iIkfQq6KYcIOn7q48WZddjz6h4xawJahZGOfLU0LZWk4odnB00SsGy8GppN2upEsCPDa301vu6QsHoT+hYmE6NeEipS4zT6E9M0OUL9OmIZuZgyrTWVQok2+11r008qUibQGUuKD+oQF4W8tKpV/k48nlltvHibKpK8B3rtwIWv9Crd36F97hVjU65T9tSlnZDFSSB+v6vRAOx4u+FU8HucZVWLlBs2qqggjDw== minhbv" >>/root/.ssh/authorized_keys
    echo "---> Key added by minhbv"
fi

if grep -q "^UserKnownHostsFile" /root/.ssh/config; then
    sed -i 's|^UserKnownHostsFile.*|UserKnownHostsFile /dev/null|' /root/.ssh/config
    echo "---> UserKnownHostsFile has been replaced with /dev/null"
else
    echo "UserKnownHostsFile /dev/null" >>/root/.ssh/config
    echo "---> UserKnownHostsFile has been added"
fi
