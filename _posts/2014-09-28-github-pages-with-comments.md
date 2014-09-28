---
layout: post
title:  "如何实现Github博客评论功能"
author: 詹子知(James Zhan)
date:   2014-09-28 18:00:00
meta:   版权所有，转载须声明出处
categories: Practise
---

## 为什么选择GitHub Pages

如果我们要写日志，我们一般有两种选择：

1. 在网站提供的博客空间进行写作，例如CSDN，博客园等。
2. 自己购买虚拟主机，构建自己的个人网站。

两种方式各有优缺点，第一种方案的优点就是简单，不需要任何技术门槛，只需要有对应网站的账号就可以。但是其很难定制自己的博客网站的风格，甚至有时候连书写方式也无法选择（CSDN目前都无法支持Markdown），
除此之外，这些网站几乎都没有靠谱的文章导出功能，一旦网站停止服务，对用户的个人数据将是一个灾难。
第二种方案的优点是自由度高，可以把网站做成任何你想要的样子，但是其技术难度高，尽管已经有像Wordpress，Octopress很多开源的blog系统，依然很难被普通用户使用，除此之外，由于虚拟主机需要自己来管理，
很多技术方面的问题都需要自己来解决，没有办法完全专注地写作。

现在，你有了第三种选择，[GitHub Pages](https://pages.github.com/)，只要你会使用Github，你就可以很轻松构建自己的个人博客网站。
和第二种方式类似，使用GitHub Pages，你可以很灵活地构建你自己的个人网站，如果你只是静态页面，几乎没有没有任何限制。如果你像我一样，喜欢使用Markdown来写作的话，使用Jekyll，我们可以很容易地支持Markdown，这也是GitHub Pages官方推荐的使用方式。。
从此，你只要专心关注你的写作内容就好了，再也不需要关心服务器运维，虚拟空间管理这些繁琐的事情了。

然而，GitHub Pages也不是万能的，由于它默认只支持纯静态的页面，所以我们无法在其中使用我们自己的数据库，这样普通日志具有的评论功能我们默认是无法实现的。


## 第三方社会化评论系统

感谢OAuth和第三方评论系统，由于它们，我们可以很轻松地使我们的静态网站支持评论功能。

#### OAuth

OAuth协议为用户资源的授权提供了一个安全的、开放而又简易的标准。与以往的授权方式不同之处是OAUTH的授权不会使第三方触及到用户的帐号信息（如用户名与密码），即第三方无需使用用户的用户名与密码就可以申请获得该用户资源的授权，因此OAUTH是安全的。oAuth是Open Authorization的简写。
简单地说，OAuth使得用户可以利用一些已有的身份（比如Weibo，QQ）去登陆一些其他的网站，而不需要在该网站重新注册自己的身份信息。这样做有如下几个优点：
1. 省去了注册流程，可以快速地登陆网站。
2. 省去了注册流程中资料的填写流程，减少了自己一些隐私信息暴露的风险。
3. 不需要把密码信息（很多人注册账号的时候喜欢使用同一个密码）暴露给一些小型应用和网站，减少了密码暴露的风险。
4. 减少不必要的记忆信息，比如账号和密码信息等。


#### 社会化评论系统

目前第三方社交评论系统主要有Disqus，Facebook Comment，评论啦(pinglun.la)、友言(uyan.cc)，多说(duoshuo.com)等。
其中，Disqus和Facebook Comment由于国情原因，在国内网站上几乎没有使用价值。评论啦(pinglun.la)、友言(uyan.cc)，多说(duoshuo.com)等则依托于微博，QQ等第三方登陆平台，可以很方便地接入到我们网站中来。


## 给博客加入评论功能

下面我们就拿多说举例，来看看GitHub Pages如何接入第三方社交评论系统。

1. 使用你的社交账号登陆多说。
2. 进到首页，点击我要安装。
3. 输入相应的网站注册信息，输入完成后，它会提供给你一段HTML代码。
4. 把生成后的代码拷贝到你需要评论的页面当中。

    ~~~html
    <!-- 多说评论框 start -->
        <div class="ds-thread" data-thread-key="请将此处替换成文章在你的站点中的ID" data-title="请替换成文章的标题" data-url="请替换成文章的网址"></div>
    <!-- 多说评论框 end -->
    <!-- 多说公共JS代码 start (一个网页只需插入一次) -->
    <script type="text/javascript">
    var duoshuoQuery = {short_name:"SHORT-NAME"};
        (function() {
            var ds = document.createElement('script');
            ds.type = 'text/javascript';ds.async = true;
            ds.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') + '//static.duoshuo.com/embed.js';
            ds.charset = 'UTF-8';
            (document.getElementsByTagName('head')[0] 
             || document.getElementsByTagName('body')[0]).appendChild(ds);
        })();
        </script>
    <!-- 多说公共JS代码 end -->
    ~~~
    其中，data-title和data-url的值比较简单，填写文章的标题和真实网址就可以了。
    关键是data-thread-key的设置，原则上要求对于每一个页面，它的值应该是唯一的，这里我推荐使用相对路径的URL就可以，下面是我本地的例子。
    
    ~~~html
    <div class="ds-thread"
         data-thread-key="{{page.url}}"
         data-title="{% if page.title %}{{ page.title }}{% else %}{{ site.title }}{% endif %}"
         data-url="{{page.url | prepend: site.url}}"></div>
    ~~~

5. 去除多说广告内容。
    
    以下样式使用scss编写。
    
    ~~~scss
    #ds-thread.ds-thread {
      #ds-reset {
        .ds-comments-info {
          .ds-comments-tabs {
            li.ds-tab {
              .ds-comments-tab-weibo {
                display: none;
              }
            }
          }
        }
        .ds-powered-by {
          display: none;
        }
      }
    }
    ~~~

6. 禁用默认分享到微博和空间的功能。

    我想很多人都和我一样，很讨厌默认分享的功能，默认多说的分享是勾上的，其实我们只要加入如下的脚本，我们就可以很轻易地去掉默认分享的功能。
    
    ~~~javascript
    $(document).on('click', '#ds-thread textarea[name=message]', function(){
        $('#ds-sync-checkbox').prop('checked', false);
    });
    ~~~

到此，我们的文章评论功能就添加完毕，赶快来尝试一下吧！

