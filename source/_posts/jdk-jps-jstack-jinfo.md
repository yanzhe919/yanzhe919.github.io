title: jdk命令jps jstack jinfo
date: 2017-10-25 16:43:19
tags: [jvm,jdk]
categories: Java
description: jps，显示当前用户java程序运行的进程状态，`jps -lmv [pid]` 。jstack，检查线程运行情况，是否有死锁,`jstack [-l] pid`。jinfo，获取正在运行或崩溃的java程序配置信息，但Java7后不再使用，`jinfo -flag MaxPermSize pid`

---

# JDK开发组件简介
JDK包含了一批用于Java开发的组件，自JDK 1.5开始内置，其中包括：
 - javac：编译器，将后缀名为.java的源代码编译成后缀名为“.class”的字节码
 - java：运行工具，运行.class的字节码
 - jar：打包工具，将相关的类文件打包成一个文件
 - javadoc：文档生成器，从源码注释中提取文档，注释需匹配规范
 - jdb debugger：调试工具
 - jps：显示当前java程序运行的进程状态
 - javap：反编译程序
 - appletviewer：运行和调试applet程序的工具，不需要使用浏览器
 - javah：从Java类生成C头文件和C源文件。这些文件提供了连接胶合，使Java和C代码可进行交互。[2]
 - javaws：运行JNLP程序
 - extcheck：一个检测jar包冲突的工具
 - apt：注释处理工具[3]
 - jhat：java堆分析工具
 - jstack：栈跟踪程序
 - jstat：JVM检测统计工具
 - jstatd：jstat守护进程
 - jinfo：获取正在运行或崩溃的java程序配置信息
 - jmap：获取java进程内存映射信息
 - idlj：IDL-to-Java编译器。将IDL语言转化为java文件[4]
 - policytool：一个GUI的策略文件创建和管理工具
 - jrunscript：命令行脚本运行
JDK中还包括完整的JRE（Java Runtime Environment），Java运行环境，也被称为private runtime。包括了用于产品环境的各种库类，如基础类库rt.jar，以及给开发人员使用的补充库，如国际化与本地化的类库、IDL库等等。
JDK中还包括各种样例程序，用以展示Java API中的各部分。

## jps
Java Virtual Machine Process Status Tool,显示指定系统内所有的HotSpot虚拟机进程。与unix上的ps类似，只不过jps是用来显示java进程，可以把jps理解为ps的一个子集。使用jps时，如果没有指定hostid，它只会显示本地环境中所有的Java进程；如果指定了hostid，它就会显示指定hostid上面的java进程，不过这需要远程服务上开启了[jstatd服务](http://blog.csdn.net/fenglibing/article/details/17323515).
jps仅查找当前用户的Java进程，而不是当前系统中的所有进程。

### 原理

jdk中的jps命令可以显示当前运行的java进程以及相关参数，它的实现机制如下：
java程序在启动以后，会在java.io.tmpdir指定的目录下，就是临时文件夹里，生成一个类似于hsperfdata_User的文件夹，这个文件夹里（在Linux中为/tmp/hsperfdata_{userName}/），有几个文件，名字就是java进程的pid，因此列出当前运行的java进程，只是把这个目录里的文件名列一下而已。 至于系统的参数什么，就可以解析这几个文件获得。
```shell
hollis@hos:/tmp/hsperfdata_hollis$ pwd
/tmp/hsperfdata_hollis
hollis@hos:/tmp/hsperfdata_hollis$ ll
total 48
drwxr-xr-x 2 hollis hollis  4096  4月 16 10:54 ./
drwxrwxrwt 7 root   root   12288  4月 16 10:56 ../
-rw------- 1 hollis hollis 32768  4月 16 10:57 2679
hollis@hos:/tmp/hsperfdata_hollis$
```
上面的内容就是我机器中/tmp/hsperfdata_hollis目录下的内容，其中2679就是我机器上当前运行中的java的进程的pid，我们执行jps验证一下：
```
hollis@hos:/tmp/hsperfdata_hollis$ jps
2679 org.ec lipse.equinox.launcher_1.3.0.v20130327-1440.jar
4445 Jps
```
执行了jps命令之后，我们发现有两个java进程，一个是pid为2679的eclipse运行的进程，另外一个是pid为4445的jps使用的进程（他也是java命令，也要开一个进程）

### 命令格式
`jps [options] [hostid]`

### option参数
 · -l : 输出主类全名或jar路径
 · -q : 只输出LVMID,即忽略输出的类名、Jar名以及传递给main方法的参数，只输出pid
 · -m : 输出JVM启动时传递给main()的参数，如果是内嵌的JVM则输出为null。
 · -v : 输出JVM启动时显示指定的JVM参数
 · -V : 输出通过标记的文件传递给JVM的参数（.hotspotrc文件，或者是通过参数-XX:Flags=<filename>指定的文件）。
 · -J : 用于传递jvm选项到由javac调用的java加载器中，例如，“-J-Xms48m”将把启动内存设置为48M，使用-J选项可以非常方便的向基于Java的开发的底层虚拟机应用程序传递参数。

### hostid
hostid指定了目标的服务器，它的语法如下：
[protocol:][[//]hostname][:port][/servername]
 · protocol - 如果protocol及hostname都没有指定，那表示的是与当前环境相关的本地协议，如果指定了hostname却没有指定protocol，那么protocol的默认就是rmi。
 · hostname - 服务器的IP或者名称，没有指定则表示本机。
 · port - 远程rmi的端口，如果没有指定则默认为1099。
 · Servername - 注册到RMI注册中心中的jstatd的名称。

### 示例
```shell
$ jps -lmv
13352 sun.tools.jps.Jps -lmv -Dapplication.home=D:\Program Files\Java\jdk1.8.0_102 -Xms8m
```


[jps命令](http://blog.csdn.net/fenglibing/article/details/6411932)

### JPS失效处理

现象： 用ps -ef|grep java能看到启动的java进程，但是用jps查看却不存在该进程的id。待会儿解释过之后就能知道在该情况下，jconsole、jvisualvm可能无法监控该进程，其他java自带工具也可能无法使用

分析： jps、jconsole、jvisualvm等工具的数据来源就是这个文件（/tmp/hsperfdata_userName/pid)。所以当该文件不存在或是无法读取时就会出现jps无法查看该进程号，jconsole无法监控等问题

原因：

（1）、磁盘读写、目录权限问题 若该用户没有权限写/tmp目录或是磁盘已满，则无法创建/tmp/hsperfdata_userName/pid文件。或该文件已经生成，但用户没有读权限

（2）、临时文件丢失，被删除或是定期清理 对于linux机器，一般都会存在定时任务对临时文件夹进行清理，导致/tmp目录被清空。这也是我第一次碰到该现象的原因。常用的可能定时删除临时目录的工具为crontab、redhat的tmpwatch、ubuntu的tmpreaper等等

这个导致的现象可能会是这样，用jconsole监控进程，发现在某一时段后进程仍然存在，但是却没有监控信息了。

（3）、java进程信息文件存储地址被设置，不在/tmp目录下 上面我们在介绍时说默认会在/tmp/hsperfdata_userName目录保存进程信息，但由于以上1、2所述原因，可能导致该文件无法生成或是丢失，所以java启动时提供了参数(-Djava.io.tmpdir)，可以对这个文件的位置进行设置，而jps、jconsole都只会从/tmp目录读取，而无法从设置后的目录读物信息，这是我第二次碰到该现象的原因

附：

1.如何给main传递参数 在eclipse中，鼠标右键->Run As->Run COnfiguations->Arguments->在Program arguments中写下要传的参数值

1.如何给JVM传递参数 在eclipse中，鼠标右键->Run As->Run COnfiguations->Arguments->在VM arguments中写下要传的参数值（一般以-D开头）

[Java命令学习系列（1）：Jps](http://www.importnew.com/18132.html)

## jstack (检查线程运行情况，是否有死锁)
Java Stack Trace,用于生成给定的java进程ID或core file或远程调试服务的Java虚拟机当前时刻堆栈信息的线程快照。线程快照是当前java虚拟机内每一条线程正在执行的方法堆栈的集合，生成线程快照的主要目的是定位线程出现长时间停顿的原因，如线程间死锁、死循环、请求外部资源导致的长时间等待等。 线程出现停顿的时候通过jstack来查看各个线程的调用堆栈，就可以知道没有响应的线程到底在后台做什么事情，或者等待什么资源。 如果是在64位机器上，需要指定选项"-J-d64"，Windows的jstack使用方式只支持以下的这种方式：
`jstack [-l] pid`
如果java程序崩溃生成core文件，jstack工具可以用来获得core文件的java stack和native stack的信息，从而可以轻松地知道java程序是如何崩溃和在程序何处发生问题。另外，jstack工具还可以附属到正在运行的java程序中，看到当时运行的java程序的java stack和native stack的信息, 如果现在运行的java程序呈现hung的状态(死锁)，jstack是非常有用的。

### 命令格式
`jstack [ option ] pid`
`jstack [ option ] executable core`
`jstack [ option ] [server-id@]remote-hostname-or-IP`

 · executable Java executable from which the core dump was produced.
(可能是产生core dump的java可执行程序)
 · core 将被打印信息的core dump文件
 · remote-hostname-or-IP 远程debug服务的主机名或ip
 · server-id 唯一id,假如一台主机上多个远程debug服务
 · pid 需要被打印配置信息的java进程id,可以用jps查询.

### option参数

 ·  -F  to force a thread dump. Use when jstack <pid> does not respond (process is hung)当正常输出请求(jstack [-l] <pid>)不被响应时，强制输出线程堆栈
 ·  -m  如果调用到本地方法的话，可以一并显示C/C++的堆栈
 ·  -l  长列表. 除堆栈外，显示关于锁的附加信息.例如属于java.util.concurrent的ownable synchronizers列表.

### 示例

当linux出现cpu被java程序消耗过高时，可使用以下步骤查找
1.top查找出哪个进程消耗的cpu高
```
21125 co_ad2    18   0 1817m 776m 9712 S  3.3  4.9  12:03.24 java
5284 co_ad     21   0 3028m 2.5g 9432 S  1.0 16.3   6629:44 java
21994 mysql     15   0  449m  88m 5072 S  1.0  0.6  67582:38 mysqld
8657 co_sparr  19   0 2678m 892m 9220 S  0.3  5.7 103:06.13 java
```
这里我们分析21125这个java进程。

2.top中shift+h查找出哪个线程消耗的cpu高
先输入`top -p 21125`，然后再按shift+h。这里意思为只查看21125的进程，并且显示线程。
```
21233 co_ad2    15   0 1807m 630m 9492 S  1.3  4.0   0:05.12 java
20503 co_ad2_s  15   0 1360m 560m 9176 S  0.3  3.6   0:46.72 java
21134 co_ad2    15   0 1807m 630m 9492 S  0.3  4.0   0:00.72 java
22673 co_ad2    15   0 1807m 630m 9492 S  0.3  4.0   0:03.12 java
```
这里我们分析21233这个线程，并且注意的是，这个线程是属于21125这个进程的。

3.jstack查找这个线程的信息
jstack [进程]|grep -A 10 [线程的16进制]
即：
`jstack 21125|grep -A 10 52f1`

-A 10表示查找到所在行的后10行。21233用计算器转换为16进制52f1，注意字母是小写。
结果：
```
"http-8081-11" daemon prio=10 tid=0x00002aab049a1800 nid=0x52f1 in Object.wait() [0x0000000042c75000]
   java.lang.Thread.State: WAITING (on object monitor)
     at java.lang.Object.wait(Native Method)
     at java.lang.Object.wait(Object.java:485)
     at org.apache.tomcat.util.net.JIoEndpoint$Worker.await(JIoEndpoint.java:416)
```
说不定可以一下子定位到出问题的代码。
[原文链接](http://flysnowxf.iteye.com/blog/1162691)

[其他死锁分析](http://www.importnew.com/18176.html)

## jinfo（Java7后不再使用）
jinfo(JVM Configuration info)这个命令作用是实时查看和调整虚拟机运行参数。 之前的jps -v口令只能查看到显示指定的参数，如果想要查看未被显示指定的参数的值就要使用jinfo口令.
另外，Java7的官方文档指出，这一命令在后续的版本中不再使用。

### 命令格式
`jinfo [option] [args] LVMID`
或 `jinfo [option] <executable <core>`
或 `jinfo [option] [server_id@]<remote server IP or hostname>`

### option参数

 ·  -flag <name>         输出指定JVM args参数的值
 ·  -flag [+|-]<name>    启用或禁用指定JVM args参数
 ·  -flag <name>=<value> 对指定JVM args参数设值
 ·  -flags               不需要args参数，输出所有JVM参数的值
 ·  -sysprops            输出系统属性，等同于System.getProperties()
 ·  <no option>          to print both of the above
 ·  -h | -help           to print this help message

### 示例
查看<pid>2333的MaxPerm大小可以用
`jinfo -flag MaxPermSize 2333`
