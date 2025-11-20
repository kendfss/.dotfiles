# Bash equivalent of pexp function
pexp() {
  for arg in "$@"; do
    # In bash, we'd need to manually interpret prompt escapes
    # This is a simplified version that doesn't do full prompt expansion
    echo "$arg"
  done
}

# Set prompt symbols
tick='✔'
cross='✗'
dot='•'

# Bash PROMPT_COMMAND to update prompt dynamically
set_bash_prompt() {
  local exit_code=$?
  
  # Get current directory (similar to zsh's %~)
  local pth
  if [[ "$PWD" == "$HOME" ]]; then
    pth="~"
  elif [[ "$PWD" == "$HOME"/* ]]; then
    pth="~${PWD#$HOME}"
  else
    pth="$PWD"
  fi
  
  # Shorten path if too long (keep last 2 components)
  if [[ $(echo "$pth" | tr -cd '/' | wc -c) -gt 2 ]]; then
    pth="...${pth##*/*/}"
  fi
  
  # Set color based on exit code
  local status_color
  if [ $exit_code -eq 0 ]; then
    status_color='32'  # green
  else
    status_color='31'  # red
  fi
  
  # Get hostname/model info
  local host_info
  if [[ -n "$TERMUX__PREFIX" ]]; then
    host_info=$(getprop ro.product.model 2>/dev/null || echo "$HOSTNAME")
  else
    host_info="$HOSTNAME"
  fi
  
  # Build the prompt
  PS1="\[\033[1;36m\]$pth\[\033[0m\]"  # bold cyan path
  
  PS1+="(\033[${status_color}m\u@${host_info}\033[0m)"
  
  # Add status symbol
  if [ $UID -eq 0 ]; then
    PS1+=" $dot "
  else
    if [ $exit_code -eq 0 ]; then
      PS1+=" $tick "
    else
      PS1+=" $cross "
    fi
  fi
}

# Use PROMPT_COMMAND in bash (equivalent to precmd in zsh)
PROMPT_COMMAND=set_bash_prompt

# For the RPROMPT equivalent in bash, you'd need to use:
# - screen/tmux for right-side display, or
# - a two-line prompt, or  
# - accept that bash doesn't natively support RPROMPT
