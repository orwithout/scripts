#!/bin/bash
export LC_ALL=en_US.UTF-8

func_print_help() {
    echo "#[LATENCY-SEE]-ver.202206013-by-haif.fistbump20210603"
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "用例: "
    echo "./latencysee.sh   -k all     #中止所有本脚本已运行的实例"
    echo "./latencysee.sh   ssh-tcp:qq.com:80      #ssh测试tcp端口延时 对某些服务延时会增加 (推荐nping模式)"
    echo "./latencysee.sh   nping-tcp:ali1.fsbm.cc:19765    #使用nping测试ali1.fsbm.cc的tcp端口19765 如果要后台运行可增加参数 -t file"
    echo "./latencysee.sh   nping-tcp:ali1.fsbm.cc:19765  -t file   #使用nping测试ali1.fsbm.cc的tcp端口19765 如果要后台运行可增加参数 -t file"
    echo "./latencysee.sh   nping-udp:ali1.fsbm.cc:19765    #需依赖于对端udp服务会不会有回音 (推荐socat联机模式)"
    echo
    echo "联机模式: "
    echo "./latencysee.sh   socat-tcp:ali1.fsbm.cc:19765   #使用socat测试 ali1.fsbm.cc的tcp19765端口"
    echo "./latencysee.sh   socat-udp:ali1.fsbm.cc:19765   #udp"
    echo "*socat联机模式 需要先在对端主机上安装socat 并开启端口侦听 方法:"
    echo "    服务端执行 socat TCP-LISTEN:19765,fork PIPE  (客户端echo Hello |socat  -v - tcp:ali1.fsbm.cc:19765)"
    echo "    服务端执行 socat -T0.1 UDP-LISTEN:19765,fork PIPE    #udp必须指定-T否则会耗尽资源 (客户端echo Hello |socat  -v - udp:ali1.fsbm.cc:19765)"
    echo "    安装socat方法: 执行yum install -y socat 或ubuntu系统 执行apt install -y socat"
    echo "    或下载二进制http://www.dest-unreach.org/socat/download/socat-1.7.4.3.tar.gz 解压后命名为socat 放在与本脚本同目录中"
    echo
    echo "参数说明: "
    echo "-d  -d paping-tcp:qq.com:443(使用paping进程qq.com的tcp端口443)  -d socat-udp:ali1.fsbm.cc:19765(使用socat检测ali1.fsbm.cc的udp端口19765)"
    echo "    支持socat-tcp socat-udp nping-tcp nping-udp nping-icmp ssh-tcp ping-icmp arping-arp paping-tcp mtr-tcp mtr-udp mtr-icmp shell-udp shell-tcp"
    echo "    *如果-d 项参数在最前面则可以省略 -d"
    echo "-t  -t console屏幕上显示结果 -t file 结果保存到文件 (文件保存在本脚本同目录的./latencysee.sh.work/中"
    echo "-k  -k socat-tcp:ali1.fsbm.cc:80杀掉对应后台进程  -k all杀掉所有本脚本的进程   或-k show 显示本脚本所有在运行的进程"
    echo "-s  与-k show 完全相同"
    echo "-i  检测间隔 默认1秒"
    echo "-h  打印帮助"
    echo
    echo "更多用例: "
    echo "./latencysee.sh   nping-tcp:ali1.fsbm.cc:19765    #使用nping测试ali1.fsbm.cc的tcp端口19765 如果要后台运行可增加参数 -t file"
    echo "./latencysee.sh   nping-tcp:ali1.fsbm.cc:19765 -t file    #后台运行并将结果写到./latencysee.sh.work/nping-udp-ali1.fsbm.cc-19765.html"
    echo "./latencysee.sh   -s         #查看本脚本已运行的所有实例的进程"
    echo "./latencysee.sh   -k 123456  #中止进程组id为 123456 的实例"
    echo "./latencysee.sh   -k socat-tcp:ali1.fsbm.cc:19765    #中止检测目标为 socat-tcp:ali1.fsbm.cc:19765 的实例"
    echo "./latencysee.sh   ping-icmp:114.114.114.114      #ping延时记录"
    echo "./latencysee.sh   arping-arp:10.55.0.2               #arp协议ping内网ip 10.55.0.2"
    echo "./latencysee.sh   nping-icmp:ali1.fsbm.cc"
    echo "./latencysee.sh   shell-tcp:114.114.114.114:443      #使用bash原生提供的套接字检测tcp延时"
    echo "./latencysee.sh   mtr-tcp:114.114.114.114    #traceroute测试tcp延时(udp协议发包 icmp协议收包)"
    echo "./latencysee.sh   mtr-tcp:114.114.114.114    #traceroute测试udp延时(tcp协议发包 icmp协议收包)"
    echo "./latencysee.sh   mtr-icmp:114.114.114.114   #traceroute测试icmp延时(icmp协议发包 icmp协议收包)"
    echo "./latencysee.sh   paping-tcp:114.114.114.114:53  #paping测试tcp端口延时(需要下载paping二进制放到脚本同目录 命名为'paping') "
    echo "*nping安装方法rpm -vhU https://nmap.org/dist/nping-0.7.92-1.x86_64.rpm (对应卸载方法rpm -e nping.x86_64)"
    echo "*paping下载 https://code.google.com/archive/p/paping/downloads"

    echo
    echo "笔记："
    echo "tcp测试推荐 socat联机模式>nping>socat>ssh>shell>mtr>paping  调试发现paping目前版本cpu消耗很高"
    echo "udp测试推荐 socat联机模式>nping>socat>mtr>shell  shell-udp模式任何时候都是连通状态结果是否可靠还请自行判断"
    echo "icmp测试推荐 ping>nping>mtr  mtr做任何协议探测 都有可能只能探测去达目标链路上的某一个网关的延时"
    echo "arp测试只有 arping"
    echo "nping-icmp nping-tcp2 mtr-tcp 需要root权限"
    echo "----------------------------------------------------------------------------------------------------------------"
}


#--用于终止运行、抛出警告等-------------------------------------
EXECUTING="$(echo executing: "$0" "$*" |tr -s ' ')"
START_PWD="pwd: $(pwd)"
SHELL_NAME=$(basename "$0")
PGID_THIS="$$"
PGID_FILE="uuid-9fa64886-71ef-11ec-90d6-0242ac120003"
def_note() {  #$0 $1(提示的字符串)
    echo "${SHELL_NAME[2]} " "$1" >&2
}
def_warning() {  #$0 $1(提示的字符串)
    echo -e "\e[35m$SHELL_NAME Warning :\e[0m" "$1" >&2
}
def_exit() {  #def_exit $1(设置的$?值) $2(退出提示信息)
    echo -e "\e[31m$SHELL_NAME Error $1: 程序已退出\e[0m" "$2"  >&2
	echo "${FUNCNAME[*]}" >&2
    echo "$EXECUTING" >&2
    echo "$START_PWD" >&2
    [[ -f $PGID_FILE ]] && rm -f "$PGID_FILE" && def_warning "已清理pgid记录文件PGID_FILE"
    kill -TERM -- -"$PGID_THIS" 
    #def_warning "已杀死当前组进程 $PGID_THIS"
    #exit "$1"
}





#--参数获取 和初始化------------------------------------------------------------
if [[ -z $1 ]] ;then
    def_exit 1 "没有指定参数 (使用-h查看帮助)"
elif grep -qEw '^-.*' <<< "$1" ;then
    :
elif grep -qEwi 'show|s' <<< "$1" ;then
    KILL='show'
    shift
else
    DEST="$1"
    shift
fi

while getopts 'd:t:k:i:sh' OPT; do
	if grep -Ew '^-[dtkish]{1}' <<< "$OPTARG" ;then
		echo -e "\e[31m Error 1 : 程序已退出\e[0m" "参数格式错误 可能是指定了需要给值的参数你却没有给值 导致第二个参数的名$OPTARG被赋予成为了它的值"  >&2
		exit 1
	fi
    case $OPT in
		d)	DEST="$OPTARG";;
        t)  WRITETO="$OPTARG";;
        k)  KILL="$OPTARG";;
        i)  INTERVAL="$OPTARG";;
        s)  KILL="show";;
		h) 	func_print_help
			exit 0
			;;
		?)	echo "参数未能识别 : $OPTARG"
			exit 0
			;;
    esac
done

#参数初始化
PATH_WORK="$(realpath "$0").work"
#PATH_BASE=$(dirname "$PATH_WORK")
PGID_THIS="$$"
PGID_FILE="$PATH_WORK"/"${DEST//:/-}".pgid
PGID_FILE_TO_KILL="$PATH_WORK"/"${KILL//:/-}".pgid





# $KILL 不为空
# shellcheck disable=SC2009

func_kill() {
    if [[ -f $PGID_FILE_TO_KILL ]] ;then
        pgid_num=$(<"$PGID_FILE_TO_KILL") \
        &&rm -f "$PGID_FILE_TO_KILL" && def_warning "已清理pgid记录文件$PGID_FILE_TO_KILL"
        kill -TERM -- -"$pgid_num"   && def_warning "已杀死$PGID_FILE_TO_KILL 的进程组 $pgid_num"
    elif grep -qEwi 'all|a' <<< "$KILL" ;then
        pre_kill=$(basename "$0")
        pre_kill=$(ps x  -o "%r %c" |grep -Ew "$pre_kill" | grep -Ewo '[0-9]+' |sort -t: -u -k1,1)  #sort 去重
        rm -f "$PATH_WORK"/*.pgid && def_warning "已清理所有pgid记录文件"
        for i in $pre_kill ;do
            [[ $i = "$PGID_THIS" ]] && continue  #不要杀死自己了
            kill -TERM -- -"$i" && def_warning "已杀死进程组 $i"
        done
    elif grep -qEwi 'show|s' <<< "$KILL" ;then
        echo "---------------------------------------------------------------------------------------"
        echo "ps x -o \"%r %p %c %a\""        
        if [[ $(whoami) = 'root' ]] ;then
            ps x -o "%r %p %c %a" |grep -Ei "pid|sleep|$(basename "$0")"
        else
            ps x -o "%r %p %c %a"
        fi
        echo
        echo "组pid记录文件 :"
        ls -l "$PATH_WORK"/*.pgid
        echo
        echo "---------------------------------------------------------------------------------------"
    elif grep -q '^[[:digit:]]*$' <<< "$KILL" ;then   #是个数字
        kill -TERM -- -"$KILL" && def_warning "已杀死进程组 $KILL" \
        && grep -rw "$KILL" "$PATH_WORK" |cut -d: -f1 |xargs rm -f  #删除含有记录此 进程组id的文件
    else
        def_exit 2 "-k 的参数值无法识别 $KILL 或找不到对应pgid(进程组id)的记录文件$PGID_FILE_TO_KILL"
    fi
}


#func_trap_def() {
#    echo "asdf"
#    [[ -f $PGID_FILE ]] && rm -f "$PGID_FILE"
#    kill -TERM -- -"$PGID_THIS"
#}
#trap  func_trap_def SIGINT    #如果程序退出 定义扫尾工作 以避免后面会使用的后台进程不会正常停止   #如果有后台进程 貌似不支持






#--用于实现各种检测方式---------------------------------------------------------------------------------
func_vsudo_init() {
    if [[ $(whoami)$(sudo -a whoami 2>&1) =~ "root" ]] ;then
        vSUDO="sudo -a"
    else
        def_exit 3 "$DEST模式必须要root权限 或者sudo的免密权限"
    fi
}

func_pin_init() {
    [[ $DEST1 =~ "icmp" || $DEST1 = 'ping' ]] &&LOGGING_func='func_pingicmp'
    echo "(检测方法 ping $1 -c $JUDGES_TOTAL)"
}
func_pingicmp(){  #$1:目标主机地址  $2:端口    #返回$LOSS_MARK表示丢包  或一个数字 表示延时的毫秒数
    result_ping=$(ping "$1" -c "$JUDGES_TOTAL" 2>&1 |tail -n3) ||def_exit 4 "ping $1 -c $JUDGES_TOTAL 获取数据失败"
    ok_ping=$(echo "$result_ping" |grep -oiE "[0-9]+\\s*received" |grep -oiE "[0-9]+")
    if [[ $ok_ping -lt $JUDGES_OK ]] ;then
        FUNC_RETURNED="$LOSS_MARK"
    else
        FUNC_RETURNED=$(echo "$result_ping" |grep -oE "=\\s+[0-9\.]+/[0-9\.]+" |grep -oE "/[0-9]+." |grep -oE "[0-9]+")
    fi
}

func_arp_init() {
    if socat 2>&1 |grep -qEw 'command not found' ;then
        def_exit 3 "请先安装arping nping 方法(centos) yum install -y arping 或(ubuntu) apt install -y arping"
    fi
    [[ $DEST1 =~ arp.*arp || $DEST1 = 'arping' ]] && LOGGING_func='func_arping'
    echo "(检测方法 arping $1 -c $JUDGES_TOTAL)"
}
func_arping(){  # $1:目标主机 $2:端口号   #返回$LOSS_MARK表示丢包  或一个数字 表示延时的毫秒数
    (( tmp_arping=JUDGES_TOTAL+2 ))
    result_arping=$(arping "$1" -c "$JUDGES_TOTAL" 2>&1 |tail -n$tmp_arping)
    ok_arping=$(echo "$result_arping" |grep -Eio "Received\\s*[0-9]+" |grep -Eo "[0-9]+")
    if [[ $ok_arping -lt $JUDGES_OK ]] ;then
        FUNC_RETURNED="$LOSS_MARK"
        return
    fi

    tmp_arping=$(echo "$result_arping" |grep -Ewo '[\.0-9]+ms' |tr -d 'ms')
    result_arping=0
    for i in $tmp_arping ;do
        result_arping=$(echo " $result_arping  $i" |gawk '{printf("%i\n",$1+$2)}')
    done
    FUNC_RETURNED="$(echo "$result_arping $ok_arping" |gawk '{printf("%i\n",($1/$2))}')"
}

func_ssh_init() {
    [[ $DEST1 =~ "tcp" || $DEST1 = 'ssh' ]] && LOGGING_func='func_sshtcp'
    echo "(检测方法 time timeout 8 ssh -oBatchMode=yes -oStrictHostKeyChecking=no 'uuid-9fa64886-71ef-11ec-90d6-0242ac120003'@$1 -p$2 -v  对某些服务延时会增加)"  #https://www.openssh.com/manual.html
}
func_sshtcp() {  #$1:目标主机地址  $2:端口    #返回$LOSS_MARK表示丢包  或一个数字 表示延时的毫秒数
    ok_sshping=0
    result_sshping=0
    for ((i=1;i<="$JUDGES_TOTAL";i++)) ;do    #测试$JUDGES_TOTAL次，以获取延时平均值和丢包率
        tmp_sshping=$( (time timeout 8 ssh -oBatchMode=yes -oStrictHostKeyChecking=no 'uuid-9fa64886-71ef-11ec-90d6-0242ac120003'@"$1" -p"$2" -v) 2>&1)
        if [[ "$tmp_sshping" =~ "established" ]] ;then
            tmp_sshping=$(echo "$tmp_sshping" |gawk -F"[\t ms]" '/^real.*[0-9]+m[0-9]+.*s$/{print $3}')
            result_sshping=$(echo "$result_sshping $tmp_sshping" |gawk '{printf("%.3f\n",$1+$2)}')
            ((ok_sshping+=1))
        fi
    done
    #((tmp_sshping=JUDGES_TOTAL-ok_sshping))
    if [[ $ok_sshping -lt $JUDGES_OK ]] ;then
        FUNC_RETURNED="$LOSS_MARK"
    else
        FUNC_RETURNED=$(echo "$result_sshping $ok_sshping" |gawk '{printf("%i\n",1000*$1/$2/2-2)}')  #修正 -2
    fi
    
}

func_she_init() {
    SHELL_type=''
    SHELL_type=$(grep -Eo 'udp|tcp' <<< "$DEST1")
    LOGGING_func='func_shell'
    echo "(检测方法 time timeout 8 bash -c \"</dev/$SHELL_type/$1/$2\" ;echo \$?)"  #https://stackoverflow.com/questions/4922943/test-if-remote-tcp-port-is-open-from-a-shell-script
}
func_shell() {  #$1:目标主机地址  $2:端口    #返回$LOSS_MARK表示丢包  或一个数字 表示延时的毫秒数
    ok_shell=0
    result_shell=0
    for ((i=1;i<="$JUDGES_TOTAL";i++)) ;do    #测试$JUDGES_TOTAL次，以获取延时平均值和丢包率
        tmp_shell=$( (time timeout 8 bash -c "</dev/$SHELL_type/$1/$2" ;echo $?) 2>&1)
        if [[ $(echo "$tmp_shell" |tail -n1 |grep -E '[0-9]+') = 0 ]] ;then  #返回了0 说明端口是连通
            tmp_shell=$(echo "$tmp_shell" |gawk -F"[\t ms]" '/^real.*[0-9]+m[0-9]+.*s$/{print $3}')
            result_shell=$(echo "$result_shell $tmp_shell" |gawk '{printf("%.3f\n",$1+$2)}')
            ((ok_shell+=1))
        fi
    done
    if [[ $ok_shell -lt $JUDGES_OK ]] ;then
        FUNC_RETURNED="$LOSS_MARK"
    else
        FUNC_RETURNED=$(echo "$result_shell $ok_shell" |gawk '{printf("%i\n",1000*$1/$2/2)}')  #修正 -2
    fi
}

func_mtr_init(){  #$1:测试类型 $2:主机地址  #初始化 MTR_maxTTL MTR_type MTR_sudo
    if traceroute 2>&1 |grep -qEw 'command not found' ;then
        def_exit 3 "没有安装traceroute命令 请使用 yum install traceroute 或 apt install traceroute 进行安装"
    fi
    MTR_maxTTL=$(traceroute "$DEST2" -q"$JUDGES_TOTAL" -w2 -n)
    MTR_maxTTL=$(echo "$MTR_maxTTL" |grep -Eo "[0-9]{1,2}.*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+.*" |tail -1 |tr ' ' '\t' |cut -f1)
    MTR_type=''
    if [[ $DEST1 =~ 'udp' ]] ;then
        vSUDO=''
    elif [[ $DEST1 =~ 'tcp' ]] ;then
        MTR_type='-T'
        vSUDO=$(func_vSUDO_init)
    elif [[ $DEST1 =~ 'icmp' ]] ;then
        MTR_type='-I'
        vSUDO=''
    else
        def_exit 3 "mtr检测类型不支持$DEST1 (支持tcp udp icmp)"
    fi
    LOGGING_func='func_mtr'
    echo "(检测方法 $vSUDO traceroute $1 -q$JUDGES_TOTAL -w2 -n -m$MTR_maxTTL $MTR_type  mtr模式的回程都是icmp协议)"
}
func_mtr(){  #$1:目标主机地址    #返回$LOSS_MARK表示丢包  或一个数字 表示延时的毫秒数
    #echo "$2 traceroute $1 -q$JUDGES_TOTAL -w2 -n -m$MTR_maxTTL $3"  #debug
    result_mtr=$(traceroute "$1" -q"$JUDGES_TOTAL" -w2 -n -m"$MTR_maxTTL" $MTR_type 2>&1)  # $3 可能为空的变量 不要加双引号
    #echo "$tmp_inmtrudp" >&2  #debug
    #echo "$1" >&2      #debug
    result_mtr=$(echo "$result_mtr" |grep -E "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" |tail -1 |grep -Eo ' [0-9]+\.[0-9]+ ')
    ok_mtr=$(echo "$result_mtr" |wc -l)
    if [[ $ok_mtr -lt $JUDGES_OK ]] ;then
        FUNC_RETURNED="$LOSS_MARK"
    else
        result_mtr_i=0
        for i in $result_mtr ;do
            result_mtr_i=$(echo "$result_mtr_i $i" |gawk '{printf("%.3f\n",$1+$2)}')
        done
        FUNC_RETURNED=$(echo "$result_mtr_i $ok_mtr" |gawk '{printf("%i\n",$1/$2)}')
    fi
}

func_soc_init(){   #$1:测试类型 $2:目标主机 $3:端口    #初始化SOCAT_path SOCAT_type
    if [[ -f ./socat ]] ;then
        chmod +x ./socat ||def_exit 3 "检测到./socat 但修改可执行失败"
        SOCAT_path='./socat'
    elif socat 2>&1 |grep -qEw 'command not found' ;then
        def_exit 3 "没有安装socat wget下载 http://www.dest-unreach.org/socat/download/socat-1.7.4.3.tar.gz 解压后命名为socat 放在与本脚本同目录中\n或使用yum ap安装"
    else
        SOCAT_path='socat'
    fi
    
    SOCAT_type=''
    if [[ $DEST1 =~ 'udp' ]] ;then
        SOCAT_type='udp'
    elif [[ $DEST1 =~ 'tcp' ]] ;then
        SOCAT_type='tcp'
    else
        def_exit 3 "socat检测类型不支持$DEST1 (支持tcp 或udp)"
    fi
    LOGGING_func='func_socat'
    echo "(检测方法 echo 'h'| $SOCAT_path -v - $SOCAT_type:$1:$2 )"
    echo "(对端机开启端口侦听方法(可选): socat -T0.1 $SOCAT_type-LISTEN:$2,fork PIPE  或(tcp): socat TCP-LISTEN:$2,fork PIPE)"
}
func_socat(){  # $1:目标主机 $2:端口号   #返回$LOSS_MARK表示丢包  或一个数字 表示延时的毫秒数
    #服务端     socat UDP-LISTEN:19765,fork PIPE
    #客户端     echo Hello |socat  -v - udp:ali1.fsbm.cc:19765
    #客户端     echo Hello |socat  -v - tcp:ali1.fsbm.cc:19765
    ok_socat=0
    result_socat=0
    for ((i=1;i<="$JUDGES_TOTAL";i++)) ;do    #测试$JUDGES_TOTAL次，以获取延时平均值和丢包率
        tmp_socat=$(echo 'h' |$SOCAT_path -v - "$SOCAT_type":"$1":"$2" 2>&1) #发个h过去 
        #echo "$4 -v - $3:$1:$2  ====$tmp_socat===="  #debug
        if [[ "$tmp_socat" =~ '<' ]] ;then  #表示收到了回信
            tmp_socat=$(echo "$tmp_socat" |grep -Eo '[0-9]{4}.*[0-9]{6}')

            tmp_socat_1=$(echo "$tmp_socat" |sed -n '1p')
            tmp_socat_2=$(echo "$tmp_socat" |sed -n '2p')
            tmp_socat=$(echo "$(date -d "$tmp_socat_1" +%s) $(date -d "$tmp_socat_2" +%s)" |gawk '{printf("%i\n",($2-$1)*1000000)}')
            tmp_socat=$(echo "$(date -d "$tmp_socat_1" +%6N) $(date -d "$tmp_socat_2" +%6N) $tmp_socat" |gawk '{printf("%i\n",($3+$2-$1)/1000)}')

            (( result_socat = result_socat + tmp_socat ))
            ((ok_socat+=1))
        fi
    done
    if [[ $ok_socat -lt $JUDGES_OK ]] ;then
        FUNC_RETURNED="$LOSS_MARK"
    else
        FUNC_RETURNED="$(echo "$result_socat $ok_socat" |gawk '{printf("%i\n",($1/$2))}')"
    fi
}

func_pap_init() {
    LOGGING_func='func_papingtcp'
    echo "(检测方法 ./paping --nocolor $1 -p $2 -c $JUDGES_TOTAL -t 2000  发现paping对cpu占用偏高)"
}
func_papingtcp(){  #$1:目标主机地址  $2:端口    #返回$LOSS_MARK表示丢包  或一个数字 表示延时的毫秒数
    result_paping=$(./paping --nocolor "$1" -p "$2" -c "$JUDGES_TOTAL" -t 2000 2>&1 |tail -n 5)
    ok_paping=$(echo "$result_paping" |grep -oiE "Connected.*=.*," |cut -d= -f2 |cut -d, -f1)
    if [[ $ok_paping -lt $JUDGES_OK ]] ;then
        FUNC_RETURNED="$LOSS_MARK"
    else
        FUNC_RETURNED=$(echo "$result_paping" |grep -oiE "Average.*=.*ms" |grep -oE "[0-9]+\.[0-9]+ms" |cut -d. -f1)
    fi
}

func_npi_init() {
    #rpm -vhU https://nmap.org/dist/nping-0.7.92-1.x86_64.rpm
    #rpm -e nping.x86_64
    if socat 2>&1 |grep -qEw 'command not found' ;then
        def_exit 3 "请先安装nping 方法rpm -vhU https://nmap.org/dist/nping-0.7.92-1.x86_64.rpm (对应卸载方法rpm -e nping.x86_64)"
    fi

    NPING_type=''
    NPING_port='-p '"$DEST3"
    vSUDO=''
    NPING_grep='Rcvd'
    if [[ $DEST1 =~ 'tcp2' ]] ;then
        NPING_type='--tcp'
        vSUDO=$(func_vSUDO_init)
        NPING_grep='Successful.*connections'
    elif  [[ $DEST1 =~ 'icmp' ]] ;then
        NPING_type='--icmp'
        NPING_port=''
        vSUDO=$(func_vSUDO_init)
    elif [[ $DEST1 =~ 'tcp' ]] ;then
        NPING_type='--tcp-connect'
        NPING_grep='Successful.*connections'
    elif [[ $DEST1 =~ 'udp' ]] ;then
        NPING_type='--udp'
    else
        def_exit 3 "nping检测协议目前不支持$DEST1 (支持tcp udp icmp)"
    fi

    
    LOGGING_func='func_nping'
    echo "(检测方法 $vSUDO nping $NPING_type $1 $NPING_port -c $JUDGES_TOTAL --rate 64)"  #https://nmap.org/book/nping-man.html
}
func_nping() {  # $1:目标主机   #返回$LOSS_MARK表示丢包  或一个数字 表示延时的毫秒数
    #echo "$NPING_sudo nping $NPING_type $1 $NPING_port -c $JUDGES_TOTAL"
    result_nping=$(nping "$NPING_type" "$1" $NPING_port -c "$JUDGES_TOTAL" --rate 64 2>&1 |tail -n3) #NPING_sudo 和NPING_port 不能打双引号 因为它可能为空
    ok_nping=$(echo "$result_nping" |grep -Eio "$NPING_grep:\\s*[0-9]+" |grep -Eo "[0-9]+")
    if [[ $ok_nping -lt $JUDGES_OK ]] ;then
        FUNC_RETURNED="$LOSS_MARK"
    else
        FUNC_RETURNED=$(echo "$result_nping" |grep -Eio "Avg\\s*rtt:\\s*[0-9]+" |grep -Eo "[0-9]+")
    fi
}





#--用于写下记录--------------------------------------------------------------------
func_loggong_init() {
    #初始化需要的函数、和检测功能是否已定义
    LOGGING_func=uuid-9fa64886-71ef-11ec-90d6-0242ac120003
    func_"${DEST1:0:3}"_init  "$DEST2" "$DEST3"
    declare -F $LOGGING_func >/dev/null || def_exit 3 "指定的检测方法$DEST1 未定义 请检测参数给的是否正确 (使用-h 获取帮助)"
    declare -F "func_logging_to_$WRITETO" >/dev/null || def_exit 2 "指定的-t $WRITETO未定义 目前只支持-t console(输出到控制台) -t file输出记录到文件 (使用-h 获取帮助"
}

func_logging_date() { # $1:回车换行方式 $2:检测方式:主机地址:端口    #异步 每到整点时间 输出一条日期-时间信息字符串
    while true ;do
        minute_inloggingdate=$(date +%M |gawk '{printf("%i\n",$1)}')
        printf '%b' "$1$(date "+%Y-%m-%d-%H:%M:%S")-$2-单位 ms [组进程ID $PGID_THIS]"
        (( minute_inloggingdate = (60-minute_inloggingdate)*60 ))
        sleep $minute_inloggingdate
    done
}

func_logging_time() {
    sec_inloggingtime=$(date +%S |gawk '{printf("%i\n",$1)}')
    while  true  ;do
        (( sec_inloggingtime2 = TIME_TAG_NEXT - sec_inloggingtime ))
        sleep $sec_inloggingtime2
        sec_inloggingtime=$(date +%S)
        printf '%b' "$1$(date +%M):$sec_inloggingtime"
        sec_inloggingtime=$(date +%S |gawk '{printf("%i\n",$1)}')
    done
}

func_dns() {  # $1:主机地址
    #如果是域名 解析为ip
    if ! grep -qEw '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$DEST2" ;then  #将域名解析为ip
        name_host="$(ping "$DEST2" -c1 2>&1)"
        date_dns_info="当前时间$(date "+%Y-%m-%d-%H:%M:%S") 域名$DEST2解析"
        if grep -qEi 'Name.*not known' <<< "$name_host" ;then
            returned_DNS_toconsole="\033[31m$date_dns_info失败!!!\033[0m"  #m91 血色
            returned_DNS_tofile="<font color=\"#FF0000\">$date_dns_info失败!!!</font>"  #m91 血色
        else
            DEST2="$(echo "$name_host" |grep -Ewim1 ping |grep -Ewo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |tail -n1)"
            returned_DNS_toconsole="\033[34m$date_dns_info=$DEST2\033[0m"
            returned_DNS_tofile="<font color=\"#0000FF\">$date_dns_info=$DEST2</font>"
        fi
    fi
}

func_logging_to_console() {  # $1:检测类型 $2:目标主机地址 $3:端口 $4:记录方式
    #初始化
    func_loggong_init "$DEST2" "$DEST3"
    echo -n "如果发现异常中止方法./$(basename "$0") -k $PGID_THIS  或kill -TERM -- -$PGID_THIS"  
    
    #DNS tag
    func_dns
    echo -en "\n$returned_DNS_toconsole"

    #时间tag
    func_logging_date '\n' "$DEST1:$DEST2:$DEST3" &
    whoami >/dev/null  #没有什么作用，仅仅是为了起个延时作用
    func_logging_time '\n' &
    
    #死循环记录延时 里面要注重性能
    while true ;do
        $vSUDO $LOGGING_func "$DEST2" "$DEST3"
        if ! grep -q '^[[:digit:]]*$' <<< "$FUNC_RETURNED" ;then
            echo -en "\033[31m $FUNC_RETURNED\033[0m"  #m91 血色
        elif ((FUNC_RETURNED < 5)) ;then
            echo -en "\033[34m $FUNC_RETURNED\033[0m"  #m94 蓝色
        elif ((FUNC_RETURNED < 13)) ;then
            echo -en "\033[94m $FUNC_RETURNED\033[0m"  #m34 蓝色
        elif ((FUNC_RETURNED < 21)) ;then
            echo -en "\033[36m $FUNC_RETURNED\033[0m"  #m36 青色
        elif ((FUNC_RETURNED < 34)) ;then
            echo -en "\033[32m $FUNC_RETURNED\033[0m"  #m32 绿色
        elif ((FUNC_RETURNED < 55)) ;then
            echo -en "\033[90m $FUNC_RETURNED\033[0m"  #m90 灰色
        elif ((FUNC_RETURNED < 89)) ;then
            echo -en "\033[33m $FUNC_RETURNED\033[0m"  #m33 黄色
        elif ((FUNC_RETURNED < 144)) ;then
            echo -en "\033[35m $FUNC_RETURNED\033[0m"  #m35 品红
        elif ((FUNC_RETURNED < 233)) ;then
            echo -en "\033[95m $FUNC_RETURNED\033[0m"  #m95 猩红
        else
            echo -en "\033[91m $FUNC_RETURNED\033[0m"  #m31 红色
        fi
        if [[ $FUNC_RETURNED =~ $LOSS_MARK ]] ;then
            sleep "$LOSS_NEXT"
        else
            sleep "$OK_NEXT"
        fi
    done
}

func_logging_to_file() {
    #log文件路径
    tmp_inloggingfile=$DEST2/$(date +%Y-%m)_$(hostname -I |tr -d ' ').$(whoami)__"$DEST1"__"$DEST2""${DEST3:+_$DEST3}".html
    if [[ -d /opt/files/log/ && $(hostname -I) =~ 10\.4\.100\.19 ]] ;then
        logging_html=/opt/files/log/"$tmp_inloggingfile"  #日志记录文件
        echo "日志文件下载 http://f.fsbm.cc/log/$tmp_inloggingfile"
    else
        logging_html="$PATH_WORK"/"$tmp_inloggingfile"
        echo "日志文件所在 $PATH_WORK/$tmp_inloggingfile"
    fi
    #log文件初始化
    tmp_inloggingtofile="$(dirname "$logging_html")"
    if [[ ! -d $tmp_inloggingtofile ]] ;then
        mkdir -p "$tmp_inloggingtofile" ||def_exit 3 "创建日志目录$tmp_inloggingtofile"
    else
        [[ -w $tmp_inloggingtofile ]] || def_exit 3 "要记录的日志的文件路径不具有可写权限$tmp_inloggingtofile"
    fi
    #pgid文件路径初始化
    tmp_inloggingtofile="$(dirname "$PGID_FILE")"
    if [[ ! -d $tmp_inloggingtofile ]] ;then
        mkdir -p "$tmp_inloggingtofile" ||def_exit 3 "创建pgid(组进程id)文件保存目录失败$tmp_inloggingtofile"
    else
        [[ -w $tmp_inloggingtofile ]] || def_exit 3 "要保存pgid(组进程id)的文件路径不具有可写权限$tmp_inloggingtofile"
    fi

    #初始化
    func_loggong_init "$DEST2" "$DEST3" &>> "$logging_html"
    echo "开始后台运行 中止方法./$(basename "$0") -k $DEST  或./$(basename "$0") -k all (中止所有本脚本实例)"
    echo "$$ " > "$PGID_FILE"  

    {
        #DNS tag
        func_dns
        echo "<br />$returned_DNS_tofile"
        #插入时间标记
        func_logging_date '<br />' "$DEST1:$DEST2:$DEST3" &
        whoami >/dev/null  #没有什么作用，仅仅是为了起个延时作用
        func_logging_time '<br />' &

        #记录延时
        while true ;do
            $vSUDO $LOGGING_func "$DEST2" "$DEST3"
            if ! grep -q '^[[:digit:]]*$' <<< "$FUNC_RETURNED" ;then
                echo "<font color=\"#FF0000\"> $FUNC_RETURNED</font>"  #血色
            elif ((FUNC_RETURNED < 5)) ;then
                echo "<font color=\"#0000FF\"> $FUNC_RETURNED</font>"  #蓝色
            elif ((FUNC_RETURNED < 13)) ;then
                echo "<font color=\"#000080\"> $FUNC_RETURNED</font>"  #亮蓝
            elif ((FUNC_RETURNED < 21)) ;then
                echo "<font color=\"#008080\"> $FUNC_RETURNED</font>"  #青色
            elif ((FUNC_RETURNED < 34)) ;then
                echo "<font color=\"#008000\"> $FUNC_RETURNED</font>"  #绿色
            elif ((FUNC_RETURNED < 55)) ;then
                echo "<font color=\"#808080\"> $FUNC_RETURNED</font>"  #灰色
            elif ((FUNC_RETURNED < 89)) ;then
                echo "<font color=\"#808000\"> $FUNC_RETURNED</font>"  #黄色
            elif ((FUNC_RETURNED < 144)) ;then
                echo "<font color=\"#800080\"> $FUNC_RETURNED</font>"  #品红
            elif ((FUNC_RETURNED < 233)) ;then
                echo "<font color=\"#FF00FF\"> $FUNC_RETURNED</font>"  #猩红
            else
                echo "<font color=\"#800000\"> $FUNC_RETURNED</font>"  #红色
            fi

            if [[ $FUNC_RETURNED =~ $LOSS_MARK ]] ;then
                sleep "$LOSS_NEXT"
            else
                sleep "$OK_NEXT"
            fi
        done 
    }  &>> "$logging_html" &
}


#用于进一步的参数初始化
func_logging_main(){
    WRITETO=${WRITETO:-console}  #为空则等于console
    LOSS_MARK='X'
    JUDGES_TOTAL=1    #每论检测发多少次ping包
    JUDGES_OK=1     #收到多少个包 判定为是连通的 进而按收到的包数计算平均延时
    #OK_JUDGED='1/1'  #n/m格式 ,表示：每轮检测发m次ping包 ,如果收到了n~m个返回 ,则判定为检测ok ,否则判定本轮为loss
    OK_NEXT=${INTERVAL:-1}  #如果上一轮检测ok ,等待几秒做下一轮检测
    LOSS_NEXT=${INTERVAL:-1}  #如果上一轮检测不通 ,等待几秒做下一轮检测
    TIME_TAG_NEXT=60  #多久(秒)插入一次当前的时间 建议60的整数倍

    DEST1=${DEST%%:*}  #获取进程方式
    #DEST1=${DEST1//[![:alnum:]]/}  #删除非字母非数字的字符
    DEST2=${DEST#*:}  #获取检测目标主机
    DEST2=${DEST2%%:*}
    DEST3=${DEST##*:}  #获取进程目标端口
    if [[ $DEST3 = "$DEST2" ]] ;then
        if [[ $DEST1 =~ tcp ]] ;then
            DEST3='80'
        elif [[ $DEST1 =~ udp ]] ;then
            DEST3='53'
        else
            DEST3=''
        fi
    fi
    func_logging_to_"$WRITETO"
}



if [[ -n $KILL ]] ;then
    func_kill
else
    func_logging_main
fi




