#!/usr/bin/env bash
# Global variables
SHELL_TYPE=""
SHELL_RC_PATH=""
OS_TYPE=""
SUDO_ACCESS="False"
export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"

# Check default shell
if [[ "$SHELL" == "/bin/bash" ]]; then
    echo "Bash is the default shell."
    SHELL_TYPE="bash"
    SHELL_RC_PATH="$HOME/.bashrc"
elif [[ "$SHELL" == "/bin/zsh" ]]; then
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
    else
        echo "User does not have sudo access."
    fi
fi

# Install XCode Command Line Tools If Possible
function install_xcode_mac() {
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

function install_brew_mac() {
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

function install_oh_my_zsh() {
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

function install_gnu_utils_brew_mac() {
    echo "Checking for GNU Utils..."
    for util in "gawk" "gsed" "grep" "findutils" "coreutils" "libtool" "gnu-indent" "gnu-getopt";
    do
        if brew list $util &> /dev/null; then
            echo "$util is already installed."
        else
            echo "Installing $util..."
            brew install $util && echo "$util is now installed."
            echo "Adding $util to PATH..."
            echo "# Add $util to PATH" >> $SHELL_RC_PATH
            echo "export PATH=\"$(brew --prefix)/opt/$util/libexec/gnubin:\$PATH\"" >> $SHELL_RC_PATH
            echo "export MANPATH=\"$(brew --prefix)/opt/$util/libexec/gnuman:\$MANPATH\"" >> $SHELL_RC_PATH
        fi
    done
}

# install wget via brew
function install_wget_brew_mac() {
    echo "Checking for wget..."
    if brew list wget &> /dev/null; then
        echo "wget is already installed."
    else
        echo "Installing wget..."
        brew install wget && echo "wget is now installed."
    fi
}

# install obsidian via brew
function install_obsidian_brew_mac() {
    echo "Checking for obsidian..."
    if brew list obsidian &> /dev/null; then
        echo "obsidian is already installed."
    else
        echo "Installing obsidian..."
        brew install --cask obsidian && echo "obsidian is now installed."
    fi
}

# install rsync via brew
function install_rsync_brew_mac() {
    echo "Checking for rsync..."
    if brew list rsync &> /dev/null; then
        echo "rsync is already installed."
    else
        echo "Installing rsync..."
        brew install rsync && echo "rsync is now installed."
    fi
}

# install pyenv and pyenv-virtualenv via brew
function install_pyenv_brew_mac() {
    echo "Checking for pyenv..."
    if brew list pyenv &> /dev/null; then
        echo "pyenv is already installed."
    else
        echo "Installing pyenv..."
        brew install pyenv && echo "pyenv is now installed."
        echo "Adding pyenv shims to PATH..."
        echo "# Add pyenv shims to PATH" >> $SHELL_RC_PATH
        echo "export PATH=\"$(pyenv root)/shims:\$PATH\"" >> $SHELL_RC_PATH
    fi

    echo "Checking for pyenv-virtualenv..."
    if brew list pyenv-virtualenv &> /dev/null; then
        echo "pyenv-virtualenv is already installed."
    else
        echo "Installing pyenv-virtualenv..."
        brew install pyenv-virtualenv && echo "pyenv-virtualenv is now installed."
    fi

}

function install_ripgrep_brew_mac() {
    echo "Checking for ripgrep..."
    if brew list ripgrep &> /dev/null; then
        echo "ripgrep is already installed."
    else
        echo "Installing ripgrep..."
        brew install ripgrep && echo "ripgrep is now installed."
    fi
}

function install_git_delta_brew_mac() {
    echo "Checking for git-delta..."
    if brew list git-delta &> /dev/null; then
        echo "git-delta is already installed."
    else
        echo "Installing git-delta..."
        brew install git-delta && echo "git-delta is now installed."
        echo "Adding git-delta to git config..."
        git config --global core.pager "delta --dark --line-numbers"
        git config --global delta.side-by-side true
    fi

}

function create_applications_dir_mac() {
    if [[ ! -d "$HOME/Applications" ]]; then
        echo "Creating Applications directory..."
        mkdir $HOME/Applications
    fi
}

function install_firefox_brew_mac() {
    echo "Checking for firefox..."
    if brew list firefox &> /dev/null; then
        echo "firefox is already installed."
    else
        echo "Installing firefox..."
        brew install firefox && echo "firefox is now installed."
    fi
}

function install_discord_brew_mac() {
    echo "Checking for discord..."
    if brew list discord &> /dev/null; then
        echo "discord is already installed."
    else
        echo "Installing discord..."
        brew install discord && echo "discord is now installed."
    fi
}

function install_openssh_brew_mac() {
    echo "Checking for openssh..."
    if brew list openssh &> /dev/null; then
        echo "openssh is already installed."
    else
        echo "Installing openssh..."
        brew install openssh && echo "openssh is now installed."
        # Check if brew path is in PATH, and if not, add it
        if [[ ! "$PATH" == *"$(brew --prefix)/bin"* ]]; then
            echo "Adding $(brew --prefix)/bin to PATH..."
            echo "# Add Homebrew to PATH" >> $SHELL_RC_PATH
            echo "export PATH=\"$(brew --prefix)/bin:\$PATH\"" >> $SHELL_RC_PATH
        fi
    fi
}

function install_vscode_brew_mac() {
    echo "Checking for Visual Studio Code..."
    if brew list visual-studio-code &> /dev/null; then
        echo "Visual Studio Code is already installed."
    else
        echo "Installing Visual Studio Code..."
        brew install --cask visual-studio-code && echo "Visual Studio Code is now installed."
    fi
}

function install_warp_brew_mac() { 
    echo "Checking for warp..."
    if brew list warp &> /dev/null; then
        echo "warp is already installed."
    else
        echo "Installing warp..."
        brew install --cask warp && echo "warp is now installed."
    fi

}

function install_background_music() {
    echo "Checking for Background Music..."
    if brew list background-music &> /dev/null; then
        echo "Background Music is already installed."
    else
        echo "Installing Background Music..."
        brew install --cask background-music && echo "Background Music is now installed."
    fi

}

function install_bitwarden_brew_mac() {
    echo "Checking for Bitwarden..."
    if brew list bitwarden &> /dev/null; then
        echo "Bitwarden is already installed."
    else
        echo "Installing Bitwarden..."
        brew install --cask bitwarden && echo "Bitwarden is now installed."
    fi

}

function install_nord_vpn_brew_mac() {
    echo "Checking for Nord VPN..."
    if brew list nordvpn &> /dev/null; then
        echo "Nord VPN is already installed."
    else
        echo "Installing Nord VPN..."
        brew install --cask nordvpn && echo "Nord VPN is now installed."
    fi
}

function install_brave_browser_brew_mac() {
    echo "Checking for Brave Browser..."
    if brew list brave-browser &> /dev/null; then
        echo "Brave Browser is already installed."
    else
        echo "Installing Brave Browser..."
        brew install --cask brave-browser && echo "Brave Browser is now installed."
    fi

}

function install_stats_brew_mac() {
    echo "Checking for Stats..."
    if brew list stats &> /dev/null; then
        echo "Stats is already installed."
    else
        echo "Installing Stats..."
        brew install --cask stats && echo "Stats is now installed."
    fi
}

function install_neovim_brew_mac() {
    echo "Checking for Neovim..."
    if brew list neovim &> /dev/null; then
        echo "Neovim is already installed."
    else
        echo "Installing Neovim..."
        brew install neovim && echo "Neovim is now installed."
    fi

}

function install_rust_brew_mac() {
    echo "Checking for Rust..."
    if brew list rust &> /dev/null; then
        echo "Rust is already installed."
    else
        echo "Installing Rust..."
        brew install rust && echo "Rust is now installed."
    fi

}

function install_texshop_brew_mac() {
    echo "Checking for TeXShop..."
    if brew list texshop &> /dev/null; then
        echo "TeXShop is already installed."
    else
        echo "Installing TeXShop..."
        brew install --cask texshop && echo "TeXShop is now installed."
    fi
}

function install_gcc_brew_mac() {
    echo "Checking for gcc..."
    if brew list gcc &> /dev/null; then
        echo "gcc is already installed."
    else
        echo "Installing gcc..."
        brew install gcc && echo "gcc is now installed."
    fi

}

function install_qmk_toolbox_mac() {
    echo "Checking for qmk-toolbox..."
    if brew list qmk-toolbox &> /dev/null; then
        echo "QMK Toolbox is already installed."
    else
        echo "Installing qmk-toolbox..."
        brew install --cask qmk-toolbox && echo "qmk-toolbox is now installed."
    fi

}

case "$OS_TYPE" in
    "mac")
        install_xcode_mac
        if [[ "$SHELL_TYPE" == "zsh" ]]; then
            install_oh_my_zsh
        fi
        create_applications_dir_mac
        install_brew_mac
        install_gnu_utils_brew_mac
        install_wget_brew_mac
        install_rsync_brew_mac
        install_pyenv_brew_mac
        install_ripgrep_brew_mac
        install_openssh_brew_mac
        install_firefox_brew_mac
        install_brave_browser_brew_mac
        install_discord_brew_mac
        install_git_delta_brew_mac
        install_bitwarden_brew_mac
        install_vscode_brew_mac
        install_rust_brew_mac
        install_texshop_brew_mac
        install_stats_brew_mac
        if [[ "$SUDO_ACCESS" == "True" ]]; then
            install_gcc_brew_mac
            install_background_music
            install_nord_vpn_brew_mac
            install_neovim_brew_mac
            install_qmk_toolbox_mac
        fi
        install_warp_brew_mac
        echo "==============================="
        echo "Installation complete."
        echo "Please restart your terminal."
        echo "==============================="
        ;;
    "linux")
        echo "Linux installation not supported yet."
        ;;
    *)
        echo "Unsupported OS"
        exit 1
        ;;
esac

exit 0

