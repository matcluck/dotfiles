#!/bin/bash
tools=()
config=`readlink -f ~/.config`

# Do an apt update
sudo apt update

# Uncomment the tools that you would like to install/configure
tools+=("gtk-3.0")
tools+=("i3")
tools+=("nvim")

# move config for tool into .config folder
for tool in "${tools[@]}"; do
	# i3 specific configuration
	if [ "$tool" == "i3" ]; then
		sudo apt install i3 -y
	fi
	# neovim specific configuration
	if [ "$tool" == "nvim" ]; then
		#sudo apt install neovim -y # fkn debian repos
		sudo apt install -y curl
    latest=`basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/neovim/neovim/releases/latest)`
		wget https://github.com/neovim/neovim/releases/download/$latest/nvim-linux-`uname -m`.appimage
		chmod +x nvim-linux*
		mv nvim-linux* ~/.local/bin/nvim

		# Delete existing configuration?
		read -p "Overwrite your existing nvim configuration? (y/n): " confirm
		if [[ "$confirm" =~ ^[Yy]$ ]]; then
			rm -rf ~/.config/nvim
			cp -r nvim ~/.config/nvim
			nvim
		fi
	fi	

	# Create directory if it doesn't exist
	if [ ! -d "$config/$tool" ]; then
  		mkdir -p "$config/$tool"
	fi

	echo "Placing the configuration contents for $tool in $config/$tool"
	cp -R $tool/* "$config/$tool/"
done
