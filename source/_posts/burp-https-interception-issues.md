title: 使用Brup拦截HTTPS请求时候的一些问题
date: 2016-09-28 09:56:50
tags: [网络安全,HTTPS]
categories:
description: IE设置代理时，需全局代理。Brup证书要安装到根证书。仍HTTPS握手失败可能需要下载不受限的JCE。
---

## 关于Brup 

Brup 是一个可用于执行Web应用程序安全测试的集成平台。可以拦截HTTPS请求，修改浏览器与目标应用程序之间的通信。类似软件还有[Fiddler](https://www.telerik.com/download/fiddler/fiddler4)，但是需要安装该软件。[Brup免费版](https://portswigger.net/burp/freedownload)是一个jar，可以用于Java环境下直接执行。

## 一些问题

### IE中设置代理时，需要设置全局代理

IE中即是设置局域网(LAN)设置。
可排除例外：ctldl.windowsupdate.com;api.bing.com;*.microsoft.com;*.verisign.com

### 安装Brup软件证书到 受信任的根证书颁发机构

1. 开启Brup软件时，使用系统管理员打开IE，输入`http://burp/cert`，可下载cert.der，然后选中安装到受信任的根证书颁发机构。

2. 在警告信息中找到Brup证书，签发者为`PortSwigger CA`，安装到受信任的根证书颁发机构。

### HTTPS仍握手失败 handshake_failure

已经添加Brup证书仍然提示HTTPS握手失败时`Received fatal alert: handshake_failure`，检查Burp中的Alerts标签页，查看第一次出现失败提示的下方，是否有提示下载并安装不受限的JCE。

```
Attempting to auto-select SSL parameters for <FQDN>
Failed to auto-select SSL parameters for <FQDN>
You have limited key lengths available. To use stronger keys, please download and install the JCE unlimited strength jurisdiction policy files, from Oracle.
javax.net.ssl.SSLException: server certificate change is restricted during renegotiation
server certificate change is restricted during renegotiation
```

若有，则下载并解压。

[jdk6中的不受限JCE](http://www.oracle.com/technetwork/java/embedded/embedded-se/downloads/jce-6-download-429243.html)
[jdk7中的不受限JCE](http://www.oracle.com/technetwork/java/embedded/embedded-se/downloads/jce-7-download-432124.html)
[jdk8中的不受限JCE](http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html)

替换掉使用Java版本中的`jre/lib/security`路径下的`local_policy.jar`和`US_export_policy.jar`两个jar包即可。替换前最好先备份一下。



