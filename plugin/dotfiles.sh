[[ -v __import_dotfiles ]] && return

__import_dotfiles=1

source ./plugin/utils.sh

function download_dotfiles() {
  local dots="$HOME/${DOTFILES_DIR:-".dotfiles"}"

  if [[ -n $DOTFILES_REPO ]]; then
    local url="https://github.com/${DOTFILES_REPO}.git"

    if [[ ! -d $dots ]]; then
      if [[ -z "$(command -v 'git')" ]]; then
        perror 'git non è disponibile.'
        return 2
      fi

      git clone "$url" "$dots" > /dev/null 2>&1
      
      if [[ $? -ne 0 ]]; then
        perror 'clonazione repository fallita!'
        return 3
      fi
    fi
  else
    perror 'repository non definita.'
    return 1
  fi

  return 0
}

function link_dotfiles() {
  local dots="$HOME/${DOTFILES_DIR:-".dotfiles"}"
  local blacklist="${SYMLINK_BLACKLIST:--}"

  if [[ -d "$dots/.git" ]]; then
    if [[ -z $SYMLINK_BLACKLIST ]]; then
      pwarn 'blacklist non specificata, passo a lettura regex da tastiera.'
    fi

    mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"

    find "$dots" -mindepth 1 -maxdepth 1 | grep -Evf "$blacklist" | while read item; do
      local dest=

      if [[ -d "$item" ]]; then
        # directory in ~/.config
        dest="${XDG_CONFIG_HOME:-$HOME/.config}/$(basename "$item")"
      else
        # file in ~
        dest="$HOME/$(basename "$item")"
      fi

      ln -s "$item" "$dest"
    done
  else
    perror "la directory \`$dots\` non è una repository valida."
    return 1
  fi

  return 0
}
