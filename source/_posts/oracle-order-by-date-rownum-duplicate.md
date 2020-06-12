title: oracle分页中根据时间排序时数据重复的问题
date: 2015-10-09 16:41:22
tags: oracle
categories: oracle
description: 解决方案，在根据时间排序后，增加唯一性列排序，如主键。
---

分页查询中，数据按照日期时间排序时，出现数据重复。 原因是：在数据中，日期的值不是唯一的。
解决方案，在根据时间排序后，增加唯一性列排序，如主键。

详见 [gavinloo的专栏](http://blog.csdn.net/gavinloo/article/details/12782095)

另外，在Oracle中一个汉字相当于3个varchar2长度，UTF-8时候
GBK是一个汉字两个，utf-8是一个汉字3个。

ojdbc.jar包位于以下目录
cd $ORACLE_HOME/jdbc/lib

