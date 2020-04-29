title: filter中复制request的inputStream，多次取流
date: 2016-10-26 16:11:44
tags: [Java,stream]
categories: Java
description: 解决filter中读取request中的inputStream后，不能再次获取流进行操作的问题。使用wrapper，例如一个自建类继承HttpServletRequestWrapper。
---

## 前期在struts1中尝试

有个项目中使用的是Struts1，想着写个自己的ActionServlet和ReqeustProcessor，将其中的MultipartRequestWrapper换成自己实现的类。

```java
package com.yz.testweb.common.web;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.upload.MultipartRequestWrapper;
import org.springframework.web.struts.DelegatingRequestProcessor;

@Deprecated
public class YZDelegatingRequestProcessor extends DelegatingRequestProcessor {

    @Override
    protected HttpServletRequest processMultipart(HttpServletRequest request) {
        if (!"POST".equalsIgnoreCase(request.getMethod())) {
            return (request);
        }
      
        String contentType = request.getContentType();
        if ((contentType != null) &&
            contentType.startsWith("multipart/form-data")) {
                 YZMultipartRequestWrapper wrapper = (YZMultipartRequestWrapper)(request);
            return (wrapper);
        } else {
            return (request);
        }
    }
    
    @Override
    protected void doForward(
            String uri,
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException, ServletException {
                
            // Unwrap the multipart request, if there is one.
            if (request instanceof MultipartRequestWrapper) {
                request = ((YZMultipartRequestWrapper) request).getRequest();
            }else if (request instanceof YZMultipartRequestWrapper) {
                request = ((YZMultipartRequestWrapper) request).getRequest();
            }

            RequestDispatcher rd = getServletContext().getRequestDispatcher(uri);
            if (rd == null) {
                response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    getInternal().getMessage("requestDispatcher", uri));
                return;
            }
            rd.forward(request, response);
        }
    
    @Override
    protected void doInclude(
            String uri,
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException, ServletException {
                
            // Unwrap the multipart request, if there is one.
            if (request instanceof MultipartRequestWrapper) {
                request = ((YZMultipartRequestWrapper) request).getRequest();
            }else if (request instanceof YZMultipartRequestWrapper) {
                request = ((YZMultipartRequestWrapper) request).getRequest();
            }

            RequestDispatcher rd = getServletContext().getRequestDispatcher(uri);
            if (rd == null) {
                response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    getInternal().getMessage("requestDispatcher", uri));
                return;
            }
            rd.include(request, response);
        }
}


```

在struts-config中需要将processorClass换成自己实现的
```xml

    <controller>
        <set-property property="processorClass" value="com.yz.testweb.common.web.YZDelegatingRequestProcessor" />
    </controller>
```


```java
package com.yz.testweb.common.web;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.Globals;
import org.apache.struts.action.ActionServlet;
import org.apache.struts.config.ModuleConfig;
import org.apache.struts.util.ModuleUtils;

public class YZActionServlet extends ActionServlet {

    /**
     * 
     */
    private static final long serialVersionUID = 6096137956303373911L;

    @SuppressWarnings("deprecation")
    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        YZMultipartRequestWrapper wrapper = null;
         wrapper = new YZMultipartRequestWrapper(request);
        ModuleUtils.getInstance().selectModule(request, getServletContext());
        ModuleConfig config = getModuleConfig(request);

        YZDelegatingRequestProcessor processor = getProcessorForModule(config);
        if (processor == null) {
           processor = (YZDelegatingRequestProcessor) getRequestProcessor(config);
        }
     
        processor.process(wrapper, response);
    }

    @SuppressWarnings("deprecation")
    private YZDelegatingRequestProcessor getProcessorForModule(ModuleConfig config) {
        String key = Globals.REQUEST_PROCESSOR_KEY + config.getPrefix();
        return (YZDelegatingRequestProcessor) getServletContext().getAttribute(key);
    }
    
}


```

在web.xml中将对应struts的action换成自己实现的
```xml

    <servlet>
            <servlet-name>action</servlet-name>
            <servlet-class>com.yz.testweb.common.web.YZActionServlet</servlet-class>
            <!-- 其他配置略 -->
    </servlet>
    <servlet-mapping>
        <!-- 其他配置略 -->
    </servlet-mapping>
```

后面发现一个参考链接后
[解决在Filter中读取Request中的流后, 然后再Control中读取不到的做法](https://my.oschina.net/vernon/blog/363693)根本不用这么麻烦。直接只要实现个Wrapper类就好了。所以有了最后的版本。


## 使用继承自HttpServletRequestWrapper的Wrapper类，较通用

因为项目中使用了apache的commoms-io.jar，所以直接使用了其中的IOUtils，可用其他方案替代复制流操作。代码仅作参考。java版本，servlet版本不同，实现的ServletInputStream，方法可能会有不同。


```java
package com.yz.testweb.common.web;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;

import javax.servlet.ServletInputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

import org.apache.commons.io.IOUtils;


public class YZMultipartRequestWrapper extends HttpServletRequestWrapper {


    private ByteArrayOutputStream cacheBytes;

    public YZMultipartRequestWrapper(HttpServletRequest request) throws IOException {
        super(request);
        cacheBytes = new ByteArrayOutputStream();
        IOUtils.copy(super.getInputStream(), cacheBytes);
    }


    @Override
    public ServletInputStream getInputStream() throws IOException {
        return new CacheServletInputStream();
    }

    class CacheServletInputStream extends ServletInputStream{

        private ByteArrayInputStream bais;

        public CacheServletInputStream(){
            bais = new ByteArrayInputStream(cacheBytes.toByteArray());
        }

        @Override
        public int read() throws IOException {
            return bais.read();
        }

        @Override
        public void close() throws IOException {
            super.close();
            bais.close();
            cacheBytes.close();
        }


    }

    @Override
    public BufferedReader getReader() throws IOException {
        return new BufferedReader(new InputStreamReader(getInputStream(),"UTF-8"));
    }

}

```


filter类中使用
```java
    
    //判断为multipartRequest后使用
        if(req != null && req.getContentType() != null && req.getContentType().indexOf("multipart/form-data") > -1){
        YZMultipartRequestWrapper reqWrapper = new YZMultipartRequestWrapper(request);    

        /**
        //中间进行其他操作-1.使用spring中的MultipartResolver
        MultipartResolver resolver = new CommonsMultipartResolver(wrapper.getSession().getServletContext());
        MultipartHttpServletRequest multipartRequest = resolver.resolveMultipart(wrapper);

        //中间进行其他操作-2.使用apache的commons.fileupload.jar
        DiskFileItemFactory factory = new DiskFileItemFactory();
        factory.setSizeThreshold(1024*1024*2); // 2M
        ServletFileUpload f = new ServletFileUpload(factory);
        List<FileItem> list = f.parseRequest(req);        
        
        //其他取值校验操作等

        **/

        filterChain.doFilter(reqWrapper,response);
    }else{
        filterChain.doFilter(request,response);
    }
```


