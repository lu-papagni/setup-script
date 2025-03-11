[[ -v __import_dotfiles ]] && return

__import_dotfiles=1

source ./plugin/utils.sh

function download_dotfiles() {
  local url=
  local dots="${DOTFILES_DIR:-$HOME/.dotfiles}"

  if [[ -n $DOTFILES_REPO ]]; then
    printf -v url 'https://github.com/%s.git' "$DOTFILES_REPO"
    command -v 'git' > /dev/null && git clone "$url" "$dots" > /dev/null 2>&1

    if [[ $? -ne 0 ]]; then
      perror 'clonazione repository fallita!'
      return 2
    fi
  else
    perror 'repository non definita.'
    return 1
  fi

  return 0
}

function link_dotfiles() {
  local dots="${DOTFILES_DIR:-$HOME/.dotfiles}"
  local blacklist="${SYMLINK_BLACKLIST:--}"

  if [[ -d "$dots/.git" ]]; then
    if [[ -z $SYMLINK_BLACKLIST ]]; then
      pwarn 'blacklist non specificata, passo a lettura regex da tastiera.'
    fi

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
