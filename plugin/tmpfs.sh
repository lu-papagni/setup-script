[[ -v __import_tmpfs ]] && return

__import_tmpfs=1

source ./plugin/utils.sh

function configure_tmpfs() {
  local fsargs=( 'noexec' 'defaults' 'nodev' 'nosuid' 'noatime' )
  local -r size="${TMPFS_MAX_SIZE:-256}"

  if [[ $(id -u) -eq 0 ]]; then
    if [[ $ENABLE_TMPFS = true ]]; then
      printf 'tmpfs\t/tmp\ttmpfs\t' >> /etc/fstab
      printf '%s,' "${fsargs[@]}" >> /etc/fstab
      printf 'size=%dm\t0 0' "$size" >> /etc/fstab

      return 0
    fi
  else
    perror 'configurare `tmpfs` richiede privilegi di root.'
  fi

  return 1
}
