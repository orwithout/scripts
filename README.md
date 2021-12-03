nif.sh (network info shell)  
ver :0.7.5.20211202  
用于检测两台Linux之间 [端口状态] [延时] [带宽] [路由追踪]  
  
快速使用  
① 下载: wget https://raw.githubusercontent.com/orwithout/scripts/main/nif.sh  
② cd 进入到下载目录  
③ 给与执行权限 chmod +x ./nif.sh  
  
使用示例  
测试tcp :  
./nif.sh qq.com 80  
测试udp :  
./nif.sh 8.8.8.8 -n-u:53 -lnu -etlso  
测试延时 :  
./nif.sh 8.8.8.8 -c-c:8080 -bump  
测试带宽  
./nif.sh 8.8.8.8 -i-i:8080 -bump  
全量测试自动向导
./nif.sh -bump  
  
脚本会按需申请对远端机的ssh连接密码,以及本地sudo提权,  
然后按需在本端和远端机上安装/使用 sshpass nmap socat iperf3 (使用完后自动需清理)  
和按需在远端机上设置forward、iptables转发 (使用完后自动复原)  
  
使用说明 :  
https://raw.githubusercontent.com/orwithout/scripts/main/nif.sh.help  
  
结果展示  
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
MAC Address: 00:50:56:8B:73:F3 (VMware)  
TRACEROUTE  
HOP RTT     ADDRESS  
1   0.33 ms 2.3.4.1  
2   0.66 ms 1.2.3.4  
------------------------------------------------  
  
