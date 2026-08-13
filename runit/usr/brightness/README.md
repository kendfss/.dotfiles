# brightness

a runit service that stores screen brightness on shutdown and loads it at
startup

## install

```zsh
sudo ln -s {$DOTFILES,}/etc/sv/brightness
sudo ln -s {/etc/sv,/var/service}/brightness     # saves re-making 2 links on change of origin
```

## monitoring

just run `sudo sv status brightness` to see if it's on
