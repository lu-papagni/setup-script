#!/usr/bin/env bash

# Importa impostazioni
source 'conf/script.cfg'

# Fallback ai valori di default
[[ -z "$DOTS_DIR" ]] && DOTS_DIR="$HOME/.dotfiles"
[[ -z "$SOURCES_SRC_DIR" ]] && SOURCES_SRC_DIR='packagelist'
[[ -z "$SETUP_CONF_DIR" ]] && SETUP_CONF_DIR='conf'
[[ -z "$DOTS_REPO" ]] && DOTS_REPO='https://github.com/lu-papagni/dots.git'
[[ -z "$SETUP_SYSTEMD_UNITS" ]] && SETUP_SYSTEMD_UNITS=true

# Importa tutti i moduli
for f in modules/*.sh; do source $f; done

# Se esiste .git allora la repo è gia stata clonata
if [[ ! -d "$DOTS_DIR/.git" ]]; then
  # Controllo se git è installato
  if ! command -v 'git' &> /dev/null; then
    echo "Impossibile proseguire: git non è installato"
    exit 1
  fi

  # Clono la repository
  git clone --recurse-submodules "$DOTS_REPO" "$DOTS_DIR"
  
  if [[ $? -ne 0 ]]; then
    echo "Clonazione di \`$DOTS_REPO\` fallita!"
    exit 1
  fi

  # Aggiorno i sottomoduli
  ( cd "$DOTS_DIR" && git submodule update --remote )
fi

Setup-System
Setup-Distribution
Install-Packages
Link-ConfigFiles "conf/link-ignore.txt"
Setup-Systemd
Setup-DesktopEnvironment
Setup-Apps

echo "Fatto!"
