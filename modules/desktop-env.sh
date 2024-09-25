#!/usr/bin/env bash

function Import-PlasmaSettings() {
  local -r profile="$1"

  if [[ -r "$profile_path" ]]; then
    echo "Caricamento profilo \`$profile\`"
    konsave -a "$profile"
  fi
}

function Setup-DesktopEnvironment() {
  if [[ -v KDE_SESSION_VERSION ]]; then
    local plasma_profile

    echo "KDE Plasma (ver. $KDE_SESSION_VERSION) rilevato."
    read -p "Nome del profilo da caricare" plasma_profile

    Import-PlasmaSettings "$plasma_profile"
  fi
}
