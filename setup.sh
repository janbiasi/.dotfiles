#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin main;

function doIt() {
	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "setup.sh" \
		--exclude "README.md" \
		--exclude "LICENSE" \
		-avh --no-perms . ~;
	source ~/.bash_profile;
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;

echo "Installing Homebrew ..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo -e "Done!\n"

echo "Installing NVM ..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
echo -e "Done!\n"

echo "Installing SDKMAN ..."
curl -s "https://get.sdkman.io" | bash
echo -e "Done!\n"

echo "Installing Oh My ZSH ..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo -e "Done!\n"
