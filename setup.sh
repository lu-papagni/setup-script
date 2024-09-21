#!/usr/bin/env bash

source ./modules/*.sh

DOTS_DIR='~/.dotfiles'
DOTS_REPO='https://github.com/lu-papagni/dots.git' 

Install-Packages
Setup-System
Setup-Distribution

if command -v 'git' &> /dev/null; then
  mkdir -p "$DOTS_DIR"
  git clone --recurse-submodules "$DOTS_REPO" "$DOTS_DIR"

  if [[ $? -ne 0 ]]; then
    echo "Clonazione repository fallita!"
    exit 1
  fi

  Link-ConfigFiles
  chsh -s "$(command -v 'zsh')" "${SUDO_USER:-$(whoami)}"
else
  echo "Git non è installato sul sistema."
fi
