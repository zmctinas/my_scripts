#!/bin/bash

# 更新系统
echo "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y

# 安装必要的依赖
echo "Installing necessary dependencies..."
sudo apt install -y build-essential pkg-config libssl-dev git-all screen protobuf-compiler unzip curl

# 安装 Protocol Buffers (protoc)
PROTOC_VERSION=29.1
PROTOC_ZIP=protoc-$PROTOC_VERSION-linux-x86_64.zip

# 检查当前 protoc 版本
echo "Checking current protoc version..."
INSTALLED_PROTOC_VERSION=$(protoc --version 2>/dev/null | awk '{print $2}')

if [[ "$INSTALLED_PROTOC_VERSION" == "$PROTOC_VERSION" ]]; then
  echo "protoc version $PROTOC_VERSION is already installed. Skipping installation."
else
  echo "Downloading and installing protoc version $PROTOC_VERSION..."
  curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOC_VERSION/$PROTOC_ZIP
  unzip -o $PROTOC_ZIP -d $HOME/.local
  rm -f $PROTOC_ZIP

  # 更新 PATH 环境变量以包含 protoc
  if ! grep -q 'export PATH="${HOME}/.local/bin":${PATH}' ~/.profile; then
    echo 'export PATH="${HOME}/.local/bin":${PATH}' >> ~/.profile
    echo "Updated PATH in ~/.profile"
  fi
  source ~/.profile

  # 验证 protoc 是否安装成功
  echo "Verifying protoc installation..."
  protoc --version || { echo "Failed to install protoc!"; exit 1; }
fi

# 安装 Rust
echo "Checking for Rust installation..."
if ! rustc --version &>/dev/null; then
  echo "Rust not found. Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

  # 配置 Rust 环境变量
  echo "Configuring Rust environment variables..."
  source $HOME/.cargo/env
  if ! grep -q 'source $HOME/.cargo/env' ~/.profile; then
    echo 'source $HOME/.cargo/env' >> ~/.profile
    echo "Updated Rust environment configuration in ~/.profile"
  fi
fi

# 验证 Rust 是否安装成功
echo "Verifying Rust installation..."
rustc --version || { echo "Failed to install Rust!"; exit 1; }

# 安装 Nexus CLI
echo "Running Nexus CLI installation in a new screen session..."
if ! screen -ls | grep -q "nexus"; then
  screen -dmS nexus bash -c "curl https://cli.nexus.xyz | sh; exec bash"
  echo "Nexus CLI installation is running in a screen session named 'nexus'."
else
  echo "A screen session named 'nexus' already exists. Please check its status."
fi

echo "All tasks completed successfully!"