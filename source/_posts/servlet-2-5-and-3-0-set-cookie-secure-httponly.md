title: servlet 2.5及3.0设置cookie secure httponly等属性
date: 2017-02-27 13:43:55
tags: [Java,AppScan,安全]
categories: Java
description: 1. 在Filter或其他位置中设置reponse.setHeader("Set-Cookie",cookieValue)。2. 在Servlet 3.0及以上中在web.xml中配置session-config中cookie-config的属性。
---

安全标记是可以由应用服务器的HTTP响应中发送一个新的cookie给用户时，可以设置一个选项。安全标志的目的是阻止cookies未授权方被观察由于Cookie的明文传输。
为了实现这一目标，支持安全标志的浏览器将只与安全标志时请求去一个HTTPS页面发送cookie。以另一种方式说，浏览器不会设置通过未加密的HTTP请求的安全标志发送的cookie。
通过设置安全标记，浏览器将防止通过未加密的信道的cookie的传输。
[SecureFlag](https://www.owasp.org/index.php/SecureFlag)

增加 cookie 安全性添加HttpOnly和secure属性

## 属性简单说明

### secure属性

当设置为true时，表示创建的 Cookie 会被以安全的形式向服务器传输，也就是只能在 HTTPS 连接中被浏览器传递到服务器端进行会话验证，如果是 HTTP 连接则不会传递该信息，所以不会被窃取到Cookie 的具体内容。

### HttpOnly属性

如果在Cookie中设置了"HttpOnly"属性，那么通过程序(JS脚本、Applet等)将无法读取到Cookie信息，这样能有效的防止XSS攻击。

## Servlet不同版本Web.xml的差异
`web.xml`是Java Web Application的一种描述Web项目如何部署的配置文件。

### 1.Servlet 3.1 deployment descriptor,Java EE 7
Java EE 7 XML schema, namespace is http://xmlns.jcp.org/xml/ns/javaee/

```xml
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee 
         http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">
</web-app>
```

### 2. Servlet 3.0 deployment descriptor,Java EE 6
Java EE 6 XML schema, namespace is http://java.sun.com/xml/ns/javaee

```xml
<web-app xmlns="http://java.sun.com/xml/ns/javaee"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://java.sun.com/xml/ns/javaee 
          http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
          version="3.0">
</web-app>
```

### 3. Servlet 2.5 deployment descriptor,Java EE 5
Java EE 5 XML schema, namespace is http://java.sun.com/xml/ns/javaee
```xml
<web-app xmlns="http://java.sun.com/xml/ns/javaee"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://java.sun.com/xml/ns/javaee 
          http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"
          version="2.5">
</web-app>
```

### 4. Servlet 2.4 deployment descriptor,J2EE 1.4
J2EE 1.4 XML schema, namespace is http://java.sun.com/xml/ns/j2ee
```xml
<web-app xmlns="http://java.sun.com/xml/ns/j2ee"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee 
          http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd"
          version="2.4">

  <display-name>Servlet 2.4 Web Application</display-name>
</web-app>
```

### 5. Servlet 2.3 deployment descriptor,J2EE 1.3
J2EE 1.3 DTDs schema. This web.xml file is too old, highly recommend you to upgrade it.

```xml
<!DOCTYPE web-app PUBLIC
 "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
 "http://java.sun.com/dtd/web-app_2_3.dtd" >

<web-app>
  <display-name>Servlet 2.3 Web Application</display-name>
</web-app>
```


Servlet 2.3到3.0之间的改变可以访问[Servlet wiki](http://en.wikipedia.org/wiki/Java_Servlet)查看详细。

## 设置Cookie属性

### Servlet 3.0 及以上版本设置Web.xml

Servlet 3.0及以上版本支持在Web.xml中设置所有的session cookie 属性为Secure HttpOnly。

```xml
<session-config>
  <cookie-config>
    <secure>true</secure>
    <http-only>true</http-only>
  </cookie-config>
</session-config>
```

### DWR的cookie DWRSESSIONID的设置
DWR默认cookie值 `path=${contextPath}`

Examples of attribute strings:
```shell
domain=mydomain.com
path=/mypath; secure
```

The cookie attributes are configured through the cookieAttributes setting in web.xml:
```xml
<init-param>
    <param-name>cookieAttributes</param-name>
    <param-value>path=/mypath; secure</param-value>
</init-param>
```
or setter from JavaScript after including engine.js:
```javascript
dwr.engine.setCookieAttributes("path=/mypath; secure");
```
or by making configuration before including engine.js:
```javascript
var dwrConfig {
    cookieAttributes: "path=/mypath; secure"
}
```
or the corresponding for AMD loading:
```javascript
require.config({
    (other AMD settings)
    config: {
        "dwr/amd/engine": {
            cookieAttributes: "path=/mypath; secure"
        }
    }
});
```

### 在Java代码中为Cookie写Filter

在Web.xml中配置CookieFilter
```xml
<filter>  
    <filter-name>cookieFilter</filter-name>  
    <filter-class>com.test.CookieFilter</filter-class>  
</filter>  
  
<filter-mapping>  
    <filter-name>cookieFilter</filter-name>  
    <url-pattern>/*</url-pattern>  
</filter-mapping> 
```

```java
public class CookieFilter implements Filter {  
    public void doFilter(ServletRequest request, ServletResponse response,  
            FilterChain chain) throws IOException, ServletException {  
        HttpServletRequest req = (HttpServletRequest) request;  
        HttpServletResponse resp = (HttpServletResponse) response;  
  
        Cookie[] cookies = req.getCookies();  
  
        if (cookies != null) {  
                Cookie cookie = cookies[0];  
                if (cookie != null) {  
                    /*
                    cookie.setMaxAge(3600); 
                    cookie.setSecure(true); 
                    resp.addCookie(cookie);
                    */  
                      
                    //Servlet 2.5不支持在Cookie上直接设置HttpOnly属性  
                    String value = cookie.getValue();  
                    StringBuilder builder = new StringBuilder();  
                    builder.append("JSESSIONID=" + value + "; ");  
                    builder.append("Secure; ");  
                    builder.append("HttpOnly; ");  
                    Calendar cal = Calendar.getInstance();  
                    cal.add(Calendar.HOUR, 1);  
                    Date date = cal.getTime();  
                    Locale locale = Locale.CHINA;  
                    SimpleDateFormat sdf =   
                            new SimpleDateFormat("dd-MM-yyyy HH:mm:ss",locale);  
                    builder.append("Expires=" + sdf.format(date));  
                    resp.setHeader("Set-Cookie", builder.toString());  

                    /*
                    String sessionid = request.getSession().getId();
                    response.setHeader("SET-COOKIE", "JSESSIONID=" + sessionid + "; secure");
                    */ 
                }  
        }  
        chain.doFilter(req, resp);  
    }  
  
    public void destroy() {  
    }  
  
    public void init(FilterConfig arg0) throws ServletException {  
    }  
}  
```

## 在WAS中设置cookie secure

在IBM Webphere ,WAS中设置cookie secure，可以考虑修改WAS配置。

### To set Secure flag to JSESSIONID cookie (same for WebSphere 7.x and 8.x)

    1. log in log in WebSphere admin console
    2. Navigate to Server > Server types > WebSphere application servers
    3. Click on server name (default is server1)
    4. Click on link Web Container settings > Web Container
    5. Click on link Session Management
    6. Click on link Enable Cookies. This bit a litle bit confusing, you have to click on text not on the check box
    7. select option (check box) Restrict cookies to HTTPS sessions
    8. Save changes

### To set HttpOnly flag in WebSphere 8.x to JSESSIONID cookie

    1. log in log in WebSphere admin console
    2. Navigate to Server > Server types > WebSphere application servers
    3. Click on server name (default is server1)
    4. Click on link Web Container settings > Web Container
    5. Click on link Session Management
    6. Click on link Enable Cookies. This bit a litle bit confusing, you have to click on text not on the check box
    7. select option (check box) Set session cookies to HTTPOnly to help prevent cross-site scripting attacks
    8. Save changes

### To set HttpOnly flag in WebSphere 7.x to JSESSIONID cookie

    1. log in log in WebSphere admin console
    2. Navigate to Server > Server types > WebSphere application servers
    3. Click on server name (default is server1)
    4. Click on link Web Container settings > Web Container
    5. Click on link Custom Proprties
    6. Click on button New
    7. Enter name: com.ibm.ws.webcontainer.httpOnlyCookies value:* (HttpOnly will be set on all cookies not only JSESSIONID)
    8. Click on OK button
    9. Save changes

