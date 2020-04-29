title:  自动装包与拆包中需要注意的int Integer数据范围
date: 2015-03-03 17:42:58
tags: Java  
categories: Java 
description: 1.自动拆包时，对于-128-127的值会放在内存中重用，超出范围则不会；2.定义Integer时，赋值null，自动拆包时，编译通过，运行报错。

---

在这里，区别一个概念“==”和equals（） 
    “==”是比较两个对象是不是引用自同一个对象 
     “equals（）”是比较两个对象的内容 
``` java
	Integer data1 = 500;  
	Integer data2 = 500;  
	System.out.println(data1==data2);  
```
## -128-127之间int可以自动拆包
 自动装包时，对于值从-128-127之间的数(int)，被装包后，会被放在内存中进行重用，如果超出了这个值的范围就不会被重用的，所以每次new出来的Integer都是一个新的对象


``` java
	Integer i = null;//表明i没有参考至任何对象 
	int j = i ;//相当于 int j = i.intValue（） 
```
## Integer赋值为null，可以自动拆包
编译时是可以通过的，因为它的语法是正确的，但在运行时，就会排除NullPointerException错误，这是由于i并没有参考至任何对象造成的