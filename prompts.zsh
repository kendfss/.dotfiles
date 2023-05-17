# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html

tick='✔'
cross='✗'
dot='•'

pth="%(3C.%-1d:%1~.%1~)"
# echo :$pth
# export PS1="%B%F{blue}%-1d:%1~%f%b(%F{%(?.green.red)}%n%#%m%f) %(!.$dot.%(?.$tick.$cross)) "
export PS1="%B%F{cyan}$pth%f%b(%F{%(?.green.red)}%n%#%m%f) %(!.$dot.%(?.$tick.$cross)) "

  # Expand prompt format strings
pexp() {
  for arg in "$@"; do
    echo "${(%)arg}"
  done
}



