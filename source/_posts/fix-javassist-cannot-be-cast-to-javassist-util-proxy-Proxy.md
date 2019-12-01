title: 修复 $$_javassist_ cannot be cast to javassist.util.proxy.Proxy
date: 2016-05-09 19:01:37
tags: [Java]
categories: Java
description: strust2-core包中的javassist与Hibernate中的javassist有冲突，在pom文件中可以用exclusions排除javassist。
---

在程序中出现下面的错误：

$$_javassist_ cannot be cast to javassist.util.proxy.Proxy

这是因为 javassist 引用了不同的办法。

从 POM 中可以看出来。

在 POM 中定义，取消 3.11 版本的引用。
```xml
<dependency>
                        <groupId>org.apache.struts</groupId>
                        <artifactId>struts2-core</artifactId>
                        <version>2.3.24</version>
                        <exclusions>
                                <exclusion>
                                        <artifactId>javassist</artifactId>
                                        <groupId>javassist</groupId>
                                </exclusion>
                        </exclusions>
                </dependency>
```
这里的 exclusions 是排除包，因为 Struts2中有javassist，Hibernate 中也有javassist,所以如果要整合Hibernate，一定要排除掉Struts2中的javassist，否则就冲突了。

[原文链接](https://www.ossez.com/archiver/tid-30321.html)
