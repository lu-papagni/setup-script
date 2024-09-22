#!/usr/bin/env bash

source ./modules/*.sh

DOTS_DIR="$HOME/.dotfiles"
DOTS_REPO='https://github.com/lu-papagni/dots.git' 
SOURCES_SRC_DIR="packagelist"

Setup-System
Setup-Distribution
Install-Packages
Setup-DesktopEnvironment

mkdir -p "$DOTS_DIR"
git clone --recurse-submodules "$DOTS_REPO" "$DOTS_DIR"

if [[ $? -ne 0 ]]; then
  echo "Clonazione di \`$DOTS_REPO\` fallita!"
  exit 1
fi

Link-ConfigFiles

# Cambio shell
chsh -s "$(command -v 'zsh')" "${SUDO_USER:-$(whoami)}"
