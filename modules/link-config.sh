#!/usr/bin/env bash

[[ -v __DEFINE_LINK ]] && return
readonly __DEFINE_LINK

function Link-ConfigFiles() {
  local -r conf_dir="${DOTS_DIR:-"~/.dotfiles"}"
  local -r ignorefile='link-ignore.txt'
  local file_except="$(mktemp)"
  local dir_except="$(mktemp)"

  if [[ -r "$ignorefile" ]]; then
    local line

    while read -r line; do
      [[ -z "$line" ]] && continue

      if [[ "$line" == */ ]]; then
        echo "${line/%\//}" >> "$dir_except"
      else
        echo "$line" >> "$file_except"
      fi
    done < "$ignorefile"

    unset line
  else
    echo "Impossibile trovare il file delle eccezioni: uso quelle di default." >&2

    echo 'DOCS' >> "$dir_except" 
    echo '.git' >> "$dir_except" 
    echo 'setup' >> "$dir_except" 

    echo '.git*' >> "$file_except"
    echo '*.md' >> "$file_except"
    echo 'user_*.*' >> "$file_except"
    echo '.zshrc.ohmyzsh' >> "$file_except"
  fi

  # Trovo e collego i file
  find "$conf_dir" -mindepth 1 -maxdepth 1 -type d | grep -vGf "$dir_except" | xargs -I{} ln -s "~/.config"
  find "$conf_dir" -mindepth 1 -maxdepth 1 -type f | grep -vGf "$file_except" | xargs -I{} ln -s "~"
}
