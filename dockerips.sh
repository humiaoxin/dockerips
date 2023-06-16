#!/bin/bash

# 函数：列出当前运行的容器信息
list_containers() {
    echo "正在列出运行中的容器："
    docker ps --format "table {{.Names}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}" | column -t -s $'\t'
}

# 函数：获取容器网络信息
get_container_network() {
    read -p "输入容器名称或ID（按回车键查看所有容器）：" container
    if [ -z "$container" ]; then
        containers=$(docker ps -q)
    else
        containers=$container
    fi

    for container in $containers
    do
        echo "获取容器网络信息：$container"
        docker inspect $container --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" | awk '{print "IP 地址:", $1}'
        echo "-------------------------------------"
    done
}

# 函数：获取容器挂载信息
get_container_mounts() {
    read -p "输入容器名称或ID（按回车键查看所有容器）：" container
    if [ -z "$container" ]; then
        containers=$(docker ps -q)
    else
        containers=$container
    fi

    for container in $containers
    do
        echo "获取容器挂载信息：$container"
        docker inspect $container --format "{{range .Mounts}}{{.Source}}:{{.Destination}} {{end}}" | column -t -s $':'
        echo "-------------------------------------"
    done
}

# 函数：查看容器资源使用情况
get_container_stats() {
    read -p "输入容器名称或ID（按回车键查看所有容器）：" container
    if [ -z "$container" ]; then
        containers=$(docker ps -q)
    else
        containers=$container
    fi

    for container in $containers
    do
        echo "获取容器资源使用情况：$container"
        docker stats $container --no-stream | awk '{print $2, $3, $4, $5, $6, $7, $8}' | column -t
        echo "-------------------------------------"
    done
}

# 函数：查看容器中的进程信息
get_container_processes() {
    read -p "输入容器名称或ID（按回车键查看所有容器）：" container
    if [ -z "$container" ]; then
        containers=$(docker ps -q)
    else
        containers=$container
    fi

    for container in $containers
    do
        echo "获取容器中的进程信息：$container"
        docker exec $container ps aux | column -t
        echo "-------------------------------------"
    done
}

# 函数：检测容器新增文件
check_container_new_files() {
    read -p "输入容器名称或ID（按回车键查看所有容器）：" container
    if [ -z "$container" ]; then
        containers=$(docker ps -q)
    else
        containers=$container
    fi

    for container in $containers
    do
        echo "检测容器新增文件：$container"
        docker diff $container | grep A | awk '$1 ~ /^[ACDR]/ {print $2}'
        echo "-------------------------------------"
    done
}

# 主菜单
while true
do
    echo "-------------------------------------"
    echo "Docker 容器入侵排查"
    echo "-------------------------------------"
    echo "1. 列出运行中的容器"
    echo "2. 获取容器网络信息"
    echo "3. 获取容器挂载信息"
    echo "4. 获取容器资源使用情况"
    echo "5. 获取容器中的进程信息"
    echo "6. 检测容器新增文件"
    echo "0. 退出"
    echo

    read -p "请输入选项：" option

    case $option in
        1)
            list_containers
            ;;
        2)
            get_container_network
            ;;
        3)
            get_container_mounts
            ;;
        4)
            get_container_stats
            ;;
        5)
            get_container_processes
            ;;
        6)
            check_container_new_files
            ;;
        0)
            echo "退出程序"
            exit 0
            ;;
        *)
            echo "无效的选项，请重新输入"
            ;;
    esac

    echo
done
