title: Linux下统计当前文件夹下的文件个数、目录个数
date: 2015-11-27 17:27:07
tags: Linux
categories: Linux
description: 使用ls命令配合管理、grep命令实现统计需求。rsync快速删除大量文件夹`rsync -a --delete empty_dir/    yourdirectory/`
---

[这篇文章](http://www.jb51.net/article/56474.htm)主要介绍了Linux下统计当前文件夹下的文件个数、目录个数,本文使用ls命令配合管理、grep命令实现统计需求.


1) 统计当前文件夹下文件的个数
```shell
ls -l |grep "^-"|wc -l
```

2) 统计当前文件夹下目录的个数
```shell
ls -l |grep "^d"|wc -l
```
 
3) 统计当前文件夹下文件的个数，包括子文件夹里的
```shell
ls -lR|grep "^-"|wc -l
```
 
4) 统计文件夹下目录的个数，包括子文件夹里的
```shell
ls -lR|grep "^d"|wc -l
```
 
说明：
```shell
ls -l
```
长列表输出当前文件夹下文件信息(注意这里的文件，不同于一般的文件，可能是目录、链接、设备文件等)
```shell
grep "^-"
```
这里将长列表输出信息过滤一部分，只保留一般文件，如果只保留目录就是 ^d
```shell
wc -l
```
统计输出信息的行数，因为已经过滤得只剩一般文件了，所以统计结果就是一般文件信息的行数，又由于一行信息对应一个文件，所以也就是文件的个数。


## linux 快速删除大量文件夹/大文件

假如你要在linux下删除大量文件，比如100万、1000万，那么rm -rf *可能就不好使了. rsync 可以用来清空目录或文件

```shell
mkdir empty_dir
rsync -a --delete empty_dir/    yourdirectory/
rm -r empty_dir/ yourdirectory/
```

```
rsync --delete-before -a -H -v --progress --stats /tmp/test/ log/

```
选项说明：
–delete-before 接收者在传输之前进行删除操作
–progress 在传输时显示传输过程
-a 归档模式，表示以递归方式传输文件，并保持所有文件属性
-H 保持硬连接的文件
-v 详细输出模式
–stats 给出某些文件的传输状态

### 为什么rsync能够快速删除大文件

#### rm 会重建

rm命令大量调用了lstat64和unlink，可以推测删除每个文件前都从文件系统中做过一次lstat操作。过程：正式删除工作的第一阶段，需要通过getdirentries64调用，分批读取目录（每次大约为4K），在内存中建立rm的文件列表；第二阶段，lstat64确定所有文件的状态；第三阶段，通过unlink执行实际删除。这三个阶段都有比较多的系统调用和文件系统操作。

#### rsync所做的系统调用很少

rsync所做的系统调用很少：没有针对单个文件做lstat和unlink操作。命令执行前期，rsync开启了一片共享内存，通过mmap方式加载目录信息。只做目录同步，不需要针对单个文件做unlink。


#### rm的上下文切换比较多

另外，在其他人的评测里，rm的上下文切换比较多，会造成System CPU占用较多——对于文件系统的操作，简单增加并发数并不总能提升操作速度。


#### 频繁做减法不如直接从头来过
把文件系统的目录与书籍的目录做类比，rm删除内容时，将目录的每一个条目逐个删除(unlink)，需要循环重复操作很多次；rsync删除内容时，建立好新的空目录，替换掉老目录，基本没开销。

