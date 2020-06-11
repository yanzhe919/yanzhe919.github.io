title: 安装IBM WebSphere MQ以及一些基本MQ命令
date: 2016-03-15 08:53:38
tags: [MQ]
categories: Java
description: 安装IBM MQ后，本地连接报错2035，一点解决办法。以及一些基本MQ命令。

---


IBM® MQ 是强大的消息传递中间件，有助于简化并加速多个平台中多种应用和业务数据的集成。IBM MQ 通过消息传递队列发送和接收消息数据，有助于应用、系统、服务和文件间的信息实现有保证、安全、可靠的交换，从而简化业务应用的创建和维护。它可以为范围广泛的产品提供统一消息传递，能够满足企业范围的消息传递需求，为物联网和移动设备提供连通性。

[官网地址](http://www-03.ibm.com/software/products/zh/ibm-mq)

### 安装后 MQ 本地连接，2035


** `WIN + X` 然后 A 以管理员打开cmd 添加用户     `NET USER MQUSER /ADD`    查看用户组 `Win + R LUSRMGR.MSC`

另外创建用户在MQM组后，仍然报错时，可以考虑输入以下命令
```shell
** 关闭通道验证
alter qmgr CHLAUTH(DISABLED)
ALTER AUTHINFO(SYSTEM.DEFAULT.AUTHINFO.IDPWOS) AUTHTYPE(IDPWOS) CHCKCLNT(NONE)
REFRESH SECURITY TYPE(CONNAUTH)
```

[原文链接](http://www-01.ibm.com/support/docview.wss?uid=swg21680930)

### 一些基本命令

```shell
** (查看MQ是否安装成功)
crtmqm

** (创建/替换WebSphere MQ 队列管理器"Test001")
crtmqm -lc -lf 20480 -lp 20 -ls 2 Test001 

** 查看MQ 队列管理器状态
dspmq

** 启动 WebSphere MQ 队列管理器“Test001”
strmqm Test001

** 查看MQ 队列管理器状态
dspmq

** 执行temp.txt中的MQ相关命令，并将结果输出到mq.log
runmqsc Test001 < D:\mq\temp.txt >mq.log

** 启动队列管理器 Test001 的 MQSC
runmqsc Test001

** 1 : dis qs(*) AMQ8450: 显示队列状态详细信息
dis qs(*)


** 创建通道 S_CHL
def chl(S_CHL) chltype(SVRCONN) TRPTYPE(TCP)  maxmsgl(10485760) replace


START CHL(S_CHL) 

def chl(S_CHL) chltype(SVRCONN) TRPTYPE(TCP) MCAUSER('mqm')  maxmsgl(10485760) replace

ALTER CHL(S_CHL) CHLTYPE(SVRCONN) MCAUSER(null) 
ALTER CHL(S_CHL) CHLTYPE(SVRCONN) MCAUSER('MUSR_MQADMIN') 
ALTER CHL(S_CHL) CHLTYPE(SVRCONN) MCAUSER('Administrator') 

** 查看
dis qcluster(*)

** 创建监听TESTLISTENER
def listener(TESTLISTENER) TRPTYPE(TCP) PORT(1415) BACKLOG(0) CONTROL(QMGR) 

** 启动监听
START LISTENER(TESTLISTENER) 

** 显示队列管理器的细节
dis qmgr

** 修改队列管理器CCSID
alter qmgr ccsid(1415)

** 关闭通道验证
alter qmgr CHLAUTH(DISABLED)

** 创建队列 TESTQL01
def ql(TESTQL01) maxdepth(100000) maxmsgl(10485760) defprty(9) defpsist(yes) replace

** 退出
end

ALTER AUTHINFO(SYSTEM.DEFAULT.AUTHINFO.IDPWOS) AUTHTYPE(IDPWOS) CHCKCLNT(NONE)
REFRESH SECURITY TYPE(CONNAUTH)

** 停止并删除
endmqm Test001
dltmqm Test001


```
