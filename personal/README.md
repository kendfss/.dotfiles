# cheat

My personal cheatsheets for [cheat.sh](https://github.com/cheat/cheat).

## install

### linux

it should be installed at `$HOME/.config/cheat/cheatsheets/personal`. The
following should do the trick

```sh
mkdir -p $HOME/.config/cheat/cheatsheets
ln -s $DOTFILES/personal $HOME/.config/cheat/cheatsheets/personal
go install github.com/cheat/cheat/cmd/cheat@latest # if you've not already
```
