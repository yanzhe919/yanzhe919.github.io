title: 使用URL命令工具curl
date: 2016-04-25 14:36:44
tags: [curl,http命令行工具,copy /b隐藏文件,wget]
categories: curl
description: curl是一款非常强大的支持URL语法传输数据的开源命令行工具和库，可以用它发起网络请求，输出返回的数据。curl 支持的协议比wget多。隐藏文件：copy /b file.rar+pic.jpg pic.jpg
---

## 简单介绍CURL
[curl](https://curl.haxx.se/) 是一款非常强大的支持URL语法传输数据的开源命令行工具和库，可以用它发起网络请求，输出返回的数据。支持各种操作系统，支持各种协议包括DICT, FILE, FTP, FTPS, Gopher, HTTP, HTTPS, IMAP, IMAPS, LDAP, LDAPS, POP3, POP3S, RTMP, RTSP, SCP, SFTP, SMB, SMTP, SMTPS, Telnet and TFTP. curl supports SSL certificates, HTTP POST, HTTP PUT, FTP uploading, HTTP form based upload, proxies, HTTP/2, cookies, user+password authentication (Basic, Plain, Digest, CRAM-MD5, NTLM, Negotiate and Kerberos), file transfer resume, proxy tunneling 以及更多。

最新下载地址，[摸这里](https://curl.haxx.se/download.html)

## 常用curl命令

### 获取网页
```shell
curl yzhe.ml 
```

### 获取网页并保存，下载文件 -o ，FTP 下载 -O ，显示进度 -# ，续传 -c ，分块下载 -r
```shell
curl -o 文件名 地址
curl -o result.html http://www.baidu.com
#fetch all the categories from 00 to 99
curl -o 'category-#1#2.html' 'http://www.example.com/category.php?CATID=[0-9][0-9]'
curl -o 'category-#1.html' 'http://www.example.com/category.php?CATID=[0-99]'
#fetch several main pages and store them in files named accordingly
curl -o '#1.html' 'http://www.example.com/{news,blog,careers,contact,sitemap}/'
curl -o '#1-#2-#3-#4.html'/ "http://www.example.com/cgi0bin/item.cgi?prod=[0001-9999]&cat=[0-9]&color={red,yellow,blue,green}&size={s,m,l,xl}"

#fetch a file by FTP have curl automatically pick the output filename将下载的文件保存到file.zip中
curl -O ftp://ftp.example.com/pub/download/file.zip
curl -u name:passwd -O ftp://ip:port/path/file
curl -O ftp://name:passwd@ip:port/path/file
## 下载file.zip中，格式任意，突然掉线，文件续传
curl -c -O 地址/file.zip
## 分块下载 ，一个文件file.zip，格式任意
curl -r 0-10240 -o "file.part1" 地址file1.zip &\
curl -r 10241-20480 -o "file.part2" 地址file1.zip &\
curl -r 20481-40960 -o "file.part3" 地址file1.zip &\
curl -r 40961- -o "file.part4" 地址zhao1.zip
##合并文件 UNIX或苹果，用 
cat file.part* > file.zip
##合并文件 Windows copy /b表示以二进制的形式合并 可以使用通配符（?或者*）
copy /b file.part* file.zip
copy /b file.part1+file.part2+file.part3+file.part4 file.zip
或者
type file.part* > file.zip
```

### 显示HTTP RESPONSE头信息 -i
```shell
curl -i 地址
```

### 只显示HTTP RESPONSE头信息 -I
```shell
curl -I 地址
```

### 显示完整HTTP通信过程 -v
-v参数可以显示一次http通信的整个过程，包括端口连接、http request/response头信息和HTML源码。
```shell
curl -v 地址
```

### 把更详细的结果保存在指定的文件中 --trace
```shell
curl --trace test.txt 地址
curl --trace-ascii test.txt 地址
```
打开test.txt即可查看详细结果。

### 发送表单信息 POST -d ，表单编码--data-urlencode
GET 方式
```shell
curl 地址?keyword=词
```
注：zsh下需要在url两边加单引号

如果发送的表单为POST，则需要使用-d参数
```shell
curl -d "name=xxx&password=xxx" 地址
curl -o output.html -d "userid=root" -d "passwd=fluffy" / -d "submit=Login" -d @formstate.txt /  http://www.example.com/servlet/login.do
##将参数名及取值都存储在文件中。然后，在命令行上，使用@来引用它
```

使用--data-urlencode参数，curl可以为你的表单编码。
```shell
curl --data-urlencode "name=xxx&password=xxx"  地址
```

### HTTP动词(检测不安全的HTTP方法) -X
使用-X参数，curl就可以支持其它HTTP动词，比如 OPTIONS
可以用来检测不安全的HTTP方法
```shell
curl -X OPTIONS 地址
```

### 文件上传 -F 
使用-F参数可实现文件上传，curl 就会以multipart/form-data的方式发送 POST 请求。
```shell
curl -F "action=upload" -F "filename=@file.tar.gz" 地址

curl -F upload=@localfilename -F press=OK 地址 
```

### 模拟referer -e或者--referer
想要验证网站的防盗链，可以尝试模拟referer，使用-e或者 --referer 命令
认为从地址A过来
```shell
curl -e "地址A" "地址B"
```

### 模拟浏览器信息user-agent --user-agent -A
```shell
curl --user-agent '想仿造的user-agent' 地址
chrome
Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.87 Safari/537.36

##使用cURL模仿搜索引擎
#fetch as Google,Get the article content
curl -o curl-google.html -A / 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)' / http://www.linux-mag.com/id/744/
##需要这样获取页面并确保没有机密信息被泄露给搜索引擎http://www.linux-mag.com/id/744/服务器使用user-agent字符串来区分google和普通浏览器，google将自己标记为“Googlebot”。该服务器保存对 ogle和yahoo这类搜索引擎的可见性，但是要求普通用户在付费或注册后才能查看其内容
```
user-agent是访问者的设备，包括系统、CPU、浏览器版本等等.

### 保存cookie -b -D，发送cookie -c
-b选项确定在会话开始时到哪里读取cookie
-c选项指出在哪里写入在会话中接收到的cookie
cookie信息也被存到了cookie0001.txt,cookie信息追加到http request里面去： -b
```shell
curl -D cookie0002.txt -b cookie0001.txt 地址

curl -b file_name 地址

##保持会话状态
curl -b cookies.txt -c newcookies.txt 地址

##发送假造的cookie
curl -b session-id-time=-1 地址
```

### 加密HTTP和HTTPS -E xx.pem ,--cert 
curl 可以直接访问https的网站
如果是采用证书认证的http地址，证书在本地，那么curl这样使用：
```shell
curl -E mycert.pem https://地址
```

### 略过https证书访问 -k, 
通过SSL/TLS获取页面时忽略它不能验证SSL证书
```shell
curl -k https://地址
curl https://地址 --insecure
```

### 显示抓取错误 -f 
```shell
curl -f http://www.baidu.com
```

### 在给定端口上使用http代理 -x
```shell
curl -x 127.0.0.1:8088 地址
```

### 上传文件 -T 
```shell
## FTP上传
curl -T localfile -u name:passwd ftp://upload_site:port/path/
## HTTP上传的PUT method
curl -T localfile http://地址
```

### 通过dict协议去查字典
```shell
curl dict://dict.org/d:computer
```

## CURL其他参数
[curl所有参数](https://curl.haxx.se/docs/manpage.html)
 
 
-a/--append 上传文件时，附加到目标文件  
 -A/--user-agent <string>  设置用户代理发送给服务器  
 - anyauth   可以使用“任何”身份验证方法  
 -b/--cookie <name=string/file> cookie字符串或文件读取位置  
 - basic 使用HTTP基本验证  
 -B/--use-ascii 使用ASCII /文本传输  
 -c/--cookie-jar <file> 操作结束后把cookie写入到这个文件中  
 -C/--continue-at <offset>  断点续转  
 -d/--data <data>   HTTP POST方式传送数据  
 --data-ascii <data>  以ascii的方式post数据  
 --data-binary <data> 以二进制的方式post数据  
 --negotiate     使用HTTP身份验证  
 --digest        使用数字身份验证  
 --disable-eprt  禁止使用EPRT或LPRT  
 --disable-epsv  禁止使用EPSV  
 -D/--dump-header <file> 把header信息写入到该文件中  
 --egd-file <file> 为随机数据(SSL)设置EGD socket路径  
 --tcp-nodelay   使用TCP_NODELAY选项  
 -e/--referer 来源网址  
 -E/--cert <cert[:passwd]> 客户端证书文件和密码 (SSL)  
 --cert-type <type> 证书文件类型 (DER/PEM/ENG) (SSL)  
 --key <key>     私钥文件名 (SSL)  
 --key-type <type> 私钥文件类型 (DER/PEM/ENG) (SSL)  
 --pass  <pass>  私钥密码 (SSL)  
 --engine <eng>  加密引擎使用 (SSL). "--engine list" for list  
 --cacert <file> CA证书 (SSL)  
 --capath <directory> CA目录 (made using c_rehash) to verify peer against (SSL)  
 --ciphers <list>  SSL密码  
 --compressed    要求返回是压缩的形势 (using deflate or gzip)  
 --connect-timeout <seconds> 设置最大请求时间  
 --create-dirs   建立本地目录的目录层次结构  
 --crlf          上传是把LF转变成CRLF  
 -f/--fail          连接失败时不显示http错误  
 --ftp-create-dirs 如果远程目录不存在，创建远程目录  
 --ftp-method [multicwd/nocwd/singlecwd] 控制CWD的使用  
 --ftp-pasv      使用 PASV/EPSV 代替端口  
 --ftp-skip-pasv-ip 使用PASV的时候,忽略该IP地址  
 --ftp-ssl       尝试用 SSL/TLS 来进行ftp数据传输  
 --ftp-ssl-reqd  要求用 SSL/TLS 来进行ftp数据传输  
 -F/--form <name=content> 模拟http表单提交数据  
 -form-string <name=string> 模拟http表单提交数据  
 -g/--globoff 禁用网址序列和范围使用{}和[]  
 -G/--get 以get的方式来发送数据  
 -h/--help 帮助  
 -H/--header <line>自定义头信息传递给服务器  
 --ignore-content-length  忽略的HTTP头信息的长度  
 -i/--include 输出时包括protocol头信息  
 -I/--head  只显示文档信息  
 从文件中读取-j/--junk-session-cookies忽略会话Cookie  
 - 界面<interface>指定网络接口/地址使用  
 - krb4 <级别>启用与指定的安全级别krb4  
 -j/--junk-session-cookies 读取文件进忽略session cookie  
 --interface <interface> 使用指定网络接口/地址  
 --krb4 <level>  使用指定安全级别的krb4  
 -k/--insecure 允许不使用证书到SSL站点  
 -K/--config  指定的配置文件读取  
 -l/--list-only 列出ftp目录下的文件名称  
 --limit-rate <rate> 设置传输速度  
 --local-port<NUM> 强制使用本地端口号  
 -m/--max-time <seconds> 设置最大传输时间  
 --max-redirs <num> 设置最大读取的目录数  
 --max-filesize <bytes> 设置最大下载的文件总量  
 -M/--manual  显示全手动  
 -n/--netrc 从netrc文件中读取用户名和密码  
 --netrc-optional 使用 .netrc 或者 URL来覆盖-n  
 --ntlm          使用 HTTP NTLM 身份验证  
 -N/--no-buffer 禁用缓冲输出  
 -o/--output 把输出写到该文件中  
 -O/--remote-name 把输出写到该文件中，保留远程文件的文件名  
 -p/--proxytunnel   使用HTTP代理  
 --proxy-anyauth 选择任一代理身份验证方法  
 --proxy-basic   在代理上使用基本身份验证  
 --proxy-digest  在代理上使用数字身份验证  
 --proxy-ntlm    在代理上使用ntlm身份验证  
 -P/--ftp-port <address> 使用端口地址，而不是使用PASV  
 -Q/--quote <cmd>文件传输前，发送命令到服务器  
 -r/--range <range>检索来自HTTP/1.1或FTP服务器字节范围  
 --range-file 读取（SSL）的随机文件  
 -R/--remote-time   在本地生成文件时，保留远程文件时间  
 --retry <num>   传输出现问题时，重试的次数  
 --retry-delay <seconds>  传输出现问题时，设置重试间隔时间  
 --retry-max-time <seconds> 传输出现问题时，设置最大重试时间  
 -s/--silent静音模式。不输出任何东西  
 -S/--show-error   显示错误  
 --socks4 <host[:port]> 用socks4代理给定主机和端口  
 --socks5 <host[:port]> 用socks5代理给定主机和端口  
 --stderr <file>  
 -t/--telnet-option <OPT=val> Telnet选项设置  
 --trace <file>  对指定文件进行debug  
 --trace-ascii <file> Like --跟踪但没有hex输出  
 --trace-time    跟踪/详细输出时，添加时间戳  
 -T/--upload-file <file> 上传文件  
 --url <URL>     Spet URL to work with  
 -u/--user <user[:password]>设置服务器的用户和密码  
 -U/--proxy-user <user[:password]>设置代理用户名和密码  
 -v/--verbose  
 -V/--version 显示版本信息  
 -w/--write-out [format]什么输出完成后  
 -x/--proxy <host[:port]>在给定的端口上使用HTTP代理  
 -X/--request <command>指定什么命令  
 -y/--speed-time 放弃限速所要的时间。默认为30  
 -Y/--speed-limit 停止传输速度的限制，速度时间'秒  
 -z/--time-cond  传送时间设置  
 -0/--http1.0  使用HTTP 1.0  
 -1/--tlsv1  使用TLSv1（SSL）  
 -2/--sslv2 使用SSLv2的（SSL）  
 -3/--sslv3         使用的SSLv3（SSL）  
 --3p-quote      like -Q for the source URL for 3rd party transfer  
 --3p-url        使用url，进行第三方传送  
 --3p-user       使用用户名和密码，进行第三方传送  
 -4/--ipv4   使用IP4  
 -6/--ipv6   使用IP6  
 -#/--progress-bar 用进度条显示当前的传送状态  

## wget参数
curl 支持的协议比wget多(支持http,https,ftp,gopher,dict,telent,ladap or file)
wget [参数列表] [目标软件、网页的网址]

wget 支持 http ,https, ftp 断点续传
 
1.下载整个网页
 
wget http://baidu.com
 
2.下载目录
 
wget -r -np -nd http://www.baid.com/s/
 
-r表示递归  np表示不遍历父目录  nd 表示在本机重新创建目录结构
 
3.wget -r -np -nd -accept=jpg,txt http://www.baidu.com/s/
 
accept=jpg,txt 表示只下载 s目录下 jpg  txt文件
 
4.wget -r -np -nd -reject=jpg,txt http://www.baidu.com/s/
 
reject=jpg,txt 表示除jpg txt文件外，下载s目录下其他所有文件
 
5.wget -i address.txt
 
实现批量下载，下载地址保存在 address.txt中

-V,–version 显示软件版本号然后退出；
-h,–help显示软件帮助信息；
-e,–execute=COMMAND 执行一个 “.wgetrc”命令

-o,–output-file=FILE 将软件输出信息保存到文件；
-a,–append-output=FILE将软件输出信息追加到文件；
-d,–debug显示输出信息；
-q,–quiet 不显示输出信息；
-i,–input-file=FILE 从文件中取得URL；

-t,–tries=NUMBER 是否下载次数（0表示无穷次）
-O –output-document=FILE下载文件保存为别的文件名
-nc, –no-clobber 不要覆盖已经存在的文件
-N,–timestamping只下载比本地新的文件
-T,–timeout=SECONDS 设置超时时间
-Y,–proxy=on/off 关闭代理

-nd,–no-directories 不建立目录
-x,–force-directories 强制建立目录

–http-user=USER设置HTTP用户
–http-passwd=PASS设置HTTP密码
–proxy-user=USER设置代理用户
–proxy-passwd=PASS设置代理密码

-r,–recursive 下载整个网站、目录（小心使用）
-l,–level=NUMBER 下载层次

-A,–accept=LIST 可以接受的文件类型
-R,–reject=LIST拒绝接受的文件类型
-D,–domains=LIST可以接受的域名
–exclude-domains=LIST拒绝的域名
-L,–relative 下载关联链接
–follow-ftp 只下载FTP链接
-H,–span-hosts 可以下载外面的主机
-I,–include-directories=LIST允许的目录
-X,–exclude-directories=LIST 拒绝的目录

 
## 使用DOS COPY /b隐藏文件[转]
我们平时为了隐藏一些文件，费尽心思，不同的人有不同的方法去隐藏，有的人会放进系统文件夹，有些人会放到一些不起眼的文件夹里，有的人放进回收站（要是碰上我就惨了，我有时不时清空回收站的爱好）。有的用软件来隐藏，一旦忘记了密码，就找不回文件了，哭死！！！   其实最危险的地方就是最安全的地方，这句话相信我们都听说过。但也不是叫你把东西放到桌面上，起名叫做我的自拍照，这样的话，怎么也安全不过去吧。   下面给大家介绍一个很好用的方法，要用到DOS指令里的COPY命令，DOS菜鸟不用担心，很简单的。   第一步：准备好我们要隐藏的文件，例如是一个word文档的doc文件，叫做：file.doc   第二步：准备好一张jpg图片，大小无所谓。例如jpg图片叫做：pic.jpg   第三步：把file.doc给压缩成rar文件（如果你的电脑上没有装rar软件的话，那我就没话说了，赶快下载一个装去），在file.doc上击右键，选择添加到压缩文件，在常规那里写入文件名，起名为file.rar，选择上方的高级，点击右边的设置密码按键，把显示密码和加密文件夹给勾上，然后输入一个中文密码，例如密码为：我是菜鸟我怕谁，然后按确定。   [为什么要用中文密码呢？因为中文密码没有人想得到，就算想到你是用了中文密码，要破解也是难上加难啊。如果用中文再混上个特殊符号如：！·#￥%……——*（之类的，再加个数字9加个字母z,这密码就更变态了]   [为什么要加密文件名呢？因为加密了文件名后，人家双击了你的RAR文件，就要密码，没有密码连文件名都不给你看，别说是解压。]   第四步：在开始的运行那里输入cmd进入控制台，假如你的file.rar和pic.jpg放在D盘下，你就在控制台里输入D: 回车进入D盘，然后输入：copy /b pic.jpg+file.rar file.jpg   这样就完成了，这时候，D盘应该会生成一个叫做file.jpg的图片，打开一看，和pic.jpg是一样的，但是查看一下大小，你会发现，其大小是file.rar和pic.jpg加起来的大小，没错，合并在一起了，你的rar文件就在其中。 
  如果你想查看你的rar，很简单，直接把后缀名改为.rar就OK了，双击之后，会要求你输入密码，因为刚才你设置了密码嘛，输入你的中文，怎么回事？？？中文不能输入，哈哈！！！打开记事本，先把中文密码输入进去，然后复制这几个字，再粘贴到rar上面就行了。   再把后缀rar改为jpg，就又变回图片了，怎么样，好玩吧。这样的图片，放在哪都安全，只要不被人家删掉的啦。
