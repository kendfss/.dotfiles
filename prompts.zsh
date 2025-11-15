# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
pexp() {
  for arg in "$@"; do
    echo "${(%)arg}"
  done
}


# autoload -Uz vcs_info
# zstyle ':vcs_info:*' enable git
# zstyle ':vcs_info:git:*' formats '%F{green}(%b)%f%F{red}%([dirty])*%f'
# zstyle ':vcs_info:git:*' actionformats '%F{green}(%b|%a)%f%F{red}%([dirty])*%f'

# precmd_vcs_info() {
#     vcs_info
# }

if [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
  autoload -Uz vcs_info

  precmd_vcs_info() {
      vcs_info
    
      # Check git status and set color based on changes
      if [[ "$vcs_info_msg_0_" != "" ]]; then
          local color="green"
          local branch="$vcs_info_msg_0_"
        
          # Check for unstaged changes first (takes priority)
          if git diff --quiet --exit-code 2>/dev/null; then
              # No unstaged changes
              if ! git diff --cached --quiet --exit-code 2>/dev/null; then
                  # But there are staged changes
                  color="yellow"
              fi
          else
              # There are unstaged changes
              color="red"
          fi
        
          # Reconstruct the prompt with the appropriate color
          vcs_info_msg_0_="(%F{$color}${branch}%f)"
      fi
  }

  precmd_functions+=( precmd_vcs_info )
  setopt prompt_subst

  RPROMPT='${vcs_info_msg_0_}'

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:*' unstagedstr '%u'
  zstyle ':vcs_info:*' stagedstr '%c'

  # Use three format groups: %0_ for branch, %1_ for unstaged, %2_ for staged
  zstyle ':vcs_info:git:*' formats '%b' '%u' '%c'
fi

tick='✔'
cross='✗'
dot='•'

pth="%(3C.%-1d:%1~.%1~)"
# echo :$pth
# export PS1="%B%F{blue}%-1d:%1~%f%b(%F{%(?.green.red)}%n%#%m%f) %(!.$dot.%(?.$tick.$cross)) "
# export PS1="%B%F{cyan}$pth%f%b$(git_prompt_info)(%F{%(?.green.red)}%n%#%m%f) %(!.$dot.%(?.$tick.$cross)) "
export PS1="%B%F{cyan}$pth%f%b(%F{%(?.green.red)}%n%#%m%f) %(!.$dot.%(?.$tick.$cross)) "

  # Expand prompt format strings
