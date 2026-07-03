#!/usr/bin/env bash
#
# Copyright 2026 Keita Sekiguchi
#
# Licensed under the Apache License, Version 2.0
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# ROS 2のディストリビューション
ROS_DISTRO="humble"

# sudo権限の確認
sudo -v

# Ubuntu情報の読み込み
. /etc/os-release
UBUNTU_CODENAME="${UBUNTU_CODENAME:-$VERSION_CODENAME}"

# パッケージリストの更新
sudo apt update

# Universeリポジトリ有効化に必要なツールのインストール
sudo apt install -y curl software-properties-common

# UbuntuのUniverseリポジトリを有効化
sudo add-apt-repository -y universe

# Universe有効化後のパッケージリスト更新
sudo apt update

# rosdepのインストール
sudo apt install -y python3-rosdep2

# ROS 2のGPGキーを追加
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
  -o /usr/share/keyrings/ros-archive-keyring.gpg

# ROS 2のaptリポジトリを追加
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu ${UBUNTU_CODENAME} main" \
  | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# ROS 2リポジトリ追加後のパッケージリスト更新
sudo apt update

# 既存パッケージのアップグレード
sudo apt upgrade -y

# ROS 2 Desktop版をインストール
sudo apt install -y "ros-${ROS_DISTRO}-desktop"

# 新しいターミナルでROS 2環境が自動読み込みされるように設定
if ! grep -q "source /opt/ros/${ROS_DISTRO}/setup.bash" ~/.bashrc; then
  echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
fi

# 現在のターミナルにもROS 2環境を反映
source "/opt/ros/${ROS_DISTRO}/setup.bash"

# rosdepを初期化し、依存関係データベースを更新
if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
  sudo rosdep init
fi

rosdep update

# 完了メッセージ
echo "ROS 2 ${ROS_DISTRO} のインストールが完了しました。"
echo "確認: ros2 --version"
