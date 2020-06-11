title: 简单使用processbuilder执行shell命令-调用SFTP
date: 2017-07-18 14:07:23
tags: [Java]
categories: Java
description: 在jdk 1.5 前使用Runtime.exec()。之后可用ProcessBuilder执行shell命令。 
---

## ProcessBuilder.start()和 Runtime.exec()
### 相同：都可获取Process实例
ProcessBuilder.start() 和 Runtime.exec() 方法都被用来`创建一个操作系统进程（执行命令行操作），并返回 Process 子类的一个实例`，该实例可用来控制进程状态并获得相关信息。 

每个ProcessBuilder实例管理一个进程属性集。ProcessBuilder的start()方法利用这些属性创建一个新的Process实例。start()方法可以从同一实例重复调用，以利用相同或者相关的属性创建新的子进程。 

### Process类
Process 类提供了`执行从进程输入、执行输出到进程、等待进程完成、检查进程的退出状态以及销毁（杀掉）进程`的方法。创建进程的方法`可能无法针对某些本机平台上的特定进程很好地工作`，比如，本机窗口进程，守护进程，Microsoft Windows 上的 Win16/DOS 进程，或者 shell 脚本。创建的子进程没有自己的终端或控制台。它的所有标准 io（即 stdin、stdout 和 stderr）操作都将通过三个流 (getOutputStream()、getInputStream() 和 getErrorStream()) `重定向到父进程`。父进程使用这些流来提供到子进程的输入和获得从子进程的输出。`因为有些本机平台仅针对标准输入和输出流提供有限的缓冲区大小，如果读写子 进程的输出流或输入流迅速出现失败，则可能导致子进程阻塞，甚至产生死锁`。 当没有 Process 对象的更多引用时，不是删掉子进程，而是继续异步执行子进程。 对于带有 Process 对象的 Java 进程，没有必要异步或并发执行由 Process 对象表示的进程。 

### 不同点：参数不同，ProcessBuilder更多控制
ProcessBuilder.start() 和 Runtime.exec()`传递的参数有所不同`，Runtime.exec()可接受一个单独的字符串，这个字符串是通过空格来分隔可执行命令程序和参数的；也可以接受字符串数组参数。而ProcessBuilder的构造函数是一个字符串列表或者数组。列表中第一个参数是可执行命令程序，其他的是命令行执行是需要的参数。 
通过查看JDK源码可知，`Runtime.exec最终是通过调用ProcessBuilder来真正执行操作的,以ProcessBuilder里用ProcessImpl,start 的一个子进程执行命令,`。 

ProcessBuilder为进程提供了更多的控制，例如，可以设置当前工作目录，还可以改变环境参数。而Process的功能相对来说简单的多。
ProcessBuilder是一个final类，有两个带参数的构造方法，你可以通过构造方法来直接创建ProcessBuilder的对象。而Process是一个抽象类，一般都通过Runtime.exec()和ProcessBuilder.start()来间接创建其实例。

### 注意：

 1. 修改进程构建器的属性将影响后续由该对象的 start() 方法启动的进程，但从不会影响以前启动的进程或 Java 自身的进程。
 2. ProcessBuilder类不是同步的。如果多个线程同时访问一个 ProcessBuilder，而其中至少一个线程从结构上修改了其中一个属性，它必须 保持外部同步。
 3. 当没有 Process 对象的更多引用时，不是删掉子进程，而是继续异步执行子进程。 对于带有 Process 对象的 Java 进程，没有必要异步或并发执行由 Process 对象表示的进程。

## 使用ProcessBuilder执行shell命令，示例SFTP

Java示例如下，sftp.properties中四个参数如代码所示。
```java

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.util.*;

/**
 * 项目名称：
 * Created by YZ on 2017-7-17 16:49.
 */
public class SFTPProcessUtil {
    private static Logger logger = LoggerFactory.getLogger(SFTPProcessUtil.class);
    public static PropertyResourceBundle perperty = null;
    public static String sftpDir = null;

    public synchronized static List<String> ls(){
        List<String> list = null;
        if (perperty == null)
            perperty = (PropertyResourceBundle) ResourceBundle.getBundle("sftp");
        String curNormalUser = perperty.getString("sftp.curNormalUser");
        String sftpUser = perperty.getString("sftp.user");
        String sftpHost = perperty.getString("sftp.host");
        if (sftpDir == null)
            sftpDir = perperty.getString("sftp.dir");
        if(!(regexStr(curNormalUser,sftpUser,sftpHost,sftpDir))){
            logger.error("SFTPProcessUtil regexStr failed,please check:["+curNormalUser+"],["+sftpUser+"],["+sftpHost+"],["+sftpDir+"]");
            return null;
        }
        curNormalUser = curNormalUser.trim();
        sftpUser = sftpUser.trim();
        sftpHost = sftpHost.trim();
        sftpDir = sftpDir.trim();

        ProcessBuilder check = null;
        InputStream is =null;
        Process process = null;
        BufferedReader br = null;
        OutputStream os = null;
        BufferedWriter bw = null;
        try {
            check = new ProcessBuilder("whoami");
            process = check.start();
            if (process.waitFor() == 0){
                is = process.getInputStream();
                br = new BufferedReader(new InputStreamReader(is,"UTF-8"));
                String line;
                if ((line = br.readLine()) != null){
                    logger.info("ProcessBuilder Result:"+line);
                    if (!curNormalUser.equalsIgnoreCase(line.trim())){
                        if (!"root".equals(line.trim())){
                            return null;
                        }else{
                            closeProcess(process,br,bw);
                            check = new ProcessBuilder("su",curNormalUser);
                            process = check.start();
                            os = process.getOutputStream();
                            bw = new BufferedWriter(new OutputStreamWriter(os,"UTF-8"));
                            bw.write("sftp " + sftpUser+"@"+sftpHost+"<<!\n");
                            bw.write("ls "+ sftpDir + "\n");
                            bw.write("bye\n");
                            bw.write("!\n");
                            bw.write("exit\n");
                            bw.flush();
                            is = process.getInputStream();
                            br = new BufferedReader(new InputStreamReader(is,"UTF-8"));
                            line = null;
                            list = new ArrayList<String>();
                            while((line = br.readLine()) != null){
                                logger.info("ProcessBuilder Result:"+line);
                                if(!(line.startsWith("sftp> ls") || line.startsWith("sftp> bye"))){
                                    list.add(line.substring(line.lastIndexOf("/") + 1,line.length()));
                                }
                            }
                        }
                    }else{
                        closeProcess(process,br,bw);
                        check = new ProcessBuilder("sftp",sftpUser+"@"+sftpHost,"<<!\n");
                        process = check.start();
                        os = process.getOutputStream();
                        bw = new BufferedWriter(new OutputStreamWriter(os,"UTF-8"));
                        bw.write("ls " + sftpDir + "\n");
                        bw.write("bye\n");
                        bw.write("!\n");
                        bw.flush();
                        is = process.getInputStream();
                        br = new BufferedReader(new InputStreamReader(is,"UTF-8"));
                        line = null;
                        list = new ArrayList<String>();
                        while((line = br.readLine()) != null){
                            logger.info("ProcessBuilder Result:"+line);
                            if(!(line.startsWith("sftp> ls") || line.startsWith("sftp> bye"))){
                                list.add(line.substring(line.lastIndexOf("/") + 1,line.length()));
                            }
                        }
                    }
                }
            }else {
                is = process.getErrorStream();
                br = new BufferedReader(new InputStreamReader(is,"UTF-8"));
                String line;
                logger.error("shell exec error begin");
                while((line = br.readLine()) != null){
                    logger.error(line);
                }
                logger.error("shell exec error end");
            }
            if (list != null){
                Collections.reverse(list);
                for (String s:list
                     ) {
                    logger.info("SFTPProcessUtil.ls() retrun:"+s);
                }
            }
        } catch (IOException e) {
            logger.error("ProcessBuilder IOException:",e);
        } catch (InterruptedException e) {
            logger.error("ProcessBuilder InterruptedException:",e);
        } catch (Exception e){
            logger.error("ProcessBuilder Exception:",e);
        }finally {
            try {
                closeProcess(process,br,bw);
            } catch (IOException e) {
                logger.error("ProcessBuilder closeProcess:",e);
            }
        }
        return list;
    }

    private static void closeProcess(Process process, BufferedReader br, BufferedWriter bw) throws IOException {
        if (br != null)
            br.close();
        if (bw != null)
            bw.close();
        if (process != null)
            process.destroy();
    }

    /**
     * 验证配置文件中的参数是否可用
     * @param strs
     * @return
     */
    public static boolean regexStr(String... strs){
        boolean regex = true;
        for(String str:strs){
            if (str == null) {regex = false; return false;}
            if(str.matches("[\t\n\r\f\u0000|;&$><`\\!~]+")) {regex = false;return false;}
            str = str.trim();
            str = str.replaceAll("[\u4E00-\u9FA5a-zA-Z0-9._-]","");
            str = str.replaceAll("[?/\\x22]","");
            regex = regex && "".equals(str.trim());
        }

        return regex;
    }
}



```

PS：如果是root用户，需要跳转到普通用户。使用su 用户名，跳转时不需要使用输入重定向。但是在操作完后，记得使用exit退出。使用sftp命令时，可以使用`<<`将输入重定向，并约定结束标记，例如`<<!\n`，结束时，即需要使用`!\n`。
`ls dir` dir 可输入如`/user/????.xml`

下面是一个利用修改过的工作目录和环境启动进程的例子：
```java
 ProcessBuilder pb = new ProcessBuilder("myCommand", "myArg1", "myArg2");
 //切换当前 Process p = pb.start();的环境
 Map<String, String> env = pb.environment();
 env.put("VAR1", "myValue");
 env.remove("OTHERVAR");
 env.put("VAR2", env.get("VAR1") + "suffix");
 //切换工作目录
 pb.directory("myDir");
 Process p = pb.start();
```
 要利用一组明确的环境变量启动进程，在添加环境变量之前，首先调用 Map.clear()。 

## Java中的命令注入

Java的native调用
 a. Windows是CreateProcessW 创建子进程执行命令
 b. Unix中以enecve 来创建子进程执行命令

Java并没有使用system函数进行创建子进程执行命令，通常我们也知道system的函数非常容易发生注入风险，比如system("ls "+"test;rm *); 后面部分是用户输入的，用户输入通过注入符号`;`和后续指令`rm *`，被系统执行。
 execve, CreateProcessW 函数通过执行命令和参数分别传递的方式，这种方式杜绝了system的拼接命令的方式，有一定的安全性，但也未必是安全的。

例如windows下的`cmd.exe /K `参数可以批量执行命令。如果传入`&&del *`,最后变成
`cmd.exe /K "del C:\\test1.txt && del *&&del C:\\test2.txt"`.
Unix下的`/bin/bash –c `参数，后续输入参数为执行命令，如果传入`;rm *`,最后等效于
`/bin/bash –c "sh script.sh; rm *"`.

所以我们应该对参数进行过滤/转码

### 常用黑名单

 a.  |;&$><`\!可以将这些字符直接作为黑名单过滤
 b.  \t\n\r\f \u0000 这些字符需要作为黑名单过滤，特别是空字符截断 `\u0000` (这个在JVM6里是没有保护)

白名单一般只需允许`[a-z][A-Z][0-9] _- `等有限的字符.

### 常用shell命令的转码

![常用shell命令的转码](common shell trans.png)
参考[博客](http://blog.csdn.net/raintungli/article/details/51917122)。
