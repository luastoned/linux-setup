## move to assets
cd assets

## download extensions
curl -o git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
curl -o git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

## copy bashrc & extensions
sudo cp .bashrc ~/.bashrc
sudo cp git-prompt.sh ~/.git-prompt.sh
sudo cp git-completion.bash ~/.git-completion.bash

source ~/.bashrc
