title: 在VPS上搭建自己的ss服务端
date: 2015-10-18 20:16:59
tags: [vps,SS]
categories:
description: 使用shadowsocks-libev搭建，内存占用小（600k左右），低 CPU 消耗。多用户配置，不能直接在配置文件中设置多端口，需要使用多个配置文件开启多个实例才行。简单启动:setsid ss-server -c /etc/shadowsocks-libev/config.json -u  查看启动:ps -ef | grep ss-server | grep -v ps | grep -v grep
---

## 乱谈在前

搭建时使用的[shadowsocks-libev](https://github.com/shadowsocks/shadowsocks-libev)。

该版本的特点是内存占用小（600k左右），低 CPU 消耗，甚至可以安装在基于 OpenWRT 的路由器上。

Go 版是二进制安装，无需编译，非常简单快捷。

Python版的Shadowsocks易部署，后期升级维护都非常方便，相当适合新手，支持的特性也最多，稳定性好，运行效率高。

而目前只有 Python 和 Go 版是支持在配置文件里直接设置多端口的，至于 libev 版则需要使用多个配置文件并开启多个实例才行。


```shell
{
    "server":"0.0.0.0",
    "port_password":{
        "8388":"password1",
        "8389":"password2",
        "8390":"password3",
        "8391":"password4"
    },
    "timeout":300,
    "method":"aes-256-cfb"
}
```

所谓的多用户，其实就是把不同的端口给不同的人使用，每个端口则对应不同的密码。Python 和 Go 版通过简单的修改单一配置文件，然后重启程序即可。
自用的话，没必要使用多用户了。占用内存小的，满适合的。适合的，才是最好的。

Python版的Shadowsocks部署：
[史上最详尽Shadowsocks从零开始一站式FQ教程(G+)需FQ](http://shadowsocks.blogspot.com/2015/01/shadowsocks.html)

网络上还有各种一键安装脚本，可以使用。

自用VPS
HK
[1核CPU、256MB内存、256MB vSwap、10GB SSD硬盘、500GB/月流量,1Gbps端口、1个IPv4、4个IPv6 $25每年，可月付$2.95](https://my.hostus.us/aff.php?aff=671&pid=183)
[1核CPU、512MB内存、512MB vSwap、15GB SSD硬盘、750GB/月流量,1Gbps端口、1个IPv4、4个IPv6 $35每年，可季付$10](https://my.hostus.us/aff.php?aff=671&pid=179)
[2核CPU、768MB内存、768MB vSwap、30GB SSD硬盘、2TB/月流量,1Gbps端口、1个IPv4、4个IPv6 $48每年，可季付$15](https://my.hostus.us/aff.php?aff=671&pid=180)
US 洛杉矶&亚特兰大&达拉斯
[HostUS US LEB OVZ Special - 768MB RAM - 2048 GB/月流量 $10每年](https://my.hostus.us/aff.php?aff=671&pid=103)

HK 一般没货 看到就抢吧
[1核CPU、512MB内存、512MB vSwap、10GB SSD硬盘、750GB/月流量,1Gbps端口、1个IPv4、4个IPv6 $25每年](https://my.hostus.us/aff.php?aff=671&pid=178)
[1核CPU、768MB内存、768MB vSwap、20GB SSD硬盘、2000GB/月流量,1Gbps端口、1个IPv4、4个IPv6 $35每年](https://my.hostus.us/aff.php?aff=671&pid=177)

搬瓦工便宜型号没货了

[archlinux维基ss详细安装](https://wiki.archlinux.org/index.php/Shadowsocks_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

## 安装SHADOWSOCKS服务端

### CentOS：

使用CentOS，版本最好是CentOS 6.x 32或64位

1. 先安装必须的包：

```shell
yum install -y gcc automake autoconf libtool make build-essential autoconf libtool gcc
yum install -y curl curl-devel zlib-devel openssl-devel perl perl-devel cpio expat-devel gettext-devel
yum install -y git
```

2. 然后通过git下载源码：

```shell
git clone https://github.com/madeye/shadowsocks-libev.git
```

3. 从源码编译安装：

```shell
cd shadowsocks-libev
./configure
make
make install
```

同样在源码目录下，执行以下命令卸载
```shell
make uninstall
make clean
```
其他Unix-like的系统，特别是Debian-based的Linux发行版如： Ubuntu, Debian or Linux Mint
```shell
apt-get install build-essential autoconf libtool libssl-dev
git clone https://github.com/madeye/shadowsocks-libev.git
cd shadowsocks-libev
./configure
make
make install
```

### Ubuntu/Debian：

1. 先安装必须的包：

```shell
apt-get install build-essential autoconf libtool libssl-dev gawk debhelper git
```

2. 然后通过git下载源码：

```shell
git clone https://github.com/shadowsocks/shadowsocks-libev.git
```

3. 然后生成deb包并安装，一步步执行（留意是否出错 如果出错需要检查系统或者之前的步骤）：

```shell
cd shadowsocks-libev
dpkg-buildpackage -us -uc
cd ..
dpkg -i shadowsocks-libev*.deb
```

### 直接从作者提供的软件源安装（Ubuntu/Debian）

由于作者更新源码后并不一定更新这些预编译的包，所以无法保证最新版本，但步骤比较简单。不推荐这种方式。

先添加GPG Key：

```shell
wget -O- http://shadowsocks.org/debian/1D27208A.gpg | sudo apt-key add -
```

Ubuntu 12.04 / Debian Wheezy以上版本(libssl 1.0.1以上)：

在/etc/apt/sources.list末尾添加：

```shell
deb http://shadowsocks.org/debian wheezy main
```

Ubuntu 11.04 / Debian Squeeze（libssl 0.9.8~1.0.0)：

在/etc/apt/sources.list末尾添加：

```shell
deb http://shadowsocks.org/debian squeeze main
```

最后安装

```shell
apt-get update
apt-get install shadowsocks-libev
```

## 配置与启动

### 配置
配置文件为：/etc/shadowsocks-libev/config.json，格式说明：


```shell
# 如果etc目录没有权限，需要命令解除限制
restorecon -R -v /etc
# 如果文件权限问题
chattr -i config.json
# 如果etc下没有shadowsocks-libev目录
mkdir shadowsocks-libev

cat > /etc/shadowsocks-libev/config.json << EOF
# 也可以直接建立配置文件
cat << "EOF" > /etc/shadowsocks.json
{
    "server":"my_server_ip",
    "server_port":8388,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"mypassword",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false,
    "workers": 1
}
```

其中：
```shell
server：主机域名或者IP地址，尽量填IP
server_port：服务器监听端口
password：密码
method：加密方式 默认为table,其他有rc4,rc4-md5,aes-128-cfb, aes-192-cfb, aes-256-cfb,bf-cfb, camellia-128-cfb, camellia-192-cfb,camellia-256-cfb, cast5-cfb, des-cfb
如果客户端有OpenWRT路由器等设备，或者路由器性能较弱，推荐rc4-md5，性能更好；否则可以选用安全性更好的aes-256-cfb等，虽然计算复杂度上升，会有性能的损失，不过对于PC机以及现在的智能手机来说没有任何问题。性能没多大损失。

timeout：连接超时时间，单位秒。要适中。
fast_open：	use [TCP_FASTOPEN](https://github.com/shadowsocks/shadowsocks/wiki/TCP-Fast-Open), true / false
workers：	number of workers, available on Unix/Linux
```
注意引号。

### 启动

Ubuntu/Debian 通过deb包安装的（deb包安装的默认会开启自启）：

```shell
service shadowsocks-libev restart
```

CentOS，拷贝启动脚本shadowsocks-libev到/etc/init.d/目录下后，启动：

```shell
# 启动
ssserver -c /etc/shadowsocks.json -d start
ssserver -c /etc/shadowsocks.json -d stop
```

shadowsocks-libev脚本
```shell
cat << "EOF" > /etc/init.d/
#!/bin/sh
#
#====================================================================
# Run level information:
# chkconfig: 2345 99 99
# Description: lightweight secured scoks5 proxy
# processname: ss-server
# Run "/sbin/chkconfig --add shadowsocksd" to add the Run levels.
#====================================================================
NAME=shadowsocks
PIDFILE=/var/run/$NAME.pid
DAEMON=/usr/local/bin/ssserver
# DAEMON_OPTS="-c /etc/shadowsocks.json"
DAEMON_OPTS="-c /etc/shadowsocks-libev/config.json"
start() {
    echo -n "Starting daemon: "$NAME
    touch $PIDFILE
    chown root:root $PIDFILE
    start-stop-daemon --make-pidfile --bashadowsocks ckground --start --quiet --pidfile $PIDFILE  --chuid root:root --exec $DAEMON -- $DAEMON_OPTS || true
    echo "."
}
stop() {
    echo -n "Stopping daemon: "$NAME
    start-stop-daemon --stop --quiet --oknodo --pidfile $PIDFILE || true
    echo "."
}
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        echo -n "Restarting daemon: "$NAME
        stop
        sleep 1
        start
        ;;
    *)
    echo "Usage: "$1" {start|stop|restart}"
    exit 1
esac
exit 0
EOF
```
```shell
chmod u+x /etc/init.d/shadowsocksd
# update-rc.d shadowsocksd defaults
启动：/etc/init.d/shadowsocksd start
停止：/etc/init.d/shadowsocksd stop
重启：/etc/init.d/shadowsocksd restart
查看状态：/etc/init.d/shadowsocksd status
```
需要开机自启的，可以建立符号连接到/etc/rc.d/SXXshadowsocks-libev
ln -s /etc/init.d/shadowsocksd /etc/rc.d/rc3.d/S100shadowsocksd
/sbin/chkconfig --add shadowsocksd
或者直接调用[ss-server命令](https://github.com/shadowsocks/shadowsocks-libev#usage)运行，

直接使用下面的简单命令启动
```shell
setsid ss-server -c /etc/shadowsocks-libev/config.json -u
```

查看shadowsocks是否正确启动并监听相应端口，看到有ss-server进程LISTEN正确的端口就表示成功：

```shell
netstat -lnp
```

也可以用
```shell
ps -ef | grep ss-server | grep -v ps | grep -v grep
```
查看进程是否存在。

## 升级/优化

### 升级/卸载

已安装旧版本的 shadowsocks 需要升级的话，需下载本脚本的最新版，运行卸载命令后，再次执行本脚本即可安装最新版。
```shell
./shadowsocks-libev.sh uninstall
```
### GoAgent与Shadowsocks混合代理
Chrome+SwitchSharp实现GoAgent与Shadowsocks混合代理
在SwitchSharp的配置中新建情景模式，HTTP、FTP为未加密连接可填入Goagent的代理端口配置，而在SOCKS代理中填入Shadowsocks的端口号，如此一来，HTTPS就会自动走shadowsocks，未加密流量就会走goagent，从而不用导入GoAgent CA证书，解决某些强迫症患者的特殊需求。
不过使用此方法带来的问题就是HTTPS的降速，除非你有速度良好的国外VPS，因为大部分国外服务器代理速度都拼不过GAE的。
[原链接](https://cokebar.info/archives/191)
### Shadowsocks优化方案:

#### 搬瓦工优化方案:

```shell
rm -f /sbin/modprobe
ln -s /bin/true /sbin/modprobe
rm -f /sbin/sysctl
ln -s /bin/true /sbin/sysctl
vi /etc/sysctl.conf

# 增加以下内容
fs.file-max = 51200
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
# increase TCP max buffer size settable using setsockopt()
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
# increase Linux autotuning TCP buffer limit
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
# increase the length of the processor input queue
net.core.netdev_max_backlog = 250000
# recommended for hosts with jumbo frames enabled
net.ipv4.tcp_mtu_probing=1
# 增加以上内容

sysctl -p
reboot

# 重启回来继续执行以下命令
apt-get install libnet1
apt-get install libpcap0.8
apt-get install libnet1-dev
apt-get install libpcap0.8-dev
wget https://net-speeder.googlecode.com/files/net_speeder-v0.1.tar.gz
tar zxvf net_speeder-v0.1.tar.gz
sh ./net_speeder/build.sh -DCOOKED
./net_speeder/net_speeder venet0 "tcp" > netlog &
```

注意！

关于apt-get install libnet1报错..
先执行一下
```shell
apt-get update
apt-get upgrade
```
更新完成再安装libnet1试试看..
我在搬瓦工上实测不会报错..
还有..如果是centos的话..是不能这样安装的..

安装[Net_speeder](https://github.com/snooda/net-speeder)
由于TCP的特性导致，每个包发一次，容易掉包。干脆就一个包发两次，有效降低掉包率。

debian/ubuntu安装libnet：
```shell
apt-get install libnet1
```
安装libpcap：
```shell
apt-get install libpcap0.8
```
编译需要安装libnet和libpcap对应的dev包
debian/ubuntu安装libnet-dev：
```shell
apt-get install libnet1-dev
```
安装libpcap-dev：
```shell
apt-get install libpcap0.8-dev
```

centos安装：
```shell
下载epel：https://fedoraproject.org/wiki/EPEL/zh-cn
例：CentOS6 64位：wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
如果是centos5，则在epel/5/下
然后安装epel：rpm -ivh epel-release-X-Y.noarch.rpm
然后即可使用yum安装：yum install libnet libpcap libnet-devel libpcap-devel
下载net-speeder：wget https://net-speeder.googlecode.com/files/net_speeder-v0.1.tar.gz
解压缩：tar -zxvf net_speeder-v0.1.tar.gz
使用方法(需要root权限启动）：
参数：./net_speeder 网卡名 加速规则（bpf规则）
最简单用法： # ./net_speeder venet0 “ip” 加速所有ip协议数据
```

#### Do优化方案:
```shell
vi /etc/sysctl.d/local.conf

# 增加以下内容
fs.file-max = 51200

net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.rmem_default = 65536
net.core.wmem_default = 65536
net.core.netdev_max_backlog = 4096
net.core.somaxconn = 4096

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1

# for high-latency network
net.ipv4.tcp_congestion_control = htcp #如果是do主机+debian7..可以使用hybla参数..其他vps主机如使用htcp报错请更换高版本内核或使用cubic参数

# for low-latency network, use cubic instead
# net.ipv4.tcp_congestion_control = cubic
# 增加以上内容

sysctl –system
ulimit -n 51200
reboot
```

锐速(可选..且只能安装在DO主机上..搬瓦工不支持):

首先去 http://www.serverspeeder.com/  免费注册
```shell
wget http://dl.serverspeeder.com/d/ls/serverSpeederInstaller.tar.gz
tar xzvf serverSpeederInstaller.tar.gz
bash serverSpeederInstaller.sh

vi /serverspeeder/etc/config
rsc="1"
maxmode="1"
advinacc="1"

./serverspeeder/bin/serverSpeeder.sh restart
```

### 使用国外 DNS 造成国内网站访问慢的解决方法

强大虚拟机
听说过 [VirtualBox](https://www.virtualbox.org/) 吗？开源、免费、强大的虚拟机软件。可以装个最配置非常低下的虚拟机，比如 32 MiB 内存甚至 16 MiB 内存的虚拟机（要知道 [64M 内存的 Linux 已经可以跑 WordPress 这庞然大物了](http://blog.kangzj.net/what-can-a-64m-vps-do/)），装个最简单的小 Linux，比如只有 37M 的 Ubuntu Core，然后装上依赖包几乎没有的 dnsmasq，再把 Windows / OS X 的 DNS 设为虚拟机的 IP 地址，于是便可以用了。在当今内存动辄 4 GiB 的情况下，拿 16MiB 内存出来换个更舒畅的上网体验，还是很不错的。

[解决方法详情](http://ttt.tt/50/)

### 非越狱苹果iphone/ipad使用shadowsocks

#### 直接安装Shadowsocks App

由于iOS自身的限制和Shadowsocks app代理方式的限制，我们必须得让Shadowsocks app一直保持开启才可以实现全局代理。如果通常十分钟以后iOS就会自动退出后台的一些第三方应用，那么Shadowsocks app自然也会被退出。这就导致了我们需要过一会就去打开一次Shadowsocks app。

iOS 非越狱的话，可以直接安装 Shadowsocks 的 app，下载地址请[摸我](https://itunes.apple.com/cn/app/shadowsocks/id665729974?mt=8)
中国商店如果已经没有的话，需要切换国别/地区，切换时需账户内余额为0。
可使用美国账号登陆，想要用中国区itunes的时候，可以随时转回来。
 - 先到设置里边，iTunes Store 和 App Store，点击你的apple id，进入
 - 点击查看apple id
 - 输入密码登陆
 - 点进去 country/region那里选取美国，然后点 change country or region，一路点agree
 - 然后还有account setting，重点是city，state，zip，只要这三项对了就没问题了
 - 再是确定啊，什么的你就成功转成美国账号了

美国App Store中Shadowsocks还在，下载地址请[摸我](https://itunes.apple.com/us/app/shadowsocks/id665729974?ls=1&mt=8)

WiFi设置中，http代理地址http://127.0.0.1:8090/proxy.pac

#### 与电脑中同一局域网内，实现iPhone/iPad全局自动翻墻。

 - 勾选电脑客户端的“允许来自局域网的连接”。
 - 获取Pac地址，也很简单。打开我们浏览器，找到这个菜单:工具-Internet选项-链接-局域网设置
 - 获取本机局域网IP地址。快捷操作方法：WIN+R，输入cmd回车，输入ipconfig回车。找到IPv4地址——— 192.168.1.*** 那个，就是你本机ip地址。
 - ipad配置和手机配置。找到WiFi设置，点击你连接上的WiFi后面那个感叹号图标，在最下面，HTTP代理的地方，选择自动，然后在下面填上如 http://你电脑的ip:1080/pac(一般自建端口没改，默认为1080)，接着返回。例如http://192.168.1.228:1080/pac

提醒：1、不要把ip地址填错了，是填你小飞机那台电脑的ip；2、国内网站不会翻墻，只是Google、YouTube这些常见的网站会翻墻；3、自定义需要翻墻的网站请手动添加到“小飞机右键-PAC-编辑本地PAC文件”，然后替换掉里面一个网址就行了。4、开小飞机的电脑关机后，需要关闭掉iPhone/iPad的HTTP代理，不然上不去网。

另外，还可以用百度云存储或者自己的网站空间存储pac文件
编辑pac文件，由于iphone/ipad不支持socks代理，我们这里要自己编辑pac文件。新建proxy.pac文件，写入以下代码：

function FindProxyForURL(url, host) { return "SOCKS 192.168.xxx.xxx:yyyy"; }

192.168.xxx.xxx就是你电脑的ip,yyyy是你刚才配置shadowsocks客户端的那个重要端口。
将proxy上传到云存储，并且复制公开分享的连接,或者你的网站目录中（www.url.com/proxy.pac）
设置 -> 无线局域网-> 点击你连接的无线，在最下边的http代理，选择自动，输入你刚才放置pac文件的地址

pac文件放在云盘上是不可以的啊！

## Linux VPS 服务器后简单的安全设置

查看尝试暴力破解IP

```shell
cat /var/log/secure|awk '/Failed/{print $(NF-3)}'|sort|uniq -c|awk '{print $2"="$1;}'
```
查询出来的结果中包含了“ip地址=数量”就是攻击者信息

### 修改默认端口号22

```shell
vi /etc/ssh/sshd_config

```
找到#port 22
将前面的#去掉,然后修改端口 port 12345 （这里的端口可以自己根据实际情况定义）
为了保险起见，可以将“#port 22”修改为两行“port 22”“port 1234”，1234测试无误后再删掉”port 22″
然后重启ssh服务
```shell
service sshd restart
```

firewall-cmd --zone=public --add-port=1022/tcp --permanent
阿里云添加自定义安全规则https://help.aliyun.com/document_detail/51644.html
https://linux.cn/article-8098-1.html

### 禁用远程root登录

root登录直接就获得权限，而且root这个用户名太常见了。在禁用root登录前首先一定要先增加一个普通权限的用户,并设置密码：
```shell
useradd test
passwd test
```

然后禁止ROOT远程SSH登录：
```shell
vi /etc/ssh/sshd_config


#把其中的
PermitRootLogin yes

#改为
PermitRootLogin no

#如果PermitRootLogin前面的有#的话也一定要删除掉，否则无法生效。

#再重启sshd服务

service sshd restart

#以后我们便可以通过普通权限的ssh账户连接我们的vps，如果需要管理权限的话，可以用下面命令提升到root权限
su root
```

如果root用户有另外一套密码的话会更加有效。


### 使用SSH Key登录VPS，关闭密码登录

1、把自己的公匙放在 https://launchpad.net/ 网站，并得到类似 https://launchpad.net/~showfom/+sshkeys 这样的地址，然后通过以下命令导入你的 Key

```shell
curl https://launchpad.net/~showfom/+sshkeys > ~/.ssh/authorized_keys

# 如果没有 .ssh 目录，可以新建立一个

mkdir .ssh
```

2、也可以直接写入 authorized_keys 文件
```shell
cat >>/root/.ssh/authorized_keys<<EOF

ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAna/D52fTZ1YNjxnwAJAUhxRdPCwar8ZfWLdwHEmT64Zqtxrz65KRxesHFRVND8Xn1GKtuQIQMu/d5fFhEajFbjoSw/n+Mz58irzUXDbE34Y/nxy1/iWc6aJz6lX6wT7nnDcVoqX8Be8j/8sjS7cMFarn3Iy+0bSQNON3681+hEFM7mpoYyqrCVBpARfiiEZb8tNkfzrKJFrciZ87yaKkncPeDCIbYKjuJY2hciK+Y+IptLdoMj5kQkSXStJFQUfFg+s3FQJ9Istu4C7BF3ZafD4mEupA7P90RRUjLj95mUW/P/ebWGsMVbnxz/Xmq3OL/TOuo85umbSN44DmSB3NEQ== showfom-rsa-key-20130701
EOF
```

### shadowsocks的timeout设置

good, 你已经有了一个自己的shadowsocks代理了，现在想要把这个代理公布出去给所有人分享。
但是没有两个小时，代理就没法使用了，为什么？因为你需要额外注意以下事项（以下步骤需要比较高的linux技能）
本文只关注于确保shadowsocks服务还“活着”，如果你希望让其跑得更快，请参考
https://github.com/clowwindy/shadowsocks/wiki/Optimizing-Shadowsocks

超时时间越长，连接被保持得也就越长，导致并发的tcp的连接数也就越多。对于公共代理，这个值应该调整得小一些。推荐60秒。

### 检查操作系统的各种限制
对于openvz的vps，特别需要检查一下
shell# cat /proc/user_beancounters
Version: 2.5
       uid  resource                     held              maxheld              barrier                limit              failcnt
     1005:  kmemsize                  6499239             34332672             50331648             50331648                    0
            lockedpages                     0                    0                12288                12288                    0
            privvmpages                 20185                89959  9223372036854775807  9223372036854775807                    0
            shmpages                      654                  670  9223372036854775807  9223372036854775807                    0
            dummy                           0                    0  9223372036854775807  9223372036854775807                    0
            numproc                        26                  102  9223372036854775807  9223372036854775807                    0
            physpages                   12181                24887                    0                24576                  536
            vmguarpages                     0                    0  9223372036854775807  9223372036854775807                    0
            oomguarpages                 7054                30538  9223372036854775807  9223372036854775807                  473
            numtcpsock                     52                 1500                 1500                 2000             21583239
            numflock                        1                    5  9223372036854775807  9223372036854775807                    0
            numpty                          1                   16  9223372036854775807  9223372036854775807                    0
            numsiginfo                      0                   63  9223372036854775807  9223372036854775807                    0
            tcpsndbuf                 7497680             29165536            104857600            209715200                    0
            tcprcvbuf                18891984             88633288            104857600            209715200                    0
            othersockbuf                39304               386848  9223372036854775807  9223372036854775807                    0
            dgramrcvbuf                     0               166480  9223372036854775807  9223372036854775807                    0
            numothersock                   27                   37                 1500                 2000                    0
            dcachesize                2293779             25165824             25165824             25165824                    0
            numfile                       362                 1910  9223372036854775807  9223372036854775807                    0
            dummy                           0                    0  9223372036854775807  9223372036854775807                    0
            dummy                           0                    0  9223372036854775807  9223372036854775807                    0
            dummy                           0                    0  9223372036854775807  9223372036854775807                    0
            numiptent                      30                   30  9223372036854775807  9223372036854775807                    0
其中 numtcpsock 表示 tcp 连接数。像上面这样的情况，就不适合用于公共代理，因为vps商限制了并发的tcp连接数。
shell# ulimit -n
1024
这个命令检查默认的一个进程可以打开的文件数。1024这个默认值是不够的。推荐设置为8000
shell# ulimit -n 8000
shell# ss-server -s 0.0.0.0 -p 1080 -k xxxx -m rc4
上面启动ss-server的命令只是示意性的，请替换成你自己的启动命令。ulimit的设置是一次性的，每次启动ss-server之前都要设置一下。

### 防止vps被用于暴力破解ssh密码等非法行为
只要shadowsocks被公开出去，肯定会有人拿代理用于暴力破解ssh的密码。
推荐你把shadowsocks限制为只允许访问443和80两个端口。如果你不添加这样的限制，
很多vps商都会因为ssh连接开得太多而暂停对你的服务。
shell# adduser http-ss
shell# su http-ss -c "ss-server -s 0.0.0.0 -p 1080 -k xxxx -m rc4"
让ss-server以特定的用户启动
shell# iptables -t filter -A OUTPUT -d 127.0.0.1 -j ACCEPT
shell# iptables -t filter -m owner --uid-owner http-ss -A OUTPUT -p tcp --sport 1080 -j ACCEPT
shell# iptables -t filter -m owner --uid-owner http-ss -A OUTPUT -p tcp --dport 80 -j ACCEPT
shell# iptables -t filter -m owner --uid-owner http-ss -A OUTPUT -p tcp --dport 443 -j ACCEPT
shell# iptables -t filter -m owner --uid-owner http-ss -A OUTPUT -p tcp -j REJECT --reject-with tcp-reset
对于http-ss用户，限制其不能访问80,443之外的端口

### 防止DMCA Compliant
虽然你已经把shadowsocks限制为只能访问80/443端口，但是对于美国的vps，仍然有额外的一点需要注意。
因为美国的vps需要遵从美国的DMCA版权法律，如果该vps被用于bt下载，而且正好遇上了电影公司设置的蜜罐的话，
你的vps的ip就会被记录下来。然后DMCA Compliant律师函会被送往你的vps商那，然后就会被停止服务。
为了避免shadowsocks帐号被用于bt下载，你不得不对80端口的流量再进一步进行限制
shell# apt-get update && apt-get install -y nginx
安装nginx
server {
    listen 127.0.0.1:3128;
    server_name localhost;
    resolver 8.8.8.8;
    location / {
        set $upstream_host $host;
    if ($request_uri ~ "^/announce.*") {
            return 403;
        }
        if ($request_uri ~ "^.*torrent.*") {
            return 403;
        }
        proxy_set_header Host $upstream_host;
        proxy_pass http://$upstream_host;
        proxy_buffers 8 32k;
        proxy_buffering off;
   }
}
然后配置nginx的server
shell# iptables -t nat -m owner --uid-owner http-ss -A OUTPUT -p tcp --dport 80 -j REDIRECT --to-port 3128
把所有的80端口流量转到nginx来处理

### denyhosts 防 ssh 破解密码
考虑到很多人看不懂 user_beancounters 各项的含义，可以解释一下 numtcpsock 表示 tcp 连接数
防 ssh 破解密码可以 apt-get install denyhosts
[denyhosts](https://github.com/denyhosts/denyhosts)
[通过DenyHosts阻止SSH暴力攻击教程](http://www.bootf.com/571.html)
很多人用的是网上找的一键安装脚本或者傻瓜教程，他们可能没有能力在此基础上再做其它的修改。不如直接提供一个优化好的一键安装脚本。 或许你可以直接改一改我的这个脚本把端口限制加进去。
```shell
#!/bin/bash

apt-get update
apt-get install -y -qq python-pip python-m2crypto supervisor
pip install shadowsocks

PORTS_USED=`netstat -antl |grep LISTEN | awk '{ print $4 }' | cut -d: -f2|sed '/^$/d'|sort`
PORTS_USED=`echo $PORTS_USED|sed 's/\s/$\|^/g'`
PORTS_USED="^${PORTS_USED}$"

SS_PASSWORD=`dd if=/dev/urandom bs=32 count=1 | md5sum | cut -c-32`
SS_PORT=`seq 1025 9000 | grep -v -E "$PORTS_USED" | shuf -n 1`

wget https://raw.githubusercontent.com/shadowsocks/stackscript/master/shadowsocks.json -O /etc/shadowsocks.json
wget https://raw.githubusercontent.com/shadowsocks/stackscript/master/shadowsocks.conf -O /etc/supervisor/conf.d/shadowsocks.conf
wget https://raw.githubusercontent.com/shadowsocks/stackscript/master/local.conf -O /etc/sysctl.d/local.conf

sed -i -e s/SS_PASSWORD/$SS_PASSWORD/ /etc/shadowsocks.json
sed -i -e s/SS_PORT/$SS_PORT/ /etc/shadowsocks.json

sysctl --system

service supervisor stop
echo 'ulimit -n 51200' >> /etc/default/supervisor
service supervisor start

supervisorctl reload
```

### 查看TCP连接数

通过iptables来实现,比如你的shadowsocks本地地址192.168.0.4和端口2009120091端口的统计命令:sudo iptables -I OUTPUT -s 192.168.0.4 -p tcp --sport 20091然后去查看统计tcp连接数信息:sudo iptables -n -v -L -t filter

正常情况下，Shadowsocks服务监听着外网IP的端口，出网，入网IP均为公网IP，如果可以使Shadowsocks使用独立的IP做出网和入网IP，那要准确统计流量就毫无困难了。

每个Shadowsocks都分配公网IP，明显不现实。免费且不限制无限使用的IP，恐怕只有内网的IP段了。配合NAT转发，即可通过公网IP链接至Shadowsocks服务。



步骤：


1. 添加一个loop back用的内网IP，例如10.10.10.10：



ifconfig eth0:ss1 10.10.10.10 netmask 255.255.255.0 up
如果你的网卡不是eth0，就自行修改为其他的。



2. 修改Shadowsocks的配置文件，更改server的IP为内网IP，例如10.10.10.10：


"server":"10.10.10.10",


3. 重新启动Shadowsocks服务



4. 修改/etc/sysctl.conf，确保：



net.ipv4.ip_forward
的值为1，且未被注释。

修改完毕后保存，执行


sysctl -p


5. 因为Shadowsocks服务监听的是内网IP，直接通过公网IP链接至Shadowsocks的端口是不行的，因此这里需要使用NAT进行转发，执行：


iptables -t nat -I PREROUTING -p tcp --dport SHADOWSOCKS监听的端口 -j DNAT --to-destination 10.10.10.10


6. 执行下面两个命令，统计Shadowsocks出网和入网的流量：

iptables -I INPUT -d 10.10.10.10
iptables -I OUTPUT -s 10.10.10.10
其中INPUT是入网流量，也就是用户连接Shadowsocks后，给服务器发送的数据。OUTPUT是出网流量，也就是服务器给用户发送的数据。



完成上面的步骤后，执行iptables，使用-v参数即可查看流量使用情况：


iptables -L -n -v



最后提醒一下：

1. 使用ifconfig添加的IP只是临时的，重启后会消失，可以修改网卡的配置文件(/etc/network/interfaces或/etc/sysconfig/network-scripts/)添加IP，或者把添加IP的命令加到/etc/rc.local里面。

2. iptables添加的规则要保存，否则重启后会消失。

### 安装 CSF 防火墙屏蔽尝试入侵服务器的 IP

CSF 防火墙安装略简单，几个命令即可搞定：
```shell
rm -fv csf.tgz
wget http://www.configserver.com/free/csf.tgz
tar -xzf csf.tgz
cd csf
sh install.sh
```
然后运行
```shell
perl /usr/local/csf/bin/csftest.pl
```
检测是否安装成功

为了防止系统误屏蔽本地 IP，可以修改 /etc/csf/csf.allow 和 /etc/csf/csf.ignore 文件加入你需要的白名单 IP ，然后用
```shell
csf -r
```
命令重启读取配置文件即可。

### 用 iptables 只开启常规端口
一般我们只需要开启 22, 53， 80， 443 这三个常见的对外开放端口，可以使用如下命令


清空 iptables 默认规则
```shell
iptables -F
```
允许 22 端口进入和返回
```shell
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
```
允许 53 端口，一般作为 DNS 服务使用
```shell
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT
```
允许本机访问本机
```shell
iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
iptables -A OUTPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
```
允许所有 IP 访问 80 和 443 端口，一般作为 http 和 https 用途
```shell
iptables -A INPUT -p tcp -s 0/0 --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -s 0/0 --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
```
保存配置
```shell
iptables-save > /etc/sysconfig/iptables
```
重新加载 iptables
```shell
iptables -L
```

### 安装 fail2ban 屏蔽并举报扫描 SSH 端口的 IP
安装 fail2ban ，屏蔽之余，还能自动写举报信给 IP 所在的 ISP。

CentOS 下安装：

导入 epel 源：

CentOS 6.x 32 位：
```shell
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
```
CentOS 6.x 64 位：
```shell
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
```
安装 fail2ban
```shell
yum -y install fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
service fail2ban start
```
Ubuntu / Debian 下安装：
```shell
apt-get install fail2ban -y
```
通过查看 /var/log/fail2ban.log 文件即可知道有哪些精力过剩的家伙在整天扫描你的 SSH 了。
