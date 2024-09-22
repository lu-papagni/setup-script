#!/usr/bin/env bash

function Install-AurHelper() {
  local build_dir="$(mktemp -d)"
  local -r url='https://aur.archlinux.org/yay.git'

  (
    git clone --depth=1 "$url" "$build_dir" && \
    cd "$build_dir" && \
    makepkg -si
  )

  if [[ $? -eq 0 ]]; then
    echo "Installazione riuscita!"
  else
    echo "Installazione fallita!"
  fi
}

function Setup-Distribution() {
  local current="$(cat '/etc/os-release' | grep -oP 'PRETTY_NAME="\K[^"]+')"
  local supported=(
    'arch'
    'fedora'
    'debian'
  )

  local i=0
  for distro in ${supported[@]}; do
    if echo "$current" | grep -i "$distro" &> /dev/null; then
      current="$distro"
      echo "La distribuzione è supportata."
      break
    fi
    ((i+=1))
  done

  # Esci se la distribuzione non è supportata
  if [[ $i -ge ${#supported[@]} ]]; then
    echo "Distribuzione non supportata."
    return 1
  fi

  unset i

  case "$current" in
    'arch')
      echo "Installazione AUR helper..."
      Install-AurHelper

      # TODO: Servizio di stampa
      # TODO: Impostazioni del package manager
      # TODO: Pulizia automatica cache pacman
      ;;
    'fedora')
      # TODO: rpm fusion
      echo "Coming soon..."
      ;;
    'debian')
      echo "Coming soon..."
      ;;
  esac

  echo "Distribuzione configurata."
}
