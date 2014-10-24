---
layout: post
title:  "打造你的OSX开发环境"
author: 詹子知(James Zhan)
date:   2014-10-01 18:00:00
meta:   版权所有，转载须声明出处
category: system
tags: [osx, javascript, ruby, php, java]
---

## 以下App Store上的软件，你值得拥有。
* **Pages**, **Numbers**, **Keynote** OS X三件套。
* **Alfred** 和Spotlight类似，可以快速启动应用程序和打开文件，但是比Spotlight体验好很多。
* **OmniGraffle** 比较实用的画图工具，和Viso类似，但是定制和扩展性更强。
* **Evernote** 印象笔记，一款非常好用的笔记工具，如果想使用Markdown来写笔记，可以结合一些第三方插件来使用。
* **The Unarchiver** OS X下的解压神器。
* **Skitch** OS X下的截屏神器，操作简单。


## 第三方软件
* [**Adobe Photoshop CS6**](http://www.adobe.com/cn/products/photoshop.html) 不解释，OS X下体验更佳。    
* [**Parallels Desktop**](http://www.parallels.com/cn/products/desktop/) OS X下最好用的虚拟机软件，就是价格比较坑，升级价格和全价差不多。
* [**Axure RP**](http://www.axure.com/) 比较好用的产品原型设计工具。
* [**XMind**](http://www.xmind.net/) 比较好用的一款思维导图工具。
* [**astah professional**](http://astah.net/download) 一款比较专业的UML画图工具。
* [**MySQL Workbench**](http://www.mysql.com/products/workbench/) 官方的MySQL客户端。


## 开发者必备

### 集成开发环境
如果你是Java开发者（或者同时编辑Ruby，Python，PHP，JavaScript，Scala，Groovy，Clojure等程序），强烈建议你安装[IntelliJ IDEA](http://www.jetbrains.com/idea/download/)。如果你只做前端开发，那么[WebStrom](http://www.jetbrains.com/webstorm/)是不错的选择，另外，[RubyMime](http://www.jetbrains.com/ruby/)，[PyCharm](http://www.jetbrains.com/pycharm/)，[PhpStorm](http://www.jetbrains.com/phpstorm/)作为Ruby，Python，PHP的单项开发环境也不错。

如果你不想花钱，又不想实用盗版软件，那么[Eclipse](http://www.eclipse.org/downloads/)，[NetBeans](https://netbeans.org/)也可以凑合着用。

### 编辑器
如果你习惯使用命令行，配合编辑器开发程序也是一个不错的选择，除了vi和emacs之外（后面会单独介绍），以下编辑器你值得拥有。

* **TextWrangler** 一种免费的文本编辑器，功能和NodePad++类似，可以直接在App Store上下载。
* [TextMate](https://macromates.com/download)，个人用的比较顺手的一个，有各种扩展可以提高你的开发效率。
     * [源码地址](https://github.com/textmate/textmate)
     * [Solarized Theme](https://github.com/deplorableword/textmate-solarized)
* [Sublime Text](http://www.sublimetext.com/)，如果你从Linux迁移过来，Sublime一定不陌生，它确实是一个非常好用的一个编辑器。
* [LightTable](http://lighttable.com/) 一款新出世的编辑器，完全[开源](https://github.com/LightTable/LightTable)，使用Clojure语言编写，非常容易扩展和定制。

### 浏览器
* [Chrome](https://www.chromedownload.org) 速度快，调试方便，目前是我开发主要试用的浏览器。
* [Firefox](http://www.firefox.com.cn/) 有点笨重，但是作为开发调试工具还是不错的。
* **Safari**，系统自带的默认浏览器，和OSX系统集成度高，可以实现在不同的Apple设备之间同步阅读进度。
* **Opera**，App Store上提供直接下载，小巧，快速。


### 开发环境准备

#### 选择合适的Terminal
相比原生的Terminal，我更喜欢使用 [iTerm2](http://iterm2.com/)，它提供了很多现代的特性，比如主题定制，分屏，自动完成等多种功能。

#### 安装XCode
XCode可以直接从App Store上下载和更新，安装完以后，我们需要启动它一次，这个时候它会提示你去接受它的协议。 接下来，我们需要安装Command Line Tool。

~~~sh
xcode-select --install
~~~

#### 安装oh-my-zsh
[oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)是一套开源，社区驱动的用于管理zsh配置的框架，可以使用如下的方式安装。

~~~sh
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

# Optionally, backup your existing ~/.zshrc file
cp ~/.zshrc ~/.zshrc.orig

cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# Set Zsh as your default shell:
chsh -s /bin/zsh
~~~
接下来，重启你的命令行就可以发现oh-my-zsh已经配置好了。

如果你想更改zsh的配置，可以编辑~/.zshrc个性化你的配置。
比如我本地的配置为：

~~~sh
ZSH_THEME="jameszhan"
plugins=(git svn mvn brew gem go lein npm node rails ruby rvm)
~~~
    
#### 安装Homebrew
[Homebrew](http://brew.sh/)是OSX下非常好用的包管理工具，类似于Ubuntu下的apt-get，用于替换OSX下的老牌包管理工具port。

~~~sh
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
~~~

##### 通过Homebrew安装一些实用工具
~~~sh
brew update
brew install curl wget tree gnu-sed gawk rename
~~~

##### 通过Homebrew安装一些常用服务
~~~sh
brew update
brew install redis mysql postgresql mongodb sqlite nginx
~~~

#### Vim vs. Emacs
~~~sh
# Install MacVim
brew install macvim --with-cscope --with-lua --override-system-vim
# Install Emacs
brew install emacs --cocoa --srgb
~~~
1. 喜欢Vim的看[这里](http://coolshell.cn/articles/11312.html)。
2. 喜欢Emacs的看[这里](http://www.masteringemacs.org/)，给个现成的[.emacs.d](https://github.com/purcell/emacs.d)。

#### 准备Ruby开发环境
##### 安装Ruby
1. 通过[rbenv](https://github.com/sstephenson/rbenv)安装ruby

    ~~~sh
    brew update
    brew install rbenv ruby-build
    rbenv versions
    rbenv install 2.0.0-p247
    ~~~
2. 通过[RVM](https://rvm.io/)安装ruby

    ~~~sh
    # install rvm on /usr/local/rvm
    curl -sSL https://get.rvm.io | sudo bash -s stable
    sudo chown -R YOURNAME:rvm /usr/local/rvm
    rvm reload
    rvm list known
    # Install latest stable ruby version
    rvm install 2.1.2
    rvm use 2.1.2 —default
    
    # update RVM
    rvmsudo rvm get stable
    sudo chown -R YOURNAME:rvm /usr/local/rvm
    ~~~

##### 安装常用的gem

~~~sh
gem install pry rails bundler --no-ri --no-rdoc
gem install jekyll
gem install sinatra
~~~
    
##### 开发工具选择
1. EDITOR (TextMate, MacVim, Sublime) + iTerm
2. RubyMime
    

#### 准备Java的开发环境
##### 安装JDK
我们可以从Oracle官网上去[下载](http://www.oracle.com/technetwork/java/javase/downloads/index.html)JDK的最新版本，目前最新版本是JDK8，建议把JDK7和JDK8都装上，可以在~/.zshrc文件指定JAVA_HOME的路径来切换Java的版本。

~~~
#export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_26.jdk/Contents/Home
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_67.jdk/Contents/Home
~~~
注意：具体Java版本以你本地安装的版本为准。
##### 安装Maven

~~~sh
brew install maven
~~~

##### JVM语言

~~~sh
# Groovy
brew install groovy
brew install grails
# Scala
brew install scala
brew install typesafe-activator
# Clojure
brew install leiningen
~~~
    
##### 开发工具选择
1. IDE (IntelliJ IDEA, Eclipse, Netbeans)
2. [Emacs](http://www.braveclojure.com/using-emacs-with-clojure/)(Clojure语言开发推荐)

#### 准备Node开发环境

##### 安装node和npm
~~~sh
brew install node --enable-debug
~~~

##### 在~/.zshrc配置全局NODE_PATH
~~~sh
export NODE_PATH="/usr/local/lib/node_modules/"
~~~
##### 安装常用的组件
~~~sh
npm install express
npm install jquery
~~~

##### 开发工具的选择
1. WebStorm
2. EDITOR (MacVim, Sublime, Textmate) + iTerm

#### 搭建PHP开发环境
##### 安装PHP和启动fcgi

~~~sh
brew tap homebrew/homebrew-php
# Install php-cgi
brew reinstall php56 --with-mysql --with-cgi --with-pgsql --with-homebrew-curl --without-pear

# Install fcgi
brew install spawn-fcgi

# Start fcgi
spawn-fcgi -a 127.0.0.1 -p 6666 -C 6 -f /usr/local/bin/php-cgi -u james -d /u/var/run/fcgi -P /u/var/run/fcgi/spawn_fcgi.pid > /dev/null
~~~
更多安装选项可以试用`brew options php56`查看。

##### 测试PHP环境
###### `Nginx` 配置
~~~
http {
    upstream fastcgi_server {
        server  127.0.0.1:6666;
    }
    server {
        listen              80;
        server_name         localhost;
        index               index.html index.htm index.php;

        location / {
	        root   			/u/var/www;
	        index  			index.php index.html index.htm;
        }
        location ~ \.php$ {
	        root			/u/var/www;
	        fastcgi_pass	fastcgi_server;
	        fastcgi_index	index.php;
	        fastcgi_param	SCRIPT_FILENAME  $document_root/$fastcgi_script_name;
	        include			conf/fastcgi_params;
        }
    }
}
~~~
###### 测试页面(`index.php`)
~~~php
<?php
	phpinfo();
?>
~~~
访问http://localhost/index.php页面即可以查看PHP环境是否搭建成功。

##### 开发工具的选择
1. IDE (PhpStorm, Eclipse, Zend Studio, Komodo, Netbeans) 
3. EDITOR (MacVim, Emacs, Sublime) + iTerm

#### 其他编程语言
如果你是编程语言控，在OS X下你可以很方便地试用各种编程语言。

~~~sh
# install python 2.7
brew install python
# install python 3
brew install python3

# ANSI Common Lisp
brew install clisp
# Scheme
brew install mit-scheme
# newLISP
brew install newlisp

# Smalltalk
brew install gnu-smalltalk --tcltk

# Go语言
brew install go

# Prolog
brew install swi-prolog --with-jpl --with-xpce 
# Erlang
brew install erlang

# Lua
brew install lua
# Io语言
brew install io
~~~

## 一些实用技巧
### 挂载硬盘到指定目录
这里，我们演示如何把第二块硬盘挂载到/opt目录。

~~~sh
# 列出当前所有硬盘信息
diskutil list
# diskN 一般代表第N个硬盘，diskNS1一般表示EFI分区信息，diskNS2一般表示我们的目标分区卷。
# 列出指定硬盘的详细信息，这里面我们可以得到它的UUID信息
diskutil info /Volumes/HHD

#如果挂载点目录不存在，需要先创建它
# sudo mkdir /opt
# 把第二块硬盘加载到/opt目录
diskutil mount -mountPoint /opt/  /dev/disk2s2

# 注意，如果你的硬盘已经挂载到了具体目录，比如/Volumes/HDD，在挂载前，你必须先卸载它。
diskutil unmount  /dev/disk2s2
~~~

通过以上的命令，我们确实可以做到把硬盘挂载到具体目录，然后当我们机器重启后，通过刚刚命令修改的配置就会失效。如果我们想固定把硬盘加载到某个目录（尤其当我们第二块硬盘也是内置硬盘）时，又当如何处理呢？事实上，非常简单，执行如下命令，在`fstab`中加入一条记录即可。

~~~sh
sudo vifs
~~~
我的电脑配置记录如下：

~~~
UUID=DE74EC97-3EFC-3197-AC0E-AC596773D738 /opt hfs rw 1 0
~~~
注意：UUID即为命令`diskutil`查看该卷详情得到的`Volume UUID`，在挂载前，必须保证挂载的目录已经存在.

### Finder显示默认隐藏的文件

~~~sh
# 显示所有隐藏文件
defaults write com.apple.finder AppleShowAllFiles -bool YES
killall Finder

# 取消显示所有隐藏文件
defaults write com.apple.finder AppleShowAllFiles -bool NO
killall Finder
~~~ 

### TimeMachine中命令行操作权限问题
##### 删除指定的目录

~~~sh
# Before OSX 10.9
sudo /System/Library/Extensions/TMSafetyNet.kext/Helpers/bypass rm -frv 2011-10-16-232226/Macintosh\ HD/opt/ 
# After OSX 10.10
sudo /System/Library/Extensions/TMSafetyNet.kext/Contents/Helpers/bypass rm -frv 2011-10-16-232226/Macintosh\ HD/opt/ 
# DELETE All .DS_Store
sudo /System/Library/Extensions/TMSafetyNet.kext/Contents/Helpers/bypass find . -name '.DS_Store' -print -delete
~~~
重装完系统，特别是在有第二块硬盘的情况下，在使用TimeMachine的时候，会发现整个硬盘很有可能要重新备份，而不是在原来的基础上增量备份，这无疑是对备份空间的巨大浪费，如果你之前已经备份了该磁盘的话，可以强制把TimeMachine中的对应备份强制恢复到该分区即可解决这个问题。


### 视频格式转换


### Extended Attributes (EAs)
当我们使用`ls -l`查看文件目录时，细心的同学会发现有些文件的ACL后面都多一个@，这个就是我们这节要讨论的扩展属性。  

~~~sh
-rw-r--r--@ 1 james  admin     3409417 Oct 21 22:54 CoRD.zip
-rw-r--r--@ 1 james  admin      755402 Oct 21 22:54 HexFiend.zip
~~~
在UNIX/Linux当中，文件可以拥有rwx之外的扩展属性，在本例中，测试的几个文件打上了颜色的tag，要查看扩展属性的详情，可以使用命令`ls -l@`查看。

~~~sh
-rw-r--r--@ 1 james  admin     3409417 Oct 21 22:54 CoRD.zip
	com.apple.FinderInfo	        32
	com.apple.metadata:_kMDItemUserTags	        53
-rw-r--r--@ 1 james  admin      755402 Oct 21 22:54 HexFiend.zip
	com.apple.FinderInfo	        32
	com.apple.metadata:_kMDItemUserTags	        53
~~~
可以使用`xattr`命令来操作扩展属性。

~~~sh
xattr -d com.apple.metadata:_kMDItemUserTags CoRD.zip
xattr -w hello world CoRD.zip
~~~
`ls -l@ CoRD.zip`结果如下：

~~~sh
-rw-r--r--@ 1 james  admin   3.3M Oct 21 22:54 CoRD.zip
	hello	   5B
~~~
使用`xattr -cr TARGET`可以清空目标文件所有的扩展属性信息，这个对于从TimeMachine拷贝出来的文件批量清除扩展属性特别有效。

另外，在复制文件的过程中，`cp`指定`-X`可以取消复制EAs。


### 常用的命令

~~~sh
# 删除所有.DS_Store文件
sudo find / -name '.DS_Store' -print -delete
# 删除当前目录下所有空子目录 
find . -type d -empty -delete -print

# 找出目录下大于100M的文件
find . -type f -size +100000k 
find . -type f -size +100000k -exec ls -lh {} \; | awk '{ print $5 " => " $9 " " $10 }' 

# 试用tail实时监控日志
tail -fn 500 /var/log/messages #参数-f使tail不停地去读最新的内容，这样有实时监视的效果

# 分割和合并文件
split -b 300m BIGFILE PREFIX
cat PREFIX* > BIGFILE

# 查看目录大小
du -sh /opt
# 查看本地磁盘使用信息
df -h

# 查看当前使用的SHELL名称
echo $SHELL
echo $0
env | grep SHELL
cat /etc/passwd | grep USERNAME

# SCP常用操作
# 获取远程服务器上的文件
scp -P 22 admin@192.168.1.96:/home/admin/test.tar.gz ~/test.tar.gz
# 获取远程服务器上的目录
scp -P 22 -r admin@192.168.1.96:/home/admin/test/ ~/test
# 将本地文件上传到服务器上
scp -P 22 /home/james/test.tar.gz admin@192.168.1.96:/home/admin/test.tar.gz
# 将本地目录上传到服务器上
scp -P 22 -r /home/james/test/ admin@192.168.1.96:/home/admin/test


# 批量重命名文件
# 本例演示了把当前目录下的所有MP3文件的名称去除多余的字符，只保留序号。
rename 's/.+(\d+).mp3/$1.mp3/' *.mp3

# 批量下载整个网站
wget -r -np http://www.sandpile.org/

# 批量Unlock文件
chflags -R nouchg /PATH/TO/DIRECTORY/WITH/LOCKED/FILES/

# 一些查看用户和系统信息的命令
id
finger
uname -a
ulimit -a
~~~



## 一些小工具

* [CoRD](http://pan.baidu.com/s/1gd7rq4V) 一款远程桌面工具，连远程Windows桌面效果还不错。
* [HexFriend](http://pan.baidu.com/s/1i3wxLTb), [0xED](http://pan.baidu.com/s/1qWHOpUs) 比较实用的二进制编辑工具。
* [MacDjView](http://pan.baidu.com/s/1qW0ntj2) 如果你有djvu格式的图书，这个工具可以帮到你。







