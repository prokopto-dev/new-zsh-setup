#!/usr/bin/env bash
# Global variables
SHELL_TYPE=""
SHELL_RC_PATH=""
OS_TYPE=""
SUDO_ACCESS="False"

# RCFiles Folder For Subfiles
RCFILES_PATH="$HOME/.rcfiles"

# Install List For Flags with defaults
local INSTALL_LIST="wget rsync pyenv ripgrep git-delta openssh gnu_utils"

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
        --brave) INSTALL_LIST="$INSTALL_LIST brave";;
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
            INSTALL_LIST="$INSTALL_LIST brave";
            INSTALL_LIST="$INSTALL_LIST firefox";
            INSTALL_LIST="$INSTALL_LIST bitwarden";
            INSTALL_LIST="$INSTALL_LIST nordvpn";
            INSTALL_LIST="$INSTALL_LIST texshop";
            INSTALL_LIST="$INSTALL_LIST qmk-toolbox";
            INSTALL_LIST="$INSTALL_LIST toot";
            INSTALL_LIST="$INSTALL_LIST neovim";
            INSTALL_LIST="$INSTALL_LIST raycast";
            ;;
        *) echo "Unknown parameter passed: $1"; exit 1;;
    esac
    shift
done

# Check default shell
if [[ "$SHELL" == *"bash" ]]; then
    echo "Bash is the default shell."
    SHELL_TYPE="bash"
    SHELL_RC_PATH="$HOME/.bashrc"
elif [[ "$SHELL" == *"zsh" ]]; then
    echo "Zsh is the default shell."
    SHELL_TYPE="zsh"
    SHELL_RC_PATH="$HOME/.zshrc"
else
    echo "Unsupported shell - $SHELL"
    exit 1
fi

# First, check the OS
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "Linux detected."
    OS_TYPE="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Mac OS detected."
    OS_TYPE="mac"
else
    echo "Unsupported OS"
    exit 1
fi

# Check for sudo access
if [[ "$OS_TYPE" == "linux" ]]; then
    export HOMEBREW_CASK_OPTS=""
    if groups | grep -q -w "sudo"; then
        echo "User has sudo access."
        SUDO_ACCESS="True"
    else
        echo "User does not have sudo access."
    fi
elif [[ "$OS_TYPE" == "mac" ]]; then
    if groups | grep -q -w "admin" ; then
        echo "User has sudo access."
        SUDO_ACCESS="True"
        export HOMEBREW_CASK_OPTS=""
    else
        echo "User does not have sudo access."
    fi
fi

# Install XCode Command Line Tools If Possible
install_xcode_mac() {
    echo "Checking for XCode Command Line Tools..."
    if xcode-select -p &> /dev/null; then
        echo "XCode Command Line Tools are already installed."
    else
        if [[ "$SUDO_ACCESS" == "True" ]]; then
            echo "Installing XCode Command Line Tools..."
            xcode-select --install
        else
            echo "User does not have sudo access, please contact administrator to install XCode Command Line Tools."
            exit 1
        fi
    fi
}

install_brew_mac() {
    echo "Checking for Homebrew..."
        if [[ "$SUDO_ACCESS" == "True" ]]; then
            if command -v brew &> /dev/null; then
                echo "Homebrew is already installed."
            else
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
        else
            if [[ -d "$HOME/.homebrew" ]]; then
                echo "Homebrew is already installed locally for non-sudo."
            else
            echo "User does not have sudo access, installing Homebrew to $HOME/.homebrew"
            mkdir $HOME/.homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C $HOME/.homebrew
            eval "$($HOME/.homebrew/bin/brew shellenv)"
            brew update --force --quiet
            chmod -R go-w "$(brew --prefix)/share/zsh"
            echo "Adding Homebrew to PATH..."
            echo "# Add Homebrew to PATH" >> $SHELL_RC_PATH
            echo "eval \"$($HOME/.homebrew/bin/brew shellenv)\"" >> $SHELL_RC_PATH
            if [[ -d "$HOME/Applications" ]]; then
                echo "Adding appdir optional to casks for homebrew"
                echo "export HOMEBREW_CASK_OPTS=\"--appdir=$HOME/Applications\"" >> $SHELL_RC_PATH
            fi
            fi
        fi
}

setup_rc_folders() {
    if [[ ! -d "$HOME/.rcfiles" ]]; then
        echo "Creating .rcfiles directory..."
        mkdir -p $HOME/.rcfiles
    fi
}

create_applications_dir_mac() {
    if [[ ! -d "$HOME/Applications" ]]; then
        echo "Creating Applications directory..."
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
    if [[ ! "$PATH" == *"$(brew --prefix)/bin"* ]]; then
            # grep shell rc file for brew path, if not found, add it
            if ! grep -q "export PATH=\"$(brew --prefix)/bin:\$PATH\"" $SHELL_RC_PATH; then
                echo "Adding $(brew --prefix)/bin to PATH..."
                echo "# Add Homebrew to PATH" >> $SHELL_RC_PATH
                echo "export PATH=\"$(brew --prefix)/bin:\$PATH\"" >> $SHELL_RC_PATH
            fi
    fi
    if brew list $APP &> /dev/null; then
        echo "$APP is already installed."
    else
        echo "Installing $APP..."
        brew install $cask_arg $APP && echo "$APP is now installed."
        if [[ "$GNU_FLAG" == "True" ]]; then 
            echo "export PATH=\"$(brew --prefix)/opt/$APP/libexec/gnubin:\$PATH\"" >> $RCFILES_PATH/gnurc
            echo "export MANPATH=\"$(brew --prefix)/opt/$APP/libexec/gnuman:\$MANPATH\"" >> $RCFILES_PATH/gnurc
            # check if gnurc is already imported by shell rc file
            if ! grep -q "source $RCFILES_PATH/gnurc" $SHELL_RC_PATH; then
                echo "source $RCFILES_PATH/gnurc" >> $SHELL_RC_PATH
            fi
        elif [[ "$PYENV_FLAG" == "True"]]; then
            echo "Adding pyenv shims to PATH..."
            echo "export PATH=\"$(pyenv root)/shims:\$PATH\"" >> $RCFILES_PATH/pyenvrc
            # check if pyenvrc is already imported by shell rc file
            if ! grep -q "source $RCFILES_PATH/pyenvrc" $SHELL_RC_PATH; then
                echo "source $RCFILES_PATH/pyenvrc" >> $SHELL_RC_PATH
            fi
        fi
        elif [[ "$SERVICE_FLAG" == "True" ]]; then
            echo "Starting $APP service..."
            brew services start $APP
        fi
    fi
}

install_oh_my_zsh() {
    echo "Checking for Oh My Zsh..."
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Oh My Zsh is already installed."
    else
        echo "Installing Oh My Zsh..."
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
                    local GNU_UTIL_LIST="coreutils findutils libtool gsed gawk gnutls gnu-indent gnu-getopt grep"
                    for gnuutil in GNU_UTIL_LIST; do
                        install_brew_app $gnuutil gnu
                    done
                    ;;
                "emacs");&
                "visual-studio-code") ;&
                "qmk-toolbox") ;&
                "warp") ;&
                "nordvpn") ;&
                "bitwarden") ;&
                "brave-browser") ;&
                "texshop") ;&
                background-music) ;&
                "stats") install_brew_app $app cask;;
                "emacs") install $app service;;
                "git-delta") 
                        install_brew_app $app
                        echo "Adding git-delta to git config..."
                        git config --global core.pager "delta --dark --line-numbers"
                        git config --global delta.side-by-side true;;
                *) install_brew_app $app;;
            esac
        done
    "linux")
        if [[ "$SHELL_TYPE" == "zsh" ]]; then
            install_oh_my_zsh
        fi
        echo "Linux installation not supported yet."
        ;;
    *)
        echo "Unsupported OS"
        exit 1
        ;;
esac

echo "==============================="
echo "Installation complete."
echo "Please restart your terminal."
echo "Or at the very least run the following command:"
echo "source $SHELL_RC_PATH"
echo "==============================="
exit 0

