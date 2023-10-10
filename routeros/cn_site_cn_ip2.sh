#!/bin/bash
export LC_ALL=en_US.UTF-8

###################################################
# 执行后会生成routeros脚本，用于设定routeros上中国网站dns解析策略的： CN_SITE.rsc  和用于生成中国ip地址簿的：CN_IP.rsc  
# 将这些脚本通过winbox 上传到routeros，然后通过winbox 的命令行终端，依次执行所有脚本,例如：import CN_SITE.rsc 、import CN_IP.rsc
# 然后可以在 ip/dns/static  或/ip/Firewall/address list 中查看域名和ip清单
###################################################

curl -s https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt | \
sed -e 's/^/add address=/g' -e 's/$/ list=CN_IP/g' | \
sed \
-e $'1i\\\n/ip firewall address-list' \
-e $'1i\\\nremove [/ip firewall address-list find list=CN_IP]' \
-e $'1i\\\nremove [/ip firewall address-list find list=PRIVATE_IP]' \
-e $'1i\\\nadd address=10.0.0.0/8 list=PRIVATE_IP' \
-e $'1i\\\nadd address=172.16.0.0/12 list=PRIVATE_IP' \
-e $'1i\\\nadd address=192.168.0.0/16 list=PRIVATE_IP' > CN_IP.rsc


echo '/ip dns static' > CN_SITE.rsc && \
echo 'remove [/ip dns static find comment=CN_SITE type=FWD]' >> CN_SITE.rsc && \
curl -s https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf | \
sed -e 's%^server=/%add name=%g' | \
sed 's%/114.114.114.114$% match-subdomain=yes forward-to=202.96.134.133 comment=CN_SITE%g' >> CN_SITE.rsc


