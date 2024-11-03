#!/usr/bin/env bash

# Effettua il setup del package manager
function Setup-PackageManager() {
  local -r manager="$1"

  case "$manager" in
    'yay')
      if [[ "$(whoami)" != "root" ]]; then
        yay -Syu
      elif [[ -n "$SUDO_USER" ]]; then
        sudo -u "$SUDO_USER" yay -Syu
      else
        echo "L'amministratore non può effettuare il setup di \`yay\`"
      fi
      ;;
    'flatpak')
      # flathub
      echo "Aggiungo FlatHub..."
      flatpak remote-add --if-not-exists 'flathub' 'https://dl.flathub.org/repo/flathub.flatpakrepo'
      flatpak update --appstream
      ;;
    'dnf')

      # Ricreo la cache
      sudo dnf clear all
      sudo dnf makecache
      sudo dnf update -y

      # rpm fusion
      echo "Abilito RPM Fusion..."
      sudo dnf install \
        "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
      sudo dnf install \
        "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
      ;;
    'apt' | 'apt-get')
      echo "ATTENZIONE: nessun setup specifico per \`$manager\`"
      ;;
  esac
}

# Rimuove le fonti indesiderate per indice
function Remove-UnwantedSources() {
  local remove_indices
  local sources=("$@")

  # Stampo lista
  local source_name

  for i in ${!sources[@]}; do
    source_name="$(basename "${sources[$i]}")"
    source_name="${source_name/%\.*/}"

    # Stampo su stderr
    echo "$((i+1))) $source_name" >&2
  done

  unset source_name

  # Leggo fonti da ignorare
  read -p "Fonti da ignorare (separate da spazi, INVIO per annullare): " -a remove_indices
  
  # Rimuovo gli elementi
  for k in ${remove_indices[@]}; do
    [[ "$k" =~ [[:digit:]] ]] && unset sources[$((k-1))]
  done

  echo "${sources[@]}"
}

# Ottiene il comando che determina i privilegi del package manager
function Get-PrivilegePrefix() {
  local privilege
  local -r run_as="$1"
  local -r username="$([[ -n "$SUDO_USER" ]] && echo "$SUDO_USER" || whoami)"

  case "$run_as" in
    'root')
      [[ "$username" = "root" ]] && privilege="" || privilege="sudo"
      ;;
    'user')
      if [[ "$username" != "root" ]]; then
        privilege="sudo -u $username"
      else
        echo "Impossibile eseguire come root!" >&2
        return 1
      fi
      ;;
    *)
      echo "Il valore di \`run_as\` non può essere \`$run_as\`" >&2
      return 2
      ;;
  esac

  echo -n "$privilege"
}

# Logica principale installazione
function Install-Packages() {
  local sources_dir="${SOURCES_SRC_DIR:-"packagelist"}"

  # Controllo se esiste la directory
  if [[ ! -d "$sources_dir" ]]; then
    echo "Era prevista una directory \`$sources_dir\` nella directory di lavoro, ma non è stata trovata."
    return 1
  fi

  local -r managers=("$(find "$sources_dir" -mindepth 1 -maxdepth 1 -type d | xargs -I{} basename {})")

  # Parsing del file
  for manager in ${managers[@]}; do
    if command -v "$manager" &> /dev/null; then
      local install_cmd
      local run_as
      local skip_confirm_cmd

      Setup-PackageManager "$manager"

      case "$manager" in
        'yay')
          install_cmd="-S --needed"
          run_as="user"
          skip_confirm_cmd="--noconfirm --askyesremovemake"
          ;;
        'dnf')
          install_cmd="install"
          run_as="root"
          skip_confirm_cmd="-y"
          ;;
        'apt' | 'apt-get')
          install_cmd="install"
          run_as="root"
          skip_confirm_cmd="-y"
          ;;
        'flatpak')
          install_cmd="install"
          run_as="user"
          skip_confirm_cmd="-y"
          ;;
        'pip')
          install_cmd="install"
          run_as="user"
          skip_confirm_cmd="--no-input"
          ;;
        *)
          echo "Il package manager \`$manager\` non è supportato." >&2
          ;;
      esac

      # Ottengo le fonti
      local sources=("$(find "$sources_dir/$manager" -mindepth 1 -type f -name '*.txt')")

      # Rimuovo gli elementi
      echo "Fonti per \`$manager\`:"
      sources="$(Remove-UnwantedSources ${sources[@]})"

      # Installo i pacchetti
      for source in ${sources[@]}; do
        local packages

        if [[ ! -r "$source" ]]; then
          echo "Fonte \`${source}\` illeggibile."
          continue
        fi

        # Leggo i pacchetti da file
        mapfile -t packages < "$source"

        echo "Installo i pacchetti dalla fonte \`$source\`..."
        sh -c "$(Get-PrivilegePrefix "$run_as") $manager $install_cmd ${packages[*]} $skip_confirm_cmd"
      done
    else
      echo "Package manager \`$manager\` non trovato: salto la fonte."
    fi
  done
 }
