#!/usr/bin/env bash

# ██████╗  █████╗  ██████╗██╗  ██╗ █████╗  ██████╗ ███████╗███████╗
# ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔════╝ ██╔════╝██╔════╝
# ██████╔╝███████║██║     █████╔╝ ███████║██║  ███╗█████╗  ███████╗
# ██╔═══╝ ██╔══██║██║     ██╔═██╗ ██╔══██║██║   ██║██╔══╝  ╚════██║
# ██║     ██║  ██║╚██████╗██║  ██╗██║  ██║╚██████╔╝███████╗███████║
# ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝

[[ -v __DEFINE_PACKAGEINST ]] && return
readonly __DEFINE_PACKAGEINST

function InstallPackages() {
  local -r src_dir="packagelist"
  local sources=()

    # Controllo se sono stati forniti i parametri
    if [[ -z $sources ]]; then
      echo "Installazione pacchetti: non sono state forniti i parametri."
      return 1
    fi

    # Controllo se esiste la directory
    if [[ ! -d "$src_dir" ]]; then
      echo "Era prevista una directory \`$src_dir\` nella directory di lavoro, ma non è stata trovata."
      return 1
    fi

    # Parsing del file
    for source in ${sources[@]}; do
      local pgk_manager=""
      local install_cmd=""
      local packages=()
      local privilege=""
      local run_as=""
      local skip_confirm_cmd=""

      echo "Lettura lista dei pacchetti: \`$source\`"

      # Controllo se il file è leggibile
      if [[ ! -r "$src_dir/$source.txt" ]]; then
        echo "La lista \`$source\` non è leggibile. Proseguo..."
        continue
      fi

      # Leggo il package manager da usare alla prima riga del file
      pkg_manager="$(head -n 1 "$src_dir/$source.txt" | sed s/\!//)"

      # Salvo ogni pacchetto da installare, uno per riga
      for line in $(tail -n +2 "$src_dir/$source.txt"); do
        packages+=("$line")
      done

      # Imposto i comandi da eseguire in base al package manager
      case "$pkg_manager" in
        yay | pacman)
          skip_confirm_cmd="--noconfirm"
          ;;
        pacman)
          [[ "$(whoami)" != "root" ]] && privilege="sudo"
          install_cmd="-S --needed"
          ;;
        yay)
          run_as="$SUDO_USER"
          install_cmd="-S --needed --clean"
          ;;
        flatpak)
          install_cmd="install"
          skip_confirm_cmd="--assumeyes"
          ;;
        dnf | apt | 'apt-get')
          [[ "$(whoami)" != "root" ]] && privilege="sudo"
          install_cmd="install"
          skip_confirm_cmd="-y"
          ;;
        *)
          Log --error "$(Highlight "$pkg_manager") non è supportato."
          return 1
          ;;
      esac

      # Controllo che il package manager sia installato
      if ! command -v "$pkg_manager" &> /dev/null; then
        echo "Il package manager \`$pkg_manager\` non è presente sul sistema."
        return 1
      fi

      echo "Installazione pacchetti, fonte \`$source\`"

      # Comando per installare i pacchetti
      [[ -z $run_as ]] && privilege="$privilege -u $run_as"
      sh -c "$privilege $pkg_manager $install_cmd $skip_confirm_cmd ${packages[@]}"

    done # Fine parsing

    # TODO: Spostare la config di KDE nel suo modulo

   # Se KDE deve essere configurato
   if [[ -n "$SETUP_KONSAVE_PROFILE" && -r "$HOME/.dotfiles/konsave/profiles/$SETUP_KONSAVE_PROFILE" ]]; then
     Log "Caricamento profilo $(Highlight "$SETUP_KONSAVE_PROFILE")..."
     AssertExecutable "konsave" && konsave -a "$HOME/konsave/profiles/$SETUP_KONSAVE_PROFILE"
   fi

   Log "... fine installazione pacchetti."
 }
