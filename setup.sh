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

# Controllo dipendenze
while read -r dep; do
  if command -v "$dep" &> /dev/null; then
    echo "Impossibile continuare: \`$dep\` non è installato."
    echo 'Leggi la documentazione per conoscere le dipendenze di questo script.'
    exit 2
  fi
done < ./.deps

# Impostazioni
source "$SETUP_CFG_FILE"

# Moduli
source ./plugin/dotfiles.sh
source ./plugin/packages.sh
source ./plugin/wsl.sh

echo 'Download e collegamento simbolico file di configurazione...'
download_dotfiles && link_dotfiles

echo 'Configurazione mirror e installazione pacchetti...'
configure_mirrors && install_packages

if using_wsl; then
  echo 'Configurazione di WSL...'
  configure_wsl
fi

echo 'Configurazione terminata con successo!'
