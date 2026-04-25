# clipboard_backup

A runit service that maintains copies of clipboard and primary selection state.

## how it works

1. For each x11 clipboard event, the contents are retrieved from
   application-specific buffers (which are emptied when an application fails)
1. Then we copy that data into files in order to maintain a recoverable history
   - we delete old entries after there're 50 for each & either of clipboard and
     primary selection
1. At the end of a user session we shred the files, for security

## installation

```zsh
sudo ln -s {$DOTFILES,}/etc/sv/clipboard_backup
sudo ln -s {/etc/sv,/var/service}/clipboard_backup     # saves re-making 2 links on change of origin
```

### dependencies

- POSIX shell
  - tested in dash
- `xclip`
  - clipboard read/write
- `clipnotify`
  - watch for selections and copies
- `shred`
  - from coreutils
