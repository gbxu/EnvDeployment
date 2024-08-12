#!/bin/bash
THIS_PATH=$(readlink -f "$0")
THIS_DIR=$(dirname "$THIS_PATH")
MY_ENV_DEPLOYMENT=${THIS_DIR}/../../EnvDeployment
source ${MY_ENV_DEPLOYMENT}/configs/.my_aliases
echo "MY_ENV_DEPLOYMENT is located at: ${MY_ENV_DEPLOYMENT}"
echo "Get sudo to install tmux and zsh, or just copy: .zshrc .vimrc .tmux.conf .tmux.conf.local"
if [[ "$(whoami)" != "root" ]]; then
    SUDO=sudo
fi
export DEBIAN_FRONTEND=noninteractive

${SUDO} apt update
${SUDO} apt install git zsh tmux fzf command-not-found -y

# chsh -s /usr/bin/zsh
export ZSH="${MY_ENV_DEPLOYMENT}/download/.oh-my-zsh"
if [ -d ${ZSH} ];  then
    echo "${ZSH} installed."
else
    sh -c "$(curl -fsSL https://install.ohmyz.sh/) --unattended "
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH}/plugins/zsh-autosuggestions
fi

echo "export MY_ENV_DEPLOYMENT=\"${MY_ENV_DEPLOYMENT}\"" > ${HOME}/.zshrc
cat ${MY_ENV_DEPLOYMENT}/configs/.zshrc >> ${HOME}/.zshrc

cp ${MY_ENV_DEPLOYMENT}/configs/.vimrc ${HOME}/

cp ${MY_ENV_DEPLOYMENT}/configs/.tmux.conf ${HOME}/
cp ${MY_ENV_DEPLOYMENT}/configs/.tmux.conf.local ${HOME}/

cp ${MY_ENV_DEPLOYMENT}/configs/.gitconfig ${HOME}/
echo "copy configs from ${MY_ENV_DEPLOYMENT}/configs to ${HOME}" && ls ${HOME}/ -l

/bin/zsh -c "source ${HOME}/.zshrc" &&
if [ -n "$TMUX" ]; then
    tmux source-file ~/.tmux.conf
    echo "tmux configuration reloaded."
else
    echo "Not inside a tmux session. Skipping tmux configuration reload."
fi
