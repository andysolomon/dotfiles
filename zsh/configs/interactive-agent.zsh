# Pi marks its process and inherited children with AI_AGENT. The skills CLI
# uses that marker to disable its selector, but an interactive shell is
# user-driven. Keep Pi's marker for non-interactive child commands while
# letting interactive commands behave normally.
if [[ -o interactive && -t 0 && -t 1 && -n "${AI_AGENT:-}" ]]; then
  unset AI_AGENT
fi
