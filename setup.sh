#!/usr/bin/env bash

# Importa tutti i moduli
for f in modules/*.sh; do source $f; done

readonly DOTS_DIR="$HOME/.dotfiles"
readonly DOTS_REPO='https://github.com/lu-papagni/dots.git' 
readonly SOURCES_SRC_DIR="packagelist"
readonly FAV_SHELL='zsh'

if [[ ! -d "$DOTS_DIR" ]]; then
  mkdir -p "$DOTS_DIR"
  git clone --recurse-submodules "$DOTS_REPO" "$DOTS_DIR"
  
  if [[ $? -ne 0 ]]; then
    echo "Clonazione di \`$DOTS_REPO\` fallita!"
    exit 1
  fi

  ( cd "$DOTS_REPO" && git submodule update --remote )
fi

Setup-System
Setup-Distribution
Install-Packages
Link-ConfigFiles "conf/link-ignore.txt"
Setup-Systemd
Setup-DesktopEnvironment
Setup-Apps

# Cambio shell
if [[ "$SHELL" != *"$FAV_SHELL" ]]; then
  echo "Cambio shell di default: \`${SHELL##*/}\` -> \`$FAV_SHELL\`"
  chsh -s "$(command -v "$FAV_SHELL")" "${SUDO_USER:-$(whoami)}"
fi

echo "Fatto!"
