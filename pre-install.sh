#!/usr/bin/env bash

# sudo curl -s https://raw.githubusercontent.com/vanminh2018/git-test/addkey/pre-install.sh | bash

source /etc/os-release
OS=$(echo "$PRETTY_NAME" | cut -d ' ' -f 1)

if [ "$OS" == "CentOS" ]; then
    sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/sysconfig/selinux
    sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
    yum update
    yum install vim nano git net-tools htop curl wget ntp yum-utils net-tools op zsh -y
    yum -y groupinstall core base "Development Tools"
    chsh -s /usr/bin/zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-autosuggestions.git /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' /root/.zshrc
    sed -E -i 's/^ZSH_THEME="(.+)"/ZSH_THEME="gnzh"/' /root/.zshrc
    git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf
    /root/.fzf/install --all
    curl -s https://raw.githubusercontent.com/vanminh2018/git-test/addkey/addkey.sh | bash
fi

if [ "$OS" == "Debian" ] || [ "$OS" == "Ubuntu" ]; then
    apt-get update
    apt-get install lsb-release sudo vim nano git net-tools htop curl wget systemd systemd-sysv apt-transport-https ca-certificates dialog dirmngr build-essential zsh -y
    apt-get -y install inetutils-*
    sudo chsh -s /usr/bin/zsh
    if ! grep -q "export LC_ALL LANG LANGUAGE" /root/.zshrc; then
        cat <<EOF | sudo tee -a /root/.zshrc >/dev/null
LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8
LC_ALL=en_US.UTF-8
export LC_ALL LANG LANGUAGE
EOF
    fi
    sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    sudo git clone https://github.com/zsh-users/zsh-autosuggestions.git /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    sudo sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' /root/.zshrc
    sudo sed -E -i 's/^ZSH_THEME="(.+)"/ZSH_THEME="gnzh"/' /root/.zshrc
    sudo git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf
    sudo /root/.fzf/install --all
    sudo curl -s https://raw.githubusercontent.com/vanminh2018/git-test/addkey/addkey.sh | bash
fi

cat >/etc/sysctl.conf <<EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv4.ip_forward = 1
vm.swappiness = 1
EOF

sysctl -p /etc/sysctl.conf

cat <<EOF | sudo tee /root/.vimrc >/dev/null
syntax on
set background=dark
set shiftwidth=2
set tabstop=2
if has("autocmd")
  filetype plugin indent on
endif
set showcmd
set showmatch
set ignorecase
set smartcase
set autoindent
set backspace=indent,eol,start
set hidden
set incsearch
set ruler
set wildmenu
EOF

cat <<EOF | sudo tee "/etc/security/limits.conf" >/dev/null
* soft core unlimited
* hard core unlimited
* soft data unlimited
* hard data unlimited
* soft fsize unlimited
* hard fsize unlimited
* soft memlock unlimited
* hard memlock unlimited
* soft nofile 1048576
* hard nofile 1048576
* soft rss unlimited
* hard rss unlimited
* soft stack unlimited
* hard stack unlimited
* soft cpu unlimited
* hard cpu unlimited
* soft nproc unlimited
* hard nproc unlimited
* soft as unlimited
* hard as unlimited
* soft maxlogins unlimited
* hard maxlogins unlimited
* soft maxsyslogins unlimited
* hard maxsyslogins unlimited
* soft locks unlimited
* hard locks unlimited
* soft sigpending unlimited
* hard sigpending unlimited
* soft msgqueue unlimited
* hard msgqueue unlimited
EOF
