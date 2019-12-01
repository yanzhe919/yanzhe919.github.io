title: jdk命令jstat监视虚拟机运行时状态信息
date: 2017-10-30 17:07:40
tags: [jvm,jdk]
categories: Java
description: jstat，监视虚拟机运行时状态信息。`jstat -gc 进程pid 2000 20`，查看进程新生代老年代的内存使用情况，年轻代老年代垃圾收集次数及时间,每隔2000ms输出pid的gc情况，一共输出20次。`jstat -gccause 进程pid`，查看进程垃圾收集原因。C即Capacity 总容量，U即Used 已使用的容量
---

## jstat简介
jstat命令(Java Virtual Machine Statistics Monitoring Tool)用于监控基于HotSpot的JVM，对其堆的使用情况进行实时的命令行的统计，使用jstat我们可以对指定的JVM做如下监控：
 - 类的加载及卸载情况
 - 查看新生代、老生代及持久代的容量及使用情况
 - 查看新生代、老生代及持久代的垃圾收集情况，包括垃圾回收的次数及垃圾回收所占用的时间
 - 查看新生代中Eden区及Survior区中容量及分配情况等
jstat工具特别强大，它有众多的可选项，通过提供多种不同的监控维度，使我们可以从不同的维度来了解到当前JVM堆的使用情况。详细查看堆内各个部分的使用量，使用的时候必须加上待统计的Java进程号，可选的不同维度参数以及可选的统计频率参数。
它主要是用来显示GC及PermGen相关的信息，如果对GC不怎么了解，先看[这篇文章](http://blog.csdn.net/fenglibing/archive/2011/04/13/6321453.aspx)否则其中即使你会使用jstat这个命令，你也看不懂它的输出。

## 命令格式

` jstat [ generalOption | outputOptions vmid [interval[s|ms] [count]] ]`

## 参数

generalOption - 单个的常用的命令行选项，如-help, -options, 或 -version。
outputOptions - 一个或多个输出选项，由单个的statOption选项组成，可以和-t, -h, and -J等选项配合使用。

 - -h<lines> 用于指定每隔几行就输出列头，如果不指定，默认是只在第一行出现列头。
 - -t<lines> 用于在输出内容的第一列显示时间戳，这个时间戳代表的时JVM开始启动到现在的时间（注：在IBM JDK5中是没有这个选项的）。
 - vmid  VM的进程号，即当前运行的java进程号。
 -  interval 间隔时间，单位可以是秒或者毫秒，通过指定s或ms确定，默认单位为毫秒。
 -  count 打印次数，如果缺省则打印无数次。
 -  -J<flag>  用于将给定的<flag>传给java应用程序加载器，例如，“-J-Xms48m”将把启动内存设置为48M。如果想查看可以传递哪些选项到应用程序加载器中，可以相看如下的文档：
        Linux and Solaris：http://docs.oracle.com/javase/1.5.0/docs/tooldocs/solaris/java.html
        Windows： http://docs.oracle.com/javase/1.5.0/docs/tooldocs/windows/java.html
 -  statOption：根据jstat统计的维度不同，可以使用如下表中的选项进行不同维度的统计，不同的操作系统支持的选项可能会不一样，可以通过-options选项，查看不同操作系统所支持选项。

参数interval和count代表查询间隔和次数，如果省略这两个参数，说明只查询一次。
假设需要每250毫秒查询一次进程5828垃圾收集状况，一共查询5次，那命令行如下：
`jstat -gc 5828 250 5`

### options参数说明

选项option代表这用户希望查询的虚拟机信息，主要分为3类：类装载、垃圾收集和运行期编译状况，具体选项及作用如下：

`jstat -class <pid>`
eg:
```shell
jstat -class 11589
 Loaded  Bytes  Unloaded  Bytes     Time   
  7035  14506.3     0     0.0       3.67
```


`jstat -gc 1262 2000 20`
这个命令意思就是每隔2000ms输出1262的gc情况，一共输出20次
输出，C即Capacity 总容量，U即Used 已使用的容量

`jstat -gccause 进程pid`
查看进程垃圾收集原因

| Option                               | 列名               | 	Displays                                       |
| ----         | ----          | --------                                           |
| –class |      | 监视类装载、卸载数量、总空间及类装载所耗费的时间 |
|        | Loaded | 加载了的类的数量 |
|        | Bytes | 加载了的类的大小，单为Kb |
|        | Unloaded |	卸载了的类的数量 |
|        | Bytes |	卸载了的类的大小，单为Kb |
|        | Time	| 花在类的加载及卸载的时间 |
| -compiler |      | 查看HotSpot中即时编译器编译情况的统计,输出JIT编译器编译过的方法、耗时等信息 |
|        | Compiled	    | 编译任务执行的次数 |
|        | Failed	    | 编译任务执行失败的次数 |
|        | Invalid	    | 编译任务非法执行的次数 |
|        | Time	执行    | 编译花费的时间 |
|        | FailedType	| 最后一次编译失败的编译类型 |
|        | FailedMethod	| 最后一次编译失败的类名及方法名 |
| -gc |      | 查看JVM中堆的垃圾收集情况的统计,监视Java堆状况，包括Eden区、2个Survivor区、老年代、永久代等的容量 |
|        | S0C 	 | 新生代中Survivor space中S0当前容量的大小（KB） |
|        | S1C 	 | 新生代中Survivor space中S1当前容量的大小（KB） |
|        | S0U 	 | 新生代中Survivor space中S0容量使用的大小（KB） |
|        | S1U 	 | 新生代中Survivor space中S1容量使用的大小（KB） |
|        | EC	 |  Eden space当前容量的大小（KB） |
|        | EU	 |  Eden space容量使用的大小（KB） |
|        | OC	 |  Old space当前容量的大小（KB） |
|        | OU	 |  Old space使用容量的大小（KB） |
|        | PC	 |  Permanent space当前容量的大小（KB） |
|        | PU	 |  Permanent space使用容量的大小（KB） |
|        | YGC 	 | 从应用程序启动到采样时发生 Young GC 的次数 |
|        | YGCT	 | 从应用程序启动到采样时 Young GC 所用的时间(秒) |
|        | FGC 	 | 从应用程序启动到采样时发生 Full GC 的次数 |
|        | FGCT	 | 从应用程序启动到采样时 Full GC 所用的时间(秒) |
|        | GCTT  | 从应用程序启动到采样时用于垃圾回收的总时间(单位秒)，它的值等于YGC+FGC |
| -gccapacity  |      | 监视内容与-gc基本相同，但输出主要关注Java堆各个区域使用到的最大和最小空间,查看新生代、老生代及持久代的存储容量情况 |
|        | NGCMN | 	新生代的最小容量大小（KB） |
|        | NGCMX | 	新生代的最大容量大小（KB） |
|        | NGC   | 	当前新生代的容量大小（KB） |
|        | S0C   | 	当前新生代中survivor space 0的容量大小（KB） |
|        | S1C   | 	当前新生代中survivor space 1的容量大小（KB） |
|        | EC	 |   Eden space当前容量的大小（KB） |
|        | OGCMN | 	老生代的最小容量大小（KB） |
|        | OGCMX | 	老生代的最大容量大小（KB） |
|        | OGC   | 	当前老生代的容量大小（KB） |
|        | OC	 |   当前老生代的空间容量大小（KB） |
|        | PGCMN | 	持久代的最小容量大小（KB） |
|        | PGCMX | 	持久代的最大容量大小（KB） |
|        | PGC   | 	当前持久代的容量大小（KB） |
|        | PC	 |   当前持久代的空间容量大小（KB） |
|        | YGC   | 	从应用程序启动到采样时发生 Young GC 的次数 |
|        | FGC   | 	从应用程序启动到采样时发生 Full GC 的次数|
| -gcutil   |      | 监视内容与-gc基本相同，但输出主要关注已使用空间占总空间的百分比,查看新生代、老生代及持代垃圾收集的情况 |
|        | S0	 | Heap上的 Survivor space 0 区已使用空间的百分比 |
|        | S1	 | Heap上的 Survivor space 1 区已使用空间的百分比 |
|        | E	 | Heap上的 Eden space 区已使用空间的百分比 |
|        | O	 | Heap上的 Old space 区已使用空间的百分比 |
|        | P	 | Perm space 区已使用空间的百分比 |
|        | YGC	 | 从应用程序启动到采样时发生 Young GC 的次数 |
|        | YGCT | 	从应用程序启动到采样时 Young GC 所用的时间(单位秒) |
|        | FGC	 | 从应用程序启动到采样时发生 Full GC 的次数 |
|        | FGCT | 	从应用程序启动到采样时 Full GC 所用的时间(单位秒) |
|        | GCT	 | 从应用程序启动到采样时用于垃圾回收的总时间(单位秒)，它的值等于YGC+FGC |
| -gccause   |      | 与-gcutil功能一样，但是会额外输出导致上一次/当前GC产生的原因. |
|        | LGCC | 	最后一次垃圾收集的原因，可能为“unknown GCCause”、“System.gc()”等 |
|        | GCC	 | 当前垃圾收集的原因 |
|  –gcnew  |      | 监视新生代GC的状况 . |
|        | S0C	 | 当前新生代中survivor space 0的容量大小（KB）|
|        | S1C	 | 当前新生代中survivor space 1的容量大小（KB）|
|        | S0U	 | S0已经使用的大小（KB）|
|        | S1U	 | S1已经使用的大小（KB）|
|        | TT	 | Tenuring threshold，要了解这个参数，我们需要了解一点Java内存对象的结构，在Sun JVM中，（除了数组之外的）对象都有两个机器字（words）的头部。第一个字中包含这个对象的标示哈希码以及其他一些类似锁状态和等标识信息，第二个字中包含一个指向对象的类的引用，其中第二个字节就会被垃圾收集算法使用到。在新生代中做垃圾收集的时候，每次复制一个对象后，将增加这个对象的收集计数，当一个对象在新生代中被复制了一定次数后，该算法即判定该对象是长周期的对象 ，把他移动到老生代，这个阈值叫着tenuring threshold。这个阈值用于表示某个/些在执行批定次数youngGC后还活着的对象，即使此时新生的的Survior没有满，也同样被认为是长周期对象，将会被移到老生代中。|
|        | MTT	 | Maximum tenuring threshold，用于表示TT的最大值。 |
|        | DSS	 | Desired survivor size (KB).可以参与这里：http://blog.csdn.net/yangjun2/article/details/6542357 |
|        | EC	 | Eden space当前容量的大小（KB） |
|        | EU	 | Eden space已经使用的大小（KB） |
|        | YGC	 | 从应用程序启动到采样时发生 Young GC 的次数 |
|        | YGCT | 	从应用程序启动到采样时 Young GC 所用的时间(单位秒) |
| –gcnewcapacity  |      | 监视内容与-gcnew基本相同，输出主要关注使用到的最大和最小空间. |
|        | NGCMN |           	新生代的最小容量大小（KB） |
|        | NGCMX |     	新生代的最大容量大小（KB） |
|        | NGC   |   	当前新生代的容量大小（KB） |
|        | S0CMX | 	新生代中SO的最大容量大小（KB） |
|        | S0C	 | 当前新生代中SO的容量大小（KB） |
|        | S1CMX | 	新生代中S1的最大容量大小（KB） |
|        | S1C	 | 当前新生代中S1的容量大小（KB） |
|        | ECMX | 	新生代中Eden的最大容量大小（KB） |
|        | EC	 | 当前新生代中Eden的容量大小（KB） |
|        | YGC	 | 从应用程序启动到采样时发生 Young GC 的次数 |
|        | FGC	 | 从应用程序启动到采样时发生 Full GC 的次数 |
| –gcold  |      | 监视老年代及持久代GC的状况  |
|        | PC	 | 当前持久代容量的大小（KB） |
|        | PU	 | 持久代使用容量的大小（KB） |
|        | OC	 | 当前老年代容量的大小（KB） |
|        | OU	 | 老年代使用容量的大小（KB） |
|        | YGC	 | 从应用程序启动到采样时发生 Young GC 的次数 |
|        | FGC	 | 从应用程序启动到采样时发生 Full GC 的次数 |
|        | FGCT | 	从应用程序启动到采样时 Full GC 所用的时间(单位秒) |
|        | GCT	 | 从应用程序启动到采样时用于垃圾回收的总时间(单位秒)，它的值等于YGC+FGC |
| -gcoldcapacity  |      | 监视内容与——gcold基本相同，输出主要关注使用到的最大和最小空间  |
|        | OGCMN |	老生代的最小容量大小（KB） |
|        | OGCMX |	老生代的最大容量大小（KB） |
|        | OGC	  | 当前老生代的容量大小（KB） |
|        | OC	  | 当前新生代的空间容量大小（KB） |
|        | YGC	  | 从应用程序启动到采样时发生 Young GC 的次数 |
|        | FGC	  | 从应用程序启动到采样时发生 Full GC 的次数 |
|        | FGCT  | 	从应用程序启动到采样时 Full GC 所用的时间(单位秒) |
|        | GCT	  | 从应用程序启动到采样时用于垃圾回收的总时间(单位秒)，它的值等于YGC+FGC |
| -gcpermcapacity |      |  输出永久代使用到的最大和最小空间   |
|        | PGCMN | 	持久代的最小容量大小（KB） |
|        | PGCMX | 	持久代的最大容量大小（KB） |
|        | PGC	   | 当前持久代的容量大小（KB） |
|        | PC	   | 当前持久代的空间容量大小（KB） |
|        | YGC	   | 从应用程序启动到采样时发生 Young GC 的次数 |
|        | FGC   | 从应用程序启动到采样时发生 Full GC 的次数 |
|        | FGCT   | 	从应用程序启动到采样时 Full GC 所用的时间(单位秒) |
|        | GCT	   | 从应用程序启动到采样时用于垃圾回收的总时间(单位秒)，它的值等于YGC+FGC |
| –printcompilation |      |  输出已经被JIT编译的方法,HotSpot编译方法的统计   |
|        | Compiled | 编译任务执行的次数 |
|        | Size	 | 方法的字节码所占的字节数 |
|        | Type	 | 编译类型 |
|        | Method	 | 指定确定被编译方法的类名及方法名，类名中使名“/”而不是“.”做为命名分隔符，方法名是被指定的类中的方法，这两个字段的格式是由HotSpot中的“-XX:+PrintComplation”选项确定的。 |

[原文链接](http://blog.csdn.net/fenglibing/article/details/6411951)

