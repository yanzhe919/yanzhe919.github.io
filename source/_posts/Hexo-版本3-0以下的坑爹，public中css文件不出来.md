title: Hexo 版本3.0以下的坑爹，public中css文件不出来
date: 2015-02-06 22:52:08
tags: Hexo
categories: Hexo 
description: Hexo版本使用的当下最新的2.8.3（因为才开始接触Hexo。菜鸟没办法啊），生成的页面版面一直都是乱的。
---
无比的坑爹啊!
===================


Hexo版本使用的当下最新的2.8.3（因为才开始接触Hexo。菜鸟没办法啊），生成的页面版面一直都是乱的。以为是还有没加载上的。- -!直接在主题里面乱找。然后才想想，会不会有人跟我一样悲催。还真有[这位兄弟](http://gsgundam.com/2015-01-29-hexo-css-missing/)。然后找到[官方解释](https://github.com/hexojs/hexo/issues/995)，
**hexo-renderer-stylus is rewritten for Hexo 3.0**.
所以3.0以前的版本要使用旧版本
``` bash
$ npm install hexo-renderer-stylus@0.1 --save
```

搭建，自定义评论框，图床，网站加速，监控，统计功能(有如[不蒜子](http://service.ibruce.info/)等)
[hexo你的博客](http://ibruce.info/2013/11/22/hexo-your-blog/)


UPDATE : 2018-06-23 好久没管过hexo，今天升级hexo 后，遇坑无数
### 当hexo g 报错 Error: expected end of comment, got end of file

<code>grep {&#35; *.md -rn </code>
找找md 文件中应该是含有 {&#35; ，需要修改为{% raw %}'{&#35;'{% endraw %} ，或是使用三个<code>`</code> 符号包含起来

### 当hexo g 报错 mozjpeg/vendor/cjpeg ENOENT 等


缺少包安装啥
```shell
sudo apt install autoconf libtool nasm wget automake gcc
或
yum install wget autoconf automake gcc nasm libtool

```

然后，执行rebuild 
```shell
npm rebuild mozjpeg  
npm rebuild gifsicle  
npm rebuild optipng-bin
npm rebuild jpegtran-bin
```
当然也是可以使用 cnpm


### 使用Gitment 替代多说

使用 GitHub Issues 搭建评论系统[gitment](https://imsun.net/posts/gitment-introduction/)









