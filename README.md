# new-zsh-setup
A script, and supporting files, for setting up a new host with `zsh` in a way that I like.

Technically also works with `bash`, and will skip `oh-my-zsh` in that case.

## Contents

Currently Installs the following

### Mac

- XCode CLI Tools
- Oh-My-Zsh (If ZSH is primary shell)
- Homebrew
- GNU Utils
    - wget
    - sed
    - awk
    - grep
    - coreutils
    - findutils
    - libtool
- Pyenv
- Pyenv-virtualenv
- ripgrep
- OpenSSH

## TODO

- [ ] Add `.ssh` config changes
- [ ] Add Linux installation functions
- [ ] Add some testing or robustness
