[[ -v __import_wsl ]] && return

__import_wsl=1

source ./plugin/utils.sh
source ./plugin/tmpfs.sh

function using_wsl() {
  local ms_kernel="$(grep -ic 'Microsoft' /proc/sys/kernel/osrelease)"

  # Se il kernel non è quello custom di WSL
  [[ $ms_kernel -lt 1 ]] && return 1

  return 0
}

function configure_wsl() {
  local wslconf="$HOME/$DOTFILES_DIR/MISC/wsl.conf"

  if [[ -f $wslconf ]]; then
    if [[ $(id -u) -eq 0 ]]; then
      pinfo 'importo la configurazione di WSL.'
      cp "$wslconf" /etc/wsl.conf
    else
      pwarn 'non è stato possibile importare la configurazione di WSL.'
      pwarn 'sono richiesti i privilegi di amministratore.'
    fi
  else
    pwarn 'configurazione di WSL non trovata.'
  fi
  
  pinfo 'abilito tmpfs su WSL.'
  configure_tmpfs
}
