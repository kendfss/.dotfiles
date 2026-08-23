# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
pexp() {
  for arg in "$@"; do
    echo "${(%)arg}"
  done
}

tick='✔'
cross='✘'
dot='•'
pth="%(3C.%-1d:%1~.%1~)"
grep -Eq '^/dev/\w+ / ' </proc/mounts && device=chroot

if [ -n "$TERMUX__PREFIX" ]; then
  export PS1="%B%F{cyan}${device:+$device:}$pth%f%b(%F{%(?.green.red)}%n%#$(/system/bin/getprop ro.product.device 2>/dev/null)%f)
%(!.$dot.%(?.$tick.$cross)) "
else 
  export PS1="%B%F{cyan}${device:+$device:}$pth%f%b(%F{%(?.green.red)}%n%#%m%f) %(!.$dot.%(?.$tick.$cross)) "
fi
