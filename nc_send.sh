#!/usr/bin/env bash


IS_DEBUG_PRINT=0 #是否打印 debug 信息

SERVER_URL=127.0.0.1 #服务器地址
SERVER_PORT=10000 #服务器 port
SERVER_PORT_RESULT=10001 #服务器返回 port
THE_KEY=xxyyzzisxyz #加签验签 key


#debug 信息打印输出
function debugPrint() {
    if [[ ${IS_DEBUG_PRINT} -gt 0 ]]; then
        printStr=$1;
        echo "----debug: $printStr";
    fi
}

function handle() {
    cmd=$1;
    debugPrint "cmd = $cmd";
    timestamp=$(date +%s)
    debugPrint "timestamp = $timestamp";
    signOri="$cmd$timestamp$THE_KEY";
    debugPrint "signOri = $signOri";
    sign=$(echo -n ${signOri} | md5 | cut -d ' ' -f1)
    debugPrint "sign = $sign";

    msg="$cmd,$timestamp,$sign";
    echo "要发送的信息：$msg";
    echo ${msg} | nc ${SERVER_URL} ${SERVER_PORT};

    #轮询服务器，直到服务器返回数据
    num=100;
    while [[ ${num} -gt 0 ]]; do
        $(sleep 0.1);
        num=$((100-1));
        resultMsg=$(nc ${SERVER_URL} ${SERVER_PORT_RESULT});
        if [[ -n ${resultMsg} ]]; then
            num=0;
        fi
    done

    echo "";
    echo "服务端返回数据：$resultMsg";
    echo ""
}


CMD="test";
#根据参数判断是否开启 debug 模式
if [[ $# != 0 ]]; then
    for theArg in $@ ; do
        if [[ "-d" == ${theArg} ]]; then
            echo "开启 debug 模式"
            IS_DEBUG_PRINT=1;
        else
            CMD=${theArg}
        fi
    done
fi

handle ${CMD}