# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
pexp() {
	for arg in "$@"; do
		echo "${(%)arg}"
	done
}

superscript() {
	local map='⁰¹²³⁴⁵⁶⁷⁸⁹'
	local arg i d out
	for arg in "$@"; do
		local out=''
		for ((i = 1; i <= ${#arg}; i++)); do
			d=${arg[i]}
			out+=${map[$((d + 1))]}
		done
		# print -r -- "$out"
		echo "$out"
	done
}

tick='✔'
cross='✘'
dot='•'
pth="%(3C.%-1d:%1~.%1~)"
grep -Eq '^/dev/sd\w+ / ' </proc/mounts && device=chroot

previous_exit_code=${previous_exit_code:-}
previous-exit-code-precmd() {
	local ret=$?
	if [ $ret = 0 ]; then
		previous_exit_code=''
	else
		previous_exit_code=$(superscript $ret)
	fi
}
add-zsh-hook precmd previous-exit-code-precmd

if [ -n "$TERMUX__PREFIX" ]; then
	export PS1='%B%F{cyan}${device:+$device:}$pth%f%b(%F{%(?.green.red)}%n%#$(/system/bin/getprop ro.product.device 2>/dev/null)%f)
%(!.$dot.%(?.$tick.$cross${previous_exit_code})) '
else
	# export PS1='%B%F{cyan}${device:+$device:}$pth%f%b(%F{%(?.green.red)}%n%#%m%f) %(!.$dot.%(?.$tick.$cross$(superscript "$?"))) '
	export PS1='%B%F{cyan}${device:+$device:}$pth%f%b(%F{%(?.green.red)}%n%#%m%f) %(!.$dot.%(?.$tick.$cross${previous_exit_code})) '
fi
