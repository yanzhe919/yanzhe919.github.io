title: 更换个国内Hexo主题
date: 2015-02-10 17:00:04
tags: Hexo 
categories: Hexo 
description: 本来在自带主题上修改，后来想想，还是找个其他主题看看吧。然后找到了coney，专为国内修改。已添加了百度分享，百度搜索，百度分析，回到页首等等。
---

# 更换了Hexo主题为coney

------

本来在自带主题上修改，后来想想，还是找个其他主题看看吧。然后找到了coney，专为国内修改。已添加了百度分享，百度搜索，百度分析，回到页首等等。
这样我在改改就可以直接用了。
<!-- more -->
然后，让我来试试Hexo的分类和标签功能先。

2015-12-01 update
添加简繁体切换，[原文摸这里](http://www.arao.me/2015/hexo-support-jian-fan-language/#more)


具体实现：
- 首先，[点击这里](/js/tw_cn.js)右键另存下载简繁字体切换所需的<code>tw_cn.js</code>文件，上传到自己的网站空间。
- 其次，修改模板，在你想要显示简繁转换按钮的地方加上下面一段代码，正常情况添加到<code>footer.ejs</code>或者<code>sidebar.ejs</code>就可以了。
```html
<a id="translateLink" href="javascript:translatePage();">繁体</a>
```
- 最后，在<code>footer.ejs</code>添加下面代码，记得更改<code>cookieDomain</code>这一项。
```javascript
<script type="text/javascript" src="http://blog.yanzhe.tk/js/tw_cn.js"></script>
    <script type="text/javascript">
    var defaultEncoding = 2; //网站编写字体是否繁体，1-繁体，2-简体
    var translateDelay = 0; //延迟时间,若不在前, 要设定延迟翻译时间, 如100表示100ms,默认为0
    var cookieDomain = "http://blog.yanzhe.tk/"; //Cookie地址, 一定要设定, 通常为你的网址
    var msgToTraditionalChinese = "繁体"; //此处可以更改为你想要显示的文字
    var msgToSimplifiedChinese = "简体"; //同上，但两处均不建议更改
    var translateButtonId = "translateLink"; //默认互换id
    translateInitilization();
    </script>
```

这就基本完成了简体繁体切换功能,不管你是hexo，jelly，Octopress等静态博客，还是wordpress，typecho，emlog，Z-Blog等动态的，都可以用上。具体的演示效果可以点击我博客底部简体中文切换字体,至于简体繁体切换按钮嘛，文字和样式可以按个人喜好自行更改。
