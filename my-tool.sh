#!/bin/bash

# 显示菜单
function show_menu() {
    echo "请选择一个操作："
    echo "1) 启动 Docker Compose 服务 (docker compose up -d)"
    echo "2) 停止 Docker Compose 服务 (docker compose down)"
    echo "3) 查看 Docker Compose 服务状态 (docker compose ps)"
    echo "4) 构建 Docker Compose 服务 (docker compose build)"
    echo "5) 查看 Docker Compose 日志 (docker compose logs)"
    echo "6) 更新系统 (sudo apt-get update && sudo apt-get upgrade)"
    echo "7) 查看磁盘使用情况 (df -h)"
    echo "8) 查看内存使用情况 (free -h)"
    echo "9) 监控系统资源 (htop)"
    echo "10) 退出"
}

# 执行命令
function execute_command() {
    case $1 in
        1)
            echo "启动 Docker Compose 服务..."
            docker compose up -d
            ;;
        2)
            echo "停止 Docker Compose 服务..."
            docker compose down
            ;;
        3)
            echo "查看 Docker Compose 服务状态..."
            docker compose ps
            ;;
        4)
            echo "构建 Docker Compose 服务..."
            docker compose build
            ;;
        5)
            echo "查看 Docker Compose 日志..."
            docker compose logs
            ;;
        6)
            echo "更新系统..."
            sudo apt-get update && sudo apt-get upgrade
            ;;
        7)
            echo "查看磁盘使用情况..."
            df -h
            ;;
        8)
            echo "查看内存使用情况..."
            free -h
            ;;
        9)
            echo "监控系统资源..."
            htop
            ;;
        10)
            echo "退出..."
            exit 0
            ;;
        *)
            echo "无效的选择！"
            ;;
    esac
}

# 循环显示菜单
while true; do
    show_menu
    read -p "请输入你的选择: " choice
    execute_command $choice
done
