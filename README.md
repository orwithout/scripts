## latencysee.sh
  
快速使用  
① 下载: wget https://raw.githubusercontent.com/orwithout/scripts/main/net/latencysee.sh  
② cd 进入到下载目录  
③ 给与执行权限 chmod +x ./latencysee.sh  
④ ./latencysee.sh   -h    #获取使用帮助  
   
使用示例  
./latencysee.sh   nping-tcp:qq.com:80    #测试qq.com 80端口延时  
./latencysee.sh   nping-udp:114.114.114.114:53    #测试114.114.114.114的udp-53端口延时  

![这是图片](./net/latencysee.sh.png "Magic Gardens")  
  
## nif.sh
(newwork info)用于检测两台Linux之间 [端口状态] [延时] [带宽] [路由追踪]  
  
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
扫描主机信息和路由追踪  
./nif.sh 8.8.8.8 -wait  
全量测试自动向导  
./nif.sh -bump  
  
脚本会按需申请对远端机的ssh连接密码,以及本地sudo提权,  
然后按需在本端和远端机上安装/使用 sshpass nmap socat iperf3 (使用完后自动清理)  
和按需在远端机上设置forward、iptables转发 (使用完后自动复原)  
  
使用说明 :  
https://raw.githubusercontent.com/orwithout/scripts/main/net/nif.sh.help  
