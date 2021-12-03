nif.sh (network info shell)  
ver :0.7.5.20211202  
用于检测两台Linux之间 [端口状态] [延时] [带宽] [路由追踪]  
  
快速使用  
① 下载: wget https://raw.githubusercontent.com/orwithout/scripts/main/nif.sh  
② cd切换到下载目录  
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
  
脚本会自动申请对远端机的ssh连接密码,以及本地sudo提权 ,  
然后按需在本端和远端机上安装/使用 sshpass nmap socat iperf3 ,
按需在远端机是设置forward、iptables转发 ,  
  
使用说明 :  
https://raw.githubusercontent.com/orwithout/scripts/main/nif.sh.help  
