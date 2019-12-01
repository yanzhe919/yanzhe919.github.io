title: 关闭Java进程
date: 2016-05-11 18:43:55
tags: [Java,停止Java进程,传递信号给进程]
categories: Java
description: 使用kill命令关闭进程，kill -9 强制退出，kill -s TERM PID传递信号程序里接收信号等。使用钩子函数，在其中进行资源回收，等待线程执行完毕。通过其他监控，判断是否需要进行资源回收停止进程。
---

Java应用程序退出的触发机制有：
1. 自动结束：应用没有存活线程或只有后台线程时;
2. System.exit(0);
3. kill 或 ctrl+C;
4. kill -9 强制退出，会导致数据丢失;
5. 通过kill -s TERM PID,传递信号给Java进程，然后程序中进行退出操作;
7. 注册一个钩子函数，使用kill时，java虚拟机会对钩子函数中资源进行回收;
8. 监控一个shutdown file是否存在，可以通过给file设定权限，只有拥有权限的人才能停止进程;
9. 另外打开一个端口，监听端口里的命令，收到命令后调用System.exit;
10. 通过JMX的mbean远程控制来实现;

## 使用命令直接关闭Java进程

### linux环境，使用kill -9/-15 pid

kill -15 pid 据说比-9更安全

方法1：截取进程pid，再kill
```shell
ps -ef | grep root(当前登录用户) | grep test.jar | grep -v grep | cut -c10-15 | xargs kill -9
```
 方法2：

1）找到linux下的所有Java进程的pids
```shell
ps -ef  | grep 当前登录用户 | grep test.jar | grep -v grep | awk '{print $2}'
```
2）循环得到的pids，kill -9 pid

### windows环境，使用taskkill

kill 命令行参数中带tomcat字符串的 java.exe 进程

方法1：
```shell
wmic process where (Name="java.exe" AND CommandLine like "%%tomcat%%") call terminate >nul 2>nul
```
方法2：
```shell
C:\Users\Administrator>wmic process where name="javaw.exe" get Processid
ProcessId
768

C:\Users\Administrator>taskkill /F /PID 768
成功: 已终止 PID 为 768 的进程。
```

## Java进程接收信号，程序进行退出相关操作

### 信号简介

信号是在软件层次上对中断机制的一种模拟，在原理上，一个进程收到一个信号与处理器收到一个中断请求可以说是一样的。
通俗来讲，信号就是进程间的一种异步通信机制。
典型的例子:
`kill -s SIGKILL pid` (即`kill -9 pid`) 立即杀死指定pid的进程。
在上面这个例子中，SIGKILL就是往pid进程发送的信号。

### 平台相关性

信号具有平台相关性，不同平台下能使用的信号种类是有差异的。
在Linux下支持的信号(对比信号列表查看描述)
`SEGV, ILL, FPE, BUS, SYS, CPU, FSZ, ABRT, INT, TERM, HUP, USR1, USR2, QUIT, BREAK, TRAP, PIPE`
在Windows下支持的信号
`SEGV, ILL, FPE, ABRT, INT, TERM, BREAK`

### 信号选择

为了不干扰正常信号的运作，又能模拟Java异步通知，我们需要先选定一种特殊的信号。
通过查看信号列表上的描述，发现 SIGUSR1 和 SIGUSR2 是允许用户自定义的信号。
那么选择它们，理论上就不会影响正常功能了。
这里我选用了USR2作为传递信号。原因是USR1有可能已被其他APP占用。

### 实例代码
```java
//在Java编程中使用信号的实际收益
import sun.misc.SignalHandler; 
import sun.misc.Signal; 


// install signals  
Signal sig = new Signal("USR2");  
Signal.handle(sig, new SignalHandler (){

        @Override  
        public void handle(Signal signalName) {  
               System.out.println(signalName.getName() + " is recevied."); 
               //do some things 
               //也可以另外定义一个类实现SignalHandler接口
        }  
});  

Signal sigTERM = new Signal("TERM");/* 注册KILL信号 */
Signal sigINT = new Signal("INT");/* 注册CTRL+C信号 */
```

发送信号前，需要先通过 ps 或 jps 获取java的进程id，然后运行
```shell
kill -s SIGUSR2 pid
```
如果在java的stdout 看到 SIGUSR2 is recevied 字样，说明信号被成功送达了。

### 在Java编程中使用信号的实际收益
信号作为最原始的进程间异步通信手段，有着诸多局限性的，比如不能传递上下文，信号随时都可能被占用导致冲突，不具备扩展性等，所以对功能性需求来说，使用它收益甚微。

当然，信号也不是一无是处，除了用作简单的异步通知外，还可以利用它的进程事件通知功能。

在Java里有一个典型例子，就是 ShutdownHook。

[原文链接](http://blog.csdn.net/kevinzhangfei/article/details/6997110)

## 启动时注册一个钩子函数

每个java进程都可以注册钩子线程，钩子线程程在程序退出的前被执行（kill -9强制退出除外）
java的hook ，钩子函数，在虚拟机启动时注册一个钩子函数，在程序退出(如使用kill命令，kill -9强制退出除外)前将会执行，java虚拟机会对钩子函数中资源进行回收。


关闭钩子 只是一个已初始化但尚未启动的线程。虚拟机开始启用其关闭序列时，它会以某种未指定的顺序启动所有已注册的关闭钩子，并让它们同时运行。运行完所有的钩子 后，如果已启用退出终结，那么虚拟机接着会运行所有未调用的终结方法。最后，虚拟机会暂停。注意，关闭序列期间会继续运行守护线程，如果通过调用 exit 方法来发起关闭序列，那么也会继续运行非守护线程。
   
   一旦开始了关闭序列，则只能通过调用 halt 方法来停止这个序列，此方法可强行终止虚拟机。
 
   一旦开始了关闭序列，则不可能注册新的关闭钩子或取消注册先前已注册的钩子。尝试执行这些操作会导致抛出 IllegalStateException 。
    
   关闭钩子可在虚拟机生命周期中的特定时间运行，因此应保护性地对其进行编码。特别是应将关闭钩子编写为线程安全的，并尽可能地避免死锁。关闭钩子还应该不 盲目地依靠某些服务，这些服务可能已注册了自己的关闭钩子，所以其本身可能正处于关闭进程中。例如，试图使用其他基于线程的服务（如 AWT 事件指派线程）可能导致死锁。
 
   关闭钩子应该快速地完成其工作。当程序调用 exit 时，虚拟机应该迅速地关闭并退出。由于用户注销或系统关闭而终止虚拟机时，底层的操作系统可能只允许在固定的时间内关闭并退出。因此在关闭钩子中尝试进行任何用户交互或执行长时间的计算都是不明智的。
   
   与其他所有线程一样，通过调用线程 ThreadGroup 对象的 uncaughtException 方法，可在关闭钩子中处理未捕获的异常。此方法的默认实现是将该异常的堆栈跟踪打印至 System#err 并终止线程；它不会导致虚拟机退出或暂停。
仅在很少的情况下，虚拟机可能会中止 ，也就是没有完全关闭就停止运行。虚拟机被外部终止时会出现这种现象，比如在 Unix 上使用 SIGKILL 信号或者在 Microsoft Windows 上调用 TerminateProcess 。如果由于内部数据结构损坏或试图访问不存在的内存而导致本机方法执行错误，那么可能也会中止虚拟机。如果虚拟机中止，则无法保证是否将运行关闭钩子。

注册钩子线程代码如下：
```java
//t为线程
Runtime.getRuntime().addShutdownHook(t);  
```

我们可以在钩子线程里做一些善后数据清理等事情，以保证程序是平滑退出的。
一般服务或框架运行都要考虑其生命周期：
如`spring`容器的`context.stop()`方法。
再如线程池`ExecutorService`的`shutdown`方法，它会保证不接受新任务，并把未执行完的任务做完。
 
我们再设计服务的时候也要考虑到停止时的`stop`方法，以便于退出时由钩子线程调用。

注册了钩子线程后，程序收到退出信号后，会保持程序运行，直到钩子线程执行完毕，才把程序的所有线程停止并退出，下面示例代码可以说明这一点：
```java
public class ShutDownTest {  
  
    public static void main(String[] args) {  
        //注册第一个钩子  
        Runtime.getRuntime().addShutdownHook(new Thread() {  
  
            public void run() {  
                try {  
                    Thread.currentThread().sleep(5000);  
                } catch (InterruptedException e) {  
                    e.printStackTrace();  
                }  
                System.out.println("clean task1 completed.");  
            }  
        });  
        //注册第二个钩子  
        Runtime.getRuntime().addShutdownHook(new Thread() {  
  
            public void run() {  
                try {  
                    Thread.currentThread().sleep(10000);  
                } catch (InterruptedException e) {  
                    e.printStackTrace();  
                }  
                System.out.println("clean task2 completed");  
            }  
        });  
        //启动子线程  
        new Thread() {  
  
            public void run() {  
                while (true) {  
                    try {  
                        Thread.currentThread().sleep(1000);  
                        System.out.println("sub thread is running");  
                    } catch (InterruptedException e) {  
                        e.printStackTrace();  
                    }  
                }  
            }  
        }.start();  
        //程序退出  
        System.exit(0);  
    }  
  
}  
```

程序输出
```shell
sub thread is running  
sub thread is running  
sub thread is running  
sub thread is running  
clean task1 completed.  
sub thread is running  
sub thread is running  
sub thread is running  
sub thread is running  
sub thread is running  
clean task2 completed  
```

注意点 ：`钩子线程里只处理善后，目标是尽可能快的退出且不保证有脏数据。如果钩子线程里做过多事情，或者发生阻塞，那么可能出现kill失效，程序不能退出的情况，这是需要强制退出`。
如以下程序会导致kill失效，需要强制退出，因为钩子线程阻塞了：
```java
public class ShutDownTest {  
  
    public static void main(String[] args) {  
        //注册钩子  
        Runtime.getRuntime().addShutdownHook(new Thread() {  
            public void run() {  
                synchronized (ShutdownFileTest.class) {  
                    try {  
                        ShutdownFileTest.class.wait();  
                    } catch (InterruptedException e) {  
                        e.printStackTrace();  
                    }  
                }  
            }  
        });  
        //启动子线程  
        new Thread() {  
            public void run() {  
                while (true) {  
                    try {  
                        Thread.currentThread().sleep(1000);  
                        System.out.println("sub thread is running");  
                    } catch (InterruptedException e) {  
                        e.printStackTrace();  
                    }  
                }  
            }  
        }.start();  
       System.exit(0);  
       }  
  
}  
```

### 没使用线程池的多线程中，钩子函数接收到关闭命令时传递死循环标志位

多线程，用线程启动死循环，然后钩子函数接收到关闭命令时传递死循环标志位。
```java
public class MyRunnable implements Runnable {
    private volatile boolean quit =false;

    public boolean isQuit() {
        return quit;
    }

    public void setQuit(boolean quit) {
        this.quit = quit;
    }

    public void run() {
        int i = 0;
        while (!quit) {
            doStuff(i++);
        }
    }

    private void doStuff(int n) {

        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("----->" + n);
    }

}


import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class TestThread {

    public static void main(String[] args) {

        final MyRunnable test = new MyRunnable();
        

        final ExecutorService executorService = Executors.newCachedThreadPool();
        executorService.execute(test);

        Runtime.getRuntime().addShutdownHook(new Thread() {
            public void run() {
                test.setQuit(true);
                sleep(5);
                    while (test.isQuit()&&!executorService.isShutdown()) {
                        System.out.println("thread is closed, now ,close executorService!"); // optional
                        executorService.shutdown();
                    }

            }

            private void sleep(int n) {
                try {
                    Thread.sleep(1000*n);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

    }

}
```

### 系统创建一个shutdown file,程序监控一个shutdown  file是否存在

系统创建一个shutdown file.并监听shutdown file是否存在。如果发现shutdown file不存在了，那么调用System.exit,将程序退出。

`如果期望只有特定的人才能终止该程序，那么你可以给文件设定权限，这样就只有特定的人可以终止程序。`
```java
import java.io.File;  
import java.io.IOException;  
  
public class ShutdownFileTest {  
  
    public static void main(String[] args) {  
        // 启动子线程  
        new Thread() {  
  
            public void run() {  
                while (true) {  
                    try {  
                        Thread.currentThread().sleep(1000);  
                        System.out.println("sub thread is running");  
                    } catch (InterruptedException e) {  
                        e.printStackTrace();  
                    }  
                }  
            }  
        }.start();  
          
        //启动shutdownfile监听线程  
        new Thread() {  
  
            public void run() {  
                File shutDownFile = new File("a.shutdown");  
                // create shut down file  
                if (!shutDownFile.exists()) {  
                    try {  
                        shutDownFile.createNewFile();  
                    } catch (IOException e) {  
                        e.printStackTrace();  
                    }  
                }  
                // watch for file deleted then shutdown   
                while (true) {  
                    try {  
                        if (shutDownFile.exists()) {  
                            Thread.currentThread().sleep(1000);  
                        } else {  
                            System.exit(0);  
                        }  
                    } catch (InterruptedException e) {  
                        e.printStackTrace();  
                    }  
                }  
            }  
        }.start();  
    }  
  
}  
```

### 通过JMX的mbean远程控制来实现

Controlled application:
run it with the folowing VM parameters:
-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.port=9999
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.ssl=false

```java
//ThreadMonitorMBean.java
public interface ThreadMonitorMBean
{
String getName();
void start();
void stop();
boolean isRunning();
}

// ThreadMonitor.java
public class ThreadMonitor implements ThreadMonitorMBean
{
private Thread m_thrd = null;

public ThreadMonitor(Thread thrd)
{
    m_thrd = thrd;
}

@Override
public String getName()
{
    return "JMX Controlled App";
}

@Override
public void start()
{
    // TODO: start application here
    System.out.println("remote start called");
}

@Override
public void stop()
{
    // TODO: stop application here
    System.out.println("remote stop called");

    m_thrd.interrupt();
}

public boolean isRunning()
{
    return Thread.currentThread().isAlive();
}

public static void main(String[] args)
{
    try
    {
        System.out.println("JMX started");

        ThreadMonitorMBean monitor = new ThreadMonitor(Thread.currentThread());

        MBeanServer server = ManagementFactory.getPlatformMBeanServer();

        ObjectName name = new ObjectName("com.example:type=ThreadMonitor");

        server.registerMBean(monitor, name);

        while(!Thread.interrupted())
        {
            // loop until interrupted
            System.out.println(".");
            try 
            {
                Thread.sleep(1000);
            } 
            catch(InterruptedException ex) 
            {
                Thread.currentThread().interrupt();
            }
        }
    }
    catch(Exception e)
    {
        e.printStackTrace();
    }
    finally
    {
        // TODO: some final clean up could be here also
        System.out.println("JMX stopped");
    }
}
}
```
Controlling application:
run it with the stop or start as the command line argument
```java
public class ThreadMonitorConsole
{

public static void main(String[] args)
{
    try
    {   
        // connecting to JMX
        System.out.println("Connect to JMX service.");
        JMXServiceURL url = new JMXServiceURL("service:jmx:rmi:///jndi/rmi://:9999/jmxrmi");
        JMXConnector jmxc = JMXConnectorFactory.connect(url, null);
        MBeanServerConnection mbsc = jmxc.getMBeanServerConnection();

        // Construct proxy for the the MBean object
        ObjectName mbeanName = new ObjectName("com.example:type=ThreadMonitor");
        ThreadMonitorMBean mbeanProxy = JMX.newMBeanProxy(mbsc, mbeanName, ThreadMonitorMBean.class, true);

        System.out.println("Connected to: "+mbeanProxy.getName()+", the app is "+(mbeanProxy.isRunning() ? "" : "not ")+"running");

        // parse command line arguments
        if(args[0].equalsIgnoreCase("start"))
        {
            System.out.println("Invoke \"start\" method");
            mbeanProxy.start();
        }
        else if(args[0].equalsIgnoreCase("stop"))
        {
            System.out.println("Invoke \"stop\" method");
            mbeanProxy.stop();
        }

        // clean up and exit
        jmxc.close();
        System.out.println("Done.");    
    }
    catch(Exception e)
    {
        // TODO Auto-generated catch block
        e.printStackTrace();
    }
}
}
```

[how-to-stop-java-process-gracefully](http://stackoverflow.com/questions/191215/how-to-stop-java-process-gracefully)

[原文链接](http://singleant.iteye.com/blog/1441219)
