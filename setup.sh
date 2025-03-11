#!/usr/bin/env bash

set -e

if [[ -n $1 && -f $1 ]]; then
  SETUP_CFG_FILE="$1"
elif [[ -f ./default.cfg ]]; then
  SETUP_CFG_FILE=./default.cfg
else
  read -p 'File di configurazione: ' SETUP_CFG_FILE

  if [[ ! -f $SETUP_CFG_FILE ]]; then
    echo "Impossibile trovare il file \`$SETUP_CFG_FILE\`. Riprovare."
    exit 1
  fi
fi

# Impostazioni
source "$SETUP_CFG_FILE"

# Moduli
source ./plugin/tmpfs.sh
source ./plugin/dotfiles.sh
source ./plugin/packages.sh

echo 'Download e collegamento simbolico file di configurazione...'
download_dotfiles && link_dotfiles

echo 'Configurazione mirror e installazione pacchetti...'
configure_mirrors && install_packages

# Solo per WSL
if [[ $(grep -ic 'Microsoft' /proc/sys/kernel/osrelease) -ge 1 ]]; then
  echo 'Impostazioni specifiche di WSL'
  echo 'Configurazione di tmpfs...'
  configure_tmpfs
fi

echo 'Configurazione terminata con successo!'
