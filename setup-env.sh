#!/usr/bin/env bash

# List of software to check/install
software=("brew" "docker" "asdf" "kubectl" "helm" "jq" "aws")
python_version="3.9.13"
dotfiles_repo="https://github.com/milorad-kukic/dotfiles"
clone_dir="$HOME/MalwareSamples"
debug_mode=false

# Function to display fancy headers
print_header() {
  echo -e "\n========================================"
  echo "           $1"
  echo "========================================"
}

# Function to show Docker-like progress (only if not in debug mode)
show_progress() {
  local msg="$1"
  if $debug_mode; then
    echo "$msg..."
  else
    local iterations=20  # Number of iterations for progress simulation
    echo -n "$msg"
    local i=0
    while [ "$i" -lt "$iterations" ]; do
      for spinner in "/" "-" "\\" "|"; do
        echo -ne "\r$msg $spinner"
        sleep 0.1
      done
      i=$((i + 1))
    done
    echo -ne "\r$msg... Done!   \n"
  fi
}

# Check if a command exists
is_installed() {
  command -v "$1" >/dev/null 2>&1
}

# Display help message
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Options:"
  echo "  -h, --help         Show this help message and exit."
  echo "  --uninstall        Uninstall all software installed by this script."
  echo "  --debug            Enable debug mode to show logs instead of spinner."
  echo
  echo "This script checks if the following software is installed:"
  echo "  - Homebrew"
  echo "  - Docker"
  echo "  - asdf"
  echo "  - kubectl"
  echo "  - helm"
  echo "  - jq"
  echo "  - AWS CLI v2"
  echo
  echo "It installs missing software, sets up Python 3.9.13 with asdf,"
  echo "installs aws-okta-processor, and clones the specified Git repository."
}

# Install Homebrew
install_brew() {
  echo "Installing Homebrew..."
  if $debug_mode; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    show_progress "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >/dev/null 2>&1
  fi

  if is_installed "brew"; then
    echo -e "\nHomebrew installed successfully!"
  else
    echo -e "\n\033[1;31mHomebrew installation failed. Please check the logs and try again.\033[0m"
    exit 1
  fi
}

# Install Docker
install_docker() {
  echo "Installing Docker Desktop..."
  if $debug_mode; then
    brew install --cask docker
  else
    show_progress "Installing Docker Desktop..."
    brew install --cask docker >/dev/null 2>&1
  fi

  if is_installed "docker"; then
    echo -e "\nDocker Desktop installed successfully!"
  else
    echo -e "\n\033[1;31mDocker installation failed. Please check the logs and try again.\033[0m"
    exit 1
  fi
}

# Install asdf
install_asdf() {
  echo "Installing asdf..."
  if $debug_mode; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.12.0
  else
    show_progress "Installing asdf..."
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.12.0 >/dev/null 2>&1
  fi
  echo '. "$HOME/.asdf/asdf.sh"' >>~/.zshrc
  echo '. "$HOME/.asdf/completions/asdf.bash"' >>~/.zshrc
  echo '. "$HOME/.asdf/asdf.sh"' >>~/.bashrc
  echo '. "$HOME/.asdf/completions/asdf.bash"' >>~/.bashrc
  source ~/.zshrc || source ~/.bashrc

  if is_installed "asdf"; then
    echo -e "\nasdf installed successfully!"
  else
    echo -e "\n\033[1;31masdf installation failed. Please check the logs and try again.\033[0m"
    exit 1
  fi
}

# Install Python using asdf
install_python_with_asdf() {
  echo "Installing Python $python_version with asdf..."
  if $debug_mode; then
    asdf plugin-add python || true
    asdf install python "$python_version"
    asdf global python "$python_version"
  else
    show_progress "Installing Python $python_version..."
    asdf plugin-add python >/dev/null 2>&1 || true
    asdf install python "$python_version" >/dev/null 2>&1
    asdf global python "$python_version" >/dev/null 2>&1
  fi

  if python --version 2>/dev/null | grep -q "$python_version"; then
    echo -e "\nPython $python_version installed and set as default successfully!"
  else
    echo -e "\n\033[1;31mPython installation failed. Please check the logs and try again.\033[0m"
    exit 1
  fi
}

# Install aws-okta-processor
install_aws_okta_processor() {
  echo "Installing aws-okta-processor..."
  if $debug_mode; then
    pip install aws-okta-processor
  else
    show_progress "Installing aws-okta-processor..."
    pip install aws-okta-processor >/dev/null 2>&1
  fi

  if pip show aws-okta-processor >/dev/null 2>&1; then
    echo -e "\naws-okta-processor installed successfully!"
  else
    echo -e "\n\033[1;31maws-okta-processor installation failed. Please check the logs and try again.\033[0m"
    exit 1
  fi
}

# Clone dotfiles repository
clone_dotfiles_repo() {
  echo "Cloning dotfiles repository..."
  if $debug_mode; then
    git clone "$dotfiles_repo" "$clone_dir"
  else
    show_progress "Cloning repository..."
    git clone "$dotfiles_repo" "$clone_dir" >/dev/null 2>&1
  fi

  if [ -d "$clone_dir" ]; then
    echo -e "\nRepository cloned to $clone_dir successfully!"
  else
    echo -e "\n\033[1;31mCloning repository failed. Please check the logs and try again.\033[0m"
    exit 1
  fi
}

# Install additional CLI tools
install_cli_tool() {
  local tool=$1
  echo "Installing $tool..."
  if $debug_mode; then
    brew install "$tool"
  else
    show_progress "Installing $tool..."
    brew install "$tool" >/dev/null 2>&1
  fi

  if is_installed "$tool"; then
    echo -e "\n$tool installed successfully!"
  else
    echo -e "\n\033[1;31m$tool installation failed. Please check the logs and try again.\033[0m"
    exit 1
  fi
}

# Parse command-line options
while [[ "$1" =~ ^- ]]; do
  case $1 in
    -h|--help)
      show_help
      exit 0
      ;;
    --uninstall)
      uninstall_software
      exit 0
      ;;
    --debug)
      debug_mode=true
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
  shift
done

# Main script logic
print_header "Checking Installed Software"

not_found=()

for tool in "${software[@]}"; do
  if is_installed "$tool"; then
    version=$("$tool" --version 2>/dev/null | head -n 1)
    echo -e "\033[1;32m$tool is installed: $version\033[0m"
  else
    echo -e "\033[1;31m$tool is not installed.\033[0m"
    not_found+=("$tool")
  fi
done

if [ ${#not_found[@]} -eq 0 ]; then
  echo -e "\033[1;32mAll software is installed.\033[0m"
else
  echo -e "\033[1;31mThe following software is missing:\033[0m"
  for tool in "${not_found[@]}"; do
    echo "- $tool"
  done
  read -p "Would you like to install the missing software? (y/n): " install_choice
  if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    for tool in "${not_found[@]}"; do
      case $tool in
        brew) install_brew ;;
        docker) install_docker ;;
        asdf) install_asdf ;;
        kubectl | helm | jq | aws) install_cli_tool "$tool" ;;
      esac
    done
  else
    echo "Skipping installation."
    exit 0
  fi
fi

install_python_with_asdf
install_aws_okta_processor
clone_dotfiles_repo

echo -e "\033[1;32mAll tasks completed successfully!\033[0m"

