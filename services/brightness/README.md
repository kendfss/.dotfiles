# brightness

a runit service that stores screen brightness on shutdown and loads it at
startup

## install

```bash
sudo ln -s $DOTFILES/services/brightness /etc/sv/brightness
sudo ln -s $DOTFILES/services/brightness /var/service/brightness
```

## monitoring

just run `sudo sv status brightness` to see if it's on
