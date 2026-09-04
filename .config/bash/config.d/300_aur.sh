aur-fetch-review() {
  if (( $# != 1 )); then
    printf 'Usage: aur-fetch-review PACKAGE_BASE\n' >&2
    return 2
  fi

  local package=$1
  local repository
  local tracked_file
  local mime_type

  if [[ ! $package =~ ^[A-Za-z0-9@._+-]+$ ]]; then
    printf 'Invalid AUR package base: %s\n' "$package" >&2
    return 2
  fi

  repository="$HOME/src/$package"
  if [[ -e $repository ]]; then
    printf 'Refusing to overwrite existing review baseline: %s\n' "$repository" >&2
    printf 'Use the documented update workflow instead.\n' >&2
    return 1
  fi

  mkdir -p "$HOME/src" || return
  cd "$HOME/src" || return

  yay -Si "$package" || return
  yay -G "$package" || return

  if [[ ! -d $repository/.git ]]; then
    printf 'Expected AUR repository was not created at %s.\n' "$repository" >&2
    printf 'Pass the AUR package-base name rather than a split-package name.\n' >&2
    return 1
  fi

  cd "$repository" || return

  printf '\n===== REMOTE =====\n'
  git remote -v

  printf '\n===== RECENT HISTORY =====\n'
  git --no-pager log -10 --oneline

  printf '\n===== TRACKED FILES =====\n'
  git ls-files

  while IFS= read -r -d '' tracked_file; do
    mime_type=$(file --brief --mime-type -- "$tracked_file")
    case $mime_type in
      text/*|application/json|application/xml|application/x-shellscript)
        printf '\n===== %s =====\n' "$tracked_file"
        sed -n '1,$p' -- "$tracked_file"
        ;;
      *)
        printf '\n===== %s (%s; inspect separately) =====\n' "$tracked_file" "$mime_type"
        ;;
    esac
  done < <(git ls-files -z)
}
