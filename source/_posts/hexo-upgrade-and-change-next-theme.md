---
title: hexo升级和切换主题到Next
date: 2018-06-24 14:45:04
tags: Hexo
categories: Hexo 
description: 
---

好久没管过hexo，今天升级hexo，切换为next主题 后，遇坑无数，记录一下。

<!-- more -->

之前一直使用的`hexo 2.8.3`，后来有台机器升级了node，这台机器上再使用hexo就有点问题。索性就都升级了。当前使用`hexo 3.7.1` 

遇坑如下：

### 当hexo g 报错 Error: expected end of comment, got end of file

找找md 文件中应该是含有 {% raw %}{&#35;{% endraw %} ，需要使用raw包含起来为<code>{% raw %}{&#35;{% endraw %}</code>，或是使用三个<code>\`</code> 符号包含起来

```
grep {# *.md -rn
# 即 {#需要改为 {% raw %}{#{% endraw %} {{ '{#' }}
```

### 当hexo g 报错 mozjpeg/vendor/cjpeg ENOENT 等


缺少包安装啥
```shell
sudo apt install autoconf libtool nasm wget automake gcc
#或
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

[hexo问题解答](https://hexo.io/zh-cn/docs/troubleshooting.html)


### 使用Gitment 替代多说

使用 GitHub Issues 搭建评论系统<span class="inline-yellow">[Gitment](https://imsun.net/posts/gitment-introduction/)</span>

在next中只需要注册，并填写参数就行了
注册一个[OAuth](https://github.com/settings/applications/new) 

将client_id 和 client_secret记下，新开一个专门存储评论的仓库，填入github_repo，填入对应自己github_user


### 使用next有点小问题

下载时没注意，直接git clone了next，也就是最新版。有点小问题，侧边栏失效。
比较v5.1.2 ，修改了`next/layout/_partials/header.swig` 为如下


```html
{% for name, path in theme.menu %}
        {% set itemName = name.toLowerCase() %}
        <li class="menu-item menu-item-{{ itemName | replace(' ', '-') }}">
          <a href="{{ url_for(name.split('||')[0]) | trim }}" rel="section">
            {% if theme.menu_icons.enable %}
              <i class="menu-item-icon fa fa-fw fa-{{ path.split('||')[1] | trim | default('question-circle') }}"></i> <br />
            {% endif %}
            {{ __('menu.' + name) | replace('menu.', '') }}
          </a>
        </li>
	
      {% endfor %}	
```

(实际上只是将原有`url_for(path.split('||')[0])` 改为了`url_for(name.split('||')[0]) `)

### 推翻上述说法，使用theme-next/hexo-theme-next中的新版

记录到一半发现next 最新版迁移了。先切换到最新版再看看

next 5.x 到 6.x 变化蛮大

从<span class="inline-yellow">[iissnan/hexo-theme-next](https://github.com/iissnan/hexo-theme-next)</span> 到了<span class="inline-yellow">[theme-next/hexo-theme-next](https://github.com/theme-next/hexo-theme-next)</span> 

## 记录以下升级步骤

关于升级第一点，没事别手贱升级！！！

### nvm 升级 nodejs

```
# git and source nvm
git clone https://github.com/creationix/nvm ~/.nvm
source ~/.nvm/nvm.sh

# install latest nodejs version, and
# set default node version to be used in new shell
nvm install node
nvm use node
nvm alias default node

# automatically source nvm on login
echo '[ -e ~/.nvm/nvm.sh ] && source ~/.nvm/nvm.sh' >> ~/.bashrc
```

### 如没安装cnpm

用的淘宝家的镜像
```
npm install cnpm -g --registry=https://registry.npm.taobao.org
```

### 升级hexo

简单粗暴全局升级hexo-cli

```
cnpm i hexo-cli -g

```

### cnpm outdated检查hexo 需要更新的组件

使用 <code>cnpm outdated</code> 查看哪些组件需要更新版本

```
cnpm outdated
Package                          Current  Wanted  Latest  Location
babel-runtime                     linked  6.26.0  6.26.0  hexo-site
eslint-config-theme-next          linked   1.1.3   1.1.3  hexo-site
hexo                              linked   4.0.0   4.0.0  hexo-site
hexo-addlink                      linked   1.0.4   1.0.4  hexo-site
hexo-all-minifier                 linked   0.5.3   0.5.3  hexo-site
hexo-autonofollow                 linked   1.0.1   1.0.1  hexo-site
hexo-deployer-git                 linked   2.1.0   2.1.0  hexo-site
hexo-filter-optimize              linked   0.2.7   0.2.7  hexo-site
hexo-generator-baidu-sitemap      linked   0.1.6   0.1.6  hexo-site
hexo-generator-feed               linked   2.2.0   2.2.0  hexo-site
hexo-generator-search             linked   2.4.0   2.4.0  hexo-site
hexo-generator-searchdb           linked   1.2.0   1.2.0  hexo-site
hexo-generator-sitemap            linked   2.0.0   2.0.0  hexo-site
hexo-leancloud-counter-security   linked   1.4.1   1.4.1  hexo-site
hexo-next-title                   linked     git     git  hexo-site
hexo-pdf                          linked   1.1.1   1.1.1  hexo-site
hexo-symbols-count-time           linked   0.7.0   0.7.0  hexo-site
hexo-tag-cloud                    linked   2.1.1   2.1.1  hexo-site
```

手工修改 `package.json` 文件中的版本号

### cnpm install --save 更新组件

```
cnpm install --save
```

### 拷贝 next 自定义的swig等

新版 next 新增支持了不少组件，可以将之前自定义的一些移除，使用新增组件。
next 支持自定义的方式发生了改变，将自定义的 swig 可以拷贝到 `source/_data/` 文件夹下，修改`custom_file_path` 对应配置

```
custom_file_path:
  head: source/_data/head.swig
  header: source/_data/header.swig
  sidebar: source/_data/sidebar.swig

```


