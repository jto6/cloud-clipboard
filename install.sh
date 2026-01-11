#!/usr/bin/env zsh
#
# Install cloud-clipboard scripts by creating symlinks in ~/.local/bin
# and ensuring clipboard tools are available
#

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
TARGET_DIR="$HOME/.local/bin"

echo "Installing cloud-clipboard..."

# Function to check if a command exists
command_exists() {
	command -v "$1" &>/dev/null
}

# Function to detect display server
detect_display_server() {
	if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
		echo "wayland"
	elif [[ -n "${DISPLAY:-}" ]]; then
		echo "x11"
	else
		echo "unknown"
	fi
}

# Function to detect package manager and install a package
install_package() {
	local package="$1"

	if command_exists apt-get; then
		echo "  Installing $package via apt..."
		sudo apt-get update -qq && sudo apt-get install -y "$package"
	elif command_exists dnf; then
		echo "  Installing $package via dnf..."
		sudo dnf install -y "$package"
	elif command_exists yum; then
		echo "  Installing $package via yum..."
		sudo yum install -y "$package"
	elif command_exists pacman; then
		echo "  Installing $package via pacman..."
		sudo pacman -S --noconfirm "$package"
	elif command_exists zypper; then
		echo "  Installing $package via zypper..."
		sudo zypper install -y "$package"
	elif command_exists brew; then
		echo "  Installing $package via brew..."
		brew install "$package"
	else
		echo "Error: No supported package manager found" >&2
		echo "Please install '$package' manually" >&2
		return 1
	fi
}

# Ensure clipboard tool is available
ensure_clipboard_tool() {
	# macOS has pbcopy/pbpaste built-in
	if [[ "$OSTYPE" == darwin* ]]; then
		echo "  Clipboard: Using macOS built-in pbcopy/pbpaste"
		return 0
	fi

	# Check if any clipboard tool is already available
	if command_exists xclip; then
		echo "  Clipboard: xclip found"
		return 0
	elif command_exists xsel; then
		echo "  Clipboard: xsel found"
		return 0
	elif command_exists wl-copy && command_exists wl-paste; then
		echo "  Clipboard: wl-clipboard found"
		return 0
	fi

	# No clipboard tool found, install based on display server
	local display_server
	display_server=$(detect_display_server)

	echo "  No clipboard tool found, detecting display server..."
	echo "  Display server: $display_server"

	case "$display_server" in
		wayland)
			echo "  Installing wl-clipboard for Wayland..."
			install_package "wl-clipboard"
			;;
		x11)
			echo "  Installing xclip for X11..."
			install_package "xclip"
			;;
		*)
			echo "Warning: Could not detect display server (X11/Wayland)" >&2
			echo "Installing xclip as default..." >&2
			install_package "xclip"
			;;
	esac
}

# Ensure clipboard tool is installed
ensure_clipboard_tool

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Scripts to install
typeset -a SCRIPTS
SCRIPTS=("ccopy" "cpaste")

for script in "${SCRIPTS[@]}"; do
	src="$SCRIPT_DIR/$script"
	dest="$TARGET_DIR/$script"

	if [[ ! -f "$src" ]]; then
		echo "Error: $src not found" >&2
		exit 1
	fi

	# Remove existing file/symlink if present
	if [[ -e "$dest" || -L "$dest" ]]; then
		rm "$dest"
		echo "  Replaced: $dest"
	else
		echo "  Created:  $dest"
	fi

	ln -s "$src" "$dest"
done

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo ""
echo "1. Ensure ~/.local/bin is in your PATH. Add to ~/.zshrc:"
echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
echo "2. Set CLIPBOARD_REPO_PATH to your clipboard sync repo:"
echo "   export CLIPBOARD_REPO_PATH=\"\$HOME/.clipboard-sync\""
echo ""
echo "3. Clone your private GitHub clipboard repo:"
echo "   git clone git@github.com:YOUR_USER/YOUR_REPO.git ~/.clipboard-sync"
echo ""
echo "Run 'ccopy --help' or 'cpaste --help' for usage information."
