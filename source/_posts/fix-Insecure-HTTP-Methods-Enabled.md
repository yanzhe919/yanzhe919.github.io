title: 解决安全扫描Insecure HTTP Methods Enabled的问题
date: 2015-12-01 14:51:04
tags: [Java,AppScan,安全]
categories: Java
description: 修改web.xml添加security-constraint属性，限制http命令中包含DELETE、OPTIONS、PUT、HEAD和TRACE这五条命令
---

项目部署在IBM WebSphere Application Server，简称WAS，上。使用IBM Rational AppScan进行安全扫描，发现一堆漏洞。
找到一个同样Insecure HTTP Methods Enabled问题的解决方案，大神原文[摸这里](http://www.cnblogs.com/Mainz/archive/2012/11/19/2777679.html)。

因为支持的http命令中包含DELETE、OPTIONS、PUT、HEAD和TRACE这五条命令。
下面解决WAS Insecure HTTP Methods Enabled，其他web server或者application server想必是一样的。

 - Risk: It is possible to upload, modify or delete web pages, scripts and files on the web server
 - Causes: The web server or application server are configured in an insecure way
 - Fix: Disable WebDAV, or disallow unneeded HTTP methods


![Insecure HTTP Methods Enabled](Insecure-HTTP-Methods.png)



修改网站的web.xml添加下面的内容即可

```xml
<security-constraint>
     <web-resource-collection>
          <web-resource-name>DisableUnsecureHttpActions</web-resource-name>
          <url-pattern>/*</url-pattern>
          <http-method>DELETE</http-method>
          <http-method>PUT</http-method>
          <http-method>HEAD</http-method>
          <http-method>TRACE</http-method>
          <http-method>OPTIONS</http-method>
     </web-resource-collection>
     <auth-constraint>
        <role-name>NotExistingRole</role-name>
     </auth-constraint>
     <user-data-constraint>
        <transport-guarantee>NONE</transport-guarantee>
     </user-data-constraint>
 </security-constraint>
```


如果有在web.xml中设置403的页面，如下，需要删除
```xml

<error-page>
  <error-code>403</error-code>
  <location>/WEB-INF/error/403.html</location>
</error-page>

```

可以使用curl工具，测试链接试下。
```shell
curl -v -X OPTIONS https://testurl --insecure

```

比较重要：最好在之前检查WAS有无配置`Enable application security`
如果在IBM WebSphere Application Server,WAS上没有生效的话，检查下WAS配置。看看`global security`下的`Enable application security`是否有被勾选，没有被勾选，请勾选，很重要很重要！
[http://stackoverflow.com/questions/5067917/websphere-security-constraint-in-web-xml-doesnt-work](http://stackoverflow.com/questions/5067917/websphere-security-constraint-in-web-xml-doesnt-work)

相关IBM WAS配置[启用基本认证以访问 Web Service](https://www.ibm.com/support/knowledgecenter/SSAW57_8.5.5/com.ibm.websphere.wlp.doc/ae/twlp_sec_ws_basicauth.html)，[验证是否启用了 WebSphere Application Server 信任关联拦截器](https://www.ibm.com/support/knowledgecenter/SSYJ99_8.5.0/migrate/mig_pre_src_tai.dita)

WAS手工卸载项目

(1)    删除war包：rm –rf /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/installedApps/localhostNode01Cell/xxx_war.ear

(2)    删除对应的配置文件：rm –rf /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/config/cells/localhostNode01Cell/applications/xxx_war.ear

/data/was/WebSphere/AppServer/profiles/AppSrv01/config/cells/dev01Node01Cell/blas/xxx_war.ear

/data/was/WebSphere/AppServer/profiles/AppSrv01/config/cells/dev01Node01Cell/cus/xxx_war.ear

删除serverindex.xml 中项目配置：

/data/was/WebSphere/AppServer/profiles/AppSrv01/config

find . -name serverindex.xml

./cells/dev01Node01Cell/nodes/dev01Node01/serverindex.xml

可以试试看
