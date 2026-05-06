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

# make scripts executable
chmod +x "$DOTFILES/scripts/vimgrep.sh"

# claude-home config (symlink individual files, not the whole dir)
echo -n "Setting up .claude-home..."
mkdir -p "$HOME/.claude-home/skills"

for FILE in CLAUDE.md settings.json; do
    if [ -a "$HOME/.claude-home/$FILE" ]; then
        if [ -h "$HOME/.claude-home/$FILE" ]; then
            echo " $FILE symlink exists."
        else
            echo " $FILE is not a symlink! You should probably fix that."
        fi
    else
        ln -s "$DOTFILES/claude-home/$FILE" "$HOME/.claude-home/$FILE"
        echo " $FILE linked."
    fi
done

if [ -h "$HOME/.claude-home/skills" ]; then
    echo " skills symlink exists."
elif [ -d "$HOME/.claude-home/skills" ] && [ ! -h "$HOME/.claude-home/skills" ]; then
    echo " skills is not a symlink! You should probably fix that."
else
    ln -s "$DOTFILES/claude-home/skills" "$HOME/.claude-home/skills"
    echo " skills linked."
fi

# mobile/iOS project conventions CLAUDE.md
echo -n "Setting up ~/Code/mobile/CLAUDE.md..."
mkdir -p "$HOME/Code/mobile"
if [ -a "$HOME/Code/mobile/CLAUDE.md" ]; then
    if [ -h "$HOME/Code/mobile/CLAUDE.md" ]; then
        echo " symlink exists."
    else
        echo " is not a symlink! You should probably fix that."
    fi
else
    ln -s "$DOTFILES/claude-home/mobile-CLAUDE.md" "$HOME/Code/mobile/CLAUDE.md"
    echo " linked."
fi

echo "Done."
