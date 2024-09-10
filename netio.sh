#!/bin/bash

# 打印颜色函数
red() { echo -e "\e[31m$1\e[0m"; }
green() { echo -e "\e[32m$1\e[0m"; }
yellow() { echo -e "\e[33m$1\e[0m"; }
cyan() { echo -e "\e[36m$1\e[0m"; }

# 检查是否是root用户
if [ "$EUID" -ne 0 ]; then
  red "请使用root权限运行此脚本"
  exit 1
fi

# 安装并配置VIM
install_vim() {
    echo "正在安装VIM..."
    apt-get update -y
    apt-get install vim -y
    green "VIM安装完成！"
}

# 创建虚拟机
create_vm() {
    read -p "请输入虚拟机ID: " vmid
    read -p "请输入虚拟机名称: " vmname
    read -p "请输入ISO文件路径: " iso_path
    read -p "请输入虚拟机磁盘大小(如: 32G): " disk_size
    read -p "请输入内存大小(MB): " memory
    read -p "请输入CPU核数: " cores

    qm create $vmid --name $vmname --memory $memory --cores $cores --net0 virtio,bridge=vmbr0 --cdrom $iso_path --scsi0 local-lvm:$disk_size
    green "虚拟机 $vmname 创建完成！"
}

# 创建LXC容器
create_lxc() {
    read -p "请输入LXC容器ID: " lxcid
    read -p "请输入LXC模板文件路径: " template_path
    read -p "请输入容器磁盘大小(如: 8G): " disk_size
    read -p "请输入内存大小(MB): " memory
    read -p "请输入CPU核数: " cores

    pct create $lxcid $template_path --storage local-lvm --rootfs $disk_size --memory $memory --cores $cores --net0 name=eth0,bridge=vmbr0,ip=dhcp
    green "LXC容器创建完成！"
}

# 配置网络
view_network() {
    echo "当前网络配置如下："
    ip addr show
    green "网络查看完成！"
}

# 配置PCI硬件直通
setup_pci_passthrough() {
    echo "配置PCI硬件直通..."
    echo "请确保已在PVE BIOS中启用了VT-d或IOMMU！"

    # 修改grub文件
    echo "正在配置GRUB文件..."
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& intel_iommu=on iommu=pt/' /etc/default/grub
    update-grub

    # 加载IOMMU模块
    echo "添加必要的内核模块..."
    echo "vfio" >> /etc/modules
    echo "vfio_iommu_type1" >> /etc/modules
    echo "vfio_pci" >> /etc/modules
    echo "vfio_virqfd" >> /etc/modules

    # 更新并重启
    green "PCI直通配置完成，请重启系统以生效。"
}

# 移除PVE订阅提示
remove_subscription_notice() {
    echo "正在移除PVE订阅提示..."
    sed -i.bak "s|if (data.status !== 'Active')|if (false)|g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
    green "已成功移除订阅提示！"
}

# Git操作
git_operations() {
    read -p "请输入Git提交信息: " commit_msg
    git add .
    git commit -m "$commit_msg"
    git push
    green "Git提交并推送完成！"
}

# 生成SSH密钥
generate_ssh_key() {
    read -p "请输入您的邮箱地址（用于SSH密钥注释）: " email
    ssh-keygen -t rsa -b 4096 -C "$email"
    green "SSH密钥生成完成。"
}

# 配置SSH Agent并添加密钥
configure_ssh_agent() {
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
    green "SSH Agent配置完成，私钥已添加。"
}

# 显示公钥
view_ssh_pubkey() {
    if [ -f ~/.ssh/id_rsa.pub ]; then
        cyan "以下是您的公钥:"
        cat ~/.ssh/id_rsa.pub
    else
        red "公钥文件不存在，请先生成密钥。"
    fi
}

# 测试与GitHub的连接
test_github_connection() {
    ssh -T git@github.com
    if [ $? -eq 1 ]; then
        green "成功连接到GitHub！"
    else
        red "连接GitHub失败，请检查SSH配置。"
    fi
}

# 显示菜单
show_menu() {
  echo "=============================="
  echo " PVE及SSH管理工具"
  echo "=============================="
  echo "1. 安装并配置VIM"
  echo "2. 创建虚拟机 (VM)"
  echo "3. 创建LXC容器"
  echo "4. 查看网络配置"
  echo "5. 配置PCI硬件直通"
  echo "6. 移除PVE订阅提示"
  echo "7. Git操作 (add, commit, push)"
  echo "8. 生成SSH密钥"
  echo "9. 配置SSH Agent并添加密钥"
  echo "10. 查看SSH公钥"
  echo "11. 测试连接GitHub"
  echo "12. 退出"
  echo "=============================="
}

# 主程序
while true; do
  show_menu
  read -p "请选择一个选项 [1-12]: " choice
  case $choice in
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
      setup_pci_passthrough
      ;;
    6)
      remove_subscription_notice
      ;;
    7)
      git_operations
      ;;
    8)
      generate_ssh_key
      ;;
    9)
      configure_ssh_agent
      ;;
    10)
      view_ssh_pubkey
      ;;
    11)
      test_github_connection
      ;;
    12)
      echo "退出脚本"
      exit 0
      ;;
    *)
      red "无效的选项，请重新选择"
      ;;
  esac
done
