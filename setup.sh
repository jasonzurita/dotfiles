#!/bin/bash
# source this to install dotfiles

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# TODO: the below `grep -v` ignore is not scalable. Eventually, I will need a better solution.
# simlink dotfiles
ls "$DOTFILES" | grep -v '\.sh' | grep -v '\.md' | grep -v '\.add' | while read DOTFILE; do
	echo -n "Symlink to $DOTFILE..."
	if [ -a "$HOME/.$DOTFILE" ]; then
		if [ -h "$HOME/.$DOTFILE" ]; then
			echo " exists."
		else
			echo " is not a symlink!"
			echo "You should probably fix that."
			exit 1
		fi
	else
		echo " creating..."
		ln -s "$DOTFILES/$DOTFILE" "$HOME/.$DOTFILE"
	fi
done

# vim color theme
echo -n "Setting up vim color theme - Darcula..."
if [ ! -d "$HOME/darcula/" ]; then
	echo -n " cloning..."
	git clone "https://github.com/blueshirts/darcula.git" "$HOME/darcula"
fi	

echo " copying darcula theme to ~/.vim/colors..."
mkdir -p "$HOME/.vim/colors/"
cp "$HOME/darcula/colors/darcula.vim" "$HOME/.vim/colors/"

# symlink vim spell file
# TODO: consider combining with above symlink code
echo -n "Symlink vim spell file..."
mkdir -p "$HOME/.vim/spell/"
if [ -a "$HOME/.vim/spell/en.utf-8.add" ]; then
    if [ -h "$HOME/.vim/spell/en.utf-8.add" ]; then
        echo " exists."
    else
        echo " is not a symlink!"
        echo "You should probably fix that."
        exit 1
    fi
else
    echo " creating..."
    ln -s "$DOTFILES/en.utf-8.add" "$HOME/.vim/spell/en.utf-8.add"
fi

# install vundle
echo -n "Installing Vundle..."
if [ -a "$HOME/.vim/bundle/Vundle.vim" ]; then
	echo " exists."
else
	echo " cloning and installing plugins..."
	git clone "https://github.com/VundleVim/Vundle.vim.git" "$HOME/.vim/bundle/Vundle.vim"
	echo -n "Running Vundle PluginInstall..."
	vim +PluginInstall +qall
fi

echo "Done."
