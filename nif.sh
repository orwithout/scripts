#!/bin/bash

print_code_structure(){
cat <<'EOF'
    #-----代码结构-----
    #1 版本、帮助、和一些全局设置
    #1.1 帮助与版本信息预定义
    #1.2 参数全为空时处理
    #1.3 劫持ctrl+c方法

    #2 参数解析、获取、与默认值设定
    #2.1 定义参数匹配规则
    #2.2 参数可用的表达方式(例如简写)的调校
    #2.3 参数检查(是否重复、和不可识别)
    #2.4 参数获取，版本、帮助、log、与运行时提醒信息输出。消耗两个参数（-h -v）
    #2.5 设置参数的默认值、额外的预处理等。消耗七个参数（p_addr p_ports p_epass p_ersu p_elso p_elsu p_tout）
    #2.6 设置-bump 和只有-w时自动指定的参数值。消耗一个参数p_bump
    #2.7 打印运行时提醒信息

    #3 设计本端的灵巧执行函数、处理参数对本端软件指定的动作
    #3.1 设计灵巧执行函数local_smart_exec。将对sudo、su -c、expect、ubuntu、debian、centos等环境信息的判断，进行包装解耦。消耗两个参数(p_lso p_lsu)
    #3.2 处理参数对本端软件指定的动作。消耗五个参数（p_le p_lp p_ln p_li p_lc）
    #3.2.1 定义退出函数，可在退出时做软件卸载
    #3.2.2 处理参数对本端expect指定的动作
    #3.2.3 处理参数对本端sshpass指定的动作
    #3.2.4 处理参数对本端nmap指定的动作
    #3.2.5 处理参数对本端iperf3指定的动作
    #3.2.6 处理参数对本端socat指定的动作

    #4 设计远端的灵巧执行函数、处理参数对远端软件指定的动作
    #4.1 设计灵巧执行函数remote_smart_exec。将对sudo、su -c、expect、ubuntu、debian、centos等环境信息的判断，进行包装解耦。消耗五个参数(p_sp p_user p_key p_pass p_rsu)
    #4.2 修订端口扫描的远端操作参数
    #4.3 处理参数对远端软件指定的动作。消耗四个参数（p_rn p_ri p_rc p_rf）
    #4.3.1 定义退出函数，可在退出时做软件卸载
    #4.3.2 处理参数对远端nmap指定的动作
    #4.3.3 处理参数对远端iperf3指定的动作
    #4.3.4 处理参数对远端socat指定的动作
    #4.3.5 处理参数对远端forward配置指定的动作

    #5 获取主机域名、ip等信息
    #5.1 获取远端主机使用的ip、域名、ping值
    #5.2 获取本端主机使用的dns、网关、和ip

    #6 软件的使用方法，和相关设置的开关方法。消耗三个参数（p_address p_count p_nif [nif_localop nif_remoteop nif_ports]）
    #6.1 定义socat、iperf3、forward于远端的服务开关函数
    #6.2 开启iperf3、socat服务
    #6.3 定义socat、iperf3、ssh于本端的使用方法函数
    #6.4 解析和实现端口扫描的所有方法
    #6.4.1 ssh扫描方法
    #6.4.2 nmap扫描方法(对部分ssh方法进行重写和覆盖)
    #6.4.3 socat方法
    #6.4.4 iperf3方法

    #7 调用处理方法或输出相关信息
    #7.1 调用端口检测方法并输出结果
    #7.2 主机信息结果输出

    #8 远程执行-exe参数命令。消耗一个参数p_exe
    #9 清场。消耗一个参数p_wait
    #10 收集的资料、笔记
EOF
}



#1 版本、帮助、和一些全局设置
#1.1 帮助与版本信息预定义
print_help(){
echo
cat <<'EOF'
nif.sh (network info shell)
ver:0.7.5.20211202
用于检测linux的[tcp/udp端口状态] [延时] [带宽] [路由追踪]
下载: wget https://github.com/orwithout/scripts/blob/main/nif.sh
快速使用: ① cd切换到下载目录 ;② 给与执行权限chmod +x ./nif.sh ;③ 执行./nif.sh -bump

--   1、结果展示
--   2、结果解说
--   3、参数说明
--   4、使用示例

1、结果展示
$ ./nif.sh 1.2.3.4 -u:ssh-user -p"ssh-password" -lso"local-sudo-passwd" -nic-ci:8085,8086  -lpu -lnu -lcu -liu -rcu -riu -w
---------------------------------------------------------------------------------------------
    (联机模式!运行如果中断,远端机可能会残留iptables规则,届时请查看./nif.sh.log.92c562a0-3ddd-11ec-9bbc-0242ac130002........
       port   state                service                  latency              bandwidth(bps)
   8085/tcp   open                 unknown/iperf3           1ms(loss0/2)         ↑17.0G/↓19.8G
   8086/tcp   open                 d-s-n/iperf3             1ms(loss0/2)         ↑16.9G/↓20.3G
   8085/udp   open                 unknown/socat            1ms(loss0/2)         ↑3.24G(loss0%)±0.000ms/↓2.31G(loss0%)±0.000ms
   8086/udp   open                 d-s-n/socat              1ms(loss0/2)         ↑2.96G(loss0%)±0.000ms/↓2.23G(loss0%)±0.000ms
 remote-sys   lan-nic   lan-ip           lan-gateway      domain             external-ip      -a                 ping
     centos   eth0      1.2.3.4          1.2.3.1          -                  1.2.3.4          1.2.3.4            0.127ms
  local-sys   lan-nic   lan-ip           lan-gateway      domain             dns-serv
     debian   ens160    2.3.4.5          2.3.4.1          -                  2.3.4.1

Nmap scan report for 1.2.3.4
Host is up (0.00033s latency).
MAC Address: 00:50:56:8B:73:F3 (citrix)
TRACEROUTE
HOP RTT     ADDRESS
1   0.33 ms 2.3.4.1
2   0.66 ms 1.2.3.4
------------------------------------------------

2、结果说明
    对端口的测试结果,会返回5个项 :port  state  service  latency  bandwidth
    -   :表示未作检测
    port :端口号,如 1234/tcp  1234/udp
    state :对端口号检测的状态结果,有 open established refused close timeout等
        open :端口可访问,且有服务开放,(来自使用了nmap的检测)
        open|filtered :端口开放但没有任何响应,服务可能开放,也可能是有防火墙在阻挡,(来自nmap检测)
        colse :端口可访问,但服务是关闭的(来自nmap)
        filtered :被防火墙阻挡(来自nmap)
        unfiltered :无法确定端口打开还是关闭,但未被防火墙阻挡(来自nmap)
        closed|filtered :可能是端口关闭,也可能是有防火墙在阻挡(来自nmap)
        established :端口打开,且有服务开放(来自使用了ssh的检测)
        refused :端口拒绝响应,估计是与nmap的close返回相似(来自ssh)
        timeout :超时,使用ssh检测时,若超过3秒未有结论,会被脚本强行设置为超时状态,极有可能是遇到了防火墙(来自ss)
    service :端口上的服务识别,如80是http服务,3306是mysql服务,未必是安装测试数据分析的结果,起参考作用(来自nmap)
        /iperf3 :说明是在远端机开启了iperf3,然后做的联机测试
        /socat :说明是在远端机开启了socat,然后做的联机测试
    latency :端口延时,如10ms(loss0/2),说明延时是10,丢包是0,一个尝试了2次而计算的平均值 .延时测试含两种方式
        ssh方式 :此方式得到的结果会受被对端的服务类型影响,例如若对端服务是iperf3,值会大于2000ms
        socat方式 :此方式需要先在对端机上也socat侦听,结果准确可信
    bandwidth :带宽测试结果,区分udp和tcp,带宽测试需要小心,会造成网络堵塞(约10秒)
        tcp结果 ↑17.1G/↓948M 表示上传带宽有17.1Gbps 下载有948Mbps
        udp结果 ↑1.70G(loss0.18%)±0.002ms/↓953M(loss0.42%)±0.011ms 表示上传1.7Gbps 丢包率0.18% 时延波动±0.002ms,下载…

3、参数说明
    -v[ersion] :打印版本、版权信息
    -h[elp] :打印帮助文档
    -a[ddress] :指定远端地址 -a:8.8.8.8 ,key:value之间冒号可以省略 -a8.8.8.8 .下同
        ip|域名 可以省略-a,在参数列表里直接写ip或域名
    -sp |-ssp :远端机器ssh服务端口 -sp:2022 -sp2022 省略则使用22 (联机测试需要ssh在远端机上执行命令,以安装/卸载软件或设置端口转发)
    -u[ser] :远端机用户名 -u:root  -umyusername
    -exe[cution] :用本脚本在远端机执行命令 -exe:'cat /etc/os-release' -exe'if true ;then ping -c 8 qq.com >./ping.log ;fi &'
    -[nci]-[tucif] :指定检测方式和待检测端口(默认是利用本机的ssh客户端，类似利用telnet,只能检测tcp)
        n指nmap,c指socat,i指iperf3,t指tcp,u指udp .对-[nci]-后面的部分 :c指远端上socat,i指远端机上iperf,f指远端iptables转发设置
        对本端机和远端机,ncituf参数逻辑上可以自由组合,但有些组合是没有意义的。一些示例：
        --:22   默认方式timeout 3 ssh -oBatchMode=yes -oStrictHostKeyChecking=no a_uuid_str@address" -v -p22 检测22(仅tcp)
                会得到established refused timeout三种结果,established说明是在线状态。若需要更详细可使用nmap且可以检测udp
        --:22,23,8086-8088 检测22 23 8086 8087 8088.可以使用[,]隔离来指定多个,也可同时使用[-]来给定一个范围.下同
        -n-:22  使用nmap检测,支持某些能回音的udp .未指定tcp或udp则都检测,下同
                会得到6种结果状态,参考nmap手册 https://nmap.org/book/man-port-scanning-basics.html
                单独指定tcp 或udp ,或两者都有(后面雷同、可以通用) -n-t:22   -n-u:22   -n-tu:22
        -n-c:22 指定--c会在远端机上开启socat以侦听待检测的端口,然后根据指定的-n使用nmap进行检测 .如果远端机上22是被占用则会失败
                单独指定tcp 或udp ,或两者都有(后面雷同、可以通用) -n-tc22   -n-uc22   -n-tuc22
        -n-cf:22比上面-n-c:22多个f,脚本会在远端开启socat,然后使用iptables将22端口劫持转发到socat上,规则,脚本会自动清理,但若强行停
                止了脚本运行,可能会导致iptables转发策略残留,在远端机上运行 sudo iptables -tnat -nvL 可以查看
                假设socat侦听了5678,远端机ip为1.2.3.4,网卡名是eth0,则脚本添加的转发规则
                是 :sudo iptables -t nat -A PREROUTING -p tcp -i eth0 -d 1.2.3.4 --dport 22 -j DNAT --to 1.2.3.4:5678
                udp:sudo iptables -t nat -A PREROUTING -p tcp -i eth0 -d 1.2.3.4 --dport 22 -j DNAT --to 1.2.3.4:5678
                对应的删除命令则
                是 :sudo iptables -t nat -D PREROUTING -p tcp -i eth0 -d 1.2.3.4 --dport 22 -j DNAT --to 1.2.3.4:5678
                udp:sudo iptables -t nat -D PREROUTING -p udp -i eth0 -d 1.2.3.4 --dport 22 -j DNAT --to 1.2.3.4:5678
                如果远端机系统可以重启,重启后,这些策略会自动消失
        -c-cf:22远端机开启socat,并将22劫持-转发给socat,然后本端机使用socat对远端22检测,会得到延时信息,未指定tcp或udp则都检测
        -i-if:22 在两端使用iperf3联机做带宽测试,未指定tcp或udp则都检测
        -nci-tucif:22远端依次开启socat iperf3 以及对应的转发,然后优先使用nmap对socat做状态检测,然后用socat测延时,iperf3测带宽
        端口|端口串 可以省略-[nci]-[tucif],在参数列表直接写端口,类似 22 或22,23,24,8080-8088
    -c[ount] :检测次数,比如延时,需要检测多次以取平均值 -c:5  -c8
    -rn |remotenmap :远端nmap软件使用 -rn:install(安装nmap) -rn:remove(用完后卸载) -rn:use(若没有则安装-使用后卸载,有则只使用)
        可以简写 -rn:i -rn:r -rn:u 下同
    -ri |remoteiperf3 :远端iperf3软件 -ri:install(安装iperf3) -ri:remove(用完后和卸载) -ri:use(若没有则安装-用后卸载,有则只使用)
    -rc |remotesocat :远端socat软件使用方法 -rc:install -rc:remove -rc:use
    -rf |remoteforwardset :远端forward -rf:enable(启用forward) -rf:disable(用完后关闭) -rf:use(若没有则开启-用后关闭,有则只使用)
    -ln |localnmap :本端机nmap使用,方法与-rn一样
    -li |localiperf3 :本端机iperf3使用,方法与-ri一样
    -lc |localsocat :本端机socat使用,方法与-rc一样 .注意,不是 -ls
    -lp |localsshpass :本端机sshpass使用,用于自动填写ssh密码,方法与上类似 -lp:install -lp:remove -lp:use
    -le |localsocat :本端机expect,用于本端自动su命令提权(不用与远端,因为不稳定) 方法与上类似 -le:install -le:remove -le:use
    -k[ey] :指定ssh私钥。ssh登录可以使用密码,也可以使用key私钥文件 -k:/home/username/.ssh/private.key
    -p[assword] :指定ssh的登录密码 -p:'mypasswd' 在命令行参数里写密码会不安全,请继续往下看
    -lso :指定本端机sudo密码,可以用来提权 -lso'mypasswd'
    -lsu :指定本端机su命令密码，也就是root密码,也是用来提取的,没有配置sudo时也可以使用 -lsu'mypasswd'
    -etp :在-p上加入et(enter),让脚本来提示你将密码输入,这样密码不会被记录到history里 -etp
    -etlso :在-lso上加入et(enter),让脚本来提示你将-lso密码输入 -etlso
    -etlsu :在-lsu上加入et(enter),让脚本来提示你将-lsu密码输入 -etlsu
    -to |timeout :使socat和iptables服务多少秒后退出,脚本被中断仍然有效,可避免服务残留,默认500,到期后依赖socat或iperf3的测试将失败
    -w[ait] :指定-wait会获取更多信息,包括主机、路由追踪
    -b[ump] :这是一个野蛮选项,繁多的参数让你心烦吧。加入一个 -bump 让脚本来为你选择,你只需要指定一个远端机的地址,和端口号
    -log :指定日志信息输出到文件 -log/var/log/nif.sh.log   -log:/home/myuser/nif.sh.log

4、使用示例($0指本脚本的执行名称)
    简单检测(速度最快,不需要任何依赖,仅持tcp) :
        $0 1.2.3.4 --t:80
        或(多端口) $0 1.2.3.4 --t:80,443,20-22
        或(域名方式) $0 abc.com 80
    使用nmap检测(本端机需要有nmap) :
        $0 1.2.3.4 -n-t:8080
        或(udp) $0 1.2.3.4 -n-u:8080
        或(自动安装/使用/卸载nmap) $0 1.2.3.4 -n-t:8080 -bump
    使用socat联机测试延时(联机模式!会在远端机上依次占用/劫持所有待测端口,需要ssh能连接远端机,且本端和远端机均需要socat) :
        $0 1.2.3.4 -sp22 -u:ssh-user -c-tc:8080
        或(udp) $0 1.2.3.4 -sp22 -u:ssh-user -c-uc:8080
        或(ssh使用私钥) $0 1.2.3.4 -sp22 -u:ssh-user -k/home/user/.ssh/private.key -c-tc:8080
        或(ssh使用密码,本端需要sshpass或expect) $0 1.2.3.4 -sp22 -u:ssh-user -etp -c-tc:8080
        或(ssh使用密码,自动安装/使用/卸载socat) $0 1.2.3.4 -sp22 -u:ssh-user -c-tc:8080 -bump
    使用iperf3联机测试带宽(联机模式!会在远端机上依次占用/劫持所有待测端口,需要ssh能连接远端机,且本端和远端机均需要iperf3) :
        $0 1.2.3.4 -sp22 -u:ssh-user -i-ti:8080
        或(udp) $0 1.2.3.4 -sp22 -u:ssh-user -i-ui:8080
        或(ssh使用私钥) $0 1.2.3.4 -sp22 -u:ssh-user -k/home/user/.ssh/private.key -i-ti:8080
        或(ssh使用密码,本端需要sshpass或expect) $0 1.2.3.4 -sp22 -u:ssh-user -etp -i-ti:8080
        或(ssh使用密码,自动安装/使用/卸载iperf3) $0 1.2.3.4 -sp22 -u:ssh-user -i-ti:8080 -bump
    使用nmap测试路由追踪(需要root权限,本端需要有nmap) :
        $0 1.2.3.4 -lso"local-sudo-password"
        或(自动sudo提取) $0 1.2.3.4 -lso"local-sudo-password"
        或(自动安装/使用/卸载nmap) $0 1.2.3.4 -lso"local-sudo-password" -ln:use
        或直接 $0 -w
    全量测试的自动向导 :
        $0 -bump
    全量测试的参数指定 :
        $0 abcd.com -u:"ssh-user" -sp22 -etp -etlso -nci-cif:8080 -ln:use -lc:use -li:use -rc:use -ri:use -rf:use -w
    仅检测主机和路由信息 :
            $0 -wait
    仅执行远程命令 :
        $0  abcd.com -u:ssh-user -etp -sp888 -exe'ls -t'  #在远程机上执行ls-t (若ssh端口是默认的22则-sp888可省略(以上通用)
    *如果想让脚本退出时保留[nmap] [socat] [iperf3] [sshpass] [expect],可用将以上出现的use替换为install(对forward是 -rf:enable)
EOF
}
print_version(){
cat<<'EOF'

             *
       *   *                    nif.sh
     *    \* / *                version :0.7.5.20211202
       * --.:. *                by :haif
      *   * :\ -                <shenzhen-fistbump-2021-12-02>
        .*  | \
       * *     \
     .  *       \
      ..        /\.
     *          |\)|
   .   *         \ |
  . . *           |/\
     .* *         /  \
   *              \ / \
 *  .  *           \   \
    * .
   *    *
  .   *    *

EOF
}
#printf "."  # echo "==1==="


# 1.2 参数为空时
print_tip_info() { printf "(请尽量等待,强行中断可导致远端机上iptables策略残留.届时请查看log :./nif.sh.log.92c56*)" ;}
p_123456789="$*"
[[ -z ${p_123456789// /} ]] &&print_help &&print_version &&exit 0
#printf "."


#1.3 ctrl+c 终止指令劫持
def_exit_exist=""
def_rl_exit_exist=""
def_rr_rl_exit_exist=""
def_sv_rr_rl_exit_exist=""
cc_exit(){
    if [[ -n $def_sv_rr_rl_exit_exist ]] ;then
        local_smart_exec_record "用户强制退出(sv)"
        def_sv_rr_rl_exit 14 "用户强制退出(sv)"  
    elif [[ -n $def_rr_rl_exit_exist ]] ;then
        local_smart_exec_record "用户强制退出(rr)"
        def_rr_rl_exit 13 "用户强制退出(rr)"
    elif [[ -n $def_rl_exit_exist ]] ;then
        local_smart_exec_record "用户强制退出(rl)"
        def_rl_exit 12 "用户强制退出(rl)"
    elif [[ -n $def_exit_exist ]] ;then
        def_exit 11 "用户强制退出(1)"
    else
        echo "用户强制退出"
    fi
}
trap 'cc_exit' INT
#printf "."



#2 参数解析与获取
#2.1 定义参数匹配规则：
__='[:]?'  #ke[:]?value，定义用来将key和value进行分割的符号
re_ver='version'
re_help='help'
re_address='address'
re_address_v='[-_\\.A-Za-z0-9]{1,254}\\.[A-Za-z0-9]{1,32}'  #awk中转义点号:\\.
re_addr='[-_\\.A-Za-z0-9]{1,254}\\.[A-Za-z0-9]{1,32}'  #地址的快速输入方式（不用加任何参数前缀符号）
re_sp='sshport'
re_sp_v='[0-9]{1,5}'
re_user='user'
re_user_v='\\S+'
re_exe='execution'
re_exe_v='\\S+'
re_nif="scan$__"'[nic]{0,3}-[tucif]{0,5}'  #完整表达式：scan:ni-tunif，以-为界。"ni-…"为本端及操作符：n指安装(使用)nmap，i指iperf3。 "…-tunif"为远端机操作符：器中t表示指定待口为tcp，u指udp，n、i指安装(使用)nmap、iperf3，f表示forward(iptables)转发
re_nif_v='([0-9]{1,5}[-,]?)+'
re_port='([0-9]{1,5}[-,]?)+'  #端口参数的快速输入方式（不用加任何参数前缀符号）
re_count='count'
re_count_v='[0-9]+'
re_rn='remotenmap'
re_rn_v='(install|inst|in|i|remove|rm|r|use|us|u)'
re_ri='remoteiperf3'
re_ri_v='(install|inst|in|i|remove|rm|r|use|us|u)'
re_rc='remotesocat'
re_rc_v='(install|inst|in|i|remove|rm|r|use|us|u)'
re_rf='remoteforwardset'
re_rf_v='(enable|en|1|disable|ds|0|use|us|u)'
re_ln='localnmap'
re_ln_v='(install|inst|in|i|remove|rm|re|r|use|us|u)'
re_li='localiperf3'
re_li_v='(install|inst|in|i|remove|rm|re|r|use|us|u)'
re_lc='localsocat'
re_lc_v='(install|inst|in|i|remove|rm|r|use|us|u)'
re_lp='localsshpass'
re_lp_v='(install|inst|in|i|remove|rm|re|r|use|us|u)'
re_le='localexpect'
re_le_v='(install|inst|in|i|remove|rm|re|r|use|us|u)'
re_key='key'
re_key_v='\\S+'
re_pass='password'
re_pass_v='\\S+'
re_lso='localsudopass'
re_lso_v='\\S+'
re_lsu='localsupass'
re_lsu_v='\\S+'
re_epass='enterpass'
re_elso='enterlso'
re_elsu='enterlsu'
re_timeout='timeout'
re_timeout_v='[0-9]+'
re_wait='wait'
re_bump='bump'
re_log='log'
re_log_v='\\S+'
#printf "."  # echo "==2.1==="


#2.2 参数可用的表达方式(例如简写)的调校：
tmpss=$*
set -- " ${tmpss// /   } "
set -- "$(echo "$*" |gawk -v matched=" --?v | -?-?ver(sion)? " -v obj=" $re_ver " '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" --?h(elp)? " -v obj=" $re_help " '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" --?a$__" -v obj=" $re_address:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -ss?p$__" -v obj=" $re_sp:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -u$__" -v obj=" $re_user:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -exe$__" -v obj=" $re_exe:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -?-?:$__" -v obj=" scan:-:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -s-" -v obj=" scan:-" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -n-" -v obj=" scan:n-" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -c-" -v obj=" scan:c-" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -i-" -v obj=" scan:i-" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -nc-| -cn-" -v obj=" scan:nc-" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -ni-| -in-" -v obj=" scan:ni-" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -ci-| -ic-" -v obj=" scan:ci-" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -nci-| -nic-| -cni-| -cin-| -inc-| -icn-" -v obj=" scan:nci-" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" --c" -v obj=" scan:-c" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" --i" -v obj=" scan:-i" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" --f" -v obj=" scan:-f" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" --t" -v obj=" scan:-t" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" --u" -v obj=" scan:-u" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -c$__" -v obj=" $re_count:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -rn$__" -v obj=" $re_rn:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -ri$__" -v obj=" $re_ri:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -rc$__" -v obj=" $re_rc:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -rf$__" -v obj=" $re_rf:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -ln$__" -v obj=" $re_ln:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -li$__" -v obj=" $re_li:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -lc$__" -v obj=" $re_lc:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -lp$__" -v obj=" $re_lp:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -le$__" -v obj=" $re_le:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -k$__" -v obj=" $re_key:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -p$__" -v obj=" $re_pass:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -lso$__" -v obj=" $re_lso:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -lsu$__" -v obj=" $re_lsu:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -en?t?-?p " -v obj=" $re_epass " '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -en?t?-?lso " -v obj=" $re_elso " '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -en?t?-?lsu " -v obj=" $re_elsu " '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -t(ime)?o(ut)?$__" -v obj=" $re_timeout:" '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -w(ait)? " -v obj=" $re_wait " '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -b(ump)? " -v obj=" $re_bump " '{gsub(matched,obj); print $0}')";
set -- "$(echo "$*" |gawk -v matched=" -log?$__" -v obj=" $re_log:" '{gsub(matched,obj); print $0}')";
#echo "【$*】"  #debug
#printf "."  # echo "==2.2==="


#2.3 参数检查(是否重复、和不可识别)：
EXECUTING="$(echo executing: "$0" "$*" |tr -s ' ')"
START_PWD="pwd: $(pwd)"
def_exit() {  #def_exit $1(设置的$?值) $2(退出提示信息)
    echo -e "\e[31mError $1: 程序已退出\e[0m"。 "$2"  >&2
    echo "$EXECUTING" >&2
    echo "$START_PWD"  >&2
    exit "$1"
}
def_exit_exist="true"
def_warning() {  #$0 $1(提示的字符串)
    echo -e "\e[35mWarning :\e[0m" "$1" >&2
}
loop_matched=()
loop_i=1
loop_lave="$*"
for i in "$__$re_ver"            "$__$re_help"                 "$re_address$__$re_address_v" "$__$re_addr"       "$re_sp$__$re_sp_v"\
         "$re_user$__$re_user_v" "$re_exe$__$re_exe_v"         "$re_nif$__$re_nif_v"         "$__$re_port"       "$re_count$__$re_count_v"\
         "$re_rn$__$re_rn_v"     "$re_ri$__$re_ri_v"           "$re_rc$__$re_rc_v"           "$re_rf$__$re_rf_v" "$re_ln$__$re_ln_v"\
         "$re_li$__$re_li_v"     "$re_lc$__$re_lc_v"           "$re_lp$__$re_lp_v"           "$re_le$__$re_le_v" "$re_key$__$re_key_v"\
         "$re_pass$__$re_pass_v" "$re_lso$__$re_lso_v"         "$re_lsu$__$re_lsu_v"         "$__$re_epass"      "$__$re_elso"\
         "$__$re_elsu"           "$re_timeout$__$re_timeout_v" "$__$re_wait"                 "$__$re_bump"       "$re_log$__$re_log_v"
do
    mtch=$(echo "$*" |tr -s ' ' |tr ' ' '\n' |gawk -v keyv="^$i$" '$0~keyv{print $0}')  #将n个参数切断为n行进行匹配
    [[ $(echo "$mtch" |wc -l) -gt 1 ]] &&def_exit 2 "参数项重复：$(echo "$mtch" |tr "\n" '  ')"  #如果匹配的有超过1行，说明参数有重复
    [[ $(echo "$mtch" |wc -l) -lt 1 ]] &&continue  #如果不足一行，说明参数为空，直接跳过
    loop_matched[loop_i]=$(echo "$mtch" |gawk -v sour="${i%%"$__"*}$__" '{sub(sour,"") ;print $0}')  #将key_re和$__的表达式匹配的部分删除。（截取$__前面部分：${i%"$__"*},最前面部分：${i%%"$__"*}，截取$__后的：${i#*"$__"} 最后的：${i##*"$__"} http://c.biancheng.net/view/1120.html）
    #echo $loop_i "${loop_matched[$loop_i]}"    #debug
    ((loop_i =loop_i +1))
    loop_lave=$(echo "$loop_lave" |gawk -v sour='\\s'"$i"'\\s' '{gsub(sour,"") ;print $0}')  #'\\s'"$i"'\\s' 表示在正则表达式$i前后，再添加空字符匹配，这样避免从非空格开始匹配
done
#echo #loop_lave "$loop_lave"  #debug
[[ -n ${loop_lave// /} ]] &&def_exit 2 "参数无法识别：$(echo "$loop_lave" |tr -s ' ')"  #使用了双斜杠，将所有空格替换掉，然后做空否检查
#printf "."  # echo "==2.3==="


#2.4 参数获取，版本、帮助、log、与运行时提醒信息输出。消耗两个参数（-h -v）：
[[ -n "${loop_matched[1]}" ]] &&print_version &&exit 0
[[ -n "${loop_matched[2]}" ]] &&print_help &&exit 0
p_uuid='92c562a0-3ddd-11ec-9bbc-0242ac130002'
p_null='/dev/null'
p_address=${loop_matched[3]}
p_addr=${loop_matched[4]}
p_sp=${loop_matched[5]}
p_user=${loop_matched[6]}
p_exe=${loop_matched[7]}
p_nif=${loop_matched[8]}
p_ports=${loop_matched[9]}
p_count=${loop_matched[10]}
p_rn=${loop_matched[11]}
p_ri=${loop_matched[12]}
p_rc=${loop_matched[13]}
p_rf=${loop_matched[14]}
p_ln=${loop_matched[15]}
p_li=${loop_matched[16]}
p_lc=${loop_matched[17]}
p_lp=${loop_matched[18]}
p_le=${loop_matched[19]}
p_key=${loop_matched[20]}
p_pass=${loop_matched[21]}
p_lso=${loop_matched[22]}
p_lsu=${loop_matched[23]}
p_epass=${loop_matched[24]}
p_elso=${loop_matched[25]}
p_elsu=${loop_matched[26]}
p_tout=${loop_matched[27]}
p_wait=${loop_matched[28]}
p_bump=${loop_matched[29]}
p_log=${loop_matched[30]}
#echo "3address-$p_address   4addr-$p_addr   5sp-$p_sp   6usr-$p_user   7exe-$p_exe   8nif-$p_nif   9port-$p_ports   10count-$p_count"
#echo "11rn-$p_rn   12ri-$p_ri   13rc-$p_rc   14rf-$p_rf   15ln-$p_ln   16li-$p_li   17lc-$p_lc   18lp-$p_ls   19le-$p_le   20key-$p_key"
#echo "21pass-$p_pass   22rsu-$p_rsu   23lso-$p_lso   24lsu-$p_lsu   25entp-$p_epass   26entrsu-$p_ersu    27entlso-$p_elso   28entlu-$p_elsu   29tout-$p_tout   30wait-$p_wait   31bump-$p_bump"
#exit 0
#printf "."  # echo "==2.4==="


#2.5 设置参数的默认值、以及一些额外的预处理，消耗七个参数（p_addr p_nif p_ports p_epass p_ersu p_elso p_elsu），新增三个参数（nif_localop nif_remoteop nif_ports）：
[[ -n $p_addr && -n $p_address ]] &&def_exit 2 "参数项重复： $p_addr   $re_address:$p_address"  #p_addr为p_address的快速输入方式所获取的值
[[ -n $p_addr && -z $p_address ]] &&p_address=$p_addr
[[ -z $p_addr && -z $p_address ]] &&p_address='localhost' &&sign_rewrote_addr=true
[[ -z $p_sp ]] &&p_sp=22 &&sign_rewrote_sp=true  #ssh服务缺省端口号
[[ -z $p_user ]] &&p_user=$(whoami) &&sign_rewrote_user=true
[[ -z $p_nif ]]  &&p_nif='-'
p_nif=${p_nif//:/}
nif_localop=$(echo "$p_nif" |gawk -F- '{print $1}')  #提取nif本端机操作符
nif_tmp=$(echo "$p_nif" |cut -d'-' -f2-)  #提取远端机操作符
nif_remoteop=$(echo "$nif_tmp" |gawk -v sour="$re_nif_v" '{sub(sour,"") ;print $0}')
nif_ports=$(echo "$nif_tmp" |gawk -v sour="$nif_remoteop" '{sub(sour,"") ;print $0}')
[[ -z "$nif_localop" ]] &&nif_localop='s'  #如果为空则默认使用s操作符，既使用ssh做端口检查
[[ -z "$nif_remoteop" ]] &&nif_remoteop='tu'  #若远端操作符为空，则默认对端口上的tcp和udp都做检查（t值tcp、u指udp）
[[ "$nif_remoteop" =~ t|u ]] ||nif_remoteop='tu'$nif_remoteop  #如果远端机器没有指定端口协议，则默认tcp和udp都做检查
[[ $nif_localop = "s" &&! $nif_remoteop =~ "t" ]]  &&def_exit 2 "$p_nif默认ssh只能扫描tcp"
[[ $nif_remoteop =~ "f" &&! $nif_remoteop =~ "c"|"i" ]]  &&def_exit 2 "$p_nif你对远端机指定了forward，但未指定iperf3或socat进行侦听"
#[[ ! $nif_remoteop =~ "f" ]]  &&nif_remoteop=$nif_remoteop'f'  #因为一个已知问题，多此开关socat时，后面的socat会开启失败，所以只打开一个socat,然后使用iptables来吧不同端口转发上来
[[ -n $nif_ports && -n $p_ports ]] &&def_exit 2 "参数项重复： $p_ports   $p_nif"  #p_ports为端口的快速输入方式所获取的值
[[ -z $nif_ports && -n $p_ports ]]  &&nif_ports=$p_ports
[[ -z $p_count || $p_count -lt 1 ]] &&p_count=2  #设置测试试延时的最小、缺省时次数
[[ -z $p_key ]] &&p_key=$p_null
[[ -n $p_epass && -n $p_pass ]] &&def_exit 2 "参数项重复： $p_epass  $p_pass"  #如果参数既指定了密码，又指定了从输入中获取密码，则判断为参数重复
[[ -n $p_ersu && -n $p_rsu ]]  &&def_exit 2 "参数项重复： $p_ersu  $p_rsu"
[[ -n $p_elso && -n $p_lso ]]  &&def_exit 2 "参数项重复： $p_elso  $p_lso"
[[ -n $p_elsu && -n $p_lsu ]]  &&def_exit 2 "参数项重复： $p_elsu  $p_lsu"
#[[ (-n $p_epass && -z $p_pass) ||(-n $p_ersu && -z $p_rsu) ||(-n $p_elso && -z $p_lso) ||(-n $p_elsu && -z $p_lsu)]] &&echo
[[ -n $p_epass && -z $p_pass ]] &&read -r -s -p "Enter the ssh password : " p_epass &&echo &&p_pass=$p_epass  #将输入的转存
[[ -n $p_ersu && -z $p_rsu ]] &&read -r -s -p "Enter the remote su-command password : " p_ersu &&echo &&p_rsu=$p_ersu
[[ -n $p_elso && -z $p_lso ]] &&read -r -s -p "Enter the local sudo password : " p_elso &&echo &&p_lso=$p_elso
[[ -n $p_elsu && -z $p_lsu ]] &&read -r -s -p "Enter the local su-command password : " p_elsu &&echo &&p_lsu=$p_elsu
[[ -z $p_pass ]] &&p_pass=$p_uuid
[[ -z $p_rsu ]] &&p_rsu=$p_uuid
[[ -z $p_lso ]] &&p_lso=$p_uuid
[[ -z $p_lsu ]] &&p_lsu=$p_uuid
SOCAT_SERV_TIMEOUT=500       #超过时长,socat服务会被关闭,之后所有依赖socat服务的测试将会显示失败，这定时退出，在脚本被强行终止时也仍然有效，下同
IPERF3_SERV_TIMEOUT=500      #超过时长,iperf3服务会被关闭,之后所有依赖iperf3服务的测试将会显示失败
IPTABLES_RULE_TIMEOUT=180
[[ -n $p_tout ]] &&SOCAT_SERV_TIMEOUT=$p_tout
[[ -n $p_tout ]] &&IPERF3_SERV_TIMEOUT=$p_tout
[[ -z $p_log ]] &&p_log='./'$(basename "$0").log.$p_uuid
[[ -e $p_log ]] ||touch "$p_log" ||def_exit 2 "参数错误,指定的log文件是:$p_log"
{   date_tmp=$(date +'%Y/%m/%d %H:%M:%S')
    printf "\n-------------%s运行log----------------------------------------------------------\n" "$date_tmp"
} >>"$p_log"
#echo "==$p_nif ===$nif_localop ==$nif_remoteop ==$nif_ports ===" #debug
#exit 0
#printf "."  # echo "==2.5==="


#2.6 设置-bump 和只有-w时自动指定的参数值
if [[ -n $p_bump ]] ;then
    [[ -z $nif_localop ||$nif_localop =~ "s" ]] &&nif_localop="nci"
    [[ -z $nif_remoteop ||! $nif_remoteop =~ "c"|"i" ]] &&nif_remoteop=$nif_remoteop"ci"
    [[ -z $p_rc &&$nif_remoteop =~ "c" ]] &&p_rc="use"
    [[ -z $p_ri &&$nif_remoteop =~ "i" ]] &&p_ri="use"
    [[ -z $p_rf ]] &&p_rf="use"
    [[ -z $p_lp &&$nif_remoteop =~ "c"|"i"|"f" ]] &&p_lp="use"
    [[ -z $p_ln &&$nif_localop =~ "n" ]] &&p_ln="use"
    [[ -z $p_li &&$nif_localop =~ "i" ]] &&p_li="use"
    [[ -z $p_lc &&$nif_localop =~ "c" ]] &&p_lc="use"
    [[ -z $p_wait ]] &&p_wait="wait"
    #[[ $p_address = "localhost" ||$p_user = $(whoami) ||$p_sp = 22 ||(-z $p_epass &&$p_pass = "$p_uuid") ||(-z $p_elso &&$p_lso = "$p_uuid" &&! $(whoami) = "root") ||-z $nif_ports ]] &&echo
    [[ $sign_rewrote_addr = "true" ]] &&read -r -p "enter the remote address[-a] :" p_address
    [[ $sign_rewrote_user = "true" ]] &&read -r -p "enter remote ssh user[-u] :" p_user
    if [[ $sign_rewrote_sp = "true" ]] ;then
        read -r -p "enter remote ssh port[-sp] :" p_sp
        [[ -z $p_sp ]] &&p_sp=22
        [[ "$p_sp" =~ [0-9]{6,}|[^0-9] ]] &&read -r -p "Error, please re-enter :" p_sp
        [[ "$p_sp" =~ [0-9]{6,}|[^0-9] ]] &&def_exit 2 "输入的ssh端口参数错误"
    fi
    [[ -z $p_epass &&$p_pass = "$p_uuid" ]] &&read -r -s -p "enter the ssh password[-etp -p]: " p_pass &&echo
    [[ -z $p_elso &&$p_lso = "$p_uuid" &&! $(whoami) = "root" ]] &&read -r -s -p "Enter the local sudo password[-etlso -lso]: " p_lso &&echo
    if [[ -z $nif_ports ]] ;then 
        read -r -p "Enter the ports to be detected[--:] :" nif_ports
        [[ $nif_ports =~ [0-9]{6,}|[^0-9,-] ]] &&read -r -p "Error, please re-enter :" nif_ports
        [[ $nif_ports =~ [0-9]{6,}|[^0-9,-] ]] &&def_exit 2 "输入的待测试端口错误"
    fi
fi
p_123456789="$*"
p_123456789=${p_123456789//$p_address/}
p_123456789=${p_123456789//$p_lso/}
p_123456789=${p_123456789//$p_wait/}
if [[ -z ${p_123456789// /} ]] ;then
    sign_only_wait=true
    [[ $sign_rewrote_addr = "true" ]] &&read -r -p "enter the remote address[-a] :" p_address
    [[ -z $p_elso &&$p_lso = "$p_uuid" &&! $(whoami) = "root" ]] &&read -r -s -p "Enter the local sudo password[-etlso -lso]: " p_lso &&echo
    echo "---$sign_only_wait"
fi
#echo "$p_pass" -- "$p_rsu" -- "$p_lso" -- "$p_lsu"
#exit 0
#printf "."  # echo "==2.6==="

#2.7 运行时信息提醒
print_tip_info() { printf "(联机模式!运行如果中断,远端机可能会残留iptables规则,届时请查看%s" "$p_log" ;}
if [[ -n $p_rn$p_ri$p_rc ]] ;then
    print_tip_info  #运行时信息输出
fi



#3 设计本端的灵巧执行函数、处理参数对本端软件指定的动作
#3.1 设计灵巧执行函数local_smart_exec，将对sudo、su -c、expect、ubuntu、debian、centos等环境信息的判断，进行包装解耦。消耗两个参数(p_lso p_lsu)：
expect_exec() {  #$0 $1(用户密码) $2(su命令密码) $3(需要执行的命令行的第一部分) $4(需要执行的命令行的第二部分) $5(需要执行的命令行的第三部分)
/usr/bin/expect<<-EOF
log_user 0
set timeout 8
spawn $3 $4 $5 $6 $7 $8 $9
expect {
    timeout {
        puts "expect timed out"
        exit 1
    }
    "yes/no" {
        send "yes\r"
        exp_continue
    }
    "password" {  #ssh or sudo passwd
        send -- "$1\r"
        exp_continue
    }
    "Password:" {  #su passwd
        send -- "$2\r"
        exp_continue
    }
    -re {^([^\r]*)\r\n} {  #能将输出put 到$()中进行捕获
        puts "::::\$expect_out(1,string)::::"
        exp_continue
    }
    
}
#puts "\$expect_out(buffer)"
#exit
EOF
}
#expect_exec "$p_lsu" "su -c" "whoami"  #debug
#expect_exec "$p_lso" "sudo" "whoami"  #debug
#expect_exec "$p_lso" "$p_lsu" "su -c" "whoami"
#expect_exec "$p_pass" "$p_rsu" "ssh $p_user@$p_address -p$p_sp" "su root -c whoami"
#exit 0
def_local_exec_pre() {
    local_exec_pre=''
    if [[ $(whoami) =~ "root" ]] ;then
        local_exec_pre=''
    elif [[ $(echo "$p_uuid" |sudo -S whoami 2>&1) =~ "root" ]] ;then  #如果sudo没有安装，也会很快出结果，所以不做sudo安装检测了
        local_exec_pre='sudo '
    elif [[ $p_lso != "$p_uuid" &&$(echo "$p_lso" |sudo -S whoami 2>&1) =~ "root" ]] ;then
        local_exec_pre='echo "$p_lso" |sudo -S '
    elif [[  $p_lsu != "$p_uuid" &&-n $(expect -V 2>&1 |grep -q -i -E "command.*not.*found" ||echo "version") &&$(expect_exec "$p_lso" "$p_lsu" "su -c" "whoami") =~ "root" ]] ;then
        local_exec_pre='expect_exec "$p_lso" "$p_lsu" "su root -c"'
    fi
}
#echo "$local_smart_exec"  #debug
#exit 0
local_sys=''
grep -q -i "centos" /etc/os-release &&local_sys=centos
grep -q -i "debian" /etc/os-release &&local_sys=debian
grep -q -i "ubuntu" /etc/os-release &&local_sys=ubuntu
[[ -z $local_sys ]] &&def_exit 3 "本端主机系统无法识别"
def_local_exec_pre
local_smart_exec() {  #$0 $1(需要执行的命令-centos) $2(需要执行的命令-ubunt) $3(debian)
    [[ -z $2 ]] &&set -- "$1" "$1"
    [[ -z $3 ]] &&set -- "$1" "$2" "$2"
    if [[ $local_sys = "centos" ]] ;then
        eval "$local_exec_pre" '$1'  #需要使用单引号！
    elif [[ $local_sys = "ubuntu" ]] ;then
        eval "$local_exec_pre" '$2'
    elif [[ $local_sys = "debian" ]] ;then
        eval "$local_exec_pre" '$3'
    else
        return 1
    fi
}
local_smart_exec_record() {  #$0 $1(需要执行的命令-centos) $2(需要执行的命令-ubunt) $3(debian)
    [[ -z $2 ]] &&set -- "$1" "$1"
    [[ -z $3 ]] &&set -- "$1" "$2" "$2"
    nowtime_tmp="$(date +"%T.%3N")"
    if [[ $local_sys = "centos" ]] ;then
        echo "$nowtime_tmp  on local :$1" >>"$p_log"
    elif [[ $local_sys = "ubuntu" ]] ;then
        echo "$nowtime_tmp  on local :$2" >>"$p_log"
    elif [[ $local_sys = "debian" ]] ;then
        echo "$nowtime_tmp  on local :$3" >>"$p_log"
    else
        return 1
    fi
}
#local_smart_exec "echo centos run" "echo ubuntu run" #debug
#x="ping qq.com"
#echo -----------------
#expect_exec "$p_pass" "$p_rsu" "ssh $p_user@$p_address -i $p_key -p $p_sp" "" "su root -c '$x'"  #debug
#echo --------------
#exit 0
printf "."  # echo "==3.1==="


#3.2 处理参数对本端软件指定的动作。消耗四个参数（p_le p_lp p_ln p_li）
#3.2.1 定义退出函数，可在退出时做软件卸载
expect_local=''
pass_local=''
nmap_local=''
iperf3_local=''
socat_local=''
expect_ver(){ expect -V 2>&1 |grep -q -i -E "command.*not.*found" ||echo "version" ;}
expect_local=$(expect_ver 2>/dev/null)
expect_local_motion="leave-it"
pass_ver(){ sshpass -V 2>&1 |grep -q -i -E "command.*not.*found" ||echo "version" ;}
pass_local=$(pass_ver 2>/dev/null)
pass_local_motion="leave-it"
nmap_ver(){ nmap -V 2>&1 |grep -q -i -E "command.*not.*found" ||echo "version" ;}
nmap_local=$(nmap_ver 2>/dev/null)
nmap_local_motion="leave-it"
iperf3_ver(){ iperf3 -v 2>&1 |grep -q -i -E "command.*not.*found" ||echo "version" ;}
iperf3_local=$(iperf3_ver 2>/dev/null)
iperf3_local_motion="leave-it"
socat_ver(){ socat -V 2>&1 |grep -q -i -E "command.*not.*found" ||echo "version" ;}
socat_local=$(socat_ver 2>/dev/null)
socat_local_motion="leave-it"
{   echo "远端机 :$p_address"
    echo "本端机 :$(hostname -I)"
    echo "-a:$p_address -sp:$p_sp -u:$p_user -exe:$p_exe port[$p_nif][$p_ports] -c:$p_count -rn:$p_rn -ri:$p_ri -rc:$p_rc -rf:$p_rf -ln:$p_ln -li:$p_li -lc:$p_lc -lp:$p_lp -le:$p_le"
    echo "-k:$p_key $p_epass $p_ersu $p_elso $p_elsu -to:$p_tout $p_wait $p_bump   $START_PWD"
    nowtime_tmp="$(date +"%T.%3N")"
    echo "运行前$nowtime_tmp :"
    if [[ -z $nmap_local ]] ;then printf "%-23s" "本端-nmap:未安装" ;else printf "%-23s" "本端-nmap:已安装" ;fi
    if [[ -z $iperf3_local ]] ;then printf "%-18s" 'iperf3:未安装' ;else printf "%-18s" 'iperf3:已安装' ;fi
    if [[ -z $socat_local ]] ;then printf "%-18s" 'socat:未安装' ;else printf "%-18s" 'socat:已安装' ;fi
    if [[ -z $expect_local ]] ;then printf "%-18s" 'expect:未安装' ;else printf "%-18s" 'expect:已安装' ;fi
    if [[ -z $sshpass_local ]] ;then printf "%-18s" 'sshpass:未安装' ;else printf "%-18s" 'sshpass:已安装' ;fi
    echo
} >>"$p_log"
def_rl_exit() {   #$0 $1(设置的$?值) $2(退出提示信息)
    [[ $expect_local_motion =~ "remove" ]] &&local_smart_exec "yum remove expect -y" "apt remove expect -y"  >&2
    [[ $pass_local_motion =~ "remove" ]] &&local_smart_exec "yum remove sshpass -y" "apt remove sshpass -y"  >&2
    [[ $nmap_local_motion =~ "remove" ]] &&local_smart_exec "yum remove nmap -y" "apt remove nmap -y"  >&2
    [[ $iperf3_local_motion =~ "remove" ]] &&local_smart_exec "yum remove iperf3 -y" "apt remove iperf3 -y"  >&2
    [[ $socat_local_motion =~ "remove" ]] &&local_smart_exec "yum remove socat -y" "apt remove socat -y"  >&2
    expect_local=$(expect_ver 2>/dev/null)
    pass_local=$(pass_ver 2>/dev/null)
    nmap_local=$(nmap_ver 2>/dev/null)
    iperf3_local=$(iperf3_ver 2>/dev/null)
    socat_local=$(socat_ver 2>/dev/null)
    [[ "$1" = -1 &&-n "$2" ]] &&echo "$2" >&2 &&return 0
    [[ "$1" =  0 &&-n "$2" ]] &&echo "$2" >&2 &&exit 0  #以成功的状态退出
    def_exit "$1" "$2"  #以失败的状态退出
}
def_rl_exit_exist="true"
#printf "."  # echo "==3.2.1==="

#3.2.2 处理参数对本端expect指定的动作
if [[ $p_le =~ i|in|inst|install ]] ;then
    if [[ -z $expect_local ]] ;then
        local_smart_exec_record "yum install -y expect" "apt install -y expect"
        local_smart_exec "yum install -y expect" "apt install -y expect" ||def_rl_exit 3 "本端$local_sys主机安装expect失败"
        def_local_exec_pre  #安装expect可能会影响local_smart_exec，如果def_local_exec_pre中设计了将su -c优先与sudo
        expect_local_motion="leave-it"
        expect_local=$(pass_ver)
    fi
elif [[ $p_le =~ u|us|use ]] ;then
    if [[ -z $expect_local &&-n $nif_ports ]] ;then
        local_smart_exec_record "yum install -y expect" "apt install -y expect"
        local_smart_exec "yum install -y expect" "apt install -y expect" ||def_rl_exit 3 "本端$local_sys主机安装expect失败"
        def_local_exec_pre  #安装expect可能会影响local_smart_exec，如果def_local_exec_pre中设计了将su -c优先与sudo
        expect_local=$(pass_ver)
        expect_local_motion="remove-it"
    fi
elif [[ $p_le =~ r|rm|remove ]] ;then
    [[ -n $expect_local ]] &&expect_local_motion="remove-it"
elif  [[ -z $p_le ]] ;then
    expect_local_motion="leave-it"
else
    def_rl_exit "参数$re_le的值无法识别：$p_le"
fi >/dev/null 2>&1
#printf "."  # echo "==3.2.2==="

#3.2.3 处理参数对本端sshpass指定的动作
if [[ $p_lp =~ i|in|inst|install ]] ;then
    if [[ -z $pass_local ]] ;then
        local_smart_exec_record "yum install -y sshpass" "apt install -y sshpass"
        local_smart_exec "yum install -y sshpass" "apt install -y sshpass" ||def_rl_exit 3 "本端$local_sys主机安装sshpass失败"
        pass_local_motion="leave-it"
        pass_local=$(pass_ver)
    fi
elif [[ $p_lp =~ u|us|use ]] ;then
    if [[ -z $pass_local &&-n $nif_ports ]] ;then
        local_smart_exec_record "yum install -y sshpass" "apt install -y sshpass"
        local_smart_exec "yum install -y sshpass" "apt install -y sshpass" ||def_rl_exit 3 "本端$local_sys主机安装sshpass失败"
        pass_local=$(pass_ver)
        pass_local_motion="remove-it"
    fi
elif [[ $p_lp =~ r|rm|remove ]] ;then
     [[ -n $pass_local ]] &&pass_local_motion="remove-it"
elif  [[ -z $p_lp ]] ;then
    pass_local_motion="leave-it"
else
    def_rl_exit "参数$re_lp的值无法识别：$p_lp"
fi >/dev/null 2>&1
#printf "."  # echo "==3.2.3==="

#3.2.4 处理参数对本端nmap指定的动作
if [[ $p_ln =~ i|in|inst|install ]] ;then
    if [[ -z $nmap_local ]] ;then
        local_smart_exec_record "yum install -y nmap" "apt install -y nmap"
        local_smart_exec "yum install -y nmap" "apt install -y nmap" ||def_rl_exit 3 "本端$local_sys主机安装nmap失败"
        nmap_local_motion="leave-it"
        nmap_local=$(nmap_ver)
    fi
elif [[ $p_ln =~ u|us|use ]] ;then
    if [[ -z $nmap_local &&-n $nif_ports ]] ;then
        local_smart_exec_record "yum install -y nmap" "apt install -y nmap"
        local_smart_exec "yum install -y nmap" "apt install -y nmap" ||def_rl_exit 3 "本端$local_sys主机安装nmap失败"
        nmap_local=$(nmap_ver)
        nmap_local_motion="remove-it"
    fi
elif [[ $p_ln =~ r|rm|remove ]] ;then
    [[ -n $nmap_local ]] &&nmap_local_motion="remove-it"
elif  [[ -z $p_ln ]] ;then
    nmap_local_motion="leave-it"
else
   def_rl_exit 3 "参数$re_ln的值无法识别：$p_ln"
fi >/dev/null 2>&1
#printf "."  # echo "==3.2.4==="

#3.2.5 处理参数对本端iperf3指定的动作
if [[ $p_li =~ i|inst|install ]] ;then
    if [[ -z $iperf3_local ]] ;then
        local_smart_exec_record "yum install -y iperf3" "apt install -y iperf3"
        local_smart_exec "yum install -y iperf3" "apt install -y iperf3" ||def_rl_exit 3 "本端$local_sys主机安装iperf3失败"
        iperf3_local_motion="leave-it"
        iperf3_local=$(iperf3_ver)
    fi
elif [[ $p_li =~ u|us|use ]] ;then
    if [[ -z $iperf3_local &&-n $nif_ports ]] ;then
        local_smart_exec_record "yum install -y iperf3" "apt install -y iperf3"
        local_smart_exec "yum install -y iperf3" "apt install -y iperf3" ||def_rl_exit 3 "本端$local_sys主机安装iperf3失败"
        iperf3_local=$(iperf3_ver)
        iperf3_local_motion="remove-it"
    fi
elif [[ $p_li =~ r|rm|remove ]] ;then
    [[ -n $iperf3_local ]] &&iperf3_local_motion="remove-it"
elif  [[ -z $p_li ]] ;then
    iperf3_local_motion="leave-it"
else
    def_rl_exit 3 "参数$re_li的值无法识别：$p_li"
fi >/dev/null 2>&1
#printf "."  # echo "==3.2.5==="

#3.2.6 处理参数对本端socat指定的动作
if [[ $p_lc =~ i|inst|install ]] ;then
    if [[ -z $socat_local ]] ;then
        local_smart_exec_record "yum install -y socat" "apt install -y socat"
        local_smart_exec "yum install -y socat" "apt install -y socat" ||def_rl_exit 3 "本端$local_sys主机安装socat失败"
        socat_local_motion="leave-it"
        socat_local=$(socat_ver)
    fi
elif [[ $p_lc =~ u|us|use ]] ;then
    if [[ -z $socat_local &&-n $nif_ports ]] ;then
        local_smart_exec_record "yum install -y socat" "apt install -y socat"
        local_smart_exec "yum install -y socat" "apt install -y socat" ||def_rl_exit 3 "本端$local_sys主机安装socat失败"
        socat_local=$(socat_ver)
        socat_local_motion="remove-it"
    fi
elif [[ $p_lc =~ r|rm|remove ]] ;then
    [[ -n $socat_local ]] &&socat_local_motion="remove-it"
elif  [[ -z $p_lc ]] ;then
    socat_local_motion="leave-it"
else
    def_rl_exit 3 "参数$re_lc的值无法识别：$p_lc"
fi >/dev/null 2>&1
printf "."  # echo "==3.2.6==="

#4 设计远端的灵巧执行函数、处理参数对远端软件指定的动作
#4.1 设计灵巧执行函数remote_smart_exec，将对sudo、su -c、expect、ubuntu、debian、centos等环境信息的判断，进行包装解耦，消耗四个参数(p_sp p_user p_key p_pass p_rsu)：
tmp1=''
tmp2=''
tmp3=''
tmp5=''
tmp6=''
tmp7=''
remote_exec_pre=' '
  { tmp1=$(ssh -oBatchMode=yes -oStrictHostKeyChecking=no "$p_user"@"$p_address" -p"$p_sp" -i"$p_key" "whoami") ;[[ $tmp1 =~ root ]] ;} >/dev/null 2>&1\
||{ tmp2=$(ssh -oBatchMode=yes -oStrictHostKeyChecking=no "$p_user"@"$p_address" -p"$p_sp" -i"$p_key" "echo $p_uuid |sudo -S whoami") ;[[ $tmp2 =~ root ]] ;} >/dev/null 2>&1\
||{ [[ $p_pass != "$p_uuid" ]] &&tmp3=$(ssh -oBatchMode=yes -oStrictHostKeyChecking=no "$p_user"@"$p_address" -p"$p_sp" -i"$p_key" "echo $p_pass |sudo -S whoami") ;[[ $tmp3 =~ root ]] ;} >/dev/null 2>&1\
||{ [[ -n $pass_local ]] &&tmp5=$(sshpass -p "$p_pass" ssh -oStrictHostKeyChecking=no "$p_user"@"$p_address" -p"$p_sp" "whoami") ;[[ $tmp5 =~ root ]] ;} >/dev/null 2>&1\
||{ [[ -n $pass_local ]] &&tmp6=$(sshpass -p "$p_pass" ssh -oStrictHostKeyChecking=no "$p_user"@"$p_address" -p"$p_sp" "echo $p_uuid |sudo -S whoami") ;[[ $tmp6 =~ root ]] ;}>/dev/null 2>&1\
||{ [[ -n $pass_local &&$p_pass != "$p_uuid" ]] &&tmp7=$(sshpass -p "$p_pass" ssh -oStrictHostKeyChecking=no "$p_user"@"$p_address" -p"$p_sp" "echo $p_pass |sudo -S whoami") ;[[ $tmp7 =~ root ]] ;} >/dev/null 2>&1
#echo "-----$tmp1 --$tmp2 --$tmp3 --$tmp4 --$tmp5 --$tmp6 --$tmp7 --$tmp8 --$tmpa --$tmpb --$tmpc --$tmpd --"
  { [[ $tmp1 =~ "root" ]] &&remote_exec_pre='ssh -oBatchMode=yes -oStrictHostKeyChecking=no $p_user@$p_address -p$p_sp -i$p_key ' ;}\
||{ [[ $tmp2 =~ "root" ]] &&remote_exec_pre='ssh -oBatchMode=yes -oStrictHostKeyChecking=no $p_user@$p_address -p$p_sp -i$p_key "sudo" ' ;}\
||{ [[ $tmp3 =~ "root" ]] &&remote_exec_pre='ssh -oBatchMode=yes -oStrictHostKeyChecking=no $p_user@$p_address -p$p_sp -i$p_key "echo $p_pass |sudo -S" ' ;}\
||{ [[ $tmp5 =~ "root" ]] &&remote_exec_pre='sshpass -p$p_pass ssh -oStrictHostKeyChecking=no $p_user@$p_address -p$p_sp ' ;}\
||{ [[ $tmp6 =~ "root" ]] &&remote_exec_pre='sshpass -p$p_pass ssh -oStrictHostKeyChecking=no $p_user@$p_address -p$p_sp "sudo" ' ;}\
||{ [[ $tmp7 =~ "root" ]] &&remote_exec_pre='sshpass -p$p_pass ssh -oStrictHostKeyChecking=no $p_user@$p_address -p$p_sp "echo $p_pass |sudo -S" ' ;}\
||{ [[ $tmp1 =~ $p_user ]] &&remote_exec_pre='ssh -oBatchMode=yes -oStrictHostKeyChecking=no $p_user@$p_address -p$p_sp -i$p_key ' ;}\
||{ [[ $tmp5 =~ $p_user ]] &&remote_exec_pre='sshpass -p $p_pass ssh -oStrictHostKeyChecking=no $p_user@$p_address -p$p_sp ' ;}\
||remote_exec_pre='ssh -oBatchMode=yes -oStrictHostKeyChecking=no $p_user@$p_address -p$p_sp '
  { [[ $tmp1 =~ $p_user ]] &&remote_cp_pre='scp -oBatchMode=yes -oStrictHostKeyChecking=no -P$p_sp -i$p_key ' ;}\
||{ [[ $tmp5 =~ $p_user ]] &&remote_cp_pre='sshpass -p$p_pass scp -oStrictHostKeyChecking=no -P$p_sp ' ;}\
||remote_cp_pre='scp -oBatchMode=yes -oStrictHostKeyChecking=no -P$p_sp '
#  { [[ $tmp1 =~ $p_user ]] &&remote_cp_pre='scp -oBatchMode=yes -oStrictHostKeyChecking=no -P$p_sp -i$p_key ' &&remote_run='ssh -oBatchMode=yes -oStrictHostKeyChecking=no $p_user@$p_address -p$p_sp -i$p_key ' ;}\
#||{ [[ $tmp5 =~ $p_user ]] &&remote_cp_pre='sshpass -p$p_pass scp -oStrictHostKeyChecking=no -P$p_sp ' &&remote_run='sshpass -p $p_pass ssh -oStrictHostKeyChecking=no $p_user@$p_address -p$p_sp ' ;}\
#||{ [[ $tmpa =~ $p_user ]] &&remote_cp_pre='expect_exec "$p_pass" "$p_rsu" "scp -P$p_sp" ' &&remote_run='expect_exec "$p_pass" "$p_rsu" "ssh $p_user@$p_address -p$p_sp" ' ;}\
#||remote_cp_pre='scp -oBatchMode=yes -oStrictHostKeyChecking=no -P$p_sp ' &&remote_run='ssh -oBatchMode=yes -oStrictHostKeyChecking=no $p_user@$p_address -p$p_sp '
#echo "==remote_exe_pre:$remote_exec_pre" ===
#echo "==remote_cp_pre:$remote_exec_pre" ===
#echo "==remote_run:$remote_run" ===
remote_sys=''
[[ $(eval "$remote_exec_pre" 'cat /etc/os-release|grep -o centos' 2>/dev/null) =~ "centos" ]] &&remote_sys=centos
[[ $(eval "$remote_exec_pre" 'cat /etc/os-release|grep -o ubuntu' 2>/dev/null) =~ "ubuntu" ]] &&remote_sys=ubuntu
[[ $(eval "$remote_exec_pre" 'cat /etc/os-release|grep -o debian' 2>/dev/null) =~ "debian" ]] &&remote_sys=debian
[[ -n $pass_local ]] &&comment_tmp="本端sshpass:未安装"
[[ -z $remote_sys && ($nif_remoteop =~ "c"|"i" || -n $p_exe) ]] &&def_rl_exit 4 "远端$p_address系统不能识别或无法联机[ssh端口$p_sp] [用户$p_user] [$comment_tmp]"
remote_smart_cp() {  #$0 $1(本端文件) $2(远端保存路径)
    if [[ -z $2 ]] ;then
        tmp_resmtcp=$(echo "$1" |grep -o -E "[^/]+" |tail -n 1)".$p_uuid"
        set -- "$1" "$tmp_resmtcp"
    fi
    eval "$remote_cp_pre" "$1 $p_user@$p_address:$2"
}
remote_smart_exec() {  #$0 $1(user) $2(host) $3(port) $4(需要执行的命令行) $5(password)  #$0 $1(需要执行的命令-centos) $(需要执行的命令-ubunt)
    [[ -z $2 ]] &&set -- "$1" "$1"
    [[ -z $3 ]] &&set -- "$1" "$2" "$2"
    set --  "$1" "$2" "$3" 
    if [[ $remote_sys = "centos" ]] ;then
        eval "$remote_exec_pre" '$1'
    elif [[ $remote_sys = "ubuntu" ]] ;then
        eval "$remote_exec_pre" '$2'
    elif [[ $remote_sys = "debian" ]] ;then
        eval "$remote_exec_pre" '$2'
    else
        return 1
    fi
}
remote_smart_cp_exec() {  #$0 $1(需要到远端执行的文件路径)
    echo "$1" > ./nif.tmp.$p_uuid
    remote_smart_cp "./nif.tmp.$p_uuid" "nif.tmp.$p_uuid"
    remote_smart_exec "bash ./nif.tmp.$p_uuid"
    #rm -rf ./nif.tmp.$p_uuid
    #remote_smart_exec "rm -rf ./nif.tmp.$p_uuid"
}
remote_smart_exec_record() {  #$0 $1(user) $2(host) $3(port) $4(需要执行的命令行) $5(password)  #$0 $1(需要执行的命令-centos) $(需要执行的命令-ubunt)
    [[ -z $2 ]] &&set -- "$1" "$1"
    [[ -z $3 ]] &&set -- "$1" "$2" "$2"
    set --  "$1" "$2" "$3"
    nowtime_tmp="$(date +"%T.%3N")"
    if [[ $remote_sys = "centos" ]] ;then
        echo "$nowtime_tmp on remote :$1" >>"$p_log"
    elif [[ $remote_sys = "ubuntu" ]] ;then
        echo "$nowtime_tmp on remote :$2" >>"$p_log"
    elif [[ $remote_sys = "debian" ]] ;then
        echo "$nowtime_tmp on remote :$3" >>"$p_log"
    else
        return 1
    fi
}
printf "."  # echo "==4.1==="


#4.2 修订nif_remoteop
[[ ! $nif_remoteop =~ "f" &&$tmp1$tmp2$tmp3$tmp5$tmp6$tmp7 =~ "root" ]]  &&nif_remoteop=$nif_remoteop'f'  #因为一个已知问题，多此开关socat时，后面的socat会开启失败，所以只打开一个socat,然后使用iptables来吧不同端口转发上来
#printf "."  # echo "==4.2==="

#4.3 处理参数对远端软件指定的动作。消耗三个参数（p_rn p_ri p_rf）
#4.3.1 定义退出函数，可在退出时做软件卸载
nmap_remote=''
iperf3_remote=''
socat_remote=''
fwdset_remote=''
nmap_remote_ver(){ remote_smart_exec "nmap -V 2>&1" |grep -q -i -E "command.*not.*found" ||echo "version" ;}
nmap_remote=$(nmap_remote_ver 2>/dev/null)
nmap_remote_motion="leave-it"
iperf3_remote_ver(){ remote_smart_exec "iperf3 -v 2>&1" |grep -q -i -E "command.*not.*found" ||echo "version" ;}
iperf3_remote=$(iperf3_remote_ver 2>/dev/null)
iperf3_remote_motion="leave-it"
socat_remote_ver(){ remote_smart_exec "socat -V 2>&1" |grep -q -i -E "command.*not.*found" ||echo "version" ;}
socat_remote=$(socat_remote_ver 2>/dev/null)
socat_remote_motion="leave-it"
fwdset_remote_ver(){ remote_smart_exec "cat /proc/sys/net/ipv4/ip_forward" ;}
fwdset_remote=$(fwdset_remote_ver 2>/dev/null)
fwdset_remote_motion="leave-it"
{   if [[ -z $nmap_remote ]] ;then printf "%-23s" "远端-nmap:未安装" ;else printf "%-23s" "远端-nmap:已安装" ;fi
    if [[ -z $iperf3_remote ]] ;then printf "%-18s" 'iperf3:未安装' ;else printf "%-18s" 'iperf3:已安装' ;fi
    if [[ -z $socat_remote ]] ;then printf "%-18s" 'socat:未安装' ;else printf "%-18s" 'socat:已安装' ;fi
    printf "%-18s" "forward:$fwdset_remote" 
    echo
} >>"$p_log"
def_rr_rl_exit() {   #$0 $1(设置的$?值) $2(退出提示信息)
    [[ -e ./nif.tmp.$p_uuid ]] &&rm -f ./nif.tmp.$p_uuid &&remote_smart_exec "rm -f ./nif.tmp.$p_uuid" >&2
    [[ $nmap_remote_motion =~ "remove" ]] &&remote_smart_exec "yum remove nmap -y" "apt remove nmap -y" >&2
    [[ $iperf3_remote_motion =~ "remove" ]] &&remote_smart_exec "yum remove iperf3 -y" "apt remove iperf3 -y" >&2
    [[ $socat_remote_motion =~ "remove" ]] &&remote_smart_exec "yum remove socat -y" "apt remove socat -y" >&2
    [[ $fwdset_remote_motion =~ "remove" ]] &&remote_smart_exec "sysctl -w net.ipv4.ip_forward=0"  >&2
    nmap_remote=$(nmap_remote_ver 2>/dev/null)
    iperf3_remote=$(iperf3_remote_ver 2>/dev/null)
    socat_remote=$(socat_remote_ver 2>/dev/null)
    fwdset_remote=$(fwdset_remote_ver 2>/dev/null)
    def_rl_exit "$1" "$2"
}
def_rr_rl_exit_exist="true"
#printf "."  # echo "==4.3.1==="

#4.3.2 处理参数对远端nmap指定的动作
if [[ $p_rn =~ i|in|inst|install ]] ;then
    if [[ -z $nmap_remote ]] ;then
        remote_smart_exec_record "yum install -y nmap" "apt install -y nmap"
        remote_smart_exec "yum install -y nmap" "apt install -y nmap" ||def_rr_rl_exit 4 "远端$remote_sys主机安装nmap失败"
        nmap_remote_motion="leave-it"
        nmap_remote=$(nmap_remote_ver)
    fi
elif [[ $p_rn =~ u|us|use ]] ;then
    if [[ -z $nmap_remote &&-n $nif_ports ]] ;then
        remote_smart_exec_record "yum install -y nmap" "apt install -y nmap"
        remote_smart_exec "yum install -y nmap" "apt install -y nmap" ||def_rr_rl_exit 4 "远端$remote_sys主机安装nmap失败"
        nmap_remote=$(nmap_remote_ver)
        nmap_remote_motion="remove-it"
    fi
elif [[ $p_rn =~ r|rm|remove ]] ;then
    [[ -n $nmap_remote ]] &&nmap_remote_motion="remove-it"
elif  [[ -z $p_rn ]] ;then
    nmap_remote_motion="leave-it"
else
    def_rr_rl_exit 4 "参数$re_rn的值无法识别：$p_rn"
fi >/dev/null 2>&1
#printf "."  # echo "==4.3.2==="

#4.3.3 处理参数对远端iperf3指定的动作
if [[ $p_ri =~ i|in|inst|install ]] ;then
    if [[ -z $iperf3_remote ]] ;then
        remote_smart_exec_record "yum install -y iperf3" "apt install -y iperf3"
        remote_smart_exec "yum install -y iperf3" "apt install -y iperf3" ||def_rr_rl_exit 4 "远端$remote_sys主机安装iperf3失败"
        iperf3_remote_motion="leave-it"
        iperf3_remote=$(iperf3_remote_ver)
    fi
elif [[ $p_ri =~ u|us|use ]] ;then
    if [[ -z $iperf3_remote &&-n $nif_ports ]] ;then
        remote_smart_exec_record "yum install -y iperf3" "apt install -y iperf3"
        remote_smart_exec "yum install -y iperf3" "apt install -y iperf3" ||def_rr_rl_exit 4 "远端$remote_sys主机安装iperf3失败"
        iperf3_remote=$(iperf3_remote_ver)
        iperf3_remote_motion="remove-it"
    fi
elif [[ $p_ri =~ r|rm|remove ]] ;then
    [[ -n $iperf3_remote ]] &&iperf3_remote_motion="remove-it"
elif  [[ -z $p_ri ]] ;then
    iperf3_remote_motion="leave-it"
else
    def_rr_rl_exit 4 "参数$re_ri的值无法识别：$p_ri"
fi >/dev/null 2>&1
#printf "."  # echo "==4.3.3==="

#4.3.4 处理参数对远端socat指定的动作
if [[ $p_rc =~ i|in|inst|install ]] ;then
    if [[ -z $socat_remote ]] ;then
        remote_smart_exec_record "yum install -y socat" "apt install -y socat"
        remote_smart_exec "yum install -y socat" "apt install -y socat" ||def_rr_rl_exit 4 "远端$remote_sys主机安装socat失败"
        socat_remote_motion="leave-it"
        socat_remote=$(socat_remote_ver)
    fi
elif [[ $p_rc =~ u|us|use ]] ;then
    if [[ -z $socat_remote &&-n $nif_ports ]] ;then
        remote_smart_exec_record "yum install -y socat" "apt install -y socat"
        remote_smart_exec "yum install -y socat" "apt install -y socat" ||def_rr_rl_exit 4 "远端$remote_sys主机安装socat失败"
        socat_remote=$(socat_remote_ver)
        socat_remote_motion="remove-it"
    fi
elif [[ $p_rc =~ r|rm|remove ]] ;then
    [[ -n $socat_remote ]] &&socat_remote_motion="remove-it"
elif  [[ -z $p_rc ]] ;then
    socat_remote_motion="leave-it"
else
    def_rr_rl_exit 4 "参数$re_rc的值无法识别：$p_rc"
fi >/dev/null 2>&1
#printf "."  # echo "==4.3.4==="

#4.3.5 处理参数对远端forward配置指定的动作
if [[ $p_rf =~ enable|en|e|1 ]] ;then
    if [[ $fwdset_remote =~ 0 ]] ;then
        remote_smart_exec_record "sysctl -w net.ipv4.ip_forward=1"
        remote_smart_exec "sysctl -w net.ipv4.ip_forward=1" ||def_rr_rl_exit 4 "远端$remote_sys主机设置forward转发失败"
        fwdset_remote_motion="leave-it"
        fwdset_remote=$(fwdset_remote_ver)
    fi
elif [[ $p_rf =~ use|us|u ]] ;then
    if [[ $fwdset_remote =~ 0 &&-n $nif_ports ]] ;then
        remote_smart_exec_record "sysctl -w net.ipv4.ip_forward=1"
        remote_smart_exec "sysctl -w net.ipv4.ip_forward=1" ||def_rr_rl_exit 4 "远端$remote_sys主机设置forward转发失败"
        fwdset_remote=$(fwdset_remote_ver)
        fwdset_remote_motion="remove-it"
    fi
elif [[ $p_rf =~ disable|dis|d|0 ]] ;then
    [[ ! $fwdset_remote =~ 0 ]] &&fwdset_remote_motion="remove-it"
elif [[ -z $p_rf ]] ;then
    fwdset_remote_motion="leave-it"
else
    def_rr_rl_exit 4 "参数$re_rf的值无法识别：$p_rf"
fi >/dev/null 2>&1
#printf "."  # echo "==4.3.5==="



#5 获取主机域名、ip等信息
#5.1 获取远端主机使用的ip、域名、ping值。消耗0个参数
re_ipv4='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[1-9]{1,3}'
get_domain() {
    if [[ -n $host_local ]] ;then
        host "$1" |grep -o -E "[^ ]+" |tail -n 1 2>/dev/null  #host命令需要依赖dnstool
    elif [[ -n $nmap_local ]] ;then
        tmp_getdom=$(nmap -Pn -sn --system-dns "$1" |gawk -F 'for|\\(' '/report for/{print $2}' 2>/dev/null)
        [[ $tmp_getdom =~ $re_ipv4 ]] ||echo "${tmp_getdom// /}"
    fi
}
remote_lan_nic=''
remote_ip=''
remote_lan_gateway=''
remote_name=''
if [[ $p_address =~ $re_ipv4 ]]; then
    remote_ip=$p_address
    remote_name=$(get_domain "$remote_ip" &)
else
    remote_name=$p_address
    remote_ip=$(timeout 2 ping "$p_address" -c 1 |head -n 1 |grep -o -E "$re_ipv4" 2>/dev/null)
fi
remote_lan_default=$(remote_smart_exec "/usr/sbin/ip route" 2>/dev/null)
remote_lan_gateway=$(echo "$remote_lan_default" |grep default |tr -s ' '|cut -d' ' -f3)
remote_lan_nic=$(echo "$remote_lan_default"  |grep default |tr -s ' '|cut -d' ' -f5)
remote_lan_ip=$(echo "$remote_lan_default"   |grep "dev.*$remote_lan_nic.*proto.*kernel" |head -n1 |tr -s ' ' |grep -o -E "$re_ipv4")
((tmp_count="$p_count"+2))
remote_ping=$(timeout $tmp_count ping "$remote_ip" -c $p_count |gawk -F"[/ ]" '/min\/avg\/max\/mdev/{print $8}' 2>/dev/null &)"ms"
printf "."  # echo "==5.1==="


#5.2 获取本端主机使用的dns、网关、和ip。消耗0个参数
local_nic=''
local_ip=''
local_gateway=''
local_name=''
local_dns=''
[[ $local_sys = centos ]] &&local_dns=$(grep -i "nameserver" /etc/resolv.conf |head -n 1 |grep -o -E "$re_ipv4")
[[ $local_sys = debian ]] &&local_dns=$(grep -i "nameserver" /etc/resolv.conf |head -n 1 |grep -o -E "$re_ipv4")
[[ $local_sys = ubuntu ]] &&local_dns=$(grep -v -E "^#|^$" /run/systemd/resolve/resolv.conf |grep -i "nameserver" |head -n 1 |grep -o -E "$re_ipv4")
tmp_addr=$remote_ip
[[ $tmp_addr =~ "localhost" ]] &&tmp_addr='114.114.114.114'
#echo "==local_dns_ip_gateway_tmp_addr:$tmp_addr =="
local_default=$(/usr/sbin/ip route 2>/dev/null)
local_gateway=$(echo "$local_default" |grep default |tr -s ' '|cut -d' ' -f3)
local_nic=$(echo "$local_default" |grep default |tr -s ' '|cut -d' ' -f5)
local_ip=$(echo "$local_default" |grep "dev.*$local_nic.*proto.*kernel" |head -n1 |tr -s ' ' |grep -o -E "$re_ipv4")
local_name=$(get_domain "$local_ip" &)
#wait
#echo "$remote_sys $remote_name $remote_ip $remote_lan_ip $remote_lan_nic $remote_lan_gateway  $remote_ping"
#echo "$local_sys $local_name $local_ip $local_nic $local_gateway $local_dns"
#exit 0
printf "."  # echo "==5.2==="



#6 软件的使用方法，和相关设置的开关方法
#6.1 定义socat iperf3 forward于远端的服务开关函数。
#保存一下任何服务开启前远端机的服务状态
{   remote_port_if=$(remote_smart_exec "/usr/sbin/ss -nlp4tu" "ss -nlp4tu" 2>/dev/null)
    remote_fwdrl_if=$(remote_smart_exec "iptables -tnat -nvL" 2>/dev/null)
    echo "远端-服务(sudo ss -nlp4tu ) :"
    [[ -n $remote_port_if ]] &&echo "$remote_port_if"
    echo "远端-iptables-nat(sudo iptables -tnat -nvL ) :"
    [[ -n $remote_fwdrl_if ]] &&echo "$remote_fwdrl_if" |grep -vE "^$"
    if [[ $tmp1$tmp2$tmp3$tmp5$tmp6$tmp7 =~ "root" ]] ;then
        printf "%-23s%-18s" "远端-有root:yes" "已准备好ssh联机:yes"
    elif [[ $tmp1$tmp2$tmp3$tmp5$tmp6$tmp7 =~ $p_user ]] ;then
        printf "%-23s%-18s%" "远端-有root:no" "已准备好ssh联机:yes"
    else
        printf "%-23s%-18s" "远端-有root:no" "已准备好ssh联机:no"
    fi
    echo
    if local_smart_exec whoami |grep -q root ;then
        printf "%-23s" "本端-有root:yes"
    else
        printf "%-8s" "本端-有root:no"
    fi
    nowtime_tmp="$(date +"%T.%3N")"
    echo
    printf "\n开始运行%s :\n" "$nowtime_tmp"
} >>"$p_log"
portsv_stop() {  #$0 $1(tcp dup) $2(端口号) $3(进程二进制名称)
    [[ $1 =~ t ]] &&set -- 't' "$2" "$3"
    [[ $1 =~ u ]] &&set -- 'u' "$2" "$3"
    port_if_a=$(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*$3" "ss -nlp4$1|grep :$2.*$3" 2>/dev/null)
   # echo "==portsv_stop port_test:=$port_if ==="
    if [[ $port_if_a =~ :$2.*$3 ]] ;then
        tmp_ptsvstp=$(echo "$port_if" |grep -o -i -E "pid=[0-9]+" |grep -o -E "[0-9]+")
        port_if=$(remote_smart_exec "kill $tmp_ptsvstp" 2>/dev/null)
        port_if=$(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*$3" "ss -nlp4$1|grep :$2.*$3" 2>/dev/null)
        if [[ $port_if =~ :$2 ]] ;then
            #remote_smart_exec_record "${port_if_a//   /} (关闭失败,可能timeout到期已自动关闭)"
            echo "portsv_stop_$2_$3_false"
            return 1
        else
            #remote_smart_exec_record "${port_if_a//   /} (关闭成功)"
            echo "portsv_$2_$3_stoped"
            return 0
        fi
    else
        echo "_$1_$2_$3_find_no"
        return 0
    fi
}
get_a_free_port() {  #$0 $1(local remote)
    tmp_gtafree=$(remote_smart_cp_exec 'comm -23 <(seq 49152 65535 |sort) <(ss -Htan |cut -d: -f2 |sort -u) |shuf |head -n 200' 2>/dev/null)
    tmp_gtafree=$(echo "$tmp_gtafree"  |grep -Eo "^[0-9]{5}$")
    tmp_gtafree=$(remote_smart_cp_exec "comm -23 <(echo $tmp_gtafree) <(iptables -tnat -nvL|grep -oE [0-9]{5} |sort -u) |shuf |head -n 1" 2>/dev/null)
    tmp_gtafree=$(echo "$tmp_gtafree"  |grep -Eo "^[0-9]{5}$")
    tmp_gtafree=$(echo "$tmp_gtafree"  |grep -Eo "^[0-9]{5}$")
    if [[ -n $tmp_gtafree ]] ;then
        echo "$tmp_gtafree"
        return 0
    else
        echo "get_a_free_port:false"
        return 1
    fi    
}
result_socatsv_start=''
socatsv_start() {  #$0 $1(tcp udp) $2(端口号) $3(定时退出时间秒数)
    [[ -z $3 ]]   &&set -- "$1" "$2" "$SOCAT_SERV_TIMEOUT"
    [[ $1 =~ t ]] &&set -- 't'  "$2" "$3" &&scl='TCP4-LISTEN'
    [[ $1 =~ u ]] &&set -- 'tu' "$2" "$3" &&scl='UDP4-LISTEN'
    port_if=$(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2" "ss -nlp4$1|grep :$2" 2>/dev/null)
    if [[ ! $port_if =~ :$2 ]] ;then
        remote_smart_exec "timeout $3 socat $scl:$2,fork EXEC:pwd" >/dev/null 2>&1 &
          { sleep 0.2 ;[[ $(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*socat" "ss -nlp4$1|grep :$2.*socat" 2>/dev/null) =~ :$2.*socat ]] ;}\
        ||{ sleep 0.3 ;[[ $(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*socat" "ss -nlp4$1|grep :$2.*socat" 2>/dev/null) =~ :$2.*socat ]] ;}\
        ||{ sleep 0.5 ;[[ $(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*socat" "ss -nlp4$1|grep :$2.*socat" 2>/dev/null) =~ :$2.*socat ]] ;}\
        ||{ sleep 0.8 ;[[ $(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*socat" "ss -nlp4$1|grep :$2.*socat" 2>/dev/null) =~ :$2.*socat ]] ;}\
        ||{ sleep 1.3 ;[[ $(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*socat" "ss -nlp4$1|grep :$2.*socat" 2>/dev/null) =~ :$2.*socat ]] ;}\
        ||{ sleep 8 ;[[ $(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*socat" "ss -nlp4$1|grep :$2.*socat" 2>/dev/null) =~ :$2.*socat ]] ;}
        tmp_sctst=$(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*socat" "ss -nlp4$1|grep :$2.*socat" 2>/dev/null)
        if [[ $tmp_sctst =~ :$2.*socat ]] ;then
            remote_smart_exec_record "timeout $3 socat $scl:$2,fork EXEC:pwd >/dev/null 2>&1 &"
            result_socatsv_start="$2"
            return 0
        else
            result_socatsv_start="socatsv_start:false"
            return 1
        fi
    else
        result_socatsv_start="socatsv_start_port:already_in_use"
        return 1
    fi
}
result_iperf3sv_start=''
iperf3sv_start() {  #$0 $1(tcp udp) $2(端口号) $3(定时退出时间秒数)
    [[ -z $3 ]]   &&set -- "$1" "$2" "$IPERF3_SERV_TIMEOUT"
    [[ $1 =~ t ]] &&set -- 't'  "$2" "$3"
    [[ $1 =~ u ]] &&set -- 'tu' "$2" "$3"
    port_if=$(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2" "ss -nlp4$1|grep :$2" 2>/dev/null)
    if [[ ! $port_if =~ :$2 ]] ;then
        remote_smart_exec "timeout $3 iperf3 -4sp $2" 2>/dev/null 1>/dev/null &
          { sleep 0.2 ;[[ $(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*iperf3" "ss -nlp4$1|grep :$2.*so" 2>/dev/null) =~ :$2.*iperf3 ]] ;}\
        ||{ sleep 0.3 ;[[ $(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*iperf3" "ss -nlp4$1|grep :$2.*iperf3" 2>/dev/null) =~ :$2.*iperf3 ]] ;}\
        ||{ sleep 0.5 ;[[ $(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*iperf3" "ss -nlp4$1|grep :$2.*iperf3" 2>/dev/null) =~ :$2.*iperf3 ]] ;}\
        ||{ sleep 0.8 ;[[ $(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*iperf3" "ss -nlp4$1|grep :$2.*iperf3" 2>/dev/null) =~ :$2.*iperf3 ]] ;}\
        ||{ sleep 1.3 ;[[ $(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*iperf3" "ss -nlp4$1|grep :$2.*iperf3" 2>/dev/null) =~ :$2.*iperf3 ]] ;}\
        ||{ sleep 8 ;[[ $(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*iperf3" "ss -nlp4$1|grep :$2.*iperf3" 2>/dev/null) =~ :$2.*iperf3 ]] ;}
        tmp_ipfst=$(remote_smart_exec "/usr/sbin/ss -nlp4$1|grep :$2.*iperf3" "ss -nlp4$1|grep :$2.*iperf3"  2>/dev/null)
        if [[ $tmp_ipfst =~ :$2.*iperf3 ]] ;then
            remote_smart_exec_record "timeout $3 iperf3 -4sp $2 >/dev/null 2>&1 &"
            result_iperf3sv_start="$2"
            return 0
        else
            result_iperf3sv_start="iperf3sv_start:false"
            return 1
        fi
    else
        result_iperf3sv_start="iperf3sv_start_port:already_in_use"
        return 1
    fi
}
#iperf3sv_start t $nif_ports
#exit 0
fwdrl_list_fordel=''
fwdrl_del() {  #$0 $1(tcp udp) $2(端口号) $3(端口号)
    [[ $1 =~ t ]] &&set -- 'tcp' "$2" "$3"
    [[ $1 =~ u ]] &&set -- 'udp' "$2" "$3"
    cmd_del="iptables -t nat -D PREROUTING -p $1 -i $remote_lan_nic -d $remote_lan_ip --dport $2 -j DNAT --to $remote_lan_ip:$3"
    cmd_re="DNAT.*$1.*$remote_lan_nic.*$remote_lan_ip.*$2.*$remote_lan_ip:$3"
    cmd_if=$(remote_smart_exec "iptables -tnat -nvL" |grep -iE "$cmd_re" 2>/dev/null)
    #echo "==fwdsv_del sate_test:=ipt=$cmd_if ==="
    if [[ "$cmd_if" =~ $cmd_re ]] ;then
        cmd_if=$(remote_smart_cp_exec "$cmd_del" 2>/dev/null)
        cmd_if=$(remote_smart_exec "iptables -tnat -nvL" |grep -iE "$cmd_re" 2>/dev/null)
        if [[ $cmd_if =~ $cmd_re ]] ;then
            remote_smart_exec_record "$cmd_del (删除失败)"
            echo "fwdrl_del:false"
            return 1
        else
            remote_smart_exec_record "$cmd_del (删除成功)"
            echo "fwdrl_deleted"
            return 0
        fi
    else
        echo "_$1_$2_$3_fwdrl_find_no"
        return 0
    fi
}
result_fwdrl_add=''
fwdrl_add() {  #$0 $1(tcp udp) $2(端口号) $3(端口号) $3(定时删除时间-秒)
    [[ $2 = "$p_sp" ]] &&result_fwdrl_add='This_is_the_SSH_cant_fwd:false' &&return 1
    [[ -z $4 ]]   &&set -- "$1"  "$2" "$3"  $IPTABLES_RULE_TIMEOUT
    [[ $1 =~ t ]] &&set -- 'tcp' "$2" "$3" "$4"
    [[ $1 =~ u ]] &&set -- 'udp' "$2" "$3" "$4"
    #cmd_add="iptables -t nat -A PREROUTING -p tcp -i $remote_lan_nic --dport $1 -j REDIRECT --to-port $2"  #用于iperf3会异常
    cmd_add="iptables -t nat -A PREROUTING -p $1 -i $remote_lan_nic -d $remote_lan_ip --dport $2 -j DNAT --to $remote_lan_ip:$3"
    cmd_re="DNAT.*$1.*$remote_lan_nic.*$remote_lan_ip.*$2.*$remote_lan_ip:$3"
    cmd_if=$(remote_smart_exec "iptables -tnat -nvL" 2>/dev/null|grep -iE "$cmd_re")
    #echo "==fwdsv_tcp_add sate_test:=ipt=$cmd_if ==="
    if [[ ! $cmd_if =~ $cmd_re ]] ;then
        cmd_if=$(remote_smart_cp_exec "$cmd_add" 2>/dev/null)
        cmd_if=$(remote_smart_exec "iptables -tnat -nvL" 2>/dev/null|grep -iE "$cmd_re")
        if [[ $cmd_if =~ $cmd_re ]] ;then
            remote_smart_exec_record "$cmd_add (添加成功)"
            result_fwdrl_add="$2 $1-forwarded-$3"
            fwdrl_list_fordel="iptables -t nat -D PREROUTING -p $1 -i $remote_lan_nic -d $remote_lan_ip --dport $2 -j DNAT --to $remote_lan_ip:$3 ;$fwdrl_list_fordel"
            addcmd_del="if true ;then sleep $4 ;iptables -t nat -D PREROUTING -p $1 -i $remote_lan_nic -d $remote_lan_ip --dport $2 -j DNAT --to $remote_lan_ip:$3 >/dev/null 2>&1 ;fi &"
            remote_smart_cp_exec "$addcmd_del" >/dev/null 2>&1 &
            return 0
        
        else
            remote_smart_exec_record "$cmd_add (添加失败)"
            result_fwdrl_add="fwdrl_add:false"
            return 1
        fi
    else
        result_fwdrl_add="fwdrl_add_fwd_rule:already_exists"
        return 1
    fi
}
printf "."  # echo "==6.1==="


#6.2 开启iperf3、socat服务
iperf3sv_port="$p_uuid"
socatsv_tcp_port="$p_uuid"
socatsv_udp_port="$p_uuid"
if [[ $nif_remoteop =~ "t" &&$nif_remoteop =~ "i" &&-n $iperf3_remote &&$nif_remoteop =~ "f" ]] ;then
    iperf3sv_port=$(get_a_free_port)
    if [[ $iperf3sv_port =~ "false" ]] ;then
        def_rr_rl_exit 6 "远端开启iperf3服务时,获取空闲端口失败$iperf3sv_port"
    fi
    iperf3sv_start t "$iperf3sv_port"
    tmp_opif3="$result_iperf3sv_start"
    if [[ $tmp_opif3 =~ "false"|"already_in_use" ]] ;then
        def_rr_rl_exit 6 "远端开启iperf3服务失败$tmp_opif3"
    fi
fi
if [[ $nif_remoteop =~ "t" &&$nif_remoteop =~ "c" &&-n $socat_remote &&$nif_remoteop =~ "f" ]] ;then
    socatsv_tcp_port=$(get_a_free_port)
    if [[ $socatsv_tcp_port =~ "false" ]] ;then
        def_rr_rl_exit 6 "远端开启socat_tcp服务时,获取空闲端口失败$socatsv_tcp_port"
    fi
    socatsv_start t "$socatsv_tcp_port"
    if [[ $result_socatsv_start =~ "false"|"already_in_use" ]] ;then
        def_rr_rl_exit 6 "远端开启soca_tcp服务失败$result_socatsv_start"
    fi
fi
if [[ $nif_remoteop =~ "u" &&$nif_remoteop =~ "c" &&-n $socat_remote &&$nif_remoteop =~ "f" ]] ;then
    socatsv_udp_port=$(get_a_free_port)
    if [[ $socatsv_udp_port =~ "false" ]] ;then
        def_rr_rl_exit 6 "远端开启socat_udp服务时,获取空闲端口失败$socatsv_udp_port"
    fi
    socatsv_start u "$socatsv_udp_port"
    if [[ $result_socatsv_start =~ "false"|"already_in_use" ]] ;then
        def_rr_rl_exit 6 "远端开启iperf3_udp服务失败$result_socatsv_start"
    fi
fi
def_sv_rr_rl_exit() {   #$0 $1(设置的$?值) $2(退出提示信息)
    portsv_stop t "$iperf3sv_port" "iperf3" >&2
    portsv_stop t "$socatsv_tcp_port" "socat" >&2
    portsv_stop u "$socatsv_udp_port" "socat" >&2
    remote_smart_cp_exec "$fwdrl_list_fordel" >&2
    def_rr_rl_exit "$1" "$2"
}
def_sv_rr_rl_exit_exist="true"
#printf "."  # echo "==6.2==="


#6.3 定义socat iperf3 ssh于本端的扫描函数。
socat_online_scan_latency() {  #$0 $1(tcp udp) $2(端口号) $3(需要减去的修正值) $4(对端主机)
    [[ -z $3 &&$1 =~ t ]] &&set -- "$1" "$2"    1  "$p_address"
    [[ -z $3 &&$1 =~ u ]] &&set -- "$1" "$2"  502  "$p_address"
    [[ -z $4 ]]    &&set -- "$1" "$2" "$3" "$p_address"
    [[ $1 =~ t ]] &&set -- 'tcp' "$2" "$3" "$4"
    [[ $1 =~ u ]] &&set -- 'udp' "$2" "$3" "$4"
    echo x |socat - "$1:$4:$2" >/dev/null 2>&1  #热身包两个
    echo x |socat - "$1:$4:$2" >/dev/null 2>&1
    #echo "reshen:$tmp"
    tmpacc='--'"(loss$p_count/$p_count)"
    tmpacci=0
    #echo "socat_online_latency:"
    for((i=1;i<="$p_count";i++)) ;do    #测试$p_count次，以获取延时平均值和丢包率
        tmp_sctolsc=$( (time echo x|socat - "$1:$4:$2") 2>&1)
        if [[ "$tmp_sctolsc" =~ "home"|"root" ]] ;then
            tmp_sctolsc=$(echo "$tmp_sctolsc" |gawk -F"[\t ms]" '/^real.*[0-9]+m[0-9]+.*s$/{print $3}')
            tmpacc=$(echo "$tmpacc $tmp_sctolsc" |gawk '{printf("%.3f\n",$1+$2)}')
            ((tmpacci+=1))
        fi
    done
    #echo "==soc: $tmpacc"
    ((tmp_sctolsc="$p_count"-"$tmpacci"))
    [[ $tmpacc =~ '-' ]] ||tmpacc="$(echo "$tmpacc $tmpacci $3" |gawk '{printf("%i\n",(1000*$1/$2-$3)/2)}')""ms(loss$tmp_sctolsc/$p_count)"
    echo "$tmpacc"
}
ssh_scan_tcp_latency() {  #$0 $1(端口号) $2(需要减去的修正值) $3(对端地址)
    [[ -z $2 ]] &&set -- "$1"  2   "$p_address"
    [[ -z $3 ]] &&set -- "$1" "$2" "$p_address"
    timeout 1 ssh -oBatchMode=yes -oStrictHostKeyChecking=no $p_uuid@"$3" -p"$1" -v >/dev/null 2>&1  #热身包两个
    timeout 1 ssh -oBatchMode=yes -oStrictHostKeyChecking=no $p_uuid@"$3" -p"$1" -v >/dev/null 2>&1
    tmpacc='--'"(loss$p_count/$p_count)"
    tmpacci=0
    for((i=1;i<="$p_count";i++)) ;do    #测试$p_count次，以获取延时平均值和丢包率
        tmp_sssclt=$( (time timeout 2 ssh -oBatchMode=yes -oStrictHostKeyChecking=no $p_uuid@"$3" -p"$1" -v) 2>&1)
        if [[ "$tmp_sssclt" =~ "established" ]] ;then
            tmp_sssclt=$(echo "$tmp_sssclt" |gawk -F"[\t ms]" '/^real.*[0-9]+m[0-9]+.*s$/{print $3}')
            tmpacc=$(echo "$tmpacc $tmp_sssclt" |gawk '{printf("%.3f\n",$1+$2)}')
            ((tmpacci+=1))
        fi
    done
    ((tmp_sssclt="$p_count"-"$tmpacci"))
    [[ $tmpacc =~ '-' ]] ||tmpacc=$(echo "$tmpacc $tmpacci $2" |gawk '{printf("%i\n",1000*$1/$2/2-$3)}')"ms(loss$tmp_sssclt/$p_count)"
    echo "$tmpacc"
}
iperf3_online_scan_tcp_bandwidth() {  #$0 $1(端口号)
    tmpup='-'
    tmpif=$(iperf3 -c "$p_address" -p"$1" -P32 |tail -n 5) #开32线程并发测试上行 使用2>&1反而会露出信息到屏幕
    #echo "=bandwidth=: $tmpup"
    if echo "$tmpif" |grep -qEi "sum.*sender" ;then
        #echo "iperf3-tcp-if-true"
        tmpup=$(echo "$tmpif" |grep -Ei "sum.*sender" |grep -oEi "[0-9\.]+\s[MGT]bits/sec" |grep -oEi "[0-9\.]+\s[MGT]" |tr -d ' ')
    elif [[ "$tmpif" =~ "onnection refused" ]] ;then
        #echo "iperf3-tcp-if-refused"
        tmpup='refused'
    elif [[ "$tmpif" =~ "such file or directory" ]] ;then
        tmpup='no-host'
    fi
    tmpdn='-'
    tmpif=$(iperf3 -c "$p_address" -p"$1" -P32 -R |tail -n 5)  #开32线程并发测试下行
    #echo "=bandwidth-dn=: $tmpdn"
    if echo "$tmpif" |grep -qEi "sum.*sender" ;then
        tmpdn=$(echo "$tmpif" |grep -Ei "sum.*sender" |grep -oEi "[0-9\.]+\s[MGT]bits/sec" |grep -oEi "[0-9\.]+\s[MGT]" |tr -d ' ')
    elif [[ "$tmpif" =~ "onnection refused" ]] ;then
        tmpdn='refused'
    elif [[ "$tmpif" =~ "such file or directory" ]] ;then
        tmpdn='no-host'
    fi
    echo "↑$tmpup/↓$tmpdn"
}
iperf3_online_scan_udp_bandwidth() {  #$0 $1(端口号)
    tmpup='-'
    tmpif=$(iperf3 -c "$p_address" -p"$1" -b1024G -u |tail -n 5)  #开1024G带宽测试上行
    #echo "=bandwidth=: $tmpup"
    if echo "$tmpif" |grep -qEi "0\.00-10\.00.*.[0-9\.]+\s[MGT]bits/sec" ;then
        tmp_ipfolsc=$(echo "$tmpif" |grep -Ei "0\.00-10\.00.*.[0-9\.]+\s[MGT]bits/sec" |head -n 1 |grep -oEi "[0-9\.]+\s[MGT]bits/sec" |grep -oEi "[0-9\.]+\s[MGT]" |tr -d ' ')
        tmpup=$tmp_ipfolsc'(loss'$(echo "$tmpif" |grep -Ei "0\.00-10\.00.*.[0-9\.]+\s[MGT]bits/sec" |head -n 1 |grep -oEi "\([0-9%\.]+\)" |grep -oEi "[0-9%\.]+")')'
        tmpup=$tmpup'±'$(echo "$tmpif" |grep -Ei "0\.00-10\.00.*.[0-9\.]+\s[MGT]bits/sec" |head -n 1 |grep -oEi "[0-9\.]+\sms" |tr -d ' ')
    elif [[ "$tmpif" =~ "onnection refused" ]] ;then
        tmpup='refused'
    elif [[ "$tmpif" =~ "such file or directory" ]] ;then
        tmpup='no-host'
    fi
    tmpdn='-'
    tmpif=$(iperf3 -c "$p_address" -p"$1" -b1024G -u -R |tail -n 6)  #开1024G带宽测试下行
    #echo "=bandwidth-dn=: $tmpdn"
    if echo "$tmpif" |grep -qEi "0\.00-10\.00.*.[0-9\.]+\s[MGT]bits/sec" ;then
        tmp_ipfolsc=$(echo "$tmpif" |grep -Ei "0\.00-10\.00.*.[0-9\.]+\s[MGT]bits/sec" |head -n 1 |grep -oEi "[0-9\.]+\s[MGT]bits/sec" |grep -oEi "[0-9\.]+\s[MGT]" |tr -d ' ')
        tmpdn=$tmp_ipfolsc'(loss'$(echo "$tmpif" |grep -Ei "0\.00-10\.00.*.[0-9\.]+\s[MGT]bits/sec" |head -n 1 |grep -oEi "\([0-9%\.]+\)" |grep -oEi "[0-9%\.]+")')'
        tmpdn=$tmpdn'±'$(echo "$tmpif" |grep -Ei "0\.00-10\.00.*.[0-9\.]+\s[MGT]bits/sec" |head -n 1 |grep -oEi "[0-9\.]+\sms" |tr -d ' ')
    elif [[ "$tmpif" =~ "onnection refused" ]] ;then
        tmpup='refused'
    elif [[ "$tmpif" =~ "such file or directory" ]] ;then
        tmpdn='no-host'
    fi
    echo ↑$tmpup/↓$tmpdn
}
nmap_scan() {  #$0 $1(tcp udp) $2(端口号)
    [[ $1 =~ t ]] &&set -- 'sT' "$2" &&nmp='tcp'
    [[ $1 =~ u ]] &&set -- 'sU' "$2" &&nmp='udp'
    tmp_nmpsc="-:-"
    tmp_nmpsc_if=$(local_smart_exec "nmap $p_address -Pn -$1 -p$2" 2>&1)
    tmp_nmpsc=$(echo -e "$tmp_nmpsc_if" |grep -i "$2\/$nmp")
    [[ -z $tmp_nmapsc ]] &&tmp_nmapsc=$(echo -e "$tmp_nmpsc_if" |grep -oiE "requires.*root")
    echo "$tmp_nmpsc" |tr -s ' ' |cut -d' ' -f2-3 |tr ' ' ':' 
}
ssh_scan_tcp() {  #$0 $1(tcp端口号)
    tmp_sssc=$(timeout 3 ssh -oBatchMode=yes -oStrictHostKeyChecking=no $p_uuid@"$p_address" -p"$1" -v 2>&1)
    if [[ $tmp_sssc =~ "established" ]] ;then
        echo 'established:-'
    elif [[ $tmp_sssc =~ "onnection srefused" ]] ;then
        echo 'refused:-'
    else
        echo 'timeout:-'
    fi
}
printf "."  # echo "==6.3==="


#6.4 解析和实现端口扫描的所有方法
#6.4.1 ssh扫描方法
state_tcp="echo -:-"
latency_tcp="echo -"
state_udp="echo local_need_nmap:-"
latency_udp="echo -"
if [[ $nif_localop =~ "s"|"n" &&! $nif_remoteop =~ "t" && $nif_remoteop =~ "u" ]] ;then
    state_tcp1() { echo "默认ssh模式:无法扫描udp" ;}
    state_tcp="state_tcp1"
elif [[ $nif_localop =~ "s"|"n" &&$nif_remoteop =~ "t" &&! $nif_remoteop =~ "c"|"i" ]] ;then
    state_tcp2() { ssh_scan_tcp "$1" ;}
    latency_tcp2() { ssh_scan_tcp_latency "$1" ;}
    state_tcp="state_tcp2"
    latency_tcp="latency_tcp2"
elif [[ $nif_localop =~ "s"|"n" &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "i" && -z $iperf3_remote &&! $nif_remoteop =~ "c" ]] ;then
    state_tcp3() { echo "远端主机:未安装iperf3" ;}
    state_tcp="state_tcp3"
elif [[ $nif_localop =~ "s"|"n" &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "i" && -n $iperf3_remote &&! $nif_remoteop =~ "f" ]] ;then
    state_tcp4() {
        iperf3sv_start t "$1"
        tmp_ssi=$result_iperf3sv_start
        if [[ $tmp_ssi = "$1" ]] ;then
            tmp_ssi=$(ssh_scan_tcp "$1")'/iperf3'
            portsv_stop t "$1" "iperf3" >/dev/null ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1-state,远端机-关闭$p_address:iperf3失败.得去手动检查!囧"
        fi
        echo "$tmp_ssi"
    }
    latency_tcp4() {
        iperf3sv_start t "$1"
        tmp_ssilt=$result_iperf3sv_start
        if [[ $tmp_ssilt = "$1" ]] ;then
            tmp_ssilt=$(ssh_scan_tcp_latency "$1")
            portsv_stop t "$1" "iperf3" >/dev/null ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1-latency,远端机-关闭$p_address:iperf3失败.得去手动检查!囧"
        fi
        echo "$tmp_ssilt"
    }
    state_tcp="state_tcp4"
    latency_tcp="latency_tcp4"
elif [[ $nif_localop =~ "s"|"n" &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "i" && -n $iperf3_remote &&$nif_remoteop =~ "f" ]] ;then
    state_tcp5() {
        fwdrl_add t "$1" "$iperf3sv_port"
        tmp_ssif="$result_fwdrl_add"
        if [[ $tmp_ssif =~ "false"|"exists" ]] ;then
            echo "$tmp_ssif"
            return 1
        fi
        tmp_ssif=$(ssh_scan_tcp "$1")'/iperf3'
        echo "$tmp_ssif"
        fwdrl_del t "$1" "$iperf3sv_port" >/dev/null 2>&1 ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1>$iperf3sv_port-state,远端机-删除$p_address:iptables规则失败.得去手动检查!囧\n规则删除命令：$cmd_del"
    }
    latency_tcp5() {
        fwdrl_add t "$1" "$iperf3sv_port"
        tmp_ssiflt="$result_fwdrl_add"
        if [[ $tmp_ssiflt =~ "false"|"exists" ]] ;then
            echo "$tmp_ssiflt"
            return 1
        fi
        tmp_ssiflt=$(ssh_scan_tcp_latency "$1")
        echo "$tmp_ssiflt"
        fwdrl_del t "$1" "$iperf3sv_port" >/dev/null 2>&1 ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1>$iperf3sv_port-state,远端机-删除$p_address:iptables规则失败.得去手动检查!囧\n规则删除命令：$cmd_del"
    }
    state_tcp="state_tcp5"
    latency_tcp="latency_tcp5"
elif [[ $nif_localop =~ "s"|"n" &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "c" && -z $socat_remote &&! $nif_remoteop =~ "i" ]] ;then
    state_tcp6() { echo "远端主机:未安装socat" ;}
    state_tcp="state_tcp6"
elif [[ $nif_localop =~ "s"|"n" &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "c" && -z $socat_remote &&$nif_remoteop =~ "i" && -z $iperf3_remote ]] ;then
    state_tcp7() { echo "远端主机未安:装iperf3与socat" ;}
    state_tcp="state_tcp7"
elif [[ $nif_localop =~ "s"|"n" &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "c" && -n $socat_remote &&(! $nif_remoteop =~ "i" ||-z $iperf3_remote) &&! $nif_remoteop =~ "f" ]] ;then
    state_tcp8() {
        socatsv_start t "$1"
        tmp_ssc="$result_socatsv_start"
        if [[ $tmp_ssc = "$1" ]] ;then
            tmp_ssc=$(ssh_scan_tcp "$1")'/socat'
            portsv_stop t "$1" "socat" >/dev/null ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1-state,远端机-关闭$p_address:socat失败.得去手动检查!囧"
        fi
        echo "$tmp_ssc"
    }
    latency_tcp8() {
        socatsv_start t "$1"
        tmp_ssclt="$result_socatsv_start"
        if [[ $tmp_ssclt = "$1" ]] ;then
            tmp_ssclt=$(ssh_scan_tcp_latency "$1")
            portsv_stop t "$1" "socat" >/dev/null ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1-latency,远端机-关闭$p_address:socat失败.得去手动检查!囧"
        fi
        echo "$tmp_ssclt"
    }
    state_tcp="state_tcp8"
    latency_tcp="latency_tcp8"
elif [[ $nif_localop =~ "s"|"n" &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "c" && -n $socat_remote &&(! $nif_remoteop =~ "i" ||-z $iperf3_remote) &&$nif_remoteop =~ "f" ]] ;then
    state_tcp9() {
        fwdrl_add t "$1" "$socatsv_tcp_port"
        tmp_sscf="$result_fwdrl_add"
        if [[ $tmp_sscf =~ "false"|"exists" ]] ;then
            echo "$tmp_sscf"
            return 1
        fi
        tmp_sscf=$(ssh_scan_tcp "$1")'/socat'
        echo "$tmp_sscf"
        fwdrl_del t "$1" "$socatsv_tcp_port" >/dev/null 2>&1 ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1>$socatsv_tcp_port-state,远端机-删除$p_address:iptables规则失败.得去手动检查!囧\n规则删除命令：$cmd_del"
    }
    latency_tcp9() {
        fwdrl_add t "$1" "$socatsv_tcp_port"
        tmp_sscflt="$result_fwdrl_add"
        if [[ $tmp_sscflt =~ "false"|"exists" ]] ;then
            echo "$tmp_sscflt"
            return 1
        fi
        tmp_sscflt=$(ssh_scan_tcp_latency "$1")
        echo "$tmp_sscflt"
        fwdrl_del t "$1" "$socatsv_tcp_port" >/dev/null 2>&1 ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1>$socatsv_tcp_port-latency,远端机-删除$p_address:iptables规则失败.得去手动检查!囧\n规则删除命令：$cmd_del"
    }
    state_tcp="state_tcp9"
    latency_tcp="latency_tcp9"
fi
#printf "."  # echo "==6.4.1==="

#6.4.2 nmap扫描方法(对部分ssh方法进行重写和覆盖)
if [[ $nif_localop =~ "n" &&-z $nmap_local ]] ;then
    def_warning "本端主机未安装nmap,仍使用默认的ssh做tcp的state扫描,udp的将忽略"
elif [[ $nif_localop =~ "n" &&-n $nmap_local &&$nif_remoteop =~ "t"|"u" &&! $nif_remoteop =~ "c"|"i"|"f" ]] ;then
    if [[ $nif_remoteop =~ "t" ]] ;then
        state_tcp10() { nmap_scan t "$1" ;}
    fi
    if [[ $nif_remoteop =~ "u" ]] ;then
        state_udp10() { nmap_scan u "$1" ;}
    fi
    state_tcp="state_tcp10"
    state_udp="state_udp10"
elif [[ $nif_localop =~ "n" &&-n $nmap_local &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "i" && -n $iperf3_remote &&! $nif_remoteop =~ "f" ]] ;then
    state_tcp11() {
        iperf3sv_start t "$1"
        tmp_ni=$(result_iperf3sv_start)
        if [[ $tmp_ni = "$1" ]] ;then
            tmp_ni=$(nmap_scan t "$1")'/iperf3'
            portsv_stop t "$1" "iperf3" >/dev/null ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1-state,远端机-关闭$p_address:iperf3失败.得去手动检查!囧"
        fi
        echo "$tmp_ni"
    }
    state_tcp="state_tcp11"
elif [[ $nif_localop =~ "n" &&-n $nmap_local &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "i" && -n $iperf3_remote &&$nif_remoteop =~ "f" ]] ;then
    state_tcp12() {
        fwdrl_add t "$1" "$iperf3sv_port"
        tmp_nif="$result_fwdrl_add"
        if [[ $tmp_nif =~ "false"|"exists" ]] ;then
            echo "$tmp_nif"
            return 1
        fi
        tmp_nif=$(nmap_scan t "$1")'/iperf3'
        echo "$tmp_nif"
        fwdrl_del t "$1" "$iperf3sv_port" >/dev/null 2>&1 ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1>$iperf3sv_port-state,远端机-删除$p_address:iptables规则失败.得去手动检查!囧\n规则删除命令：$cmd_del"
    }
    state_tcp="state_tcp12"
elif [[ $nif_localop =~ "n" &&-n $nmap_local &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "c" && -n $socat_remote &&(! $nif_remoteop =~ "i" ||-z $iperf3_remote) &&! $nif_remoteop =~ "f" ]] ;then
    state_tcp13() {
        socatsv_start t "$1"
        tmp_nc="$result_socatsv_start"
        if [[ $tmp_nc = "$1" ]] ;then
            tmp_nc=$(nmap_scan t "$1")'/socat'
            portsv_stop t "$1" "socat" >/dev/null ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1-state,远端机-关闭$p_address:socat失败.得去手动检查!囧"
        fi
        echo "$tmp_nc"
    }
    state_tcp="state_tcp13"
elif [[ $nif_localop =~ "n" &&-n $nmap_local &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "c" && -n $socat_remote &&(! $nif_remoteop =~ "i" ||-z $iperf3_remote) &&$nif_remoteop =~ "f" ]] ;then
    state_tcp14() {
        fwdrl_add t "$1" "$socatsv_tcp_port"
        tmp_ncf="$result_fwdrl_add"
        if [[ $tmp_ncf =~ "false"|"exists" ]] ;then
            echo "$tmp_ncf"
            return 1
        fi
        tmp_ncf=$(nmap_scan t "$1")'/socat'
        echo "$tmp_ncf"
        fwdrl_del t "$1" "$socatsv_tcp_port" >/dev/null 2>&1 ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1>$socatsv_tcp_port-state,远端机-删除$p_address:iptables规则失败.得去手动检查!囧\n规则删除命令：$cmd_del"
    }
    state_tcp="state_tcp14"
fi
if [[ $nif_localop =~ "n" &&-z $nmap_local ]] ;then
    :
elif [[ $nif_localop =~ "n" &&-n $nmap_local &&$nif_remoteop =~ "u" &&$nif_remoteop =~ "c" && -n $socat_remote &&! $nif_remoteop =~ "f" ]] ;then
    state_udp15() {
        socatsv_start u "$1"
        tmp_ncu="$result_socatsv_start"
        if [[ $tmp_ncu = "$1" ]] ;then
            tmp_ncu=$(nmap_scan u "$1")'/socat'
            portsv_stop u "$1" "socat" >/dev/null ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试udp:$1-state,远端机-关闭$p_address:socat失败.得去手动检查!囧"
        fi
        echo "$tmp_ncu"
    }
    state_udp="state_udp15"
elif [[ $nif_localop =~ "n" &&-n $nmap_local &&$nif_remoteop =~ "u" &&$nif_remoteop =~ "c" && -n $socat_remote &&$nif_remoteop =~ "f" ]] ;then
    state_udp16() {
        fwdrl_add u "$1" "$socatsv_udp_port"
        tmp_ncuf="$result_fwdrl_add"
        if [[ $tmp_ncuf =~ "false"|"exists" ]] ;then
            echo "$tmp_ncuf"
            return 1
        fi
        tmp_ncuf=$(nmap_scan u "$1")'/socat'
        echo "$tmp_ncuf"
        fwdrl_del u "$1" "$socatsv_udp_port" >/dev/null 2>&1 ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试udp:$1>$socatsv_udp_port-state,远端机-删除$p_address:iptables规则失败.得去手动检查!囧\n规则删除命令：$cmd_del"
    }
    state_udp="state_udp16"
fi
#printf "."  # echo "==6.4.2==="

#6.4.3 socat方法
if [[ $nif_localop =~ "c" &&-z $socat_local ]] ;then
    latency_tcp17() { echo "local_need_socat" ;}
    latency_tcp="latency_tcp17"
elif [[ $nif_localop =~ "c" &&-n $socat_local &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "c" && -z $socat_remote ]] ;then
    latency_tcp17_2() { echo "remote_need_socat" ;}
    latency_tcp="latency_tcp17_2"
elif [[ $nif_localop =~ "c" &&-n $socat_local &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "c" && -n $socat_remote &&! $nif_remoteop =~ "f" ]] ;then
    latency_tcp18() {
        socatsv_start t "$1"
        tmp_cc="$result_socatsv_start"
        if [[ $tmp_cc = "$1" ]] ;then
            tmp_cc=$(socat_online_scan_latency t "$1")
            portsv_stop t "$1" "socat" >/dev/null ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1-latency,远端机-关闭$p_address:socat失败.得去手动检查!囧"
        fi
        echo "$tmp_cc"
    }
    latency_tcp="latency_tcp18"
elif [[ $nif_localop =~ "c" &&-n $socat_local &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "c" && -n $socat_remote &&$nif_remoteop =~ "f" ]] ;then
    latency_tcp19() {
        fwdrl_add t "$1" "$socatsv_tcp_port"
        tmp_ccf="$result_fwdrl_add"
        if [[ $tmp_ccf =~ "false"|"exists" ]] ;then
            echo "$tmp_ccf"
            return 1
        fi
        tmp_ccf=$(socat_online_scan_latency t "$1")
        echo "$tmp_ccf"
        fwdrl_del t "$1" "$socatsv_tcp_port" >/dev/null 2>&1 ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1>$socatsv_tcp_port-latency,远端机-删除$p_address:iptables规则失败.得去手动检查!囧\n规则删除命令：$cmd_del"
    }
    latency_tcp="latency_tcp19"
fi
if [[ $nif_localop =~ "c" &&-z $socat_local ]] ;then
    :
elif [[ $nif_localop =~ "c" &&-n $socat_local &&$nif_remoteop =~ "u" &&$nif_remoteop =~ "c" && -n $socat_remote &&! $nif_remoteop =~ "f" ]] ;then
    latency_udp20() {
        socatsv_start u "$1"
        tmp_ccu="$result_socatsv_start"
        if [[ $tmp_ccu = "$1" ]] ;then
            tmp_ccu=$(socat_online_scan_latency u "$1")
            portsv_stop u "$1" "socat" >/dev/null ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试udp:$1-latency,远端机-关闭$p_address:socat失败.得去手动检查!囧"
        fi
        echo "$tmp_ccu"
    }
    latency_udp="latency_udp20"
elif [[ $nif_localop =~ "c" &&-n $socat_local &&$nif_remoteop =~ "u" &&$nif_remoteop =~ "c" && -n $socat_remote &&$nif_remoteop =~ "f" ]] ;then
    latency_udp21() {
        fwdrl_add u "$1" "$socatsv_udp_port"
        tmp_ccuf="$result_fwdrl_add"
        if [[ $tmp_ccuf =~ "false"|"exists" ]] ;then
            echo "$tmp_ccuf"
            return 1
        fi
        tmp_ccuf=$(socat_online_scan_latency u "$1")
        echo "$tmp_ccuf"
        fwdrl_del u "$1" "$socatsv_udp_port" >/dev/null 2>&1 ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试udp:$1>$socatsv_udp_port-latency,远端机-删除$p_address:iptables规则失败.得去手动检查!囧\n规则删除命令：$cmd_del"
    }
    latency_udp="latency_udp21"
fi
#printf "."  # echo "==6.4.3==="

#6.4.4 iperf3方法
 bandwidth_tcp="echo -"
 bandwidth_udp="echo -"
if [[ $nif_localop =~ "i" &&-z $iperf3_local ]] ;then
    bandwidth_tcp22() { echo "local_need_iperf3" ;}
    bandwidth_tcp="bandwidth_tcp22"
elif [[ $nif_localop =~ "i" &&-n $iperf3_local &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "i" && -z $iperf3_remote ]] ;then
    bandwidth_tcp23() { echo "remote_need_iperf3" ;}
    bandwidth_tcp="bandwidth_tcp23"
elif [[ $nif_localop =~ "i" &&-n $iperf3_local &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "i" && -n $iperf3_remote &&! $nif_remoteop =~ "f" ]] ;then
    bandwidth_tcp24() {
        iperf3sv_start t "$1"
        tmp_ii=$(result_iperf3sv_start)
        if [[ $tmp_ii = "$1" ]] ;then
            tmp_ii=$(iperf3_online_scan_tcp_bandwidth "$1")
            portsv_stop t "$1" "iperf3" >/dev/null ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1-bandwidth,远端机-关闭$p_address:iperf3失败.得去手动检查!囧"
        fi
        echo "$tmp_ii"
    }
    bandwidth_tcp="bandwidth_tcp24"
elif [[ $nif_localop =~ "i" &&-n $iperf3_local &&$nif_remoteop =~ "t" &&$nif_remoteop =~ "i" && -n $iperf3_remote &&$nif_remoteop =~ "f" ]] ;then
    bandwidth_tcp25() {
        fwdrl_add t "$1" "$iperf3sv_port"
        tmp_iif="$result_fwdrl_add"
        if [[ $tmp_iif =~ "false"|"exists" ]] ;then
            echo "$tmp_iif"
            return 1
        fi
        tmp_iif=$(iperf3_online_scan_tcp_bandwidth "$1")
        echo "$tmp_iif"
        fwdrl_del t "$1" "$iperf3sv_port" >/dev/null 2>&1 ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1>$iperf3sv_port-bandwidth,远端机-删除$p_address:iptables规则失败.得去手动检查!囧\n规则删除命令：$cmd_del"
    }
    bandwidth_tcp="bandwidth_tcp25"
fi
if [[ $nif_localop =~ "i" &&-z $iperf3_local ]] ;then
    :
elif [[ $nif_localop =~ "i" &&-n $iperf3_local &&$nif_remoteop =~ "u" &&$nif_remoteop =~ "i" && -n $iperf3_remote &&! $nif_remoteop =~ "f" ]] ;then
    bandwidth_udp26() {
        iperf3sv_start tu "$1"
        tmp_iiu=$result_iperf3sv_start
        if [[ $tmp_iiu = "$1" ]] ;then
            tmp_iiu=$(iperf3_online_scan_udp_bandwidth "$1")
            portsv_stop t "$1" "iperf3" >/dev/null ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试udp:$1-bandwidth,远端机-关闭$p_address:iperf3失败.得去手动检查!囧"
        fi
        echo "$tmp_iiu"
    }
    bandwidth_udp="bandwidth_udp26"
elif [[ $nif_localop =~ "i" &&-n $iperf3_local &&$nif_remoteop =~ "u" &&$nif_remoteop =~ "i" && -n $iperf3_remote &&$nif_remoteop =~ "f" ]] ;then
    bandwidth_udp27() {
        fwdrl_add t "$1" "$iperf3sv_port"
        tmp_iiuf="$result_fwdrl_add"
        if [[ $tmp_iiuf =~ "false"|"exists" ]] ;then
            echo "$tmp_iiuf"
            return 1
        fi
        fwdrl_add u "$1" "$iperf3sv_port"
        tmp_iiuf="$result_fwdrl_add"
        if [[ $tmp_iiuf =~ "false"|"exists" ]] ;then
            echo "$tmp_iiuf"
            fwdrl_del t "$1" "$iperf3sv_port" >/dev/null 2>&1 ||def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1>$iperf3sv_port-bandwidth,远端机-删除$p_address:iptables规则失败.得去手动检查!囧\n规则删除命令：$cmd_del"
            return 1
        fi
        tmp_iiuf=$(iperf3_online_scan_udp_bandwidth "$1")
        echo "$tmp_iiuf"
        tmp1_iiuf=0
        tmp2_iiuf=0
        if ! fwdrl_del t "$1" "$iperf3sv_port" >/dev/null 2>&1 ;then
            tmp1_iiuf=1
            tmp3_iiuf=$cmd_del
        fi
        if ! fwdrl_del u "$1" "$iperf3sv_port" >/dev/null 2>&1 ;then
            tmp2_iiuf=1
            tmp4_iiuf=$cmd_del
        fi
        if [[ $tmp1_iiuf = 1 &&$tmp2_iiuf = 0 ]] ;then
            def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试tcp:$1>$iperf3sv_port-bandwidth,远端机-删除$p_address:iptables规则失败.得去手动检查!囧\n规则删除命令：$tmp3_iiuf"
        elif [[ $tmp1_iiuf = 0 &&$tmp2_iiuf = 1 ]] ;then
            :  #def_sv_rr_rl_exit 6 "$nif_localop-$nif_remoteop测试udp:$1>$iperf3sv_port-bandwidth,远端机-删除$p_address:iptables规则失败.得去手动检查!囧0\n规则删除命令：$tmp4_iiuf"
        elif [[ $tmp1_iiuf = 1 &&$tmp2_iiuf = 1 ]] ;then
            def_sv_rr_rl_exit -1 "$nif_localop-$nif_remoteop测试tcp:$1>$iperf3sv_port-bandwidth,远端机-删除$p_address:iptables规则失败.得去手动检查!囧\n规则删除命令：$tmp3_iiuf"
            def_sv_rr_rl_exit  6 "$nif_localop-$nif_remoteop测试udp:$1>$iperf3sv_port-bandwidth,远端机-删除$p_address:iptables规则失败.得去手动检查!囧\n规则删除命令：$tmp4_iiuf"
        fi
    }
    bandwidth_udp="bandwidth_udp27"
fi
#echo "===state_tcp :$state_tcp"
printf "."  # echo "==6.4.4==="


#7 调用处理方法或输出相关信息
#7.1 调用端口检测方法并输出结果
ports_exp=''
for i in ${nif_ports//,/ }; do  #将形如"22,80,8088-8090,8099"的$p_tcp变量转换为"22 80 {8080..8090} 8099"形式，可在for中使用
    #echo "$i" |grep -q -E '[0-9]+-[0-9]+' &&i='{'${i//-/..}'}'
    [[ "$i" =~ [0-9]+-[0-9]+ ]] &&i='{'${i//-/..}'}'
    ports_exp=$ports_exp' '$i
done
ports_exp=${ports_exp//-/}
#printf ' port   tcp-port-state tcp-port-service latency bandwidth  udp-port-state udp-port-service latency bandwidth'
#port   tcp-port-state    service     latency   bandwidth      udp-port-state service latency bandwidth
#  80   open/filter       http        ?60ms     200↓/20↑Mb     -              -       -            -
#5353   nping             http        ?60ms     200↓/20↑Mb     -              -       -            -
[[ $sign_only_wait = "true" ]] ||printf '\n%11s   %-21s%-25s%-21s%-s' "port" "state" "service" "latency" "bandwidth(bps)"
#TCP     state        service             latency             bandwidth
#19765   open         unknown-iperf3      505ms(loss0/2)      ↑1.90G(0.29%)±0.001ms/↓1.88G(3.2%)±0.002ms
for i in $(eval echo "$ports_exp") ;do  #取出每组端口，做tcp检测动作
    state_result=$(eval $state_tcp "$i")
    tcp_state=$(echo "$state_result" |gawk -F'[: ]' '{print $1}')
    tcp_service=$(echo "$state_result" |gawk -F'[: ]' '{print $2}')
    printf '\n%11s   %-21s%-25s' "$i/tcp" "$tcp_state" "$tcp_service"
    tcp_latency=$(eval $latency_tcp "$i")
    [[ $tcp_latency =~ $i$ ]] &&tcp_latency='-'
    printf '%-21s' "$tcp_latency"
    tcp_bandwidth=$(eval $bandwidth_tcp "$i")
    [[ $tcp_bandwidth =~ $i$ ]] &&tcp_bandwidth='-'
    printf '%-s' "$tcp_bandwidth"
    #echo "$i"  #debug
done
#printf '\n UDP        state        service                latency                bandwidth'
#printf '\n\n%5s  %-13s%-20s%-20s%-s' "  UDP " "state" "service" "latency" "bandwidth"
for i in $(eval echo "$ports_exp") ;do  #取出每组端口，做udp检测动作
    state_result=$(eval $state_udp "$i")
    udp_state=$(echo "$state_result" |gawk -F'[: ]' '{print $1}')
    udp_service=$(echo "$state_result" |gawk -F'[: ]' '{print $2}')
    printf '\n%11s   %-21s%-25s' "$i/udp" "$udp_state" "$udp_service"
    udp_latency=$(eval $latency_udp "$i")
    [[ $udp_latency =~ $i$ ]] &&udp_latency='-'
    printf '%-21s' "$udp_latency"
    udp_bandwidth=$(eval $bandwidth_udp "$i")
    [[ $udp_bandwidth =~ $i$ ]] &&udp_bandwidth='-'
    printf '%-s' "$udp_bandwidth"
    #echo "$i"  #debug
done
[[ $sign_only_wait = "true" ]] ||
if [[ $tmp1$tmp2$tmp3$tmp5$tmp6$tmp7 =~ $p_user &&$p_user != "$p_uuid" &&-n $p_exe$p_rn$p_ri$p_rc ]] ;then
    [[ $tmp1$tmp2$tmp3$tmp5$tmp6$tmp7 =~ "root" ]] ||def_warning "对远端$p_address没有root权限.故不支持-[远端机软件安装/卸载] [远端机forward设置] [1024以下端口的联机测试] [执行远程命令]"
fi
if [[ -n $p_ln$p_li$p_lc$p_le$p_lp ]] ;then
    local_smart_exec whoami |grep -q root ||def_warning "对本端没有root权限.故不支持-[udp延时测试] [本端机软件安装/卸载]"
fi
#printf "."  # echo "==7.1==="


#7.2 主机信息输出
#remote   lan-nic   lan-ip           lan-gateway      domain             external-iP      -a                 ping
#         p_address 123.132.123.123  555.555.555.555                     555.555.555.555                         
[[ -z $remote_sys ]] &&remote_sys='-'
[[ -z $remote_lan_nic ]] &&remote_lan_nic='-'
[[ -z $remote_lan_ip ]] &&remote_lan_ip='-'
[[ -z $remote_lan_gateway ]] &&remote_lan_gateway='-'
[[ -z $remote_name ]] &&remote_name='-'
[[ -z $remote_ip ]] &&remote_ip='-'
[[ -z $local_sys ]] &&local_sys='-'
[[ -z $local_nic ]] &&local_nic='-'
[[ -z $local_ip ]] &&local_ip='-'
[[ -z $local_gateway ]] &&local_gateway='-'
[[ -z $local_name ]] &&local_name='-'
[[ -z $local_dns ]] &&local_dns='-'
printf '\n%11s   %-10s%-17s%-17s%-19s%-17s%-19s%-s' "remote-sys" "lan-nic" "lan-ip" "lan-gateway" "domain" "external-ip" "-a" "ping"
printf '\n%11s   %-10s%-17s%-17s%-19s%-17s%-19s%-s' "$remote_sys" "$remote_lan_nic" "$remote_lan_ip" "$remote_lan_gateway" "$remote_name" "$remote_ip" "$p_address" "$remote_ping"
#system   lan-nic   lan-ip           lan-gateway      domain             dns-serv
#         p_address 123.132.123.123  555.555.555.555                     555.555.555.555                         
printf '\n%11s   %-10s%-17s%-17s%-19s%-s' "local-sys" "lan-nic" "lan-ip" "lan-gateway" "domain" "dns-serv"
printf '\n%11s   %-10s%-17s%-17s%-19s%-s' "$local_sys" "$local_nic" "$local_ip" "$local_gateway" "$local_name" "$local_dns"
echo
echo
[[ -n $p_wait && $(local_smart_exec whoami) =~ "root" ]] &&local_smart_exec "nmap -traceroute -Pn -sn $p_address" |grep -vEi "Nmap.*done.*IP.*address.*scanned |Starting.*Nmap.*nmap.*org |^$" &&echo #2>/dev/null
#printf "."  # echo "==7.2==="



#8 远程执行-exe参数命令
[[ -z $p_exe ]] ||remote_smart_cp_exec "$p_exe"
#printf "."  # echo "==8==="



#9 清场
remote_port_if=$(remote_smart_exec "/usr/sbin/ss -nlp4tu" "ss -nlp4tu" 2>/dev/null)
remote_fwdrl_if=$(remote_smart_exec "iptables -tnat -nvL" 2>/dev/null)
def_sv_rr_rl_exit -1 "byebye"  2>/dev/null
{   echo
    nowtime_tmp="$(date +"%T.%3N")"
    echo "运行结束$nowtime_tmp :"
    if [[ -z $nmap_local ]] ;then printf "%-23s" "本端-nmap:未安装" ;else printf "%-23s" "本端-nmap:已安装" ;fi
    if [[ -z $iperf3_local ]] ;then printf "%-18s" 'iperf3:未安装' ;else printf "%-18s" 'iperf3:已安装' ;fi
    if [[ -z $socat_local ]] ;then printf "%-18s" 'socat:未安装' ;else printf "%-18s" 'socat:已安装' ;fi
    if [[ -z $expect_local ]] ;then printf "%-18s" 'expect:未安装' ;else printf "%-18s" 'expect:已安装' ;fi
    if [[ -z $sshpass_local ]] ;then printf "%-18s" 'sshpass:未安装' ;else printf "%-18s" 'sshpass:已安装' ;fi
    echo
    if [[ -z $nmap_remote ]] ;then printf "%-23s" "远端-nmap:未安装" ;else printf "%-23s" "远端-nmap:已安装" ;fi
    if [[ -z $iperf3_remote ]] ;then printf "%-18s" 'iperf3:未安装' ;else printf "%-18s" 'iperf3:已安装' ;fi
    if [[ -z $socat_remote ]] ;then printf "%-18s" 'socat:未安装' ;else printf "%-18s" 'socat:已安装' ;fi
    printf "%-18s" "forward:$fwdset_remote"
    echo
    echo "远端-服务(sudo ss -nlp4tu ) :"
    [[ -n $remote_port_if ]] &&echo "$remote_port_if"
    echo "远端-iptables-nat(sudo iptables -tnat -nvL ) :"
    [[ -n $remote_fwdrl_if ]] &&echo "$remote_fwdrl_if" |grep -vE "^$"
    echo
    echo "一些可能用的上的命令 :"
    echo "forward设置查看 :cat /proc/sys/net/ipv4/ip_forward"
    echo "forward开启或关闭 :sysctl -w net.ipv4.ip_forward=1   sysctl -w net.ipv4.ip_forward=0"
    echo "iptables转发规则查看 :sudo -tnat -nvL"
    echo "iptable转发规则添加和删除 :"
    echo "(这里假设系统的ip是1.2.3.4 网卡名称是ens160 目标动作是将传给1.2.3.4的22200端口的数据转发给1.2.3.4的22201)"
    echo "添加tcp转发 :sudo iptables -t nat -A PREROUTING -p tcp -i ens160 -d 1.2.3.4 --dport 22200 -j DNAT --to 1.2.3.4:22201"
    echo "添加udp转发 :sudo iptables -t nat -A PREROUTING -p udp -i ens160 -d 1.2.3.4 --dport 22200 -j DNAT --to 1.2.3.4:22201"
    echo "删除tcp转发 :sudo iptables -t nat -D PREROUTING -p tcp -i ens160 -d 1.2.3.4 --dport 22200 -j DNAT --to 1.2.3.4:22201"
    echo "删除udp转发 :sudo iptables -t nat -D PREROUTING -p udp -i ens160 -d 1.2.3.4 --dport 22200 -j DNAT --to 1.2.3.4:22201"
    echo "安装nmap：(centos) sudo yum install -y nmap         或(ubuntu) sudo apt install -y nmap"
    echo "安装iperf3：(centos) sudo yum install -y iperf3     或(ubuntu) sudo apt install -y iperf3"
    echo "安装socat：(centos) sudo yum install -y socat       或(ubuntu) sudo apt install -y socat"
    echo "卸载nmap：(centos) sudo yum remove -y nmap          或(ubuntu) sudo apt remove -y nmap"
    echo "卸载iperf3：(centos) sudo yum remove -y iperf3      或(ubuntu) sudo apt remove -y iperf3"
    echo "卸载socat：(centos) sudo yum remove -y socat        或(ubuntu) sudo apt remove -y socat"
    echo "版本查看 :expect -V   sshpass -V   nmap -V   iperf3 -v   socat -V"
    echo "系统存在的服务查看 :sudo ss -ntulp |grep iperf3      或sudo ss -ntulp |grep socat"
    echo "杀掉服务进程:sudo ss -ntulp查看对于端口服务的pid,然后 kill pid"
} >>"$p_log"
#[[ -z $p_wait ]] ||$p_wait
#printf "."  # echo "==9==="
exit 0



#10 收集的笔记资料
print_note(){
cat <<'EOF'
10 收集的笔记资料
10.1 nmap笔记
man主页 :https://linux.die.net/man/1/nmap
nmap检测路由和扫描udp都需要root权限
扫描tcp端口：nmap -p 443 1.2.3.4
扫描udp端口：sudo  nmap -p 443 1.2.3.4 -sU
同时扫描tcp和udp :sudo  nmap -p 443 1.2.3.4 -sT -sU

仅查询dns解析
使用系统的dns解析查询：
nmap -Pn -sn --system-dns 1.2.3.4
手动指定dns(8.8.8.8)解析查询：
nmap -Pn -sn --dns-servers 8.8.8.8 1.2.3.4

仅追踪路由：
sudo nmap abc.com -traceroute -Pn -sn
-Pn :无ping
-sn :跳过端口扫描
-n :跳过dns解析
--system-dns :使用系统dns服务器
--dns-servers 8.8.8.8 :指定8.8.8.8做dns服务器


10.2 随机未使用端口方法
获取一个：
comm -23 <(seq 49152 65535 |sort) <(ss -Htan |cut -d: -f2 |sort -u) |shuf |head -n 1
获取三个：
comm -23 <(seq 49152 65535 |sort) <(ss -Htan | awk '{print $4}' | cut -d':' -f2 | sort -u) | shuf | head -n 3


10.3 nping笔记
nping是nmap的一个子功能，也可以的单独安装
man主页 :https://linux.die.net/man/1/nping
安装：rpm -vh https://nmap.org/dist/nping-0.7.70-1.x86_64.rpm
卸载：rpe -e  nping-0.7.70-1.x86_64
测tcp :nping abc.com -p 4434          (或测 nping abc.com -p 4434 --tcp-connect)
测udp :nping --udp 1.2.3.4 -p 443    (一般不会由结果，udp需要使用回声模式)
指定测试次数 :nping --tcp-connect google.com -p 443 -c 2    (不需要root)
测试tcp :nping --tcp abc.com -p 443        (源端口也是443，因此此模式会需要root权限)

回声模式，服务端(需要root,普通模式不需要):
sudo nping --es asdf --ep 443 --once        (--es 为服务端,密码为asdf，--once为一次性服务)
客户端：
sudo nping --udp --ec asdf abc.com --ep 443   (--ec 为客户端，密码为asdf)
sudo nping --tcp --ec asdf abc.com --ep 443
*nping回声模式做udp测试貌似不支持nat


10.4 iperf3笔记
iperf3  1024端口以下需要root
参考 :https://www.jianshu.com/p/01cc7f11bbb9
服务端
iperf3 -s -p 443         侦听443，默认支持tcp\udp，看客户端如何选择
iperf3 -s -p 443 -1      服务器加入-1 表示接受一次测试后自动退出
iperf3 -s -p 443 -D -1   -D表示后台执行，-1表示执行一次后退出

客户端
iperf3 -c 1.2.3.4 -p 443                模式测试tcp
iperf3 -c 1.2.3.4 -p 443 -P 32          32线程测试上行
iperf3 -c 1.2.3.4 -p 443 -P 32 -R       32线程测试下行
iperf3 -c 1.2.3.4 -p 443 -u -b 300M     指定300M带宽规格上限，测试udp
iperf3 -c 1.2.3.4 -p 443 -u -b 300M -R  测试udp下行（服务器向客户机发包）
-t 时间，默认10秒
-i 每次发包间隔 默认为1秒 0表示禁用 -i 0  -i 1
-4 仅侦听ipv4


10.5 nc笔记
参考 :https://cikeblog.com/iptables.html
参考 :https://serverfault.com/questions/512722/how-to-automatically-close-netcat-connection-after-data-is-sent
nc版本有点多：bsd netcat   gnu netcat   ncat
侦听udp :nc -lu 8888
连接udp :nc -u 1.2.3.4 888
nc -lu -w0 888
nc -c echo
nc -lu -c hostname -p 443;date

10.6 iptables笔记
添加udp转发 :sudo iptables -t nat -A PREROUTING -p udp -i ens160 -d 1.2.3.4 --dport 80 -j DNAT --to 1.2.3.4:22
删除方法    :sudo iptables -t nat -D PREROUTING -p udp -i ens160 -d 1.2.3.4 --dport 80 -j DNAT --to 1.2.3.4:22
添加tcp转发 :sudo iptables -t nat -A PREROUTING -p tcp -i ens160 -d 1.2.3.4 --dport 80 -j DNAT --to 1.2.3.4:22
删除方法    :sudo iptables -t nat -D PREROUTING -p tcp -i ens160 -d 1.2.3.4 --dport 80 -j DNAT --to 1.2.3.4:22
查看nat转发策略：iptables -tnat -nL
或详细信息：iptables -t nat -nvL （带包数统计）

转发要生效，需要开启forward(置1)
查看forward设置状态 :cat /proc/sys/net/ipv4/ip_forward
开启 :sysctl -w net.ipv4.ip_forward=1
关闭 :sysctl -w net.ipv4.ip_forward=0


10.7 socat笔记
socat -u -t 0 udp-l:7777 system:date
socat -t 0 - udp:1.2.3.4:7777
socat -u -t 0 udp-l:5000 system:"date +"%T.%3N""
socat -t0 PIPE udp-recvfrom:5000;date +"%T.%3N"
date +"%T.%3N" ;echo x |socat -t 0 - udp:abc.com:5000;date +"%T.%3N"
socat -t0 PIPE udp-recvfrom:5000


服务端：
tcp :socat TCP4-LISTEN:2000,fork EXEC:"echo hello"
udp :socat UDP4-LISTEN:2000,fork EXEC:"echo hello"
不加fork连接一次后会自动 :socat TCP4-LISTEN:2000 EXEC:date
客户端：
udp :time echo x |socat -t0 - udp:abc.com:2000
tcp :time echo x |socat     - tcp:1.2.3.4:2000


10.8 netperf笔记
github地址 :https://github.com/HewlettPackard/netperf
netperf编译安装方法：
cd到源代码目录
./configure --enable-demo=yes
make &&makeinstall

服务侦听
netserver -p 222 -4


10.9 其他
echo $aaa    没有换行符，结果不会换行
需要换行请加双引号：echo "$aaa"
参考 :https://serverfault.com/questions/179200/difference-beetween-dnat-and-redirect-in-iptables

date显示纳秒格式
date +%s%N
date +"%T.%3N"

EOF
}
