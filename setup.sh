#!/usr/bin/env bash

# Importa tutti i moduli
for f in modules/*.sh; do source $f; done

DOTS_DIR="$HOME/.dotfiles"
DOTS_REPO='https://github.com/lu-papagni/dots.git' 
SOURCES_SRC_DIR="packagelist"

if [[ ! -d "$DOTS_DIR" ]]; then
  mkdir -p "$DOTS_DIR"
  git clone --recurse-submodules "$DOTS_REPO" "$DOTS_DIR"
  
  if [[ $? -ne 0 ]]; then
    echo "Clonazione di \`$DOTS_REPO\` fallita!"
    exit 1
  fi
fi

Setup-System
Setup-Distribution
Install-Packages
Setup-DesktopEnvironment
Link-ConfigFiles "conf/link-ignore.txt"
Setup-Systemd
Setup-Apps

# Cambio shell
if [[ "$SHELL" != *zsh ]]; then
  echo "Cambio shell di default"
  chsh -s "$(command -v 'zsh')" "${SUDO_USER:-$(whoami)}"
fi

echo "Fatto!"
