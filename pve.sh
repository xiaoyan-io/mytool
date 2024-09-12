#!/bin/bash
# 打印颜色函数
red() { printf "\e[31m%s\e[0m\n" "$1"; }
green() { printf "\e[32m%s\e[0m\n" "$1"; }
yellow() { printf "\e[33m%s\e[0m\n" "$1"; }
cyan() { printf "\e[36m%s\e[0m\n" "$1"; }

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
  red "请使用root权限运行此脚本"
  exit 1
fi

# 安装并配置VIM
install_vim() {
    printf "正在安装VIM...\n"
    apt-get update -y
    apt-get install vim -y
    green "VIM安装完成！"
}

# 创建虚拟机
create_vm() {
    read -p "请输入虚拟机ID: " vmid
    read -p "请输入虚拟机名称: " vmname
    read -p "请输入ISO文件路径: " iso_path
    # 检查ISO文件是否存在
    if [ ! -f "$iso_path" ]; then
        red "ISO文件不存在，请检查路径。"
        exit 1
    fi
    read -p "请输入虚拟机磁盘大小 (如: 32G): " disk_size
    read -p "请输入内存大小 (MB): " memory
    read -p "请输入CPU核数: " cores
    qm create "$vmid" --name "$vmname" --memory "$memory" --cores "$cores" --net0 virtio,bridge=vmbr0 --cdrom "$iso_path" --scsi0 local:"$disk_size"
    green "虚拟机 $vmname 创建完成！"
}

# 创建LXC容器
create_lxc() {
    read -p "请输入LXC容器ID: " lxcid
    read -p "请输入LXC模板文件路径: " template_path
    # 检查模板文件是否存在
    if [ ! -f "$template_path" ]; then
        red "LXC模板文件不存在，请检查路径。"
        exit 1
    fi
    read -p "请输入容器磁盘大小 (如: 8G): " disk_size
    read -p "请输入内存大小 (MB): " memory
    read -p "请输入CPU核数: " cores
    pct create "$lxcid" "$template_path" --storage local --rootfs "$disk_size" --memory "$memory" --cores "$cores" --net0 name=eth0,bridge=vmbr0,ip=dhcp
    green "LXC容器创建完成！"
}

# 查看网络配置
view_network() {
    printf "当前网络配置如下：\n"
    ip addr show
    green "网络查看完成！"
}

# Hexo 创建新文章
create_post() {
    read -p "请输入文章标题: " title
    hexo new "$title"
    green "文章 '$title' 创建完成！"
}

# Hexo 创建新分类
create_category() {
    read -p "请输入分类名称: " category
    hexo new page "categories/$category"
    green "分类 '$category' 创建完成！"
}

# Hexo 清理、生成、部署
hexo_clean_generate_deploy() {
    printf "清理Hexo缓存...\n"
    hexo clean
    green "Hexo缓存清理完成！"

    printf "生成Hexo静态文件...\n"
    hexo generate
    green "Hexo静态文件生成完成！"

    printf "部署Hexo站点...\n"
    hexo deploy
    green "Hexo站点部署完成！"
}

# 菜单显示函数
show_menu() {
  printf "==============================\n"
  printf "      PVE及SSH管理工具\n"
  printf "==============================\n"
  printf "1. 安装并配置VIM\n"
  printf "2. 创建虚拟机 (VM)\n"
  printf "3. 创建LXC容器\n"
  printf "4. 查看网络配置\n"
  printf "5. 创建Hexo文章\n"
  printf "6. 创建Hexo分类\n"
  printf "7. Hexo 清理/生成/部署\n"
  printf "8. 退出\n"
  printf "==============================\n"
}

# 主程序
while true; do
  show_menu
  read -p "请选择一个选项 [1-8]: " choice
  case "$choice" in
    1)
      install_vim
      ;;
    2)
      create_vm
      ;;
    3)
      create_lxc
      ;;
    4)
      view_network
      ;;
    5)
      create_post
      ;;
    6)
      create_category
      ;;
    7)
      hexo_clean_generate_deploy
      ;;
    8)
      green "退出程序。"
      exit 0
      ;;
    *)
      red "无效选项，请输入1到8之间的数字。"
      ;;
  esac
done
