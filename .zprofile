export DOTFILES=$HOME/.dotfiles
export ZDOTDIR=$HOME/.zsh
[[ ! (-d $ZDOTDIR || -L $ZDOTDIR) ]] && ln -fs $DOTFILES $ZDOTDIR

# emulate sh -c 'source ~/.profile'
# source

[[ -d $HOME/.cargo ]] && . "$HOME/.cargo/env"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export CPPFLAGS="-I/usr/local/opt/openjdk/include"
JAVA_HOME=$HOME/sdk/android-studio/jre
export JAVA_HOME
export PATH="$PATH:$JAVA_HOME/bin"
export GOPATH="$HOME/go"
export GCFLAGS="-G=3"

export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

if [[ -f $(command -v go) ]]; then
  export GOS=$(go env GOROOT)
  export GOP=$(go env GOPATH)
fi

# [[ -n $ANDROID_NDK_HOME ]] && export ANDROID_NDK_HOME="/usr/local/share/android-ndk"
[[ -n $ANDROID_NDK_HOME ]] && export ANDROID_NDK_HOME="$ANDROID_SDK_ROOT/ndk/24.0.8215888"


#git config --global url."git@gitlab.com:".insteadOf "https://gitlab.com"
#git config --global url."git@github.com:".insteadOf "https://gitlab.com"



export HOMEBREW_NO_AUTO_UPDATE=1

if [[ -z $(command -v set_title) ]]; then
  source "$ZDOTDIR/termsupport.zsh" 
  source "$ZDOTDIR/functions.zsh" 
  export SKIPPROFILE=1 # prevent re-sourcing this file if/when the .zshrc is sourced
fi

# set_title
initpyenv
