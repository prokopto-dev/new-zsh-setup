# new-zsh-setup
A script, and supporting files, for setting up a new host with `zsh` in a way that I like.

Technically also works with `bash`, and will skip `oh-my-zsh` in that case.

Handles both SUDO and non-sudo installations.

## How to Run

You can clone and run the `install.sh`

```shell
$ bash install.sh
```

Or you can run the following command without cloning:

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
- Pyenv
- Pyenv-virtualenv
- ripgrep
- OpenSSH
- Firefox
- Discord
- VSCode
- gcc (requires sudo, I've found...)
- Warp

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
