#!/bin/bash
# source this to install dotfiles

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ls "$DOTFILES" | grep -v '\.sh' | grep -v '\.md' | while read DOTFILE; do
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

echo -n "Installing Vundle..."
if [ -a "$HOME/.vim/bundle/Vundle.vim" ]; then
	echo " exists."
else
	git clone "https://github.com/VundleVim/Vundle.vim.git" "$HOME/.vim/bundle/Vundle.vim"
fi

echo "Done."
