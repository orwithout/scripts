#!/bin/bash
export LC_ALL=en_US.UTF-8

###################################################
# 执行后会生成routeros脚本，用于设定routeros上中国网站dns解析策略的： CN_SITE_0.rsc  ~  CN_SITE_x.rsc  和用于生成中国ip地址簿的：CN_IP.rsc  
# 将这些脚本通过winbox 上传到routeros，然后通过winbox 的命令行终端，依次执行所有脚本,例如：import CN_SITE_0.rsc 、import CN_IP.rsc 然后可以在 ip/dns/static  或/ip/Firewall/address list 中查看域名和ip清单
###################################################




# 域名项目的URL
SRC='https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf'

# 获取URL的基本文件名
SRC_FILE=$(basename $SRC)

# 下载源文件
curl -s $SRC -o $SRC_FILE

# 分割文件
split -l 9000 "$SRC_FILE" "split_"


# 依次处理每个分割文件
i=0
for FILE in split_*; do
    # 定义输出文件名
    OUTPUT="CN_SITE_${i}.rsc"
    
    # 添加头部内容
    echo "/ip dns static" > "$OUTPUT"
    
    # 使用sed处理内容并追加到输出文件
    sed -e 's%^server=/%add name=%g' "$FILE" | sed 's%/114.114.114.114$% match-subdomain=yes forward-to=202.96.134.133 comment=CN_SITE%g' >> "$OUTPUT"
    
    # 删除处理过的分割文件
    rm "$FILE"
    
    # 增加计数器
    i=$((i+1))
done


sed -i -e $'2i\\\nremove [/ip dns static find comment=CN_SITE type=FWD]' CN_SITE_0.rsc



curl -s https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt | \
sed -e 's/^/add address=/g' -e 's/$/ list=CN_IP/g' | \
sed \
-e $'1i\\\n/ip firewall address-list' \
-e $'1i\\\nremove [/ip firewall address-list find list=CN_IP]' \
-e $'1i\\\nadd address=10.0.0.0/8 list=CN_IP comment=PRIVATE_IP' \
-e $'1i\\\nadd address=172.16.0.0/12 list=CN_IP comment=PRIVATE_IP' \
-e $'1i\\\nadd address=192.168.0.0/16 list=CN_IP comment=PRIVATE_IP' \
> CN_IP.rsc
