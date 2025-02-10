#!/usr/bin/env bash

function Setup-Apps() {
  echo "Configurazione delle app in corso..."

  # Autenticazione automatica github
  if command -v 'git-credential-oauth' &> /dev/null; then
    echo "git-credential-oauth"
    git-credential-oauth config
  fi

  # TEST: Decifra file configurazione di rclone
  if command -v 'rclone' &> /dev/null; then
    echo "rclone"

    local rclone_config="$HOME/.config/rclone/rclone.conf.gpg" 

    if [[ -f "$rclone_config" ]]; then
      local gpg = "$(command -v 'gpg')"

      if [[ -n "$gpg" ]] then
        $gpg -d "$rclone_config" > "${rclone_config%\.gpg}"
      else
        echo "Attenzione: non posso decifrare configurazione di rclone, gpg mancante."
      fi
    else
      echo "rclone: file di configurazione criptato non trovato."
    fi

    unset rclone_config
  fi

  # Configura `reflector` per aggiornare i mirror
  if command -v 'reflector' &> /dev/null; then
    echo "reflector"
    systemctl enable 'reflector.timer'
  fi

  # Cambio shell
  if [[ "$SHELL" != *"$FAV_SHELL" ]]; then
    # Modifico solo se la shell è installata
    if command -v "$FAV_SHELL" &> /dev/null; then
      echo "Cambio shell di default: \`${SHELL##*/}\` -> \`$FAV_SHELL\`"
  
      # SUDO_USER viene impostata da `sudo`
      chsh -s "$(command -v "$FAV_SHELL")" "${SUDO_USER:-$(whoami)}"
    else
      echo "Impossibile impostare \`$FAV_SHELL\` come predefinita: non è installata."
    fi
  fi
}
