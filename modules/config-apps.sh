#!/usr/bin/env bash

function Setup-Apps() {
  echo "Configurazione delle app in corso..."

  # Autenticazione automatica github
  if command -v 'git-credential-oauth' &> /dev/null; then
    git-credential-oauth config
  fi

  # TEST: Decifra file configurazione di rclone
  if command -v 'rclone' &> /dev/null; then
    local -r rclone_config="$HOME/.config/rclone/rclone.conf.gpg" 

    if [[ -f "$rclone_config" ]]; then
      gpg -d "$rclone_config" > "${rclone_config%\.gpg}"
    else
      echo "rclone: file di configurazione criptato non trovato."
    fi
  fi
}
