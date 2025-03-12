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
    *)
      perror "distribuzione \`$distro\` non supportata."
      return 1
      ;;
  esac

  return 0
}

function install_packages() {
  if [[ $(id -u) -ne 0 ]]; then
    perror 'per installare i pacchetti sono necessari permessi di root.'
    return -1
  fi

  if [[ -n "$INSTALL_PACKAGES" ]]; then
    local distro="$(get_distro)"
    pinfo "trovati ${#INSTALL_PACKAGES[@]} pacchetti da installare."

    case "$distro" in
      'debian')
        apt-get update
        apt-get install --no-install-recommends "${INSTALL_PACKAGES[@]}" -y
        ;;
      *)
        perror "distribuzione \`$distro\` non supportata."
        return 1
        ;;
    esac
  fi

  return 0
}
