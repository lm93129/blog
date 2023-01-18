#!/bin/bash
#自写自用脚本
# 颜色
blue='\033[0;34m'
yellow='\033[0;33m'
green='\033[0;32m'
red='\033[0;31m'
plain='\033[0m'

#检查是否为Root
[ $(id -u) != "0" ] && { echo -e "${red}[错误]${plain} 你必须以 root 用户执行此安装程序"; exit 1; }

echo "
---------------------------------------------------------
请选择需要安装的程序，输入相应序列号回车，本脚本只对centos有效
脚本执行完毕后，如果需要安装其他的，请运行sh myshell.sh继续安装
---------------------------------------------------------
【0】更新脚本
【1】初始化系统环境
【2】安装nginx
【3】安装java
【4】安装docker
【5】安装nodejs
【6】安装ssh-key
【7】查看服务器信息并测试磁盘io和网络
【8】iptables端口转发脚本
【9】iptables防火墙设置脚本
---------------------------------------------------------
"
read os
clear

url='https://lm93129.coding.net/p/mysave/d/mysave/git/raw/master'

#更新脚本
if test $os == 0 ;then
echo '******更新脚本中******';
wget -O myshell.sh https://fs.tn/myshell.sh && bash myshell.sh;
echo '******更新完成******';
sh myshell.sh;
fi

#安装基础组件
if test $os == 1 ;then
echo '******设定系统源******';
wget -P /etc/yum.repos.d/ http://mirrors.aliyun.com/repo/epel-7.repo;
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo;
yum clean all;
yum makecache;
echo '******更新系统******';
yum -y update;
echo '******设定时区为上海时区******';
cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;
echo '******安装ntp******';
yum -y install ntp;
echo '******正在启动自动对时******';
service ntpd start;
systemctl enable ntpd.service;
systemctl disable chronyd;
echo '******关闭防火墙******';
systemctl stop firewalld.service;
systemctl disable firewalld.service;
echo '******安装git、curl、screen等基础组件******';
yum -y install epel-release;
yum -y install curl screen git nano vim htop unzip;
echo '******禁用SELinux******';
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config;
setenforce 0;
sh myshell.sh;
fi

#安装nginx
if test $os == 2 ;then
echo '******安装nginx******';
yum install -y nginx;
echo '******启动nginx******';
systemctl start nginx;
systemctl enable nginx;
echo '******nginx配置文件地址******';
nginx -t;
sh myshell.sh;
fi

#安装java1.8
if test $os == 3 ;then
echo '******正在下载java，请等待几分钟******';
wget ${url}/rpm/jdk-8u191-linux-x64.rpm;
echo -e '下载完成：			  [\033[32m  OK  \033[0m]';
echo '******正在安装程序******';
yum -y localinstall jdk-8u191-linux-x64.rpm;
sh myshell.sh;
fi

#安装docker程序
if test $os == 4 ;then
echo '******正在下载安装依赖，请等待******';
yum -y install yum-utils device-mapper-persistent-data lvm2;
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo;
echo '******开始安装docker******'
yum -y install docker-ce ;
service docker start;
systemctl enable docker;
mkdir -p /etc/docker;
tee /etc/docker/daemon.json <<-'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
  "max-size": "500m",
  "max-file": "3"
  },
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 10,
  "registry-mirrors": [
    "https://dockerhub.azk8s.cn",
    "https://reg-mirror.qiniu.com"
    ]
}
EOF
echo '******重载配置******';
systemctl daemon-reload;
systemctl restart docker;
echo '******docker已启动******';
echo '******安装docker compose******';
curl -L "${url}/docker-compose/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose;
chmod +x /usr/local/bin/docker-compose;
echo '******docker-compose已安装******';
sh myshell.sh;
fi

#安装nodejs8.14.0和pm2、yarn
if test $os == 5 ;then
echo '******正在下载nodejs8.14.0，请等待几分钟******';
wget ${url}/rpm/node-v8.14.0-linux-x64.tar.xz -P ~/Downloads;
echo -e '下载完成：			  [\033[32m  OK  \033[0m]';
echo '******正在安装程序******';
tar -xJf ~/Downloads/node-v8.14.0-linux-x64.tar.xz -C /opt;
echo 'PATH=$PATH:/opt/node-v8.14.0-linux-x64/bin' >> /etc/profile;
source /etc/profile;
echo '******设置npm源为淘宝源，并安装常用的pm2和yarn******';
npm config set registry https://registry.npm.taobao.org;
npm -g install pm2 yarn;
echo '******安装完成,请重新连接虚拟机******';
node -v;
npm -v;
sh myshell.sh;
fi

#服务器测试脚本
if test $os == 6 ;then
clear
echo '******输入github账户，并确保改账户存在公钥******';
read name
echo '******自动从github读取公钥******';
wget https://github.com/lm93129/SSHKEY_Installer/raw/master/key.sh --no-check-certificate&& bash key.sh $name;
sh myshell.sh;
fi

#服务器测试脚本
if test $os == 7 ;then
echo '******开始测试******';
wget -qO- bench.sh | bash;
fi

#iptables端口转发脚本
if test $os == 8 ;then
echo '******开始测试******';
wget ${url}/iptables-pf.sh && bash iptables-pf.sh;
fi

#iptables防火墙设置脚本
if test $os == 9 ;then
echo '******开始测试******';
wget ${url}/ban_iptables.sh && bash ban_iptables.sh;
fi

exit 0