#!/usr/bin/env bash

function Enable-SystemdUnits() {
  local -r src_dir="$1"
  local -r flags="$2"

  if [[ ! -d "$src_dir" ]]; then
    echo "Directory fonte \`$src_dir\` non trovata!" >&2
    echo "Annullo operazione." >&2
    return 1
  fi

  local units=("$(find "$src_dir" -mindepth 1 -type f -regextype posix-extended -regex '.*\.(service|timer)$')")

  # Abilita unità
  for unit in ${units[@]}; do
    local timer
    local target_file="$unit"

    # Se è un servizio controllo che ci sia un timer associato
    if [[ "$unit" == *.service ]]; then
      # Sostituisco `.service` con `.timer`
      timer="${unit%\.service}.timer"

      [[ -f "$timer" ]] && target_file="$timer"
    fi

    systemctl "$flags" enable "$target_file"

    if [[ $? -eq 0 ]]; then
      echo "Abilitata unità: \`$(basename $target_file)\`" >&2
    else
      echo "Errore abilitazione unità: \`$(basename $target_file)\`" >&2
    fi
  done
}

function Setup-Systemd() {
  local -r systemd_dots="${DOTS_DIR:-"$HOME/.dotfiles"}/systemd"

  if [[ -d "$systemd_dots" ]]; then
    echo "Abilito unità di sistema" >&2
    Enable-SystemdUnits "$systemd_dots/system"

    echo "Abilito unità utente" >&2
    Enable-SystemdUnits "$systemd_dots/user" "--user"
  else
    echo "Non sono trovate unità systemd definite dall'utente." >&2
    return 1
  fi

  return 0
}
