Role Variables
--------------
hostname=113.164.246.22

hostname=all

hostname=internal-tel4vn

Dependencies
------------
No dependencies

Example step by step to for ansible add ssh key to remote host
----------------
1. a. If you want ansible to add ssh key to remote server that use password
```
$ su jenkins

$ cd ~

$ ssh-copy-id -i ~/.ssh/id_rsa root@113.164.246.22 -p22
```
1. b. If you want ansible to add ssh key to remote server that use key, scp file to server
```
$ su jenkins

$ cd ~

$ ssh ubuntu@113.164.246.22 -i tel4vn-2019.pem -p22
```
2. Add another host in file hosts with variables if needed
