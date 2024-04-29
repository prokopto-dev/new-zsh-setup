#!/usr/bin/env bash
# Global variables
SHELL_TYPE=""
SHELL_RC_PATH=""
OS_TYPE=""
SUDO_ACCESS="False"

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
    if command -v brew &> /dev/null; then
        echo "Homebrew is already installed."
    else
        if [[ "$SUDO_ACCESS" == "True" ]]; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            echo "User does not have sudo access, installing Homebrew to $HOME/.homebrew"
            mkdir $HOME/.homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C $HOME/.homebrew
            eval "$($HOME/.homebrew/bin/brew shellenv)"
            brew update --force --quiet
            chmod -R go-w "$(brew --prefix)/share/zsh"
            echo "Adding Homebrew to PATH..."
            echo "# Add Homebrew to PATH" >> $SHELL_RC_PATH
            echo "eval \"$($HOME/.homebrew/bin/brew shellenv)\"" >> $SHELL_RC_PATH
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
    for util in "gawk" "gsed" "grep" "findutils" "coreutils" "libtool";
    do
        if brew list $util &> /dev/null; then
            echo "$util is already installed."
        else
            echo "Installing $util..."
            brew install $util
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
        brew install wget
    fi
}

# install pyenv and pyenv-virtualenv via brew
function install_pyenv_brew_mac() {
    echo "Checking for pyenv..."
    if brew list pyenv &> /dev/null; then
        echo "pyenv is already installed."
    else
        echo "Installing pyenv..."
        brew install pyenv
        echo "Adding pyenv shims to PATH..."
        echo "# Add pyenv shims to PATH" >> $SHELL_RC_PATH
        echo "export PATH=\"$(pyenv root)/shims:\$PATH\"" >> $SHELL_RC_PATH
    fi

    echo "Checking for pyenv-virtualenv..."
    if brew list pyenv-virtualenv &> /dev/null; then
        echo "pyenv-virtualenv is already installed."
    else
        echo "Installing pyenv-virtualenv..."
        brew install pyenv-virtualenv
    fi

}

function install_ripgrep_brew_mac() {
    echo "Checking for ripgrep..."
    if brew list ripgrep &> /dev/null; then
        echo "ripgrep is already installed."
    else
        echo "Installing ripgrep..."
        brew install ripgrep
    fi
}


function install_openssh_brew_mac() {
    echo "Checking for openssh..."
    if brew list openssh &> /dev/null; then
        echo "openssh is already installed."
    else
        echo "Installing openssh..."
        brew install openssh
        # Check if brew path is in PATH, and if not, add it
        if [[ ! "$PATH" == *"$(brew --prefix)/bin"* ]]; then
            echo "Adding $(brew --prefix)/bin to PATH..."
            echo "# Add Homebrew to PATH" >> $SHELL_RC_PATH
            echo "export PATH=\"$(brew --prefix)/bin:\$PATH\"" >> $SHELL_RC_PATH
        fi
    fi
}

case "$OS_TYPE" in
    "mac")
        install_xcode_mac
        if [[ "$SHELL_TYPE" == "zsh" ]]; then
            install_oh_my_zsh
        fi
        install_brew_mac
        install_gnu_utils_brew_mac
        install_wget_brew_mac
        install_pyenv_brew_mac
        install_ripgrep_brew_mac
        install_openssh_brew_mac
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

