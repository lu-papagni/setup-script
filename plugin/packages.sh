[[ -v __import_packages ]] && return

__import_packages=1

source ./plugin/utils.sh

function configure_mirrors() {
  if [[ $(id -u) -ne 0 ]]; then
    perror 'per configurare i mirror sono necessari permessi di root.'
    return -1
  fi

  local distro="$(get_distro)"

  case "$distro" in
    'debian')
      if [[ $ENABLE_UNSTABLE_MIRRORS = true ]]; then
        pinfo 'passo ai mirror di debian testing.'

        local mirrors=(
          'deb http://deb.debian.org/debian testing main'
          'deb http://security.debian.org/debian-security testing-security main'
        )

        printf '%s\n' "${mirrors[@]}" | tee -p /etc/apt/sources.list > /dev/null
      fi

      apt-get update
      apt-get upgrade -y
      apt-get full-upgrade -y
      apt-get autoremove -y
      ;;
    'fedora')
      dnf clear all
      dnf makecache
      dnf upgrade -y
      ;;
    *)
      perror "distribuzione \`$distro\` non supportata."
      return 1
      ;;
  esac

  return 0
}

function install_bob_nvim() {
  local arch="$(uname -m)"
  local os="$(uname -o)"
  local bob_file="bob-nvim-$(date +%s)"

  case "$arch" in
    x86_64)
      ;;
    arm*)
      arch='arm'
      ;;
    *)
      perror 'Architettura non compatibile con bob'
      return 1
      ;;
  esac

  case "$os" in
    *[Ll]inux)
      os='linux'
      ;;
    [Dd]arwin)
      os='macos'
      ;;
    *)
      perror 'Sistema operativo non compatibile con bob'
      return 2
  esac

  pinfo "Download di bob per OS: $os, architettura: $arch"

  # Download del file corretto
  curl -L "https://github.com/MordechaiHadad/bob/releases/download/latest/bob-$os-$arch.zip" \
    -o "/tmp/$bob_file.zip"

  if [[ $? -ne 0 ]]; then
    perror 'Impossibile scaricare bob da GitHub'
    return 3
  fi

  unzip -d '/tmp' "/tmp/$bob_file.zip"
  mkdir -p "$HOME/.local/bin"
  mv "/tmp/$bob_file.zip" "$HOME/.local/bin"

  # Rimuovo neovim dai pacchetti da installare con il package manager
  INSTALL_PACKAGES=("${INSTALL_PACKAGES[@]/neovim}")

  return 0
}

function install_packages() {
  if [[ $(id -u) -ne 0 ]]; then
    perror 'per installare i pacchetti sono necessari permessi di root.'
    return -1
  fi

  if [[ -n "$INSTALL_PACKAGES" ]]; then
    local distro="$(get_distro)"

    # Controllo se devo usare bob per installare neovim.
    # Su alcune distribuzioni come Debian il pacchetto di neovim viene aggiornato
    # molto lentamente, perciò conviene installarlo attraverso tool appositi.
    [[ $USE_BOB_NVIM = true ]] && install_bob_nvim

    if [[ $? -eq 0 ]]; then
      pinfo 'Installazione di bob completata!'
      pinfo 'Per installare neovim lanciare `bob` dalla riga di comando.'
    else
      perror 'Installazione di bob fallita.'
    fi

    # Mostro il numero di pacchetti che verranno installati
    pinfo "trovati ${#INSTALL_PACKAGES[@]} pacchetti da installare."

    # Scelgo il comando per installare i pacchetti in base alla distribuzione
    case "$distro" in
      'debian')
        apt-get update
        apt-get install --no-install-recommends "${INSTALL_PACKAGES[@]}" -y
        ;;
      'fedora')
        dnf install "${INSTALL_PACKAGES[@]}" -y
        ;;
      *)
        perror "distribuzione \`$distro\` non supportata."
        return 1
        ;;
    esac
  fi

  return 0
}
