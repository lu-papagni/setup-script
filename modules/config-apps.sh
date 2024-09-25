#!/usr/bin/env bash

function Config-AppIfInstalled() {
  local -r name="$1"
  local -r cmd="$2"

  if command -v "$name" &> /dev/null; then
    sh -c "$name $cmd"
  fi
}

function Setup-Apps() {
  # Autenticazione automatica github
  Config-AppIfInstalled git-credential-oauth 'config'
}
