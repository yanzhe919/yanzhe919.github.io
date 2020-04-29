title: CentOS下安装xfce + vnc桌面 + firefox浏览器
date: 2015-10-19 18:37:55
tags: vps
categories: 
description: 安装vnc时，注意CentOS 5和CentOS 6选择安装不同版本。firefox浏览器从官网ftp可获得，更可以从官网获取源码自行编译。也可以选择opera，chrome，方法一样
---

## 安装xfce桌面

检测系统XFCE版本
```shell
yum grouplist
```
查看是否有xfce-4.4，一般都是这个版本
```shell
yum groupinstall xfce-4.4
```

如果没有，则需要自己下载。

根据系统版本打开相应的链接：
CentOS 5 32位：http://download.fedoraproject.org/pub/epel/5/i386/
CentOS 5 64位：http://download.fedoraproject.org/pub/epel/5/x86_64/
CentOS 6 32位：http://download.fedoraproject.org/pub/epel/6/i386/
CentOS 6 64位：http://download.fedoraproject.org/pub/epel/6/x86_64/
查找“epel”，应该会找到一个“epel-release-X-X.noarch.rpm”的软件包。下载，安装之。

```shell
[root@localhost ~]# wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

rpm -ivh epel-release-6-8.noarch.rpm
```
！！！上述是下载安装的例子，具体情况请根据自己的系统版本选择！！！
```shell
yum groupinstall Xfce
yum groupinstall Fonts    （可选安装）
```

在安装过程中会出现两次"Is this ok [y/n]"我们只需要输入y且回车就可以。

## 安装VNCServer

```shell
[root@localhost ~]# yum install vnc vnc-server  (适用CentOS 5)
[root@localhost ~]# yum install tigervnc-server  (适用CentOS 6)
 
向/etc/sysconfig/vncservers里写入两行内容，懒人可以直接用如下命令写入：
[root@localhost ~]# echo 'VNCSERVERS="1:root"' >> /etc/sysconfig/vncservers
[root@localhost ~]# echo 'VNCSERVERARGS[1]="-geometry 1024x768"' >> /etc/sysconfig/vncservers
 
首次启动，会要求输入两遍密码
[root@localhost ~]# vncserver
 
修改密码用此命令
[root@localhost ~]# vncpasswd
 
如果安装的是Gnome，把~/.vnc/xstartup最后一行twm替换为gnome-session，懒人请执行以下语句替换
[root@localhost ~]# sed -i 's/twm/gnome-session/g' ~/.vnc/xstartup
 
如果安装的是xfce，则执行如下语句：
[root@localhost ~]# mv ~/.vnc/xstartup ~/.vnc/xstartup.bak
[root@localhost ~]# echo '#!/bin/sh' >> ~/.vnc/xstartup
[root@localhost ~]# echo '/usr/bin/startxfce4' >> ~/.vnc/xstartup
 
给予权限，设置开机自启动等：
[root@localhost ~]# chmod +x ~/.vnc/xstartup
[root@localhost ~]# service vncserver restart
重启服务时这里可能会提示 A VNC server is already running as :1 [FAILED]的错误，解决方法见下。
[root@localhost ~]# chkconfig vncserver on

ln -s /etc/init.d/vncserver /etc/rc.d/rc3.d/S100vncserver
```

同样的，在过程中有一次我们看到"Is this ok [y/n]"我们只需要输入y且回车就可以。

要在windows系统里连接远程VNCServer，你还需要一个VNC-Viewer，[下载地址](http://www.realvnc.com/download/binary/1731/)。连接方法：你的ip:1

如果在连接的时候出现“connect: Connect refused (10061)”的错误，在服务端执行vncserver，再次重新连接，就OK了。
在一些minimal系统里，即使英文也会出现方框乱码，请使用命令修正：yum install fontforge

### VNCServer使用方法


```shell
[root@localhost ~]# vncserver :1    启动:1
[root@localhost ~]# vncserver :2    启动:2
[root@localhost ~]# ps -ef|grep -i xvnc   查看已启动的server
[root@localhost ~]# vncserver -kill :1    杀死:1
```
今天在使用VNCServer的时候，遇到些问题，下面简单记录一下：
```shell
[root@os1 ~]# service vncserver restart
Shutting down VNC server: 1:root                           [FAILED]
Starting VNC server: 1:root A VNC server is already running as :1
                                                           [FAILED]
```                                                          
故障原因：/etc/hosts与/etc/sysconfig/network文件中的hostname不一致。
一般改掉/etc/hosts中的hostname，再重启vncserver就好了。
```shell
[root@os1 ~]# vncserver
xauth: (stdin):1:  bad display name "os1:4" in "add" command
故障原因：原因同上。
```


```shell
#添加开机服务 首先需要要执行的脚本在/etc/init.d/目录下
update-rc.d tightvncserver:1 defaults
#移除该开机服务
update-rc.d -f xxx remove
```

## 安装FireFox浏览器


[FTP](http://ftp.mozilla.org/pub/firefox/)

下载firefox releases
```shelll
wget http://ftp.mozilla.org/pub/firefox/releases/3.6.28/linux-i686/en-US/firefox-3.6.28.tar.bz2
bzip2 -d firefox-3.6.28.tar.bz2
tar -xvf firefox-3.6.28.tar

wget http://ftp.mozilla.org/pub/firefox/releases/38.0.1esr/linux-x86_64/en-US/firefox-38.0.1esr.tar.bz2
bzip2 -d firefox-38.0.1esr.tar.bz2
tar -xvf firefox-38.0.1esr.tar

mv firefox /usr/local
chown -R root:root /usr/local/firefox
cd /usr/local/bin
ln -s ../firefox/firefox

$ cd /usr/local
$ sudo mv firefox firefox-old  #将来的命名为firefox-old
$ sudo mv /root/firefox firefox-new  #将解压的firefox目录移动到/usr/lib路径下
$ sudo ln -s firefox-new firefox

#用type查看firefox命令
type firefox

yum update
yum whatprovides libgtk-x11-2.0.so.0
yum install gtk2-2.24.23-6.el6.i686
yum whatprovides libXt.so.6
yum install libXt-1.1.4-6.1.el6.i686



wget http://ftp.mozilla.org/pub/firefox/releases/32.0/linux-i686/en-US/firefox-32.0.tar.bz2
tar xjf firefox-32.0.tar.bz2
mv firefox/ /usr/local/lib/
ln -s /usr/local/lib/firefox/firefox /usr/bin/firefox
##安装flash插件
wget http://vagex-debian.googlecode.com/files/libflashplayer.so
mkdir -p /usr/local/lib/firefox/plugins
mv libflashplayer.so /usr/local/lib/firefox/plugins/

```

或者
下载firefox 3.6.28源码包，并编译安装（编译过程非常缓存，建议screen里执行）
```shell
yum install bzip2
wget http://ftp.mozilla安装flash插件

.org/pub/firefox/releases/3.6.28/source/firefox-3.6.28.source.tar.bz2
bzip2 -d firefox-3.6.28.source.tar.bz2
tar -xvf firefox-3.6.28.source.tar
cd mozilla-*
yum install gcc-c++
yum install gtk+-devel
 export PKG_CONFIG=/usr/local/bin/pkg-config
 export PKG_CONFIG_PATH=/usr/share/pkgconfig:/usr/lib64/pkgconfig
  echo $PKG_CONFIG_PATH
vi /etc/ld.so.conf
#比如将当前路径作为lib链接默认搜索路径,
include /etc/ld.so.conf.d/*.conf
include /usr/local/lib
include .
ldconfig

./configure --enable-application=browser && make && make install
#./configure --prefix=PREFIX  
#其中--prefix=PREFIX是指定安装目录，你需要将PREFIX替换为你的目录

make -f client.mk build
make -f client.mk install
#mozilla/dist/bin


rm -rf mozilla-*
```

```shell
yum -y install firefox
yum -y install fonts-chinese (可选，简体中文)
```

安装flash-plugin源
```shell
wget http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
rpm -ivh adobe-release-x86_64-1.0-1.noarch.rpm
yum install flash-plugin
```

禁用Firefox的历史记录保存功能：打开Firefox浏览器Edit→Preferences→Privacy，在Firefox will后面的框里选Never remember history。

设置Linux VPS定时关机并自动重启和删除Log文件以释放内存和硬盘。

执行下列命令，打开计划任务编辑。

```shell
vi /var/spool/cron/root

# 按下字母 i 进入编辑模式，复制以下代码，然后按下键盘上的esc键，再输入:wq 回车，就会保存退出。代码的作用是让VPS每隔三个小时重启一次。


00 00 * * * rm -rf /root/.vnc/*.log
01 00 * * * reboot
00 03 * * * rm -rf /root/.vnc/*.log
01 03 * * * reboot
00 06 * * * rm -rf /root/.vnc/*.log
01 06 * * * reboot
00 09 * * * rm -rf /root/.vnc/*.log
01 09 * * * reboot
00 12 * * * rm -rf /root/.vnc/*.log
01 12 * * * reboot
00 15 * * * rm -rf /root/.vnc/*.log
01 15 * * * reboot
00 18 * * * rm -rf /root/.vnc/*.log
01 18 * * * reboot
00 21 * * * rm -rf /root/.vnc/*.log
01 21 * * * reboot
```

vi /etc/rc.d/rc.local

定时重启firefox
首先在root目录下新建一个重启脚本vncrestart_tennfy.sh，执行以下命令即可

```shell
cat <<- EOF >> /root/vncrestart_tennfy.sh
#!/bin/sh
export DISPLAY=localhost:1.0
rm -rf ~/.vnc/*.log /tmp/plugtmp* > /dev/null 2>&1
killall firefox  > /dev/null 2>&1
/usr/bin/firefox > /dev/null 2>&1 &
EOF

#加了一个5分钟检测一次的脚本，只要不firefox关闭，或者内存大于650(768m的vps)，就重启firefox；
#!/bin/sh
export DISPLAY=localhost:1.0
USEDNC=$(free -m | awk ‘NR==2′ | awk ‘{print $3}’)
FIRE=$(pgrep firefox)
if [ -z "$FIRE" ] || [ $USEDNC -ge 650 ]
then
rm -rf ~/.vnc/*.log /tmp/plugtmp* > /dev/null 2>&1
killall firefox > /dev/null 2>&1
/usr/bin/firefox > /dev/null 2>&1 &

# 给脚本添加可执行权限

chmod a+x /root/vncrestart_tennfy.sh

echo "0 * * * * root /root/vncrestart_tennfy.sh" >>/etc/crontab
/etc/init.d/cron restart
```

Autostarted applications

在弹出的对话框中点击Add，在name中输入firefox，Description不用输入，Command中输入firefox。

重启后firefox显示offline mode的解决办法

在firefox地址栏中输入about:config

搜索这个选项

network.manage-offline-status

改成 “false”

搜索这个选项

toolkit.networkmanager.disable

改成”true”

搜索这个选项

browser.offline-apps.notify 

 改成 "false"

重新启动firefox，随便输入网址看看能否连接网络。


如果还不行的话，检查一下dns是否设置正确。可以在终端中ping下某个ip地址，如果ping的通，但是ping域名ping不通的话，就意味着你的vps的dns没有设置。


需要找到这个位置的文件

/etc/resolv.conf


鼠标右键选择open with leafpad，进入后在下面添加

nameserver 8.8.8.8 

nameserver 8.8.4.4

保存后就可以了。

首先在FireFox地址栏输入：about:config
回车后会有个警告，不理会它，确认后进入节目设置界面。
接着在过滤器中输入 browser.sessionstore 方便查找。
然后将以下三项对于以下内容修改：

browser.sessionstore.max_tabs_undo 的值改为0（把非法关闭后保存的Tab页数改为0）
browser.sessionstore.max_windows_undo 的值改为0（把保存的窗口数改为0）
browser.sessionstore.resume_from_crash 设为false（禁用恢复会话功能）

最后关闭 about:config 页，重启FireFox。

        现在可以测试下，打开FireFox，随便打开几个网页，再用任务管理器结束 FireFox 进程，再自己启动FireFox，应该看不到那恢复会话窗口了:)

另外有Debian安装LXDE
[Linux VPS Debian安装LXDE+VNC桌面 附配Firefox浏览器及简体中文](http://www.laozuo.org/2932.html)


```shell
vi /etc/rc.local
#在“exit 0”上边添加：
#vnc4server
su root -c "/usr/bin/vncserver -geometry 1024x768"
#tightvnc
su root -c "/usr/bin/tightvncserver -geometry 1024x768"
#如果需要自定义的端口，可以在分辨率参数后加入“-rfbport 5902”，其中5902可以改为你需要的端口。

#LXDE下设置开机启动的方法
vi /etc/xdg/lxsession/LXDE/autostart
@firefox-esr
```

## 安装及卸载wine

```shell
yum install wine


yum remove wine
yum remove wine-common
yum remove wine-core

#查看当前系统中安装的所有的软件包
rpm -q -a|grep wine
rpm -a [package name] 
# 卸载软件忽略依赖关系
rpm -e [package name] -nodeps 
```
