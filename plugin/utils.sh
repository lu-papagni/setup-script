[[ -v __import_utils ]] && return

__import_utils=1

function perror() {
  printf '\e[1;31mERRORE: %s\e[0m\n' "$1"
}

function pwarn() {
  printf '\e[1;33mATTENZIONE: %s\e[0m\n' "$1"
}

function pinfo() {
  printf '\e[1;32mINFO: %s\e[0m\n' "$1"
}

function get_distro() {
  printf '%s' "$(grep '^ID=' /etc/os-release | sed 's/ID=//')"
}
