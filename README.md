# Tailscale Updater for OpenWrt

[English](#tailscale-updater-for-openwrt) | [中文说明](#openwrt-tailscale-更新工具)

A shell script to automatically update Tailscale on OpenWrt devices. This tool helps you keep your Tailscale installation up-to-date by checking for new versions and performing automatic updates.

## Features

- Automatic detection of system architecture
- Checks for the latest Tailscale version
- Downloads and installs updates automatically
- Handles cleanup of temporary files
- Comprehensive logging of update process
- Supports multiple CPU architectures

## Supported Architectures

- x86_64 (amd64)
- i386/i686 (386)
- ARM (arm)
- ARM64 (aarch64)
- MIPS
- MIPS64
- MIPS64LE
- MIPSLE
- Geode
- RISC-V 64

## Installation

1. Download the update script:
```bash
wget -O /usr/sbin/tailscale-update https://raw.githubusercontent.com/bigQY/tailscale-updater-for-openwrt/main/update.sh
```

2. Make the script executable:
```bash
chmod +x /usr/sbin/tailscale-update
```

## Usage

Simply run the script to check for and install updates:
```bash
/usr/sbin/tailscale-update
```

You can also set up a cron job to run the script periodically:
```bash
# Add to /etc/crontabs/root to run daily at 3:00 AM
0 3 * * * /usr/sbin/tailscale-update
```

## Logs

The script logs all operations to `/var/tmp/tailscale_update.log`. You can monitor the update process by checking this file:
```bash
cat /var/tmp/tailscale_update.log
```

---

# OpenWrt Tailscale 更新工具

这是一个用于 OpenWrt 设备的 Tailscale 自动更新脚本。该工具可以帮助您通过检查新版本并执行自动更新来保持 Tailscale 安装的最新状态。

## 功能特点

- 自动检测系统架构
- 检查最新的 Tailscale 版本
- 自动下载和安装更新
- 自动清理临时文件
- 完整的更新过程日志记录
- 支持多种 CPU 架构

## 支持的架构

- x86_64 (amd64)
- i386/i686 (386)
- ARM (arm)
- ARM64 (aarch64)
- MIPS
- MIPS64
- MIPS64LE
- MIPSLE
- Geode
- RISC-V 64

## 安装方法

1. 下载更新脚本：
```bash
wget -O /usr/sbin/tailscale-update https://raw.githubusercontent.com/bigQY/tailscale-updater-for-openwrt/main/update.sh
```

2. 设置脚本执行权限：
```bash
chmod +x /usr/sbin/tailscale-update
```

## 使用方法

直接运行脚本即可检查并安装更新：
```bash
/usr/sbin/tailscale-update
```

您也可以设置定时任务定期运行脚本：
```bash
# 添加到 /etc/crontabs/root 实现每天凌晨 3 点自动运行
0 3 * * * /usr/sbin/tailscale-update
```

## 日志查看

脚本会将所有操作记录到 `/var/tmp/tailscale_update.log`。您可以通过查看此文件来监控更新过程：
```bash
cat /var/tmp/tailscale_update.log
```