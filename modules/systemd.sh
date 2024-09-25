#!/usr/bin/env bash

function Enable-SystemdUnits() {
  local -r src_dir="$1"
  local -r flags="$3"
  local copied_units=()

  if [[ ! -d "$src_dir" ]]; then
    echo "Directory fonte \`$src_dir\` non trovata!" >&2
    echo "Annullo operazione." >&2
    return 1
  fi

  # Abilita unità
  for unit in ${src_dir}/*; do
    local unit_name="$(basename "$unit")"

    # Se è un timer
    if [[ "$unit" == *.timer ]] && ! systemctl status "$unit_name"; then
      systemctl "$flags" enable "$unit"

      if [ $? -eq 0 ]; then
        enabled_units+=("$unit_name")
        echo "Abilitato timer: \`$unit\`" >&2
        echo "Errore abilitazione timer: \`$unit\`"
      fi

    # Altrimenti se è un servizio
    elif [[ "$unit" == *.service ]]; then
      local timer_file="${unit_name%.service}.timer"

      # Se non ha un timer corrispondente
      if [[ ! " ${enabled_units[@]} " =~ " $timer_file " ]]; then
        systemctl "$flags" enable "$unit"

        if [ $? -eq 0 ]; then
          echo "Abilitato servizio: \`$unit\`" >&2
          echo "Errore abilitazione servizio: \`$unit\`"
        fi

      else
        systemctl "$flags" enable "$timer_file"

        if [ $? -eq 0 ]; then
          echo "Abilitato timer: \`$timer_file\`" >&2
          echo "Errore abilitazione timer: \`$timer_file\`" >&2
        fi
      fi
    fi
  done
}

function Setup-Systemd() {
  local -r systemd_loc="/etc/systemd"
  local -r systemd_dots="$DOTS_DIR/systemd"
  local -r sys_dir="$systemd_loc/user"
  local -r usr_dir="$systemd_loc/system"

  if [[ -d "$systemd_dots" ]]; then
    echo "Abilito unità di sistema" >&2
    Enable-SystemdUnits "$systemd_dots/system" "$sys_dir" ""

    echo "Abilito unità utente" >&2
    Enable-SystemdUnits "$systemd_dots/user" "$usr_dir" "--user"
  else
    echo "Non sono trovate unità systemd definite dall'utente." >&2
    return 1
  fi

  return 0
}
