title: 禁止目录遍历
date: 2015-12-02 11:19:37
tags: [Java,AppScan,安全]
categories: Java
description: 修改web/application Server配置，禁止目录浏览/遍历。
---

首先说目录浏览和目录遍历漏洞，也可以叫做信息泄露漏洞，非授权文件包含漏洞。
简单来说就是直接访问目录时由于找不到默认主页而列出目录下文件。
关于目录遍历漏洞简介，[摸这里，看H3C攻防团队写的简介](http://www.h3c.com.cn/Products___Technology/Products/IP_Security/Security_Research/Home/Technology/201503/856838_30003_0.htm)或自行google。
唔，2014年3月22日，乌云漏洞报告平台曾爆出国内某著名网站存在漏洞，安全支付日志可被遍历下载。说的，也是这个漏洞。

在IBM WebSphere Application Server，有人直接叫WebSphere，下面简称WAS。

几种web/application Server禁止目录遍历的配置修改。

## WAS中禁止目录遍历

如果存在/WEB-INF/ibm-web-ext.xmi，添加/修改就好了。

```xml
	<enable-directory-browsing value="false">	
```	
或者是WAS 5.0中的directoryBrowsingEnabled
```xml
	directoryBrowsingEnabled="fasle"
```

PS:路径可能在
```shell
(WAS 4.0)PATH_TO_WASHOME/AppServer/installedApps/NAME_OF_APP.ear/NAME_OF_APP.war/WEB-INF/ibm-web-ext.xmi
(WAS 5.0)PATH_TO_WASHOME/AppServer/installedApps/NAME_OF_NODE/NAME_OF_APP.ear/NAME_OF_APP.war/WEB-INF/ibm-web-ext.xmi
(WAS 8.5)PATH_TO_WASHOME/AppServer/profiles/AppSrv01/installedApps/NAME_OF_NODE/NAME_OF_APP.ear/NAME_OF_APP.war/WEB-INF/ibm-web-ext.xmi
```

项目源码中也可以直接加上该xmi，其他配置根据项目实际情况修改
```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-ext
   xmlns="http://websphere.ibm.com/xml/ns/javaee"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xsi:schemaLocation="http://websphere.ibm.com/xml/ns/javaee http://websphere.ibm.com/xml/ns/javaee/ibm-web-ext_1_0.xsd"
      version="1.0">
  
   <jsp-attribute name="trackDependencies" value="true" />
   <jsp-attribute name="disableJspRuntimeCompilation" value="true" />
   <jsp-attribute name="reloadEnabled" value="true"/>

   <reload-interval value="5"/>
   <auto-encode-requests value="false"/>
   <auto-encode-responses value="false"/>
   <enable-directory-browsing value="false"/>
   <enable-file-serving value="false"/>
   <pre-compile-jsps value="false"/>
   <enable-reloading value="true"/>
   <enable-serving-servlets-by-class-name value="false" />  
</web-ext>
```

## TOMCAT

打开Tomcat_home\conf\web.xml，查看listings是否设置为false
修改Tomcat web.xml配置文件
```xml
<init-param>
    <param-name>listings</param-name>
    <param-value>false</param-value>
</init-param>
```

## Apache

修改Apache配置文件，在Indexes指令前加减号，禁止找不到默认主页的情况下列出目录下的文件
```xml 
<Directory /var/www/bluesmile/>
       Options -Indexes FollowSymLinks
       AllowOverride None
       Order allow,deny
       allow from all
  </Directory>
```

## Nginx

查找Nginx配置文件，检查是否开启autoindex指令，若开启，删除或注释该段配置
```xml
location /testing {
   # autoindex on;
   # autoindex_exact_size off;
   # autoindex_localtime on;
}
```

## .htaccess

这个是混进来的。本身是个配置文件。.htaccess文件，又叫分布式配置文件。
修改
```xml
<Files .htaccess>
order allow,deny
deny from all
</Files>
```
(可以把all换成某一ip地址)

## Lighttpd

使用以下命令关闭目录浏览模块
lighttpd-disable-mod dir-listing 

## IIS

打开IIS管理器，关闭目录浏览功能
详细操作参照[官方文档](https://technet.microsoft.com/zh-cn/library/cc731109(v=ws.10).aspx)

启用或禁用目录浏览
您可以通过以下方法执行此过程：使用用户界面 (UI)、在命令行窗口中运行 Appcmd.exe 命令、直接编辑配置文件或编写 WMI 脚本。
 - 用户界面

使用 UI
打开 IIS 管理器，然后导航至您要管理的级别。 有关如何打开 IIS 管理器的信息，请参阅 打开 IIS 管理器 (IIS 7)。 有关如何在 UI 的各个位置间进行导航的信息，请参阅 在 IIS 管理器中导航 (IIS 7)。
在“功能视图”中，双击“目录浏览”。
在“操作”窗格中，如果“目录浏览”功能已禁用而您要启用它，请单击“启用”。 或者，如果“目录浏览”功能已启用而您要禁用它，请单击“禁用”。
 - 命令行

若要启用或禁用目录浏览，请使用下面的语法：
```shell
appcmd set config /section:directoryBrowse /enabled:true|false
```
默认情况下，enabled 属性设置为 true，这表示目录浏览已启用。 将 enabled 属性设置为 false 时，就会禁用目录浏览。
例如，若要禁用目录浏览，请在命令提示符处键入如下命令，然后按 Enter：
```shell
appcmd set config /section:directoryBrowse /enabled:false
```
有关 Appcmd.exe 的详细信息，请参阅 Appcmd.exe (IIS 7) 。
 - 配置

本主题中的过程会影响以下配置元素：
<directoryBrowse>
有关 IIS 7 配置的详细信息，请参阅 MSDN 上的 IIS 7.0：IIS 设置架构（可能为英文页面）。
 - WMI

请使用以下 WMI 类、方法或属性执行此过程：
DirectoryBrowseSection.Enabled 属性

参考链接，[摸这里](bluesmile.cc/post-54.html)
