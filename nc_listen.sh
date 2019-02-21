#!/usr/bin/env bash


IS_DEBUG_PRINT=0 #是否打印 debug 信息

PORT_LISTENER=10000 #要监听的 port
PORT_LISTENER_RESULT=10001 #要监听返回的 port
THE_KEY=xxyyzzisxyz #加签验签 key
TIMESTAMP_VALID_INTERVAL=60 #时间戳有效时间（单位：秒）


#debug 信息打印输出
function debugPrint() {
    if [[ ${IS_DEBUG_PRINT} -gt 0 ]]; then
        printStr=$1;
        echo "----debug: $printStr";
    fi
}


#校验签名
function verifySign() {
    inputStr=$1;
    debugPrint "verify inputStr = $inputStr";
    arr=(${inputStr//,/ })

    cmd=${arr[0]};
    debugPrint "verify cmd = $cmd";
    timestamp=${arr[1]};
    debugPrint "verify timestamp = $timestamp";
    sign=${arr[2]};
    debugPrint "verify sign = $sign";

    signOri="$cmd$timestamp$THE_KEY";
    debugPrint "verify signOri = $signOri";
    theSign=$(echo -n ${signOri} | md5 | cut -d ' ' -f1)
    debugPrint "verify theSign = $theSign";

    if [[ ${theSign} == ${sign} ]]; then
        result=0;
        debugPrint "verify sign success";
    else
        result=1;
        debugPrint "verify sign fail";
    fi
    return ${result};
}

#校验时间戳
function verifyTimestamp() {
    timestamp=$1;
    debugPrint "verify timestamp = $timestamp";

    curTimestamp=$(date +%s)
    debugPrint "verify curTimestamp = $curTimestamp";

    value=$((curTimestamp-timestamp));
    debugPrint "verify curTimestamp-timestamp = $value";
    debugPrint "verify timestamp valid interval = $TIMESTAMP_VALID_INTERVAL";

    if [[ ${value} -lt ${TIMESTAMP_VALID_INTERVAL} ]]; then
        result=0;
        debugPrint "verify timestamp success";
    else
        result=1;
        debugPrint "verify timestamp fail";
    fi
    return ${result};
}

function handleCmd() {
    cmd=$1;
    debugPrint "handleCmd cmd = $cmd";

    result=0;
    case ${cmd} in
    "start")
        echo "handle start";
        ;;
    *)
        echo "handle nothing";
        ;;
    esac

    return ${result};
}


function handle() {
    echo "";
    echo "获取请求";
    inputStr=$1;
    echo "输入的字符串为：$inputStr";

    verifySign ${inputStr};
    isSignValid=$?;
    if [[ ${isSignValid} != 0 ]]; then
        echo "验签失败";
        return 1;
    fi
    echo "验签成功";

    inputArr=(${inputStr//,/ });
    cmd=${inputArr[0]};
    timestamp=${inputArr[1]};

    verifyTimestamp ${timestamp};
    isTimestampValid=$?;
    if [[ ${isTimestampValid} != 0 ]]; then
        echo "验证时间戳失败";
        return 1;
    fi
    echo "验证时间戳成功";

    handleCmd ${cmd};
    echo "ok" | nc -l ${PORT_LISTENER_RESULT};
}


#根据参数判断是否开启 debug 模式
if [[ $# != 0 ]]; then
    for theArg in $@ ; do
        if [[ "-d" == ${theArg} ]]; then
            echo "开启 debug 模式"
            IS_DEBUG_PRINT=1;
        fi
    done
fi

echo "服务启动，监听端口：$PORT_LISTENER";
#启动监听
nc -l ${PORT_LISTENER} -k | (while read i; do handle ${i}; done)