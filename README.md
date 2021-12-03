nif.sh (network info shell)  
ver :0.7.5.20211202  
用于检测两台Linux之间 [端口状态] [延时] [带宽] [路由追踪]  
下载: wget https://raw.githubusercontent.com/orwithout/scripts/main/nif.sh  
  
快速使用  
① cd切换到下载目录  
② 给与执行权限 chmod +x ./nif.sh  
  
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
  
更多说明 :  
https://raw.githubusercontent.com/orwithout/scripts/main/nif.sh.help  
