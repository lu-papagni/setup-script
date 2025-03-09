usage() {
  printf -- 'Script di setup per Linux\n\n'
  printf -- 'SINTASSI: setup.sh [file_cfg]\n'
  printf -- 'PARAMETRI\n'
  printf '%s:\t%s\n' 'file_cfg' 'Percorso assoluto o relativo di un file di configurazione compatibile.'
  printf -- '\t\tSe non viene fornito verrà richiesto in input.'
}

if [[ -n $1 && -f $1 ]]; then
  SETUP_CFG_FILE="$1"
elif [[ -f ./default.cfg ]]; then
  SETUP_CFG_FILE=./default.cfg
else
  read -p 'File di configurazione: ' SETUP_CFG_FILE

  if [[ ! -f $SETUP_CFG_FILE ]]; then
    echo "Impossibile trovare il file \`$SETUP_CFG_FILE\`. Riprovare."
    usage
    exit 1
  fi
fi

# Impostazioni
source "$SETUP_CFG_FILE"

# Moduli
source ./plugin/tmpfs.sh
source ./plugin/dotfiles.sh
source ./plugin/packages.sh

download_dotfiles && link_dotfiles
configure_mirrors && install_packages

# Solo per WSL
if [[ $(grep -ic 'Microsoft' /proc/sys/kernel/osrelease) -ge 1 ]]; then
  configure_tmpfs
fi
