#!/bin/bash

echo "################################################################"
echo "## Linux Setup"
echo "################################################################"

skipArg=$1
function skipQuestions {
  [[ "$skipArg" == "-f" || "$skipArg" == "--force" ]]
  return
}

# default yes values
runUpdate=1
runBashrc=1
runDocker=1
runNode=1
runUtilities=1
runNano=1
runTmux=1
runInotify=1
runNginx=1

# default no values
runCertbot=0
runK3d=0
runSSHKeys=0

if ! skipQuestions; then
  echo "Skip questions with -f or --force"

  read -p "Run apt update and upgrade? (Y/n) "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    runUpdate=0
  fi

  read -p "Install .bashrc? (Y/n) "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    runBashrc=0
  fi

  read -p "Install Docker? (Y/n) "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    runDocker=0
  fi

  read -p "Install Node & Yarn? (Y/n) "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    runNode=0
  fi

  read -p "Install Utilities (git, curl, tmux, ...)? (Y/n) "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    runUtilities=0
  fi

  read -p "Install Certbot? (y/N) "
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    runCertbot=0
  fi

  read -p "Install k3d, kubectl, krew, kubectx, kubens, konfig, helm ? (y/N) "
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    runK3d=1
  fi

  read -p "Update nano / tmux config? (Y/n) "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    runNano=0
    runTmux=0
  fi

  read -p "Stop nginx and nginx service? (Y/n) "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    runNginx=0
  fi

  read -p "Increase the amount of inotify watchers? (Y/n) "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    runInotify=0
  fi

  read -p "Copy SSH keys to authorized_keys ? (y/N) "
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    runSSHKeys=1
  fi
fi

if [[ $runUpdate == 1 ]]; then
  /bin/bash scripts/update.sh
fi

if [[ $runBashrc == 1 ]]; then
  /bin/bash scripts/bashrc.sh
fi

if [[ $runDocker == 1 ]]; then
  /bin/bash scripts/docker.sh
fi

if [[ $runNode == 1 ]]; then
  /bin/bash scripts/node.sh
fi

if [[ $runUtilities == 1 ]]; then
  /bin/bash scripts/utilities.sh
fi

if [[ $runCertbot == 1 ]]; then
  /bin/bash scripts/certbot.sh
fi

if [[ $runNano == 1 ]]; then
  /bin/bash scripts/nano.sh
fi

if [[ $runTmux == 1 ]]; then
  /bin/bash scripts/tmux.sh
fi

if [[ $runInotify == 1 ]]; then
  /bin/bash scripts/inotify-watchers.sh
fi

if [[ $runNginx == 1 ]]; then
  /bin/bash scripts/stop-nginx.sh
fi

if [[ $runK3d == 1 ]]; then
  /bin/bash scripts/k3d.sh
fi

if [[ $runSSHKeys == 1 ]]; then
  /bin/bash scripts/ssh-keys.sh
fi

exit 0

# read -p "Run APT update and upgrade? (Y/n) " -n 1
# case ${answer:0:1} in
# y | Y)
#   echo 'Running apt update ...'
#   ;;
# *)
#   echo 'Skipping apt update ...'
#   ;;
# esac
