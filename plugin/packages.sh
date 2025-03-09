[[ -v __import_packages ]] && return

__import_packages=1

source ./plugin/utils.sh

function configure_mirrors() {
  if [[ $(id -u) -ne 0 ]]; then
    perror 'per configurare i mirror sono necessari permessi di root.'
    return -1
  fi

  local distro="$(grep 'ID=' /etc/os-release | sed 's/ID=//')"

  case "$distro" in
    'debian')
      if [[ $ENABLE_UNSTABLE_MIRRORS = true ]]; then
        pinfo 'passo a debian testing.'

        cat > /etc/apt/sources.list <<EOF
        deb http://deb.debian.org/debian testing main
        deb http://security.debian.org/debian-security testing-security main
        EOF
      fi

      apt update
      apt upgrade -y
      apt full-upgrade -y
      apt autoremove -y
      ;;
    *)
      perror "distribuzione \`$distro\` non supportata."
      return 1
      ;;
  esac

  return 0
}

function install_packages() {
  if [[ $(id -u) -ne 0 ]]; then
    perror 'per configurare i mirror sono necessari permessi di root.'
    return -1
  fi

  if [[ -z "$INSTALL_PACKAGES" ]]; then
    perror 'nessun pacchetto da installare.'
    return 1
  fi

  pinfo "trovati ${#INSTALL_PACKAGES[@]} pacchetti da installare."

  local distro="$(grep 'ID=' /etc/os-release | sed 's/ID=//')"

  case "$distro" in
    'debian')
      if [[ -n "$INSTALL_PACKAGES" ]]; then
        apt update
        apt-get install --no-install-recommends "${INSTALL_PACKAGES[@]}" -y
      fi
      ;;
    *)
      ;;
  esac

  return 0
}
