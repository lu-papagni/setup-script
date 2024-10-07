#!/usr/bin/env bash

# Compila ed installa un AUR helper dato il link della sua repository
function Install-AurHelper() {
  local -r build_dir="$(mktemp -d)"
  local -r url="$1"
  local name="$url"

  if [[ -z "$url" || "$url" != https://?*.?*/?*.git ]]; then
    echo "URL \`$url\` invalido perché nullo o non è una repo Git."
    return 1
  fi

  # Estraggo il nome della repository 
  name="${name##\/}"; name="${name%\.git}"

  echo "Installazione di \`$name\` in corso..."

  echo "Clonazione della repository in \`$build_dir\`"
  git clone --depth=1 "$url" "$build_dir" && ( cd "$build_dir" && makepkg -si )

  if [[ $? -eq 0 ]]; then
    echo "Operazione riuscita!"
  else
    echo "Operazione fallita!"
  fi
}

function Setup-Distribution() {
  local current="$(cat '/etc/os-release' | grep -oP 'PRETTY_NAME="\K[^"]+')"

  local -r current_name="$(echo -n "$current" |
    grep -Pio '(arch|fedora|debian)' |
    tr '[:upper:]' '[:lower:]')"

  echo "Configurazione di \`$current_name\` in corso..."

  case "$current_name" in
    'arch')
      Install-AurHelper 'https://aur.archlinux.org/yay.git'

      # TODO: Servizio di stampa
      # TODO: Impostazioni del package manager
      # TODO: Pulizia automatica cache pacman
      ;;
    'fedora')
      # TEST: installazione automatica di `JetBrainsMono Nerd Font`
      # versione di Aprile 2024
      echo "Installazione di font non presenti nelle repository..."
      curl -LO --output-dir '/tmp' 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip'

      if unzip -tqq '/tmp/JetBrainsMono.zip' &> /dev/null; then
        echo "File ZIP scaricato senza errori."
        mkdir -p '~/.local/share/fonts' && \
        unzip -dq '~/.local/share/fonts' '/tmp/JetBrainsMono.zip' 'JetBrainsMonoNerdFont-*.ttf'
      else
        echo "Il file ZIP è corrotto. Riprovare."
      fi
      ;;
    'debian')
      echo "Coming soon..."
      ;;
    *)
      echo "La distribuzione \`$current_name\` non è supportata!"
      ;;
  esac

  echo "Distribuzione configurata."
}
