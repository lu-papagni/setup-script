[[ -v __import_utils ]] && return

__import_utils=1

alias perror="printf '\e[1;31mERRORE: %s\e[0m\n'"
alias pwarn="printf '\e[1;33mATTENZIONE: %s\e[0m\n'"
alias pinfo="printf '\e[1;32mINFO: %s\e[0m\n'"

function get_distro() {
  echo "$(grep 'ID=' /etc/os-release | sed 's/ID=//')"
}
