# Homebrew Tap - Brew Version Manager

A Homebrew tap providing tools to manage multiple formula versions.

## Installation

### Standard Installation

```bash
# Add the tap
brew tap tommasomeli/tap

# Install Brew Version Manager
brew install tommasomeli/tap/brew-vm

# The commands are now available
brew use --version
brew switch --version
```

### Local Installation (Development)

If you're developing this tap or have cloned the repository locally:

```bash
# Clone the repository (if you haven't already)
git clone https://github.com/tommasomeli/homebrew-tap.git
cd homebrew-tap

# Create the necessary directories in Homebrew
mkdir -p "$(brew --repository)/Library/Taps/tommasomeli"

# Create a symbolic link to your local repository
ln -sf "$(pwd)" "$(brew --repository)/Library/Taps/tommasomeli/homebrew-tap"

# Verify the tap is recognized
brew tap

# Install the Homebrew Version Manager
brew install brew-vm

# The commands are now available
brew use --version
brew switch --version
```

## Available Commands

### brew-vm use

Starts a new shell with a specific formula version in PATH.

```bash
# Display help
brew-vm use --help

# Usage
brew-vm use python 3.11
```

This command starts a new shell with the specified formula version in PATH. The shell will display the active version in the prompt, allowing you to work with that version immediately. When you're done, type `exit` to return to your normal shell.

### brew-vm set

Sets the global default version for a formula.

```bash
# Display help
brew-vm set --help

# Usage
brew-vm set python 3.11
```

This command creates the necessary symlinks to make the specified version the system default.

## Requirements

- Versioned formulas must be already installed (e.g., `python@3.11`)
- Ruby (automatically installed as a dependency)

## Technical Notes

### How It Works

The `brew-vm` formula:

1. Installs the necessary Ruby scripts to Homebrew
2. Creates a command line tool in your PATH
3. Sets the proper permissions for the scripts to be executable

## License

MIT
