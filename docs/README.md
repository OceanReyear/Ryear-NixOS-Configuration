# NixOS 配置说明（reyear-nixos）

## 目录结构

- `flake.nix`/`flake.lock`：系统入口与版本锁定（NixOS 25.11）
- `hosts/reyear-nixos/`：主机配置
  - `configuration.nix`：核心系统配置
  - `home.nix`：Home Manager 用户配置
  - `hardware-configuration.nix`：硬件检测生成（一般不手动改）
  - `README.md`：主机简要指引
- `scripts/`：运维脚本
  - `update-resume-offset.sh`：更新休眠 `resume_offset`
- `docs/README.md`：本文档

## 常用命令

- 系统构建（flake 方式）
  - `sudo nixos-rebuild switch --flake /etc/nixos#reyear-nixos`

- 更新休眠 offset（在重建 swapfile 后执行）
  - `sudo /etc/nixos/scripts/update-resume-offset.sh`
  - 然后再运行 `sudo nixos-rebuild switch --flake /etc/nixos#reyear-nixos`

- Docker
  - `sudo systemctl start docker`
  - `docker ps`

- libvirt / virt-manager
  - `virt-manager`
  - `virsh list --all`

- devShell 模板
  - `nix develop /etc/nixos/templates/devshell-node`
  - `nix develop /etc/nixos/templates/devshell-rust`
  - `nix develop /etc/nixos/templates/devshell-go`
  - `nix develop /etc/nixos/templates/devshell-python`

## 运维脚本

- `update-resume-offset.sh`：更新休眠 offset
  - `update-resume-offset.sh`
- `fetch-iso.sh`：下载 ISO 到 `/vms/libvirt/iso`
  - `fetch-iso.sh <url> [sha256]`
- `list-vms.sh`：查看 VM 目录内容
  - `list-vms.sh`
- `check-docker-mirror.sh`：检查 Docker 镜像源可用性
  - `check-docker-mirror.sh`

## 关键配置

### 1) 内核策略（稳定优先）
- 不显式指定 `boot.kernelPackages`，使用 NixOS 默认 LTS。
- 如遇硬件兼容问题再切换 `linuxPackages_latest`。

### 2) Swap + 休眠（Btrfs）
- Swapfile 位于 `/swap/swapfile`，大小 40G。
- `/swap` 使用独立子卷 `@swap`，挂载时 `nodatacow` + `compress=no`。
- 休眠通过：
  - `boot.resumeDevice = "/dev/mapper/cryptroot";`
  - `boot.kernelParams = [ "resume_offset=..." ];`
- 如果重建 swapfile，必须更新 offset：
  - `sudo btrfs inspect-internal map-swapfile -r /swap/swapfile`
  - 或直接运行脚本 `/etc/nixos/scripts/update-resume-offset.sh`

### 3) ZRAM
- `zramSwap` 启用，大小 8G
- 作用：减少 SSD swap 写入，提高交互流畅度

### 4) Snapper
- Snapper 对 `/` 和 `/home` 子卷开启
- 排除目录包含 `/vms`、`/swap`、`/tmp`、`/var/tmp`、`/var/cache`

### 5) Home Manager
- 作为 NixOS 模块集成
- 用户配置入口：`hosts/reyear-nixos/home.nix`
- 用户模块目录：`hosts/reyear-nixos/home/`
- 与系统一同通过 `nixos-rebuild switch --flake ...` 构建

### 6) Zsh 增强
- 启用 `starship` 作为提示符
- 启用 `fzf` + `fzf-tab` 作为补全增强
- 启用 `zoxide` 作为智能目录跳转

### 7) 开发环境
- Rust：`rustup`（默认 stable）
- Go：`go_1_24`
- Node.js：`nodejs_22`（npm）
- npm 国内源：`https://registry.npmmirror.com`
- Python：`python3` + `uv`
- Docker：rootful 模式（不自启），镜像源 `https://docker.mirrors.tuna.tsinghua.edu.cn`
，镜像源：`https://docker.mirrors.tuna.tsinghua.edu.cn`
- 虚拟机：`libvirt` + `virt-manager`
- 虚拟机镜像路径：`/var/lib/libvirt/images` 绑定到 `/vms/libvirt/images`
- ISO 存放路径：`/vms/libvirt/iso`
- VM 导出/备份目录：`/vms/libvirt/vms`
- ISO 下载脚本：`/etc/nixos/scripts/fetch-iso.sh`
- VM 目录查看脚本：`/etc/nixos/scripts/list-vms.sh`
- Docker 镜像源检查脚本：`/etc/nixos/scripts/check-docker-mirror.sh`
- 脚本路径已加入用户 PATH（可直接运行脚本名）
- devShell 模板：`/etc/nixos/templates/`
- Python devShell：`/etc/nixos/templates/devshell-python`
- 大文件支持：`git-lfs`

## 变更与维护注意事项

- **配置变更后必须使用 flake 构建**：
  - `sudo nixos-rebuild switch --flake /etc/nixos#reyear-nixos`

- **重建 swapfile 时必做步骤**：
  1. 重新创建 swapfile
  2. 运行 `/etc/nixos/scripts/update-resume-offset.sh`
  3. 执行 `nixos-rebuild switch --flake ...`

- **Btrfs 子卷变动**：
  - 若新增子卷，需要同步到 `fileSystems` 中
  - Snapper 排除目录需要手动维护

- **内核回归稳定**：
  - 当前使用默认 LTS 内核，如需更新请明确写入 `boot.kernelPackages`

- **Git 自动备份**：
  - 每次 `nixos-rebuild` 会自动 commit + push
  - 若网络异常或 key 不可用会影响 rebuild 速度

## Zsh 使用提示

- **fzf**：`Ctrl+R` 反向搜索历史
- **zoxide**：输入 `z <关键字>` 快速跳转目录
- **fzf-tab**：Tab 补全时支持筛选

## 故障排查

- **休眠失败或无法恢复**
  - 重新获取 offset：`sudo btrfs inspect-internal map-swapfile -r /swap/swapfile`
  - 运行更新脚本：`sudo /etc/nixos/scripts/update-resume-offset.sh`
  - 重新构建：`sudo nixos-rebuild switch --flake /etc/nixos#reyear-nixos`

- **swap 或 zram 未生效**
  - `swapon --show`
  - `cat /proc/swaps`
  - `cat /sys/block/zram0/disksize`

- **子卷挂载异常**
  - `sudo btrfs subvolume list /`
  - `findmnt /swap`

- **下载缓存异常**
  - 临时切换镜像源或添加 `https://cache.nixos.org/`

## 升级流程

- **常规升级**
  - `nix flake update /etc/nixos`
  - `sudo nixos-rebuild switch --flake /etc/nixos#reyear-nixos`

- **回滚**
  - 开机进入 GRUB 选择旧 generation
  - 或执行：`sudo nixos-rebuild --rollback`

## 恢复策略（Btrfs + Snapper）

- **查看快照**
  - `sudo snapper -c root list`
  - `sudo snapper -c home list`

- **回滚 root 子卷（危险操作，需谨慎）**
  - `sudo snapper -c root rollback <snapshot-id>`
  - 回滚后建议重启进入新 generation

- **恢复单个文件/目录**
  - `sudo snapper -c root status <snapshot-id>`
  - `sudo snapper -c root undochange <snapshot-id> <path>`
