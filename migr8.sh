
if [[ -z $MIGR8_DST ]]; then
    # MIGR8_DST=/Volumes/OLLA
    MIGR8_DST=/media/kendfss/OLLA
fi

if [[ -z $SORT_GAWK ]]; then
    SORT_GAWK="{
    ++ctr 
    sizes[ctr] = \$2
    paths[ctr] = \$1
    table[\$2] = \$1
} END {
    n = asort(sizes)
    for (ind in sizes) {
        key = sizes[ind]
        val = table[key]
        print val
    }
}
"
fi



migr8 () {
    _rm() {
        return
        # if [[ -f "$1" ]]; then
        #     rm "$1" && return
        # fi
        # rm -rf "$1"
    }

    if [[ -f sizemap.txt ]]; then
        sizeof -n "$@" > sizemap.txt
    fi
    IFS=$'\n'
    arr=($(gawk -f sort.gawk sizemap.txt))
    IFS=$' \t\n'
    # IFS=$'\n' arr=($(gawk $SORT_GAWK sizemap.txt)) IFS=$' \t\n'
    # echo $arr

    if [[ -d "$MIGR8_DST" ]]; then
        for arg in "${arr[@]}"; do
            if [[ -a "$arg" ]]; then
                arc=$MIGR8_DST/$(basename "$arg").tar
                (tar -c "$arg" > "$arc" && _rm "$arg")  || (echo "couldn't compress \"$arg\"" > /dev/stderr)
                # (tar -c "$arg" "$arc" || echo "couldn't compress \"$arg\"" > /dev/stderr ) && (mv "$arc" "$MIGR8_DST/$arc" || echo "couldn't move \"$arc\" to \"$MIGR8_DST\"") && (_rm "$arg")

                echo "migr8ed: \"$arg\"" && continue
            fi
            echo "file not found: \"$arg\""
        done
        return 0
    fi
    echo "Please ensure the \$MIGR8_DST variable is properly set for this scope: MIGR8_DST == \"$MIGR8_DST\"" > /dev/stderr && return 1
    # rm sizemap.txt
}

# migr8 /Users/kendfss/ascii_shades
# migr8 /Users/kendfss/self.notes
# migr8 /Users/kendfss/.gitconfig
# migr8 /Users/kendfss/.zsh
# migr8 /Users/kendfss/workspace
# migr8 /Users/kendfss/.dicterm
# migr8 /Users/kendfss/.ssh
# migr8 /Users/kendfss/.python_history
# migr8 /Users/kendfss/.zshenv
# migr8 /Users/kendfss/.zshrc
# migr8 /Users/kendfss/.zprofile
# migr8 /Users/kendfss/profile
# migr8 /Users/kendfss/clones
# migr8 /Users/kendfss/gitclone
# migr8 /Users/kendfss/Music
# migr8 /Users/kendfss/twos_complement
# migr8 /Users/kendfss/exponentiation
# migr8 /Users/kendfss/pi
# migr8 /Users/kendfss/Movies
# migr8 /Users/kendfss/mario
# migr8 /Users/kendfss/.gnupg
# migr8 /Users/kendfss/brewlist
# migr8 /Users/kendfss/go_dom
# migr8 /Users/kendfss/programs
# migr8 /Users/kendfss/Pictures
# migr8 /Users/kendfss/.zlogin

# migr8 /Users/kendfss/ascii_shades /Users/kendfss/.gitconfig /Users/kendfss/.zsh /Users/kendfss/.dicterm /Users/kendfss/.ssh /Users/kendfss/.python_history /Users/kendfss/.zshenv /Users/kendfss/.zshrc /Users/kendfss/.zprofile /Users/kendfss/profile /Users/kendfss/clones /Users/kendfss/twos_complement /Users/kendfss/exponentiation /Users/kendfss/pi /Users/kendfss/Movies /Users/kendfss/mario /Users/kendfss/.gnupg /Users/kendfss/brewlist /Users/kendfss/go_dom /Users/kendfss/programs /Users/kendfss/Pictures /Users/kendfss/.zlogin /Users/kendfss/workspace /Users/kendfss/self.notes /Users/kendfss/Music /Users/kendfss/gitclone 
migr8 ~/gitclone ~/.zsh ~/go
