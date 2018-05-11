# linux-setup

# download extensions
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

# copy bashrc & extensions
cp .bashrc ~/.bashrc
cp git-prompt.sh ~/.git-prompt.sh
cp git-completion.bash ~/.git-completion.bash

source ~/.bashrc
