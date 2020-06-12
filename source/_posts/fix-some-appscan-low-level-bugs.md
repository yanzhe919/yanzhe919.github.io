title: 修正一些AppScan低等级风险漏洞
date: 2017-02-27 16:34:15
tags: [Java,AppScan,安全,403改为404]
categories: Java
description: HTML5中password属性autocomplete="off"。Content-Security-Policy:default-src 'self'。X-Content-Type-Options:nosniff。X-XSS-Protection:1。Strict-Transport-Security:max-age=31536000。403改为404，可在filter中自写wrapper，重写sendError。
---

## AppScan中的一些低等级风险的问题修正建议
另外，关于安全[实用性开发人员安全须知](https://github.com/FallibleInc/security-guide-for-developers)

### 未停用密码栏位的自动完成HTML属性

将HTML中的`input`元素的`password`栏位补上`autocomplete`属性。默认为`on`，变更为`off`。PS:该栏位为HTML5新增HTML属性 `<!DOCTYPE html>`。

### 遗漏"Content-Security-Policy"标头

配置CSP(Content-Security-Policy)，在HTTP标头中配置/`<meta charset="utf-8">`中配置。可简单使用，设置值为`default-src 'self'`。
CSP 的实质就是白名单制度，开发者明确告诉客户端，哪些外部资源可以加载和执行，等同于提供白名单。它的实现和执行全部由浏览器完成，开发者只需提供配置。
关于[CSP入门](http://yanzhe919.github.io/2017/02/27/content-security-policy/)[原文-阮一峰](http://www.ruanyifeng.com/blog/2016/09/csp.html)

### 遗漏"X-Content-Type-Options"标头

配置X-Content-Type-Options，在HTTP标头中配置/`<meta charset="utf-8">`中配置。使用时，值设置为`nosniff`。

值得注意的是，当使用该HTTP标头时，浏览器会检查HTTP响应标头的Content-Type中的[MIME类型](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Basics_of_HTTP/MIME_types)。当类型不符时，将被拦截。例如`.png`如HTTP响应标头中的Content-Type不为`image/png`时，将显示失败。

#### 文件类型的分类

|类型 | 描述 | 典型示例 |
| ------------- |:-------------:| -----:|
|text |   表明文件是普通文本，理论上是可读的语言 |text/plain, text/html, text/css, text/javascript |
|image |  表明是某种图像。不包括视频，但是动态图（比如动态gif）也使用image类型 | image/gif, image/png, image/jpeg, image/bmp, image/webp,image/svg+xml(SVG矢量图)|
|audio  | 表明是某种音频文件 |  audio/midi, audio/mpeg, audio/webm, audio/ogg, audio/wav|
|video  | 表明是某种视频文件 |  video/webm, video/ogg|
|application| 表明是某种二进制数据 | application/octet-stream, application/pkcs12, application/vnd.mspowerpoint, application/xhtml+xml, application/xml,  application/pdf|


#### 在web环境最常用的视频文件的格式

|MIME 类型 |音频或视频类型|
| ------------- |:-------------:|
|audio/wave audio/wav audio/x-wav audio/x-pn-wav | 音频流媒体文件。一般支持PCM音频编码，其他解码器有限支持（如果有的话）。|
|audio/webm  | WebM 音频文件格式。Vorbis 和 Opus 是其最常用的解码器。 |
|video/webm | 采用WebM视频文件格式的音视频文件。VP8 和 VP9是其最常用的视频解码器。Vorbis 和 Opus 是其最常用的音频解码器。 |
|audio/ogg  | 采用OGG多媒体文件格式的音频文件。 Vorbis 是这个多媒体文件格式最常用的音频解码器。|
|video/ogg  | 采用OGG多媒体文件格式的音视频文件。常用的视频解码器是 Theora；音频解码器为Vorbis 。|
|application/ogg |采用OGG多媒体文件格式的音视频文件。常用的视频解码器是 Theora；音频解码器为Vorbis 。|

#### **JavaScript的MIME类型**

 - application/ecmascript
 - application/javascript
 - application/x-ecmascript
 - application/x-javascript
 - text/ecmascript
 - text/javascript
 - text/javascript1.0
 - text/javascript1.1
 - text/javascript1.2
 - text/javascript1.3
 - text/javascript1.4
 - text/javascript1.5
 - text/jscript
 - text/livescript
 - text/x-ecmascript
 - text/x-javascript

以下类型的MIME类型(带参或不带参数)禁止解释为脚本语言

 - text/plain
 - text/xml
 - application/octet-stream
 - application/xml


更详细的[MIME类型表](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Complete_list_of_MIME_types)

### 遗漏"X-XSS-Protection"标头

配置X-XSS-Protection，在HTTP标头中配置/`<meta charset="utf-8">`中配置。使用时，值设置为`1`。

 - X-XSS-Protection: 0 (禁用XSS过滤)
 - X-XSS-Protection: 1 (启用XSS过滤（一般默认在浏览器中）。如果检测到跨站脚本攻击，浏览器将消毒页面（删除不安全的部分）。)
 - X-XSS-Protection: 1; mode=block (启用XSS过滤。而非消毒的页面，如果在检测到攻击的浏览器将防止页面的呈现。)
 - X-XSS-Protection: 1; report=<reporting-uri>  (Chromium only) (启用XSS过滤。如果检测到跨站脚本攻击，浏览器将消毒页面并报告违规。本品采用CSP的功能report-uri指令发送报告。)

### 遗漏HTTP Strict-Transport-Security标头

[HTTP严格传输安全](https://zh.wikipedia.org/wiki/HTTP%E4%B8%A5%E6%A0%BC%E4%BC%A0%E8%BE%93%E5%AE%89%E5%85%A8)（英语：HTTP Strict Transport Security，缩写：HSTS）是一套由互联网工程任务组发布的互联网安全策略机制。网站可以选择使用HSTS策略，来让浏览器强制使用HTTPS与网站进行通信，以减少会话劫持风险。

配置HTTP Strict-Transport-Security，在HTTP标头中配置/`<meta charset="utf-8">`中配置。使用时，一般值设置为`max-age=31536000` (一年内有效)。

HSTS的作用是强制客户端（如浏览器）使用HTTPS与服务器创建连接。服务器开启HSTS的方法是，当客户端通过HTTPS发出请求时，在服务器返回的超文本传输协议响应头中包含`Strict-Transport-Security`字段。非加密传输时设置的HSTS字段无效。[3]
比如，`https://example.com/` 的响应头含有`Strict-Transport-Security: max-age=31536000; includeSubDomains`。这意味着两点：
 - 在接下来的一年（即31536000秒）中，浏览器只要向example.com或其子域名发送HTTP请求时，必须采用HTTPS来发起连接。比如，用户点击超链接或在地址栏输入 `http://www.example.com/` ，浏览器应当自动将 http 转写成 https，然后直接向 `https://www.example.com/` 发送请求。
 - 在接下来的一年中，如果 example.com 服务器发送的TLS证书无效，用户不能忽略浏览器警告继续访问网站。

HSTS 简单来说就是强制 HTTPS。这需要分两步，第一步是你的服务器声明愿意放弃HTTP强制所有访问为安全的HTTPS。第二步是向几大浏览器 提起申请。在没有正式接受之前只要用户第一次访问之后，浏览器还是会记住你的HSTS爱好并且之后都会强制 HTTPS 而不是由服务端通过301转向。第二步需要慎用，因为据说难以反悔。一般来说只进行第一步就可以了。
# max-age: 记住的时长, 单位是秒 (31536000 = 1 年)
# includeSubdomains: 所有子域名都强制使用 https 访问, 这个如果不确定千万别开。
# preload: 告诉浏览器可以预加载你的域名的 HSTS。

#### 作用
HSTS可以用来抵御SSL剥离攻击。SSL剥离攻击是中间人攻击的一种，由Moxie Marlinspike于2009年发明。他在当年的黑帽大会上发表的题为“New Tricks For Defeating SSL In Practice”的演讲中将这种攻击方式公开。SSL剥离的实施方法是阻止浏览器与服务器创建HTTPS连接。它的前提是用户很少直接在地址栏输入https://，用户总是通过点击链接或3xx重定向，从HTTP页面进入HTTPS页面。所以攻击者可以在用户访问HTTP页面时替换所有https://开头的链接为http://，达到阻止HTTPS的目的。
HSTS可以很大程度上解决SSL剥离攻击，因为只要浏览器曾经与服务器创建过一次安全连接，之后浏览器会强制使用HTTPS，即使链接被换成了HTTP。
另外，如果中间人使用自己的自签名证书来进行攻击，浏览器会给出警告，但是许多用户会忽略警告。HSTS解决了这一问题，一旦服务器发送了HSTS字段，用户将不再允许忽略警告。
#### 不足 
用户首次访问某网站是不受HSTS保护的。这是因为首次访问时，浏览器还未收到HSTS，所以仍有可能通过明文HTTP来访问。解决这个不足目前有两种方案，一是浏览器预置HSTS域名列表，Google Chrome、Firefox、Internet Explorer和Microsoft Edge实现了这一方案。二是将HSTS信息加入到域名系统记录中。但这需要保证DNS的安全性，也就是需要部署域名系统安全扩展。截至2016年这一方案没有大规模部署。
由于HSTS会在一定时间后失效（有效期由max-age指定），所以浏览器是否强制HSTS策略取决于当前系统时间。部分操作系统经常通过网络时间协议更新系统时间，如Ubuntu每次连接网络时，OS X Lion每隔9分钟会自动连接时间服务器。攻击者可以通过伪造NTP信息，设置错误时间来绕过HSTS。解决方法是认证NTP信息，或者禁止NTP大幅度增减时间。比如Windows 8每7天更新一次时间，并且要求每次NTP设置的时间与当前时间不得超过15小时。

#### 浏览器支持

 - Chromium和Google Chrome从4.0.211.0版本开始支持HSTS
 - Firefox 4及以上版本
 - Opera 12及以上版本
 - Safari从OS X Mavericks起
 - Internet Explorer和Microsoft Edge从Windows 10开始支持

### 检查到隐藏目录(403禁止改为404不存在)

可以的话，将回应状态码[403 - 禁止] 改为[404 - 不存在]，这样会将网站目录模糊化，可以防止泄漏网站结构。

可以在filter过滤器中自写wrapper，重写sendError。
```java
package com.yz.test.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;

public class YZHttpServletResponseWrapper extends HttpServletResponseWrapper{
    HttpServletResponse _response;
    HttpServletRequest _request;

    public YZHttpServletResponseWrapper(HttpServletRequest request,HttpServletResponse response){
        super(response);
        _response = response;
        _request = request;
    }

    @Override
    public void sendError(int sc,String msg) throws IOException{
        String path = _request.getServletPath() + _request.getPathInfo();
        if(sc == 403 && path != null){
            _response.sendError(404,msg);
        }else{
            _response.sendError(sc,msg);
        }
    }

    @Override
    public void sendError(int sc) throws IOException{
        String path = _request.getServletPath() + _request.getPathInfo();
        if(sc == 403 && path != null){
            _response.sendError(404);
        }else{
            _response.sendError(sc,ms);
        }
    }
}

```










