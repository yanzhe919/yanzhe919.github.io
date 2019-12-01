title: 转:深入分析Java中基于监视器(Monitor)的同步(Synchronization)机制
date: 2017-10-25 10:31:18
tags: [Java,Synchronization,线程]
categories: Java
description: 

---

如果读者在大学期间学习过操作系统相关课程，并且没有在课堂上睡着的话。那么可能知道，监视器(monitor)是操作系统中用于实现同步(synchronization)机制非常重要的基础数据结构。幸运的是，Java中对于同步(synchronization)机制的实现，同样是基于监视器。本文将使用类比的方式来讲述Java中同步(synchronization)机制的基础：监视器(monitor)。
<!-- more --> 
## 监视器(Monitor)概述
一个监视器可以被类比成一栋房子(Building)，该房子里面包含了一个特殊的房间(Special Room)。这个特殊的房间在某一个时刻只可以被一个客户(线程)占领。通常来说，这个房间里会包含一些数据和代码。

![Monitor](Monitor.jpg)

正如上图所示，在该栋房子中，一共会有三个房间。如果一个客户(线程)想要占领这个特殊的房间，它必须首先进入到 Hallway(Entry Set) 中进行等待。调度程序(Scheduler)将会基于某种策略(比如，FIFO),从Hallway中选择某一个客户。如果这个客户(线程)因为某些事件或原因被挂起了，该客户进离开 特殊房间 而进入 等待房间(Wait Room)，以后，调度程序可能会重新选择它，把它从 等待房间 放入到 特殊房间中。

简而言之，一个监视器就是用于监控与调度多个线程如何进入特殊房间的基础设备。它可以确保只有一个客户(线程)可以访问受保护的数据或代码。

## 实现细节
在Java虚拟机(JVM)中，每一个对象(Object)和每一个类(Class)都在逻辑上与某一个监视器(monitor)关联在一起。为了实现所有的这些监视器(monitors)之间的相互排斥能力，每一个对象(Object)和每一个类(Class)都具有一个锁(lock, 也称互斥锁(mutex))。在正统的操作系统中，这种情形又称为一个信号(semaphore)，互斥锁就是一个二元信号。

![semaphore](semaphore.jpg)

如果一个线性获得了某些数据上的一个锁(lock)，那么，直到该线程释放该锁之前，其他的线程都无法获取该锁。如果我们在进行多线程编程时，每次都需要获取信号、操作信号、释放信号等操作，那么多线程的编程体验将是非常不愉快的。幸运的是，我们并不需要这么做，JVM在底层帮我们把这些繁琐的细节做完了。

为了声明一个监控区域，该监控区域最多只允许一个客户(线程)访问，Java提供了 同步语句(synchronization statements) 和 同步方法(synchronization methods) 两种便利机制。一旦某个代码块被 synchronized 关键词包围，该代码块就变成了一个监控区域。同时，该监控区域对应的二元信号，由JVM在底层自动生成并维护着。

## 深入分析
我们知道，每一个对象(Object)或者类(Class)都有一个关联的监视器。换言之，我们可以直接说，每一个对象都有一个一个监视器，因为类(Class)在广义上也是一个JVM中的对象。因为每个对象都有它私自的空间，而且可以监控它的客户(线程)序列。

为了不同的线程之间可以互相协作，Java提供了 wait() 、notify() 等方法来 挂起一个线程、唤醒另一个等待在特定监视器上的线程。此外，Java还提供了另外三个版本的方法：
```java
wait(long timeout, int nanos)
wait(long timeout) notified by other threads or notified by timeout.
notify(all)
```

注意：这些线程之间的协作方法，只可以在同步方法 (synchronized methods) 或者 同步声明(synchronized statements) 中被调用。原因很简单，如果一个客户(线程)不需要信号的互斥，那么就没有必须让该客户与其他客户进行监视或者合作，该客户可以直接随意的访问该方法。

个人的理解：同步(synchronized)控制的是线程是否有权限访问，wait()/notify()控制的是线程之间的访问顺序，所以必须先有同步(权限)控制，在内部再进行顺序控制。

[原文链接](http://www.tiantianbianma.com/java-monitor-synchronization.html/)

