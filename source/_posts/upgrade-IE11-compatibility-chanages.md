title: 一些升级IE11后的兼容性更改
date: 2015-06-16 15:47:30
tags: IE11
categories: 
description: 在IE11中，user-agent比之前要短很多，而且去掉了最关键的MSIE的关键字.在IE11中使用document.all的方法将可能导致执行失败。

---

## User-agent 字符串更改

这是首次微软真正更改了user-agent字符串，这使得很多判断浏览器是否IE的代码无法工作，包括有些JavaScript的isIE()的方法在Internet Explorer 11上执行会返回false。
不过好在Internet Explorer 11对Web标准的支持非常好，因此不再需要之前那些IE特定的行为。

在Internet Explorer 11中，user-agent比之前的版本要短很多，而且去掉了最关键的MSIE的关键字：

Internet Explorer 10 的 user-agent（on Win 7）：


```javascript
Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)
```


Internet Explorer 11 的 user-agent（on Win 7）：


```javascript
Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv 11.0) like Gecko
```



Internet Explorer 11 的 user-agent（on Win 8）：


```javascript
Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv 11.0) like Gecko
```


* 兼容 ("兼容") 和浏览器 ("MSIE") 令牌已删除。
* "like Gecko" 令牌已添加（以便与其他浏览器一致）。
* 浏览器版本现在由新版本 ("rv") 令牌报告。



上述user-agent中增加了Gecko的标识，而Safari是首个标注了Gecko的浏览器。

IE11提倡应避免检测特定浏览器或版本，应检测需要使用的功能并使用渐进增强为不支持所需功能的浏览器或设备提供简化体验。
之前多数使用MSIE来判断是否IE浏览器的代码都无法工作，在极少数情况下，必须唯一地标识 IE11时，可以改用[Trident令牌字符串](https://msdn.microsoft.com/zh-cn/library/ms537503(v=vs.85).aspx)来判断。Trident标识是在IE9中引入的。

## 文档模式更改

从 IE11 开始，边缘模式成为首选文档模式；它代表可供浏览器使用的现行标准的最高支持。
使用 HTML5 文档类型声明启用边缘模式：

```html
<!doctype html>
```

Internet Explorer 8 中引入了边缘模式并且每个后续版本中也提供了该模式。 注意，边缘模式支持的功能会限制为呈现内容的特定浏览器版本支持的功能。
从 IE11 开始，文档模式被弃用，除了临时情况外不应再使用。 请确保更新依赖于传统功能和文档模式的站点，以便反映现行标准。
如果必须针对特定文档模式，以便在重新运行站点来支持现行标准和功能时站点能够工作，则请注意，你使用的是过渡功能，以后的版本中可能不提供该功能。
如果你当前针对传统文档模式使用 x-ua-compatible 标头，则你的站点可能无法反映适用于 IE11 的最佳体验。 有关详细信息，请参阅 modern.ie。

## 传统 API 添加、更改和删除

许多网站查找支持传统 (HTML4) 功能的浏览器，目的是提供针对早期浏览器优化的体验。 对于支持传统功能和现行标准（如 HTML5、CSS3 等）的浏览器，这是一个问题。 如果站点在搜索现行标准支持之前检测到传统功能，则可以为支持现行标准的浏览器提供传统体验和更丰富的体验。
因此，IE11 添加、更改、删除了许多默认的传统功能：


 - navigator.appName 属性现在会返回 "Netscape" 以反映 HTML5 标准和匹配其他浏览器的行为。
 - navigator.product 属性现在会返回 "Gecko" 以便反映 HTML5 标准和匹配其他浏览器的行为。
 - XDomainRequest 对象被 XMLHttpRequest 的 ORS 替换。
 - 已添加对 __proto__ 的支持。
 - 已添加 dataset 属性。


另外，为了支持现行标准指定的功能，已删除若干传统 API 功能：

| 删除 API 功能                               | 替代功能                                           |
| --------                                    | --------                                           |
| attachEvent                                 | addEventListener                                   |
| window.execScript                           | eval                                               |
| window.doScroll                          	  | window.scrollLeft、window.scrollTop                |
| document.all                                | document.getElementById                            |
| document.fileSize、img.fileSize             | 使用 XMLHttpRequest 可提取源                       |
| script.onreadystatechange和script.readyState| script.onload                                      |
| document.selection                          | window.getSelection                                |
| document.createStyleSheet                   | document.createElement("style")                    |
| style.styleSheet                            | style.sheet                                        |
| window.createPopup                          | 使用 div 或 iframe（zIndex 值很高）                |
| 二进制行为                                  | 变化:使用基于标准的等效,如 canvas、SVG 或 CSS3 动画|
| 传统数据绑定                                | 使用框架提供的数据绑定，如 WinJS                   |


从IE 4开始，document.all在IE中举足轻重。比起document.getElementById()来说，document.all是IE方式的获取元素的引用的方法。尽管IE 5增加对DOM的支持，但document.all一直沿用至IE 10。
而在Internet Explorer 11中document.all并没有真正被删除，尽管使用了document.all的代码实际上还是可以工作,但不推荐使用。

另外一个要废弃的是attachEvent()方法，该方法用于添加事件处理器，对应的detachEvent()用来移除事件处理器。这两个方法将在Internet Explorer 11中删除。移除这两个方法需要改用如下逻辑：

```javascript
function addEvent(element, type, handler){
	if(element.attachEvent){
		element.attachEvent('on' + type, handler);
	}else if(element.addEventListener){
		element.addEventListener(type, handler, false);
	}
}
```

当然，建议你优先使用标准的浏览器进行测试以确保不会因为attachEvent()的移除而影响代码执行。不过互联网上充斥着各种糟糕的监测代码，你只能确保自己的应用经过良好的标准测试。

被删除的特性还包括：

```javascript
window.execScript()	// IE版本的eval()
window.doScroll()		// IE用来滚动窗口的方式
script.onreadystatechange()	// IE脚本加载完成的时间通知方式
script.readyState()	// IE的脚本脚本加载状态
document.selection()	// IE获取当前选择文本的方式
document.createStyleSheetyleSheet()	// IE创建样式表的方式
style.styleSheet()	// IE引用样式的方式
```

所有这些被废弃的方法都有基于标准的替代方法。如果你使用的是标准的方法那恭喜你，可直接支持Internet Explorer 11.

## URL 字符编码
IE11 更改了 URL 的字符编码。 具体来说，现在使用 UTF-8 字符编码对查询字符串和 XHR 请求进行编码。

此更改会影响所有 URL，但以下除外：

- 定位名称组件（也称为“片断”）。
- 用户名和密码组件。
- file:// or ftp:// protocol links。

这些更改与其他浏览器行为匹配并简化了跨浏览器 XHR 代码。

## 自定义数据属性
IE11 添加了对 HTML5 自定义数据属性和 dataset 属性的支持，可以提供对它们的编程访问权限。你可以使用 data- 前缀后跟属性名称的方式来向元素分配数据属性：

```html
<div data-example-data="Some data here"></div>
```

要获取或设置数据属性的值，请使用此语法：

```javascript

   // to get
   var myData = element.dataset.exampleData;
   // to set
   element.dataset.exampleData = "something new";
```

## SVG“pointer-events”属性的 HTML 支持
从 IE11 开始，也支持 pointer-events 作为 HTML 元素上的 CSS 属性，其效果如下：

| 值        			| 描述                                             |
| --------             	| --------                                         |
| 无             		| 该元素不会触发指针输入事件（无法进行点击测试）。 |	
| 其他有效的指针事件值  | 该元素会触发指针输入事件。                       |	


默认情况下将继承 pointer-events 属性，所以会影响应用该属性的元素的所有后代。

## 更新反映对基于标准的规范的更改

IE11 还包括用于支持基于标准的 Web 规范（已更新或仍在发展）的更新。
 这其中包括与支持下列功能相关的更改：

弹性框（“Flexbox”）布局更新
使用 IE11，你可以更新站点来与最新的弹性框标准保持一致并简化跨浏览器的代码。

突变观察者
突变观察者是 IE11 中新的标准 Web平台功能，提供了对突变事件支持的所有相同方案的快速执行直接替代，以及对属性更改事件支持的方案的替代。

### 指针事件
为了符合万维网联合会 (W3C) 指针事件规范的候选推荐，与 Internet Explorer 10 相比，IE11 实现已略有更改。

## 判断浏览器，方法不全

### 判断IE兼容到IE9


```javascript
var _IE = (function(){
    var v = 3, div = document.createElement('div'), all = div.getElementsByTagName('i');
    while (
        div.innerHTML = '<!--[if gt IE ' + (++v) + ']><i></i><![endif]-->',
        all[0]
    );
    return v > 4 ? v : false ;
}());
```


### 判断其他浏览器

```javascript
//检测函数
var check = function(r) {
    return r.test(navigator.userAgent.toLowerCase());
};
var statics = {
    /**
    * 是否为webkit内核的浏览器
    */
    isWebkit : function() {
        return check(/webkit/);
    },
    /**
    * 是否为火狐浏览器
    */
    isFirefox : function() {
        return check(/firefox/);
    },
    /**
    * 是否为谷歌浏览器
    */
    isChrome : function() {
        return !statics.isOpera() && check(/chrome/);
    },
    /**
    * 是否为Opera浏览器
    */
    isOpera : function() {
        return check(/opr/);
    },
    /**
    * 检测是否为Safari浏览器
    */
    isSafari : function() {
    // google chrome浏览器中也包含了safari
        return !statics.isChrome() && !statics.isOpera() && check(/safari/)
    }
};
```