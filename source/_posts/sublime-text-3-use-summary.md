title: sublime text 3 使用总结
date: 2015-12-10 23:32:22
tags: Editor
categories:
description: sublime text 3使用总结
---

电脑从win10 32位换成64位，备份了蛮多软件配置。sublime text 2的配置居然忘记备份了，干脆直接换成sublime text 3[exe](http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%20Build%203083%20x64%20Setup.exe)，[zip](http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%20Build%203083%20x64.zip)，[官网](http://www.sublimetext.com/3)好了。

最少sublime text 3 中的配置文件，Package安装文件，都将在主目录下Data文件夹下，而sublime text 2，则会在用户目录下，如`AppData > Roaming > sublime text`。

## 安装Package Control

### 简单安装

最简单的方法，使用<code>Ctrl + \`</code>快捷键，或是`View > Show Console`菜单项，打开控制台，然后将`Python`代码复制粘贴进控制台。
sublime text 3
`import urllib.request,os,hashlib; h = '2915d1851351e5ee549c20394736b442' + '8bc59f460fa1548d1514676163dafc88'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by) `

顺便记录下sublime text 2
`import urllib2,os,hashlib; h = '2915d1851351e5ee549c20394736b442' + '8bc59f460fa1548d1514676163dafc88'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); os.makedirs( ipp ) if not os.path.exists(ipp) else None; urllib2.install_opener( urllib2.build_opener( urllib2.ProxyHandler()) ); by = urllib2.urlopen( 'http://packagecontrol.io/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); open( os.path.join( ipp, pf), 'wb' ).write(by) if dh == h else None; print('Error validating download (got %s instead of %s), please try manual install' % (dh, h) if dh != h else 'Please restart Sublime Text to finish installation') `

### 手动安装

如果控制台安装时，出现连接问题，修改`hosts`，添加`50.116.34.243 sublime.wbond.net`也没用的话，可以使用手动安装方法。

1. 点击 `Preferences > Browse Packages…` 菜单项。
2. 将浏览打开一个文件夹，进入上一级目录，然后进入`Installed Packages/`文件夹。
3. 下载[Package Control.sublime-package](https://packagecontrol.io/Package%20Control.sublime-package)，并copy到`Installed Packages/`文件夹。
4. 重启Sublime Text

[安装方法原文](https://packagecontrol.io/installation)

## 添加到右键菜单

如果使用的zip版，可以手动添加右键菜单，以便快速打开sublime text 3。

1. `cmd`命令中运行：`regedit`，打开注册表。
2. 依次找到`HKEY_CLASSESS_ROOT->*->Shell`，下面新建项，命名为`Edit with Sublime Text3`。
3. 在项`Edit with Sublime Text`下新建字符串值，命名为`Icon`，值为`D:\Program Files\Sublime Text 3\sublime_text.exe`,0,其中灰色地址为 Sublime Text程序文件地址。
4. 在项`Edit with Sublime Text`下新建项`Command`，该`Command`项下默认值修改为`D:\Program Files\Sublime Text 3\sublime_text.exe,1`。
5. 设置完成后，无需重启电脑，就可以在右键菜单中，显示`Edit with Sublime Text3`。

## 同步配置

### 使用Git

使用Git时，最好是将下列文件/文件夹添加到`.gitignore`文件中。

    Package Control.last-run
    Package Control.ca-list
    Package Control.ca-bundle
    Package Control.system-ca-bundle
    Package Control.cache/
    Package Control.ca-certs/


### 使用Dropbox

国内爬窗使用Dropbox。

#### Windows

如果你的Dropbox文件夹不在默认位置，您需要更改`$ ENV：USERPROFILE \ Dropbox`的到你的位置。
首先，关闭sublime text，并用管理员身份打开控制台。

在待备份机器上，使用下面的命令。
sublime text 3
```Bash
cd "$env:appdata\Sublime Text 3\Packages\"
mkdir $env:userprofile\Dropbox\Sublime
mv User $env:userprofile\Dropbox\Sublime\
cmd /c mklink /D User $env:userprofile\Dropbox\Sublime\User
```
在还原备份机器上，使用下面的命令。下面的命令将移除用户/文件夹及下所有内容。

```Bash
cd "$env:appdata\Sublime Text 3\Packages\"
rmdir -recurse User
cmd /c mklink /D User $env:userprofile\Dropbox\Sublime\User
```

#### OS X
如果你的Dropbox文件夹不在默认位置，您需要更改`~/Dropbox`的到你的位置。
首先，关闭sublime text，并打开控制台。
在待备份机器上，使用下面的命令。
```Bash
cd ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/
mkdir ~/Dropbox/Sublime
mv User ~/Dropbox/Sublime/
ln -s ~/Dropbox/Sublime/User
```

在还原备份机器上，使用下面的命令。下面的命令将移除用户/文件夹及下所有内容。
```Bash
cd ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/
rm -r User
ln -s ~/Dropbox/Sublime/User
```

#### Linux

如果你的Dropbox文件夹不在默认位置，您需要更改`~/Dropbox`的到你的位置。
首先，关闭sublime text，并打开控制台。
在待备份机器上，使用下面的命令。
```Bash
cd ~/.config/sublime-text-3/Packages/
mkdir ~/Dropbox/Sublime
mv User ~/Dropbox/Sublime/
ln -s ~/Dropbox/Sublime/User
```

在还原备份机器上，使用下面的命令。下面的命令将移除用户/文件夹及下所有内容。
```Bash
cd ~/.config/sublime-text-3/Packages/
rm -r User
ln -s ~/Dropbox/Sublime/User
```

[同步配置原文](https://packagecontrol.io/docs/syncing)

##使用技巧


单个多选变量名：Cmd-D (Win: Ctrl-D) 按一下只会只选择下一个
    跳过多选变量名：Cmd-K, Cmd-D (Win: Ctrl-K, Ctrl-D)
全选变量名：按Ctrl-Cmd-G (Win: Alt-F3)

自适应缩进的粘贴：按Cmd-Shift-v (Win: Ctrl-Shift-v) 
新建文件：Cmd-n (Win: Ctrl-n)
选择当前的最小区域：Cmd-Shift-Space (Win: Ctrl-Shift-Space)
查找打开过的文件：Ctrl+P，然后输入最近的文件名就可以即时预览到文件内容
命令输入框：Ctrl+Shift+P
查找：Ctrl + F 
查找并替换：Ctrl + Shift + F
鼠标中键，也就是鼠标滚轮！鼠标滚轮也可以选中字符，但不同用鼠标左键选择的是，他不会跨行选择，而是直接矩形选择。
Emmet使用：Tab键，如html:5,Tab键


[Sublime Text 有哪些使用技巧？](http://www.zhihu.com/question/24896283) 
[Sublime Text 有哪些实用技巧？](http://www.zhihu.com/question/19976788) 
