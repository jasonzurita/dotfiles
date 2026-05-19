#!/bin/bash
# source this to install dotfiles

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# TODO: the below `grep -v` ignore is not scalable. Eventually, I will need a better solution.
# symlink dotfiles
ls "$DOTFILES" | grep -v '\.sh' | grep -v '\.md' | grep -v '\.add' | while read DOTFILE; do
    printf "Symlink to $DOTFILE..."
    if [ "$DOTFILE" = "zshrc" ]; then
        if [ -h "$HOME/.zshrc" ]; then
            echo " exists."
        elif [ -f "$HOME/.zshrc" ]; then
            echo ""
            echo "  ⚠️  ~/.zshrc is a real file (likely a managed machine)."
            echo "     Add this line to it manually: source ~/Code/dotfiles/zshrc"
        else
            echo " creating..."
            ln -s "$DOTFILES/zshrc" "$HOME/.zshrc"
        fi
        continue
    fi
    if [ -a "$HOME/.$DOTFILE" ]; then
        if [ -h "$HOME/.$DOTFILE" ]; then
            echo " exists."
        else
            echo " is not a symlink — skipping. Fix this manually."
        fi
    else
        echo " creating..."
        ln -s "$DOTFILES/$DOTFILE" "$HOME/.$DOTFILE"
    fi
done

# vim color theme
printf "Setting up vim color theme - Darcula..."
if [ ! -d "$HOME/darcula/" ]; then
    printf " cloning..."
    git clone "https://github.com/blueshirts/darcula.git" "$HOME/darcula" --quiet
fi
mkdir -p "$HOME/.vim/colors/"
cp "$HOME/darcula/colors/darcula.vim" "$HOME/.vim/colors/"
echo " done."

# symlink vim spell file
# TODO: consider combining with above symlink code
printf "Symlink vim spell file..."
mkdir -p "$HOME/.vim/spell/"
if [ -a "$HOME/.vim/spell/en.utf-8.add" ]; then
    if [ -h "$HOME/.vim/spell/en.utf-8.add" ]; then
        echo " exists."
    else
        echo " is not a symlink — skipping. Fix this manually."
    fi
else
    echo " creating..."
    ln -s "$DOTFILES/en.utf-8.add" "$HOME/.vim/spell/en.utf-8.add"
fi

# install vundle
printf "Installing Vundle..."
if [ -a "$HOME/.vim/bundle/Vundle.vim" ]; then
    echo " exists."
else
    echo " cloning and installing plugins..."
    git clone "https://github.com/VundleVim/Vundle.vim.git" "$HOME/.vim/bundle/Vundle.vim"
    printf "Running Vundle PluginInstall..."
    vim +PluginInstall +qall
fi

# make scripts executable
chmod +x "$DOTFILES/scripts/vimgrep.sh"

# Note: ~/.claude-home is symlinked as a whole directory by the generic loop above
# (claude-home dir in dotfiles → ~/.claude-home). No per-file wiring needed here.

# mobile/iOS project conventions CLAUDE.md
printf "Setting up ~/Code/mobile/CLAUDE.md..."
mkdir -p "$HOME/Code/mobile"
if [ -a "$HOME/Code/mobile/CLAUDE.md" ]; then
    if [ -h "$HOME/Code/mobile/CLAUDE.md" ]; then
        echo " symlink exists."
    else
        echo " is not a symlink — skipping. Fix this manually."
    fi
else
    ln -s "$DOTFILES/claude-home/mobile-CLAUDE.md" "$HOME/Code/mobile/CLAUDE.md"
    echo " linked."
fi

echo "Done."
