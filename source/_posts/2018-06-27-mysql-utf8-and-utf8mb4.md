---
title: MySQL中utf8和utf8mb4的使用以及字符集相关
date: 2018-06-28 09:22:49
tags: 
 - MySQL
 - utf8mb4
 - MySQL字符集
 - MySQL大小写
 - MySQL尾部空格
 - InnoDB default ROW_FORMAT
categories:
 - MySQL
description: MySQL中utf8编码最长使用3字节，在5.5.3新增的utf8mb4，才是兼容四字节的。Java的UTF-8是支持4字节的，所以不需配置mb4 。而Java驱动会自动检测服务端的character_set_server，为utf8mb4，驱动在建立连接时设置SET NAMES utf8mb4。utf8mb4_general_ci 在比较和排序的时候更快，utf8mb4_unicode_ci 更精确。
---

# 概述

以前一般在MySQL开发了，就实际上转向Oracle了，没留意一些东西，碰到了就回头过来看看。
有小伙伴在安装MySQL后设置编码为utf8，我们以前都是会直接设置utf8mb4，这背后又隐藏着什么？这一切的背后，究竟是人性的扭曲还是道德的沦丧？

其实只是因为`Unicode 委员会还做着 “65535 个字符足够全世界用了”的美梦。` [参考](https://my.oschina.net/xsh1208/blog/1052781) 我比较喜欢这句。
也就是指的Unicode最初的[基本多文本平面](https://zh.wikipedia.org/wiki/Unicode%E5%AD%97%E7%AC%A6%E5%B9%B3%E9%9D%A2%E6%98%A0%E5%B0%84) (BMP)（U+0000至U+FFFF），BMP 已经包含了控制符、拉丁文，中、日、韩等绝大多数国际字符，但并不是所有，最常见的就算现在手机端常用的表情字符Emoji（Emoji 是一种特殊的 Unicode 编码，常见于 ios 和 android 手机上）一些不常用的汉字，如 “墅” ，这些需要四个字节才能编码出来。后来的补充字符(U+10000至U+10FFFF)，则将Unicode扩充到了(U+0000至U+10FFFF)。

 > 注：QQ里面的内置的表情不算，它是通过特殊映射到的一个gif图片。一般输入法自带的就是。

MySQL在**5.5.3**之后(查看版本：select version();)增加了这个`utf8mb4`的编码，mb4就是**most bytes 4**的意思，支持的字节数最大为4，即专门用来兼容四字节的unicode。
而我们通常在MySQL中所说的`utf8`编码，其实就是指的 **utf8mb3** 。utf8mb4 是 utf8mb3 的超集并完全兼容utf8mb3，能够用四个字节存储更多的字符。

 > utf8mb3：Unicode字符集的UTF-8编码，每个字符使用1到3个字节。
 > utf8mb4：Unicode字符集的UTF-8编码，每个字符使用1到4个字节。

对于 CHAR 类型数据，utf8mb4 会多消耗一些空间，根据 Mysql 官方建议， **使用 VARCHAR 替代 CHAR** 以有效节省空间。

当你的数据库里要求能够存入这些表情或宽字符时，可以把字段定义为 `utf8mb4`，同时要注意连接字符集也要设置为`utf8mb4`，否则在 [严格模式](http://seanlook.com/2016/04/22/mysql-sql-mode-troubleshooting/) 下会出现 `Incorrect string value: /xF0/xA1/x8B/xBE/xE5/xA2… for column 'name' ` 这样的错误，非严格模式下此后的数据会被截断。

建立数据库/表和进行数据库操作时尽量显式指出使用的字符集，而不是依赖于MySQL的默认设置，否则MySQL升级时可能带来很大困扰。

**如默认不区分大小写，可添加binary，强制进行按字节进行比较,以区分大小写。** `如建表时未添加binary属性，可能影响索引失效` <a href="#binary相关">其他binary相关</a>

**MySQL使用的UTF-8都没有BOM值。** 
`BOM(Byte Order Mark)，即文本开头为不可见的3个字节，EF BB BF`

# <a href="#修改为utf8mb4示例">utf8升级utf8mb4</a>

如果你的表定义和连接字符集都是utf8，那么直接在你的表上执行
```
ALTER TABLE tbl_name CONVERT TO CHARACTER SET utf8mb4;
```
则能够该表上所有的列的character类型变成 utf8mb4，表定义的默认字符集也会修改。

点击上面目录见修改数据库、表、字段实例，或<a href="#修改为utf8mb4示例">点这实例</a> 。

## 注意事项

 - 使用utf8mb4之后，官方建议尽量用 varchar 代替 char。
 - `SET NAMES utf8mb4;` 让连接的时候便可以插入四字节字符。（如果依然使用 utf8 连接，只要不出现四字节字符则完全没问题）。
 - `SET character-set-server = utf8mb4;` 修改服务端 `character-set-server=utf8mb4`，Java驱动会自动检测服务端 `character_set_server` 的配置，如果为utf8mb4，驱动在建立连接的时候设置 `SET NAMES utf8mb4`。
 - `SET character-set = utf8mb4;` 修改服务端c++, php, python 等语言的设置。
 - 不能ONLINE，也就是执行之后全表禁止修改，有关这方面的讨论见 [mysql 5.6 原生Online DDL解析](http://seanlook.com/2016/05/24/mysql-online-ddl-    concept/)；
 - 它可能会自动该表字段类型定义，如 [VARCHAR 被转成 MEDIUMTEXT](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html)，可以通过 MODIFY       指定类型为原类型
 - 不要随便执行`ALTER TABLE tbl_name DEFAULT CHARACTER SET utf8mb4`， **特别是当表原本不是utf8时，除非表是空的或者你确认表里只有拉丁字符**  ，否则正常和乱的就混在一起了。 
 - **最重要的是** ，你连接时使用的latin1字符集写入了历史数据，表定义是latin1或utf8，不要期望通过 `ALTER ... CONVERT ...` 能够让你达到用utf8读取历史中文数据的目的，没卵用，老老实实做逻辑dump。
 - 索引键超长问题。`Error 1071: Specified key was too long; max key length is 767 bytes`。当使用utf8mb4编码后，主键id的长度设置255，太长，只能设置小于191的。<a herf="#索引键超长">详解</a>
 - join 查询时索引失效问题。索引失效发生在utf8mb4列 在条件左边。

[摘自](http://seanlook.com/2016/10/23/mysql-utf8mb4/)

<a href="#SET NAMES utf8mb4 实际等同于SET">`SET NAMES utf8mb4;`实际等同于</a>
<a href="#MySQL字符集系统变量名简述">MySQL字符集系统变量名简述</a>

其他
 * my.cnf中的default_character_set设置只影响mysql命令连接服务器时的连接字符集，不会对使用libmysqlclient库的应用程序产生任何作用！
 * 对字段进行的SQL函数操作通常都是以内部操作字符集进行的，不受连接字符集设置的影响。
 * SQL语句中的裸字符串会受到连接字符集或introducer设置的影响，对于比较之类的操作可能产生完全不同的结果，需要小心！

# 命令详解

## 列出可用的字符集


```
SHOW CHARACTER SET;
```

或是查询`INFORMATION_SCHEMA CHARACTER_SETS表`

列出常见字符集

| Charset  | Description      | Default collation   | Maxlen |
|----------|------------------|---------------------|--------|
| gb18030  |                  | gb18030_chinese_ci  |      4 |
| gb2312   |                  | gb2312_chinese_ci   |      2 |
| gbk      |                  | gbk_chinese_ci      |      2 |
| utf16    | UTF-16 Unicode   | utf16_general_ci    |      4 |
| utf16le  | UTF-16LE Unicode | utf16le_general_ci  |      4 |
| utf32    | UTF-32 Unicode   | utf32_general_ci    |      4 |
| utf8     |                  | utf8_general_ci     |      3 |
| utf8mb4  | UTF-8 Unicode    | utf8mb4_0900_ai_ci  |      4 |

是的，没写错，utf8已经不好意思在描述里自称`UTF-8 Unicode`了

## 列出字符集的排序规则(校对集)以及规则解释

给定的字符集总是至少有一个排序规则，并且大多数字符集都有几个排序规则。

```
SHOW COLLATION WHERE Charset = 'utf8mb4';
```

或查询`INFORMATION_SCHEMA COLLATIONS表`

utf8 的默认排序规则为`utf8_general_ci`

列出`utf8mb4`的常见排序规则，默认为`utf8mb4_0900_ai_ci` ，即是UCA 9.0.0版本的Unicode，口音不敏感，不区分大小写 。


| Collation                  | Charset | Id  | Default | Compiled | Sortlen | Pad_attribute |
|----------------------------|---------|-----|---------|----------|---------|---------------|
| utf8mb4_0900_ai_ci         | utf8mb4 | 255 | Yes     | Yes      |       0 | NO PAD        |
| utf8mb4_general_ci         | utf8mb4 |  45 |         | Yes      |       1 | PAD SPACE     |
| utf8mb4_unicode_520_ci     | utf8mb4 | 246 |         | Yes      |       8 | PAD SPACE     |
| utf8mb4_unicode_ci         | utf8mb4 | 224 |         | Yes      |       8 | PAD SPACE     |

### Pad_attribute:MySQL比较字符串时尾部空格是否忽略

`NO PAD`   排序规则将字符串末尾的空格处理为任何其他字符。
`PAD SPACE`排序，尾部空格在比较中无关紧要; 比较字符串而不考虑任何尾随空格。

即是`PAD SPACE`会出现以下情况，MySQL比较字符串时会忽略尾部空格。包括其他推荐的`utf8mb4_unicode_ci`和`utf8mb4_general_ci`以及所有utf8,，这算是一个小坑，注意不要跳进来了。


```MySQL比较字符串时尾部有空格
SELECT 'a ' = 'a';
+------------+
| 'a ' = 'a' |
+------------+
|          1 |
+------------+

```

所以，**使用`utf8mb4_unicode_ci`和`utf8mb4_general_ci`时，一定要做好去空格trim操作。**

`utf8mb4_general_ci` 在比较和排序的时候更快。
`utf8mb4_unicode_ci` 是基于标准的Unicode来排序和比较，能够在各种语言之间精确排序。比如Unicode把`ß`、`Œ`当成`ss`和`OE`来看；而general会把它们当成`s`、`e`，再如`ÀÁÅåāă`各自都与 `A` 相等。


### MySQL字符串比较时，_ci不区分，_cs/_bin区分大小写

安装时如果文件系统区分，如Linux，则`lower_case_table_names`参数为0，即区分大小写。
      如果文件系统不区分，如Windows或MacOS上，即不区分大小写。
      在Windows上，默认值为1.在macOS上，默认值为2。

| OS           | lower_case_table_names | 是否区分大小写| 存储数据库、表、表别名                  |
|------------- | ---------------------- | --------------| -----                                   |
|Linux、Unix   | 0                      | 区分大小写    | 表名将按指定存储                        |
|Windows       | 1                      | 不区分大小写  | 表名将以小写形式存储在磁盘上            |
|MacOS         | 2                      | 不区分大小写  | 表名按照给定值存储，但以小写形式比较    |

**MyISAM 引擎不支持--lower_case_table_names=0在不区分大小写的文件系统上启动服务器**
**InnoDB 引擎，则应在所有平台上将此变量设置为1以强制名称转换为小写字母。**

| 后缀	| 含义                |
|-------|-------              |
|_ai    |	口音不敏感        |
|_as    |	口音敏感          |
|_ci    |	不区分大小写      |
|_cs    |	区分大小写        |
|_ks    |	假名敏感          |
|_bin   |	二进制,区分大小写 |

### Unicode排序算法(UCA)版本

对于Unicode字符集，排序规则名称可能包含一个版本号，以指示排序规则基于的Unicode排序算法（UCA）的版本。
 - utf8mb4_0900_ai_ci基于[UCA 9.0.0](http://www.unicode.org/Public/UCA/9.0.0/allkeys.txt)。

 - utf8mb4_unicode_520_ci基于[UCA 5.2.0](http://www.unicode.org/Public/UCA/5.2.0/allkeys.txt)。

 - utf8mb4_unicode_ci（没有版本命名）基于[UCA 4.0.0](http://www.unicode.org/Public/UCA/4.0.0/allkeys-4.0.0.txt)。

## INFORMATION_SCHEMA 中的大小写敏感

INFORMATION_SCHEMA表格中的 字符串列具有utf8_general_ci大小写不敏感的排序规则。当前在Linux上，`lower_case_table_names`为0，即区分大小写。
查询在SCHEMATA.SCHEMA_NAME列中 搜索 mysql数据库，和MYSQL 数据库，结果将不同。

想使用MYSQL查询出mysql
 1. 查询时COLLATE指定排序规则

```查询时COLLATE指定排序规则
SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME COLLATE utf8_general_ci = 'MYSQL';
+-------------+
| SCHEMA_NAME |
+-------------+
| mysql       |
+-------------+
```

 2. 使用UPPER或LOWER

```使用UPPER
SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE UPPER(SCHEMA_NAME) = 'MYSQL';
+-------------+
| SCHEMA_NAME |
+-------------+
| mysql       |
+-------------+
```

查询INFORMATION_SCHEMA中搜索自身时，将匹配`utf8_general_ci`规则。
```
SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'INFORMATION_SCHEMA';
```

## binary相关

**binary不同于_bin**

**LOWER() 和 UPPER() 对于二进制字符串是无效的(包括 BINARY, VARBINARY, BLOB)**
`SELECT LOWER('aA'), UPPER('zZ');`
不适用于
`SET NAMES binary;`
必须将字符串转换为非二进制字符串
`SELECT LOWER('aA'), LOWER(CONVERT('aA' USING latin1));`

binary 可将 string 转换为二进制 string。BINARY str 其实是 CAST(str AS BINARY) 的缩写。
所以，对于CHAR、VARCHAR和TEXT类型，BINARY属性可以为列分配该列字符集的 校对规则。即
**如默认不区分大小写，可添加binary，强制进行按字节进行比较,以区分大小写。** `如建表时未添加binary属性，可能影响索引失效`
这是我们通常在暂无能为力更改现有结构下的常规做法。
```
select * from some_table where binary str='abc';
```
我们可在建表建字段时，可在区分大小写的字段上添加binary属性。


对于二进制字符串，所有字符在比较中都很重要，包括尾随空格。
```
SET NAMES binary;
SELECT 'a ' = 'a';
+------------+
| 'a ' = 'a' |
+------------+
|          0 |
+------------+
```

因为binary会按字节，区分大小写，结尾使用`\0`填充到全部位数。
搜索时也是使用全部匹配，填充`\0`到位

```
CREATE TABLE t1 (
         a CHAR(10) CHARACTER SET utf8 COLLATE utf8_bin,
         b BINARY(10)
       );
INSERT INTO t1 VALUES ('a','a');
SELECT HEX(a), HEX(b),b = 'a',b = 'a\0\0\0\0\0\0\0\0\0' FROM t1;
+--------+----------------------+---------+---------------------------+
| HEX(a) | HEX(b)               | b = 'a' | b = 'a\0\0\0\0\0\0\0\0\0' |
+--------+----------------------+---------+---------------------------+
| 61     | 61000000000000000000 |       0 |                         1 |
+--------+----------------------+---------+---------------------------+
```

b 已不等于'a'
所以，有时候, 如果将索引列转换为 BINARY, MySQL可能不会使用索引。

varbinary保存变长的字符串，后面不会补\0

## 查看服务器正使用的连接的字符集和排序规则

```
SHOW VARIABLES LIKE 'character_set%';
SHOW VARIABLES LIKE 'collation%';
```

### MySQL字符集系统变量名简述


| 系统变量名                                     | 简述                           |
| :-----------------------------------------     | :------------------------------|
| character_set_system                           | 元数据Metadata使用，即USER(), CURRENT_USER(), SESSION_USER(), SYSTEM_USER(), DATABASE(), and VERSION() 等functions     |
| character_set_server、collation_server         | 服务器对应的内部操作使用       |
| character_set_database、collation_database     | 当前选中数据库的默认           |
| character_set_client                           | 客户端来源数据                 |
| character_set_connection、collation_connection | 服务器在接收时                 |
| character_set_results                          | 服务器查询结果集返回到客户端   |


另外，<a href="#查询字符串时，显示指定字符集">查询时指定字符集</a>

## SET NAMES utf8mb4 实际等同于

```
SET NAMES utf8mb4;
```

等同于
```
SET character_set_client = utf8mb4;
SET character_set_results = utf8mb4;
SET character_set_connection = utf8mb4;
```

### MySQL中的字符集转换过程

 1. MySQL Server收到请求时将请求数据从character_set_client转换为character_set_connection；

 2. 进行内部操作前将请求数据从character_set_connection转换为内部操作字符集，其确定方法如下：

  *  使用每个数据字段的CHARACTER SET设定值；

  *  若上述值不存在，则使用对应数据表的DEFAULT CHARACTER SET设定值(MySQL扩展，非SQL标准)；

  *  若上述值不存在，则使用对应数据库的DEFAULT CHARACTER SET设定值；

  *  若上述值不存在，则使用character_set_server设定值。

 3. 将操作结果从内部操作字符集转换为character_set_results。


## 查看指定数据库db_name的字符集和排序规则


```
SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'db_name';

```

或

```
USE db_name;
SELECT @@character_set_database, @@collation_database;
```

## 查询字符串时，显示指定字符集

语法：
```
[_charset_name]'string' [COLLATE collation_name]

```
示例：
```
SELECT _utf8'abc' COLLATE utf8_danish_ci;
```

## 创建和修改库、表、列的字符集和排序规则

### 创建和修改数据库db_name时，都可指定

```
CREATE DATABASE db_name
    [[DEFAULT] CHARACTER SET charset_name]
    [[DEFAULT] COLLATE collation_name]

ALTER DATABASE db_name
    [[DEFAULT] CHARACTER SET charset_name]
    [[DEFAULT] COLLATE collation_name]
```

### 创建和修改指定表tbl_name的字符集和排序规则


```
CREATE TABLE tbl_name (column_list)
    [[DEFAULT] CHARACTER SET charset_name]
    [COLLATE collation_name]]

ALTER TABLE tbl_name
    [[DEFAULT] CHARACTER SET charset_name]
    [COLLATE collation_name]

```

### 创建和修改表指定列col_name的字符集和排序规则

```
col_name {CHAR | VARCHAR | TEXT} (col_length)
    [CHARACTER SET charset_name]
    [COLLATE collation_name]
```

also be used for ENUM and SET columns:

```
col_name {ENUM | SET} (val_list)
    [CHARACTER SET charset_name]
    [COLLATE collation_name]

```

### 修改为utf8mb4示例

依次修改数据库，表，表字段
```
# 修改数据库:
ALTER DATABASE database_name CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
# 修改表:
ALTER TABLE table_name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
# 修改表字段:
ALTER TABLE table_name CHANGE column_name column_name VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

## 索引键超长

InnoDB中使用 **COMPACT** 或 **REDUNDANT** 格式的表的单个索引的最大长度为767字节，因此对于utf8mb3或utf8mb4的列，可以分别索引最多255或191个字符。
    字段定义的是能存储的字符数，比如 VARCHAR(200) 代表能够存200个汉字，索引定义是字符集类型最大长度算的，即 utf8 maxbytes=3, utf8mb4 maxbytes=4，算下来utf8和utf8mb4两种情况的索引长度分别为600 bytes和800bytes，后者超过了768，导致出错`Error 1071: Specified key was too long; max key length is 767 bytes。` 。

```
col1 VARCHAR(500) CHARACTER SET utf8, INDEX (col1(255))
col1 VARCHAR(500) CHARACTER SET utf8mb4, INDEX (col1(191))

```

 - InnoDB中 **COMPRESSED** 或 **DYNAMIC** 最多3072字节，所以分别为最多1024或768个字符utf8mb3或 utf8mb4列。但也依然不建议索引太长，太浪费空间和cpu搜索资源。

如果已有定义超过这个长度的，可加上前缀索引，如果暂不能加上前缀索引（像唯一索引），可把该字段的字符集改回utf8或latin1。
但是，（ **敲黑板啦，很重要** ），要防止出现 `Illegal mix of collations (utf8_general_ci,IMPLICIT) and (utf8mb4_general_ci,COERCIBLE) for operation '=' ` 错误：连接字符集使用utf8mb4，但 SELECT/UPDATE where条件有utf8类型的列，且条件右边存在不属于utf8字符，就会触发该异常。表示踩过这个坑。

再多加一个友好提示：EXPLAIN 结果里面的 key_len 指的搜索索引长度，单位是bytes，而且是以字符集支持的单字符最大字节数算的，这也是为什么 INDEX_LENGTH 膨胀厉害的一个原因。

## InnoDB默认表的行格式

在MySQL 5.0.3之前，**REDUNDANT** 是InnoDB唯一可用的行格式。
从MySQL 5.0.3到MySQL 5.7.8的默认行格式，为 **compact**  数据格式。
从MySQL 5.7.9开始，默认行格式由 **innodb_default_row_format** 配置选项定义， 默认设置为 **DYNAMIC** 。

更改系统表空间默认行格式DYNAMIC， COMPACT，和REDUNDANT。
```
SET GLOBAL innodb_default_row_format=DYNAMIC;
```

COMPRESSED 只能在CREATE TABLE或 ALTER TABLE时明确指定。
```
CREATE TABLE t2 (c1 INT) ROW_FORMAT=COMPRESSED;
ALTER TABLE t1 ADD COLUMN (c2 INT);
```

如未指定`ROW_FORMAT`将使用`innodb_default_row_format`，也就是实际上会补充为`ROW_FORMAT=DEFAULT`。

使用`INFORMATION_SCHEMA.INNODB_TABLES`查询表信息。
```使用INFORMATION_SCHEMA.INNODB_TABLES查询表信息
SELECT * FROM INFORMATION_SCHEMA.INNODB_TABLES WHERE NAME LIKE 'test/t1' \G
*************************** 1. row ***************************
     TABLE_ID: 54
         NAME: test/t1
         FLAG: 33
       N_COLS: 4
        SPACE: 35
   ROW_FORMAT: Dynamic
ZIP_PAGE_SIZE: 0
   SPACE_TYPE: Single
```

### 查看表的行格式

tbl_name 表名
```
SHOW TABLE STATUS WHERE name LIKE 'tbl_name%';
#或
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'tbl_name%';
```

## InnoDB最大表空间大小，表的最大大小

`innodb_page_size`只能在初始化MySQL实例之前进行配置。默认的16KB页面大小或更大适用于各种工作负载，特别是涉及涉及批量更新的表扫描和DML操作的查询。

| InnoDB页面大小 | 最大表空间大小 |
| -------------  | -------        |
| 4KB	         | 16TB           | 
| 8KB            | 32TB           |
| 16KB           | 64TB           |
| 32KB           | 128TB          |
| 64KB           | 256TB          |

最大表空间大小也是表的最大大小。


MySQL客户端程序理论上连接时，默认使用`utf8mb4`。也可以直接使用`--default-character-set`指定。


参考链接:
[全面了解mysql中utf8和utf8mb4的区别](https://my.oschina.net/xsh1208/blog/1052781)
[mysql使用utf8mb4经验吐血总结](http://seanlook.com/2016/10/23/mysql-utf8mb4/)


