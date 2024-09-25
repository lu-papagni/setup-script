#!/usr/bin/env bash

function Link-ConfigFiles() {
  local -r conf_dir="${DOTS_DIR:-"~/.dotfiles"}"
  local -r ignorefile="${1:-"link-ignore.txt"}"
  local -r file_except="$(mktemp)"
  local -r dir_except="$(mktemp)"

  if [[ -f "$ignorefile" ]]; then
    local line

    while read -r line; do
      [[ -z "$line" ]] && continue

      if [[ "$line" == */ ]]; then
        echo "${line%\/}" >> "$dir_except"
      else
        echo "$line" >> "$file_except"
      fi
    done < "$ignorefile"

    unset line
  else
    echo "Impossibile trovare il file delle eccezioni \`$ignorefile\`" >&2
    echo "Uso le impostazioni di default." >&2

    # Directory
    echo 'setup' >> "$dir_except" 
    echo '.git*' >> "$dir_except"

    # File
    echo '.git*' >> "$file_except"
    echo '*.md' >> "$file_except"
    echo '.*.ohmyzsh' >> "$file_except"
  fi

  # Link directory in /home/utente/.config
  echo "Directory: \`$conf_dir\` -> \`$HOME/.config\`" >&2

  mkdir -p "$HOME/.config"
  find "$conf_dir" -mindepth 1 -maxdepth 1 -type d |
    grep -vGf "$dir_except" |
    xargs -I{} ln -s {} "$HOME/.config"

  # Link file liberi in /home/utente
  echo "File: \`$conf_dir\` -> \`$HOME\`" >&2 

  find "$conf_dir" -mindepth 1 -maxdepth 1 -type f |
    grep -vGf "$file_except" |
    xargs -I{} ln -s {} "$HOME"
}
