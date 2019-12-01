title: jdk jmap jhat 产生并分析dump文件
date: 2017-11-01 17:03:50
tags: [jvm,jdk]
categories: Java
description: jmap生成dump文件`jmap -dump:live,format=b,file=<filename,dump.hprof> <pid>`(如heap比较大，将暂停<pid>应用)，jhat查看`jhat [-port 5000] [-J-Xmx512m] heapDump`(在浏览器中访问：http://localhost:5000/查看详细信息)，或使用MAT查看(Memory Analyzer Tool,Eclipse插件)
---

> * 如果程序内存不足或者频繁GC，很有可能存在内存泄露情况，这时候就要借助Java堆Dump查看对象的情况。
> * 使用jmap -histo:[live]查看堆内存中的对象的情况。如果有大量对象在持续被引用，并没有被释放掉，那就产生了内存泄露，就要结合代码，把不用的对象释放掉。
> * 在内存出现泄露、溢出或者其它前提条件下，建议多dump几次内存，把内存文件进行编号归档，便于后续内存整理分析。
> * 64位机上使用需要使用如下方式：`jmap -J-d64 -heap pid`

## 制作Java Dump

### Java Dump 简介
Java虚拟机的运行时快照。将Java虚拟机运行时的状态和信息保存到文件。

> * 线程Dump,包含所有线程的运行状态。纯文本格式。

> * 堆Dump,包含线程Dump,幵包含所有堆对象的状态。二进制格式。堆Dump是反应Java堆使用情况的内存镜像，其中主要包括系统信息、虚拟机属性、完整的线程Dump、所有类和对象的状态等。 一般，在内存不足、GC异常等情况下，我们就会怀疑有内存泄露。这个时候我们就可以制作堆Dump来查看具体情况。分析原因。

补足传统Bug分析手段的不足: 可在任何Java环境使用;信息量充足。 针对非功能正确性的Bug,主要为:多线程幵发、内存泄漏。

### 使用Java虚拟机制作Dump

指示虚拟机出现OOM，即虚拟机在发生内存不足错误时,自动生成堆Dump
`-XX:+HeapDumpOnOutOfMemoryError`

### 使用图形化工具制作Dump

使用JDK(1.6)自带的工具:Java VisualVM。
使用 jconsole 选项通过 HotSpotDiagnosticMXBean 从运行时获得堆转储（生成dump文件）。

### 使用命令行制作Dump

jstack:打印线程的栈信息,制作线程Dump。

jmap:打印内存映射,制作堆Dump。
这个命令执行，JVM会将整个heap的信息dump写入到一个文件，heap如果比较大的话，就会导致这个过程比较耗时，并且执行的过程中为了保证dump的信息是可靠的，所以会暂停应用。

## jmap 产生dump文件/信息

jmap(JVM Memory Map)命令用于生成heap dump文件,打印出某个java进程（使用pid）内存内的，所有‘对象’的情况（如：产生那些对象，及其数量）.还阔以查询finalize执行队列、Java堆和永久代的详细信息，如当前使用率、当前使用的是哪种收集器等。

### jmap命令格式

> * `jmap [option] <pid>`
        (to connect to running process)
> * `jmap [option] <executable <core>`
        (to connect to a core file)
> * `jmap [option] [server_id@]<remote server IP or hostname>`
        (to connect to remote debug server)

`executable` Java executable from which the core dump was produced.
(可能是产生core dump的java可执行程序)
`core` 将被打印信息的core dump文件
`remote-hostname-or-IP` 远程debug服务的主机名或ip
`server-id` 唯一id,假如一台主机上多个远程debug服务 ，用此选项参数标识服务器。
`pid` 需要打印配置信息的进程ID。该进程必须是一个Java进程。想要获取运行的Java进程列表，你可以使用jps。
### jmap option参数

> *  <none>  如果使用不带选项参数的jmap打印共享对象映射，将会打印目标虚拟机中加载的每个共享对象的起始地址、映射大小以及共享对象文件的路径全称。这与Solaris的pmap工具比较相似。
> *  -dump:[live,]format=b,file=<filename> 使用hprof二进制形式,输出jvm的heap内容到文件中. live子选项是可选的，假如指定live选项,那么只输出活的对象到文件. 想要浏览heap dump，你可以使用jhat(Java堆分析工具)读取生成的文件。这个命令执行，JVM会将整个heap的信息dump写入到一个文件，heap如果比较大的话，就会导致这个过程比较耗时，并且执行的过程中为了保证dump的信息是可靠的，所以会暂停应用。
> *  -finalizerinfo 打印正等候回收的对象的信息.
> *  -heap 打印heap的概要信息，GC使用的算法，heap的配置及wise heap的使用情况.查看java 堆（heap）使用情况
> *  -histo[:live] 打印堆的柱状图。打印每个class的实例数目,内存占用,类全名信息. VM的内部类名字开头会加上前缀”*”. 如果live子参数加上后,只统计活的对象数量. 查看堆内存(histogram)中的对象数量及大小。    
> *  -permstat 打印classload和jvm heap长久层的信息. 包含每个classloader的名字,活泼性,地址,父classloader和加载的class数量和占用内存.另外,内部String的数量和占用内存数也会打印出来. 
> *  -F 强制模式。如果指定的pid没有响应，请使用`jmap -dump`或`jmap -histo`选项。在这个模式下,live子参数无效. 当-dump没有响应时，强制生成dump快照
> *  -h | -help 打印辅助信息 
> *  -J 传递参数给jmap启动的jvm. 

### jmap示例

-heap
打印heap的概要信息，GC使用的算法，heap的配置及wise heap的使用情况,可以用此来判断内存目前的使用情况以及垃圾回收情况。
```shell
$ jmap -heap 28920
  Attaching to process ID 28920, please wait...
  Debugger attached successfully.
  Server compiler detected.
  JVM version is 24.71-b01  

  using thread-local object allocation.
  Parallel GC with 4 thread(s)//GC 方式  

  Heap Configuration: //堆内存初始化配置
     MinHeapFreeRatio = 0 //对应jvm启动参数-XX:MinHeapFreeRatio设置JVM堆最小空闲比率(default 40)
     MaxHeapFreeRatio = 100 //对应jvm启动参数 -XX:MaxHeapFreeRatio设置JVM堆最大空闲比率(default 70)
     MaxHeapSize      = 2082471936 (1986.0MB) //对应jvm启动参数-XX:MaxHeapSize=设置JVM堆的最大大小
     NewSize          = 1310720 (1.25MB)//对应jvm启动参数-XX:NewSize=设置JVM堆的‘新生代’的默认大小
     MaxNewSize       = 17592186044415 MB//对应jvm启动参数-XX:MaxNewSize=设置JVM堆的‘新生代’的最大大小
     OldSize          = 5439488 (5.1875MB)//对应jvm启动参数-XX:OldSize=<value>:设置JVM堆的‘老生代’的大小
     NewRatio         = 2 //对应jvm启动参数-XX:NewRatio=:‘新生代’和‘老生代’的大小比率
     SurvivorRatio    = 8 //对应jvm启动参数-XX:SurvivorRatio=设置年轻代中Eden区与Survivor区的大小比值 
     PermSize         = 21757952 (20.75MB)  //对应jvm启动参数-XX:PermSize=<value>:设置JVM堆的‘永生代’的初始大小
     MaxPermSize      = 85983232 (82.0MB)//对应jvm启动参数-XX:MaxPermSize=<value>:设置JVM堆的‘永生代’的最大大小
     G1HeapRegionSize = 0 (0.0MB)  

  Heap Usage://堆内存使用情况
  PS Young Generation
  Eden Space://Eden区内存分布
     capacity = 33030144 (31.5MB)//Eden区总容量
     used     = 1524040 (1.4534378051757812MB)  //Eden区已使用
     free     = 31506104 (30.04656219482422MB)  //Eden区剩余容量
     4.614088270399305% used //Eden区使用比率
  From Space:  //其中一个Survivor区的内存分布
     capacity = 5242880 (5.0MB)
     used     = 0 (0.0MB)
     free     = 5242880 (5.0MB)
     0.0% used
  To Space:  //另一个Survivor区的内存分布
     capacity = 5242880 (5.0MB)
     used     = 0 (0.0MB)
     free     = 5242880 (5.0MB)
     0.0% used
  PS Old Generation //当前的Old区内存分布
     capacity = 86507520 (82.5MB)
     used     = 0 (0.0MB)
     free     = 86507520 (82.5MB)
     0.0% used
  PS Perm Generation//当前的 “永生代” 内存分布
     capacity = 22020096 (21.0MB)
     used     = 2496528 (2.3808746337890625MB)
     free     = 19523568 (18.619125366210938MB)
     11.337498256138392% used  

  670 interned Strings occupying 43720 bytes.
```

可以很清楚的看到Java堆中各个区域目前的情况。

-histo
打印堆的对象统计，包括对象数、内存大小等等 （因为在dump:live前会进行full gc，如果带上live则只统计活对象，因此不加live的堆大小要大于加live堆的大小 ）
```shell
$ jmap -histo:live 28920 | more
 num     #instances         #bytes  class name
----------------------------------------------
   1:         83613       12012248  <constMethodKlass>
   2:         23868       11450280  [B
   3:         83613       10716064  <methodKlass>
   4:         76287       10412128  [C
   5:          8227        9021176  <constantPoolKlass>
   6:          8227        5830256  <instanceKlassKlass>
   7:          7031        5156480  <constantPoolCacheKlass>
   8:         73627        1767048  java.lang.String
   9:          2260        1348848  <methodDataKlass>
  10:          8856         849296  java.lang.Class
  ....
```

仅仅打印了前10行

`xml class name`是对象类型，说明如下：
```shell
B  byte
C  char
D  double
F  float
I  int
J  long
Z  boolean
[  数组，如[I表示int[]
[L+类名 其他对象
```


64位机上使用需要使用如下方式：
`jmap -J-d64 -heap pid`

## jhat 解析dump并启动浏览器

jhat(JVM Heap Analysis Tool)命令是与jmap搭配使用，用来分析jmap生成的dump，jhat内置了一个微型的HTTP/HTML服务器，生成dump的分析结果后，可以在浏览器中查看。在此要注意，一般不会直接在服务器上进行分析，因为jhat是一个耗时并且耗费硬件资源的过程，一般把服务器生成的dump文件复制到本地或其他机器上进行分析。

### jhat命令格式

`jhat [-stack <bool>] [-refs <bool>] [-port <port>] [-baseline <file>] [-debug <int>] [-version] [-h|-help] <file>`

### jhat option参数

> *  -stack false|true 关闭对象分配调用栈跟踪(tracking object allocation call stack)。 如果分配位置信息在堆转储中不可用. 则必须将此标志设置为 false. 默认值为 true.>
> *  -refs false|true 关闭对象引用跟踪(tracking of references to objects)。 默认值为 true. 默认情况下, 返回的指针是指向其他特定对象的对象,如反向链接或输入引用(referrers or incoming references), 会统计/计算堆中的所有对象。
> *  -port port-number 设置 jhat HTTP server 的端口号. 默认值 7000.
> *  -exclude exclude-file 指定对象查询时需要排除的数据成员列表文件(a file that lists data members that should be excluded from the reachable objects query)。 例如, 如果文件列列出了 java.lang.String.value , 那么当从某个特定对象 Object o 计算可达的对象列表时, 引用路径涉及 java.lang.String.value 的都会被排除。
> *  -baseline exclude-file 指定一个基准堆转储(baseline heap dump)。 在两个 heap dumps 中有相同 object ID 的对象会被标记为不是新的(marked as not being new). 其他对象被标记为新的(new). 在比较两个不同的堆转储时很有用.
> *  -debug int 设置 debug 级别. 0 表示不输出调试信息。 值越大则表示输出更详细的 debug 信息.
> *  -version 启动后只显示版本信息就退出
> *  -J< flag > 因为 jhat 命令实际上会启动一个JVM来执行, 通过 -J 可以在启动JVM时传入一些启动参数. 例如, -J-Xmx512m 则指定运行 jhat 的Java虚拟机使用的最大堆内存为 512 MB. 如果需要使用多个JVM启动参数,则传入多个 -Jxxxxxx.

分析同样一个dump快照，MAT需要的额外内存比jhat要小的多的多，所以建议使用MAT来进行分析，当然也看个人偏好。

### 浏览页面dump信息

该页面提供了几个查询功能可供使用：

> * All classes including platform  显示出堆中所包含的所有的类
> * Show all members of the rootset 从根集能引用到的对象
> * Show instance counts for all classes (including platform) 显示平台包括的所有类的实例数量
> * Show instance counts for all classes (excluding platform)
> * Show heap histogram  堆实例的分布表
> * Show finalizer summary
> * Execute Object Query Language (OQL) query 执行对象查询语句

一般查看堆异常情况主要看这个两个部分：
Show instance counts for all classes (excluding platform)，平台外的所有对象信息。

Show heap histogram 以树状图形式展示堆情况。

具体排查时需要结合代码，观察是否大量应该被回收的对象在一直被引用或者是否有占用内存特别大的对象无法被回收。

### jhat OQL

jhat还提供了一种对象查询语言(Object Query Language)，OQL有点类似SQL,可以用来查询。

OQL语句的执行页面: http://localhost:7000/oql/

OQL帮助信息页面为: http://localhost:7000/oqlhelp/

OQL的预发可以在帮助页面查看，这里就不详细讲解了。

[jhat](http://www.importnew.com/18236.html)
