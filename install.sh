#!/usr/bin/env bash
# Global variables
SHELL_TYPE=""
SHELL_RC_PATH=""
OS_TYPE=""
SUDO_ACCESS="False"

# Colors
RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# RCFiles Folder For Subfiles
RCFILES_PATH="$HOME/.rcfiles"

# Install List For Flags with defaults
INSTALL_LIST="wget rsync pyenv ripgrep git-delta openssh gnu_utils"

# export HOMEBREW_CASK_OPTS is used to install casks to a custom directory
export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"

# See if --emacs flag is passed
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --warp) INSTALL_LIST="$INSTALL_LIST warp";;
        --emacs) INSTALL_LIST="$INSTALL_LIST emacs";;
        --alacritty) INSTALL_LIST="$INSTALL_LIST alacritty";;
        --discord) INSTALL_LIST="$INSTALL_LIST discord";;
        --stats) INSTALL_LIST="$INSTALL_LIST stats";;
        --vscode) INSTALL_LIST="$INSTALL_LIST visual-studio-code";;
        --rust) INSTALL_LIST="$INSTALL_LIST rust";;
        --brave) INSTALL_LIST="$INSTALL_LIST brave-browser";;
        --firefox) INSTALL_LIST="$INSTALL_LIST firefox";;
        --bitwarden) INSTALL_LIST="$INSTALL_LIST bitwarden";;
        --nordvpn) INSTALL_LIST="$INSTALL_LIST nordvpn";;
        --texshop) INSTALL_LIST="$INSTALL_LIST texshop";;
        --qmk) INSTALL_LIST="$INSTALL_LIST qmk-toolbox";;
        --toot) INSTALL_LIST="$INSTALL_LIST toot";;
        --neovim) INSTALL_LIST="$INSTALL_LIST neovim";;
        --raycast) INSTALL_LIST="$INSTALL_LIST raycast";;
        --all) 
            INSTALL_LIST="$INSTALL_LIST warp";
            INSTALL_LIST="$INSTALL_LIST emacs";
            INSTALL_LIST="$INSTALL_LIST alacritty";
            INSTALL_LIST="$INSTALL_LIST discord";
            INSTALL_LIST="$INSTALL_LIST stats";
            INSTALL_LIST="$INSTALL_LIST visual-studio-code";
            INSTALL_LIST="$INSTALL_LIST rust";
            INSTALL_LIST="$INSTALL_LIST brave-browser";
            INSTALL_LIST="$INSTALL_LIST firefox";
            INSTALL_LIST="$INSTALL_LIST bitwarden";
            INSTALL_LIST="$INSTALL_LIST nordvpn";
            INSTALL_LIST="$INSTALL_LIST texshop";
            INSTALL_LIST="$INSTALL_LIST qmk-toolbox";
            INSTALL_LIST="$INSTALL_LIST toot";
            INSTALL_LIST="$INSTALL_LIST neovim";
            INSTALL_LIST="$INSTALL_LIST raycast";
            ;;
        *) printf "Unknown parameter passed: $1\n"; exit 1;;
    esac
    shift
done

# Check default shell
if [[ "$SHELL" == *"bash" ]]; then
    printf "${ORANGE}Bash${NC} is the default shell.\n"
    SHELL_TYPE="bash"
    SHELL_RC_PATH="$HOME/.bashrc"
elif [[ "$SHELL" == *"zsh" ]]; then
    printf "${ORANGE}Zsh${NC} is the default shell.\n"
    SHELL_TYPE="zsh"
    SHELL_RC_PATH="$HOME/.zshrc"
else
    printf "${RED}Unsupported shell - $SHELL${NC}\n"
    exit 1
fi

# First, check the OS
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    printf "${GREEN}Linux detected.${NC}\n"
    OS_TYPE="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    printf "${GREEN}Mac OS detected.${NC}\n"
    OS_TYPE="mac"
else
    printf "Unsupported OS\n"
    exit 1
fi

# Check for sudo access
if [[ "$OS_TYPE" == "linux" ]]; then
    export HOMEBREW_CASK_OPTS=""
    if groups | grep -q -w "sudo"; then
        printf "User has sudo access.\n"
        SUDO_ACCESS="True"
    else
        printf "User does not have sudo access.\n"
    fi
elif [[ "$OS_TYPE" == "mac" ]]; then
    if groups | grep -q -w "admin" ; then
        printf "User has sudo access.\n"
        SUDO_ACCESS="True"
        export HOMEBREW_CASK_OPTS=""
    else
        printf "${RED}User does not have sudo access.${NC}\n"
    fi
fi

# Install XCode Command Line Tools If Possible
install_xcode_mac() {
    printf "Checking for ${ORANGE}XCode Command Line Tools${NC}...\n"
    if xcode-select -p &> /dev/null; then
        printf "${ORANGE}XCode Command Line Tools${NC} are already installed.\n"
    else
        if [[ "$SUDO_ACCESS" == "True" ]]; then
            printf "Installing ${ORANGE}XCode Command Line Tools${NC}...\n"
            xcode-select --install
        else
            printf "${RED}User does not have sudo access, please contact administrator to install XCode Command Line Tools.${NC}\n"
            exit 1
        fi
    fi
}

install_brew_mac() {
    printf "Checking for ${ORANGE}Homebrew${NC}...\n"
        if [[ "$SUDO_ACCESS" == "True" ]]; then
            if command -v brew &> /dev/null; then
                printf "${ORANGE}Homebrew${NC} is already installed.\n"
            else
            printf "Installing ${ORANGE}Homebrew${NC}...\n"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
        else
            if [[ -d "$HOME/.homebrew" ]]; then
                printf "${ORANGE}Homebrew${NC} is already installed locally for non-sudo.\n"
            else
            printf "User ${RED}does not have sudo access${NC}, installing Homebrew to $HOME/.homebrew\n"
            mkdir $HOME/.homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C $HOME/.homebrew
            eval "$($HOME/.homebrew/bin/brew shellenv)"
            brew update --force --quiet
            chmod -R go-w "$(brew --prefix)/share/zsh"
            printf "Adding ${ORANGE}Homebrew${NC} to PATH...\n"
            echo "# Add Homebrew to PATH" >> $SHELL_RC_PATH
            echo "eval \"$($HOME/.homebrew/bin/brew shellenv)\"" >> $SHELL_RC_PATH
            if [[ -d "$HOME/Applications" ]]; then
                printf "Adding appdir optional to casks for homebrew\n"
                echo "export HOMEBREW_CASK_OPTS=\"--appdir=$HOME/Applications\"" >> $SHELL_RC_PATH
            fi
            fi
        fi
}

setup_rc_folders() {
    if [[ ! -d "$HOME/.rcfiles" ]]; then
        printf "Creating ${ORANGE}.rcfiles${NC} directory...\n"
        mkdir -p $HOME/.rcfiles
    fi
}

create_applications_dir_mac() {
    if [[ ! -d "$HOME/Applications" ]]; then
        printf "Creating ${ORANGE}Applications${NC} directory...\n"
        mkdir $HOME/Applications
    fi
}

install_brew_app() {
    # Format for input is install_brew_app "app_name" "extra_arg1" "extra_arg2"...
    # Valid extra args are:
    # cask - installs the app as a cask
    # gnu - installs the app as a gnu utility
    # pyenv - installs the app as a pyenv utility
    # service - installs the app as a service
    # --- Example Usage ---
    # install_brew_app "obsidian" "cask"
    # install_brew_app "gcc" "gnu"
    # install_brew_app "pyenv" "pyenv"
    # install_brew_app "emacs" "service"
    local APP="$1"
    local cask_arg=""
    local GNU_FLAG="False"
    local PYENV_FLAG="False"
    local SERVICE_FLAG="False"
    while [[ "$#" -gt 1 ]]; do
        case $1 in
            cask) cask_arg="--cask";;
            gnu) GNU_FLAG="True";;
            pyenv) PYENV_FLAG="True";;
            service) SERVICE_FLAG="True";;
            *) ;;
        esac
        shift
    done
    if [[ ! "$PATH" == *"$(brew --prefix)/bin"* ]]; 
        then
            # grep shell rc file for brew path, if not found, add it
            if ! grep -q "export PATH=\"$(brew --prefix)/bin:\$PATH\"" $SHELL_RC_PATH; then
                printf "Adding ${ORANGE}$(brew --prefix)/bin${NC} to PATH...\n"
                echo "# Add Homebrew to PATH" >> $SHELL_RC_PATH
                echo "export PATH=\"$(brew --prefix)/bin:\$PATH\"" >> $SHELL_RC_PATH
            fi
    fi
    if brew list $APP &> /dev/null; then
        printf "${ORANGE}$APP${NC} is already installed.\n"
    else
        printf "Installing ${ORANGE}$APP...${NC}\n"
        brew install $cask_arg $APP && printf "$APP is now installed.\n"
        if [[ "$GNU_FLAG" == "True" ]]; then 
            echo "export PATH=\"$(brew --prefix)/opt/$APP/libexec/gnubin:\$PATH\"" >> $RCFILES_PATH/gnurc
            echo "export MANPATH=\"$(brew --prefix)/opt/$APP/libexec/gnuman:\$MANPATH\"" >> $RCFILES_PATH/gnurc
            # check if gnurc is already imported by shell rc file
            if ! grep -q "source $RCFILES_PATH/gnurc" $SHELL_RC_PATH; then
                echo "source $RCFILES_PATH/gnurc" >> $SHELL_RC_PATH
            fi
        elif [[ "$PYENV_FLAG" == "True" ]]; then
            printf "Adding pyenv shims to PATH...\n"
            echo "export PATH=\"$(pyenv root)/shims:\$PATH\"" >> $RCFILES_PATH/pyenvrc
            # check if pyenvrc is already imported by shell rc file
            if ! grep -q "source $RCFILES_PATH/pyenvrc" $SHELL_RC_PATH; then
                echo "source $RCFILES_PATH/pyenvrc" >> $SHELL_RC_PATH
            fi
        elif [[ "$SERVICE_FLAG" == "True" ]]; then
            printf "Starting ${ORANGE}$APP${NC} service...\n"
            brew services start $APP
        fi
    fi
}

install_oh_my_zsh() {
    printf "Checking for Oh My Zsh...\n"
    if [ -d "$HOME/.oh-my-zsh" ]; then
        printf "${ORANGE}Oh My Zsh${NC} is already installed.\n"
    else
        printf "Installing ${ORANGE}Oh My Zsh${NC}...\n"
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        # Change the default prompt in oh my zsh to gianu
        sed -i 's/robbyrussell/gianu/g' $HOME/.zshrc
    fi
}

case "$OS_TYPE" in
    "mac")
        install_xcode_mac
        if [[ "$SHELL_TYPE" == "zsh" ]]; then
            install_oh_my_zsh
        fi
        create_applications_dir_mac
        setup_rc_folders
        install_brew_mac
        for app in $INSTALL_LIST; do
            case $app in
                "gnu_utils")
                    GNU_UTIL_LIST="coreutils findutils libtool gsed gawk gnutls gnu-indent gnu-getopt grep"
                    for gnuutil in $GNU_UTIL_LIST; do
                        install_brew_app $gnuutil "gnu"
                    done
                    ;;
                "emacs"|"visual-studio-code"|"qmk-toolbox"|"warp"|"nordvpn"|"bitwarden"|"brave-browser"|"texshop"|"background-music"|"stats")
                    install_brew_app $app "cask";;
                "emacs") install $app "service";;
                "git-delta") 
                        install_brew_app $app
                        printf "Adding ${ORANGE}git-delta${NC} to git config...\n"
                        git config --global core.pager "delta --dark --line-numbers"
                        git config --global delta.side-by-side true;;
                *) install_brew_app $app;;
            esac
        done
        ;;
    "linux")
        if [[ "$SHELL_TYPE" == "zsh" ]]; then
            install_oh_my_zsh
        fi
        printf "Linux installation not supported yet.\n"
        ;;
    *)
        printf "${RED}Unsupported OS${NC}\n"
        exit 1
        ;;
esac

printf "===============================\n"
printf "Installation complete.\n"
printf "Please restart your terminal.\n"
printf "Or at the very least run the following command:\n"
printf "source $SHELL_RC_PATH\n"
printf "===============================\n"
exit 0

