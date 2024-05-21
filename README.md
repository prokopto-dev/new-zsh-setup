# new-zsh-setup
A script, and supporting files, for setting up a new host with `zsh` in a way that I like.

Technically also works with `bash`, and will skip `oh-my-zsh` in that case.

Handles both SUDO and non-sudo installations.

## How to Run

You can clone and run the `install.sh`

```shell
$ git clone https://github.com/prokopto-dev/new-zsh-setup.git
$ cd new-zsh-setup
$ bash install.sh
```

You can also pass some flags in:

- `--warp` - Installs warp terminal emulator
- `--emacs` - Installs emacs
- `--alacritty` - Installs alacritty terminal emulator
- `--discord` - Installs discord chat
- `--stats` - Installs stats toolbar plugin for osx
- `--vscode` - Installs vscode
- `--rust` - Installs rust lang
- `--brave` - Installs brave browser (chromium based)
- `--firefox` - Installs firefox browser
- `--bitwarden` - Installs bitwarden password manager (desktop)
- `--nordvpn` - Installs nordvpn client
- `--texshop` - Installs texshop latex editor suite
- `--qmk` - Installs qmk keyboard firmware tools
- `--neovim` - Installs neovim
- `--toot` - Installs toot (mastodon cli)
- `--all` - Installs all of the possible tools above

---

Or you can run the following command without cloning:

> [!IMPORTANT]
> This only installs the most basic tools; if you want it to auto install more complex stuff, run the clone command and pass flags in.

```shell
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/prokopto-dev/new-zsh-setup/main/install.sh)"
```

## Contents

Currently Installs the following

### Mac

- XCode CLI Tools
- Creates an Applications Directory In Home Dir
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
    - rsync
- Pyenv
- Pyenv-virtualenv
- ripgrep
- OpenSSH
- Firefox
- Discord
- VSCode
- Warp
- Texshop
- bitwarden
- obsidian
- git-delta
- Requires SUDO:
    - gcc (requires sudo, I've found...)
    - background music
    - nordvpn

## To install applications if you don't have SUDO (MAC)

This will make a `$HOME/Applications` folder for you on Mac; `brew install --cask` commands will install to this folder.

You can also drag any `.dmg` Files into here and have them be installed as if installed in the original `/Applications` folder.

## System Settings

These will go by category, only noting those that are to be changed from any sort of default.

### Notifications

Show Previews: When Unlocked

Allow notifications when the display is sleeping: False

Allow notifications when the screen is locked: False

Allow notifications when mirroring or sharing display: False

#### Application Notifications

Turn off all other than:
- Wallet
- VPN Provider
- Messages
- Mail
- Home
- Find My
- FaceTime
- Discord
- Calendar
- App Store

## TODO

- [ ] Add `.ssh` config changes
- [ ] Add Linux installation functions
- [ ] Add some testing or robustness
