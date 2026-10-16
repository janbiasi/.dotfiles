[[ ${HERDR_ENV:-} == 1 ]] || return

_herdr_report_project() {
  local previous_status=$?
  if [[ ${_herdr_project_cwd:-} != "$PWD" ]]; then
    if "$HOME/.config/herdr/report-project.sh"; then
      _herdr_project_cwd=$PWD
    fi
  fi
  return "$previous_status"
}

PROMPT_COMMAND+=(_herdr_report_project)
