#!/usr/bin/env bash

function Set-Hostname() {
  local static
  local pretty

  echo "Hostname breve corrente: '$(hostnamectl --static)'"
  echo "Hostname dettagliato corrente: '$(hostnamectl --pretty)'"
  echo "Inserire nuovi hostname (lascia vuoto per ignorare)"

  read -p "Breve: " static 
  read -p "Dettagliato: " pretty 

  [[ -n "$static" ]] && hostnamectl --static hostname "$static"
  [[ -n "$pretty" ]] && hostnamectl --pretty hostname "$pretty"
}

# TEST: abilitazione bluetooth
function Enable-Bluetooth() {
  echo "Abilito il Bluetooth..."

  if ! systemctl status bluetooth &> /dev/null; then
    systemctl enable bluetooth && systemctl start bluetooth

    [[ $? -ne 0 ]] && echo "Il dispositivo non supporta il Bluetooth."
  fi
}

# TEST: abilitazione & setup di firewalld
function Setup-Firewalld() {
  local -r firewalld_dir="${DOTS_DIR:-"$HOME/.dotfiles"}/firewalld"
  local zones=()

  echo "Abilito firewalld..."

  if ! systemctl status firewalld &> /dev/null; then
    systemctl enable firewalld

    if [[ $? -eq 0 ]]; then
      # Impostazione delle zone
      if [[ -d "$firewalld_dir/zones" ]]; then
        zones=("$(find "$firewalld_dir/zones" -mindepth 1 -type f -name '*.xml')")

        echo "Imposto le zone di firewalld definite dall'utente"

        for zone in ${zones[@]}; do
          sudo cp -v "$zone" "/etc/firewalld/zones"
        done

        systemctl start firewalld
      else
        echo "Directory \`$firewalld_dir/zones\` mancante."
      fi
    else
      echo "Errore durante l'abilitazione di firewalld."
    fi
  fi
}

function Setup-System() {
  Set-Hostname
  Enable-Bluetooth
  Setup-Firewalld
}
