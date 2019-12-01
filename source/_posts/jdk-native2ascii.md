title: jdk自带转码工具native2ascii
date: 2017-10-24 15:05:03
tags: [Java,转码]
categories: Java
description: native2ascii.exe 是 Java 的一个文件转码工具，是将特殊各异的内容 转为 用指定的编码标准文体形式统一的表现出来，它通常位于 JDK_home\bin 目录下，安装好 Java SE 后，可在使用 native2ascii 命令进行转码。
---

## 背景

在做Java开发的时候，常常会出现一些乱码，或者无法正确识别或读取的文件，比如常见的validator验证用的消息资源（properties）文 件就需要进行Unicode重新编码。原因是java默认的编码方式为Unicode，而计算机系统编码常常是GBK等编码。需要将系统的编码转换 为java正确识别的编码问题就解决了。

##语法格式:

native2ascii -[options] [intputfile] [outputfile]

语法格式说明: 

-[options]：表示命令开关，有两个选项可供选择

　　-reverse：将Unicode编码转为本地或者指定编码，不指定编码情况下，将转为本地编码。

　　-encoding encoding_name：转换为指定编码，encoding_name为编码名称。

　　 [inputfile [outputfile]]

　　 inputfile：表示输入文件全名。

　　 outputfile：输出文件名。如果缺少此参数，将输出到控制台。


## 使用方法

native2ascii 工具将带有本机编码字符（非拉丁 1 和非单一码字符）的文件转换成带有Unicode编码字符的文件。 假设需要转化的属性文件为：D:\src\resources.properties（含有中文字符） ，转化后的属性文件为：D:\classes\resources.properties（中文字符统一转化为Unicode） 那么使用如下命令
`JAVA_HOME\bin\native2ascii -encoding GBK D:\src\resources.properties D:\classes\resources.properties`

### 控制台转换字符
在控制台中可以输入汉字回车后，就可以看到转移后的字符了。
Ctrl+C退出。
### 文件转换
`native2ascii allMessages_zh_CN.input.properties allMessages_zh_CN.properties`
将文件allMessages_zh_CN.input.properties编码后输出为allMessages_zh_CN.properties。
为了方便properties文件的管理，建议纯中文的配置文件用input命名。
### 反向单一
`native2ascii -reverse allMessages_zh_CN.properties allMessages_zh_CN.txt`注意-reverse参数

批量反向
JDK自带的工具native2ascii可以将uncode编码的文件转换为本地编码的文件，但是不能批量转换文件。

## 用法介绍
如果应用系统是面向多种语言的，编程时就不得不设法解决国际化问题，包括操作界面的风格问题、提示和帮助语言的版本问题、界面定制个性化问题等。　由于Java语言具有平台无关、可移植性好等优点，并且提供了强大的类库，所以Java语言可以辅助我们解决上述问题。Java语言本身采用双字节字符编码，采用大汉字字符集，这就为解决国际化问题提供了很多方便。从设计角度来说，只要把程序中与语言和文化有关的部分分离出来，加上特殊处理，就可以部分解决国际化问题。在界面风格的定制方面，我们把可以参数化的元素，如字体、颜色等，存储在数据库里，以便为用户提供友好的界面；如果某些部分包含无法参数化的元素，那么我们可能不得不分别设计，通过有针对性的编码来解决具体问题。

## 最佳实践
首先将JDK的bin目录加入系统变量path。在盘下建立一个test目录，在test目录里建立一个zh.txt文件，文件内容为：“熔岩”，打开“命令行提示符”，并进入C:\test目录下。下面就可以按照说明一步一步来操作，注意观察其中编码的变化。

### A：将zh.txt转换为Unicode编码，输出文件到u.txt
`native2ascii zh.txt u.txt`
打开u.txt，内容为“\u7194\u5ca9”。
 
### B：将zh.txt转换为Unicode编码，输出到控制台
`C:\test>native2ascii zh.txt`
\u7194\u5ca9
可以看到，控制台输出了“\u7194\u5ca9”。
 
### C：将zh.txt转换为ISO8859-1编码，输出文件到i.txt
`native2ascii -encoding ISO8859-1 zh.txt i.txt`
打开i.txt文件，内容为“\u00c8\u00db\u00d1\u00d2”。
 
### D：将u.txt转换为本地编码，输出到文件u_nv.txt
`native2ascii -reverse u.txt u_nv.txt`
打开u_nv.txt文件，内容为“熔岩”。
 
### E：将u.txt转换为本地编码，输出到控制台
`C:\test>native2ascii -reverse u.txt`
熔岩
可以看到，控制台输出了“熔岩”。
 
### F：将i.txt转换为本地编码，输出到i_nv.txt
`native2ascii -reverse i.txt i_nv.txt`
打开i_nv.txt文件，内容为“\u00c8\u00db\u00d1\u00d2”。发现转码前后完全一样的。也就是说，等于没有转，或者说思想糊涂，对命名没有理解。。

### G：将i.txt转换为GBK编码，输出到i_gbk.txt
`native2ascii -reverse -encoding GBK i.txt i_gbk.txt`
打开i_gbk.txt文件，内容为“\u00c8\u00db\u00d1\u00d2”。发现转码前后完全一样的。也就是说，等于没有转，或者说思想糊涂，对命名没有理解。

### H：将u_nv.txt转码到本地编码GBK，输出到控制台
`C:\test>native2ascii -reverse -encoding ISO8859-1 i.txt`
熔岩
从这个结果看，目标达到到了，编码i.txt为ISO8859-1，转为本地编码后内容为“熔岩”。从这里应该意识到，<red>native2ascii -reverse命令中-encoding指定的编码为源文件的编码格式。而在native2ascii 命令中-encoding指定的编码为（生成的）目标文件的编码格式。这一点非常的重要！切记！！</red>
继续探索，新建文件12a.txt，内容“12axyz”。看看纯字母数字的编码又如何。

### I：将纯字母数字的文本文件12a.txt转换为Unicode编码
`native2ascii 12a.txt 12a_nv.txt`
打开12a_nv.txt文件，内容为“12axyz”。
继续测试，转为ISO8859-1编码看看
`C:\test>native2ascii -encoding ISO8859-1 12a.txt`
12axyz
结果还是没有转码。
从结果可以得出结论：对于纯数字和字母的文本类型件，转码前后的内容是一样的。

