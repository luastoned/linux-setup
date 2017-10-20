# linux-setup

# remove apache2
service apache2 stop
apt-get remove apache* -y

# x86 & x64

dpkg --add-architecture i386

# update

apt-get update
apt-get upgrade -y

# ssh

mkdir ~/.ssh
cp authorized_keys ~/.ssh/
cp sshd_config /etc/ssh/
service ssh restart

# bashrc

cp .bashrc ~/.bashrc

cd ~
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

apt-get install vim git-core build-essential rlwrap curl htop libssl-dev letsencrypt -y

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.5/install.sh | bash

git clone http://luajit.org/git/luajit-2.0.git
git checkout v2.1


# update-rc.d -f postfix remove
