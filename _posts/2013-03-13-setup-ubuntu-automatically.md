---
layout: post
title:  "自动配置Ubuntu开发环境"
author: 詹子知(James Zhan)
date:   2013-03-13 22:52:00
meta:   版权所有，转载须声明出处
category: linux
tags: [linux, ubuntu, shell]
---

## 准备工作

### 安装Ubuntu

如果是机器安装，首先你需要准备Ubuntu的安装光盘，按照引导一步一步安装即可。

如果只是用于个人学习，我建议使用虚拟机来安装Ubuntu，可以从[Linux镜像][linuxmirrors]去下载对应版本的镜像，国内我推荐从[网易开源镜像][ubuntu163]上去下载对应的镜像。接下来就可以在虚拟机上安装Ubuntu了。

### 安装Ruby

既然是自动配置，就一定会用到脚本，这里选择的脚本语言是Ruby，因此我们需要首先安装Ruby。

#### Windows

下载[RubyIntaller][rubyinstaller]，双击直接安装即可。

#### Ubuntu

```sh
sudo apt-get install ruby
```

#### OS X

默认OS X已经自带了Ruby程序，如果没有特别的版本需求，一般不需要单独安装。

### 检查环境并安装相关依赖

```sh
gem update
```

如果无法更新，可能是GFW的问题，建议更换RubyGem源。

```sh
gem sources --remove https://rubygems.org/
gem sources -a https://ruby.taobao.org/
```

安装[SSHKit][sshkit]，sshkit是[Capistrano][capistrano]的一个子项目，它对[Net::SSH][net-ssh]进行了封装。

> Capistrano是Ruby领域最热门的自动化部署工具。

```sh
gem install sshkit
```

## 自动化部署

### 设置root用户SSH登陆免输入密码

如果是第一次使用，需要先启用root用户，并配置密码。

登入到Ubuntu，为root用户新增一个密码。

```sh
sudo passwd root
```

默认Ubuntu是不允许root用户使用密码SSH登陆，这个时候我们可以修改`/etc/ssh/sshd_config`，找到`PermitRootLogin`，把这一行改为如下代码即可。

```
PermitRootLogin yes
```

执行如下代码就可以使得本机root用户登陆Ubuntu不用输入密码。

```sh
cat ~/.ssh/id_rsa.pub | ssh root@10.211.55.5 'cat >> ~/.ssh/authorized_keys'
```

为了安全起见，在设置好root用户本机登陆Ubuntu免输入密码后，可以把`PermitRootLogin`改回原值。

### 自动创建新用户并设置新apt源

```ruby

host = ARGV[0]
user = ARGV[1]
password = ARGV[2]

on "root@#{host}", in: :sequence, wait: 5 do
  if test "[ -d /home/#{user} ]"
    puts "User #{user} is ready!"
  else
    execute "deluser #{user} --remove-all-files"
    puts "Not Found User #{user}, start setup user #{user}"
    execute "adduser --ingroup sudo --shell /bin/bash --disabled-password --gecos 'User for managing of deployment' --quiet --home /home/#{user} #{user}"
    execute "echo '#{user} ALL = (ALL) NOPASSWD: ALL' > /tmp/sudoer_#{user}"
    execute "mv /tmp/sudoer_#{user} /etc/sudoers.d/#{user}"
    execute "chown -R root:root /etc/sudoers.d/#{user}"

    if test "[ -d /home/#{user}/.ssh ]"
      puts "/home/#{user}/.ssh have already exists."
    else
      puts "/home/#{user}/.ssh not exists, create one."
      execute "mkdir /home/#{user}/.ssh"
      execute "chown -R #{user}:sudo /home/#{user}/.ssh"
    end

    upload! '/Users/james/.ssh/id_rsa.pub', '/tmp/id_rsa.pub'
    execute "cat /tmp/id_rsa.pub >> /home/#{user}/.ssh/authorized_keys"

    with_ssh do |ssh|
      ch = ssh.exec("passwd #{user}", &passwd_handler)
      ch.wait
    end
  end
  if test '[ -f /etc/apt/sources.list_bak ]'
    puts 'The mirrors sources list have already setup!'
  else
    capture :mv, '/etc/apt/sources.list /etc/apt/sources.list_bak'
    contents = StringIO.new <<-SOURCE_CONTENT
deb http://mirrors.aliyun.com/ubuntu/ utopic main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ utopic-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ utopic-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ utopic-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ utopic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ utopic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ utopic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ utopic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ utopic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ utopic-backports main restricted universe multiverse
    SOURCE_CONTENT
    upload! contents, '/etc/apt/sources.list'
  end
end
```

如果是第一次设置deploy(用户名可以自己定义)用户，上面的代码等价于在Ubuntu使用root用户直接执行如下代码：

```sh
# 新增用户
adduser --ingroup sudo --shell /bin/bash --disabled-password --gecos 'User for managing of deployment' --quiet --home /home/deploy deploy


# 设置sudo免输入密码
echo 'deploy ALL = (ALL) NOPASSWD: ALL' > /tmp/sudoer_deploy
mv /tmp/sudoer_deploy /etc/sudoers.d/deploy
chown -R root:root /etc/sudoers.d/deploy


# 设置本机deploy登陆Ubuntu免输入密码
mkdir /home/deploy/.ssh
chown -R deploy:sudo /home/deploy/.ssh
# 上传本地~/.ssh/id_rsa.pub文件到Ubuntu的临时目录

cat /tmp/id_rsa.pub >> /home/deploy/.ssh/authorized_keys
```

为了加快国内用户有必要更换apt源，这里推荐aliyun的源，把如下代码加到/etc/apt/sources.list即可。

```
deb http://mirrors.aliyun.com/ubuntu/ utopic main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ utopic-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ utopic-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ utopic-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ utopic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ utopic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ utopic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ utopic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ utopic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ utopic-backports main restricted universe multiverse
```

### 配置Oh-My-Zsh

```ruby
# Setup Oh-My-Zsh
on "#{user}@#{host}", in: :sequence, wait: 5 do
  capture :sudo, 'apt-get -y update'
  capture :sudo, 'apt-get -y install python-software-properties'
  capture :sudo, 'apt-get -y upgrade'
  capture :sudo, 'apt-get -y dist-upgrade'

  oh_my_zsh_dir = "/home/#{user}/.oh-my-zsh"
  if test "[ -d #{oh_my_zsh_dir} ]"
    within oh_my_zsh_dir do
      execute :git, :pull
      execute :git, :fetch, :upstream
      execute :git, :checkout, :master
      execute :git, :rebase, 'upstream/master'
    end
  else
    capture :sudo, 'apt-get -y install git' unless test('command -v git')
    execute :git, :config, '--global user.name "James Zhan"'
    execute :git, :config, '--global user.email "zhiqiangzhan@gmail.com"'
    execute :git, :clone, 'https://github.com/jameszhan/oh-my-zsh.git', oh_my_zsh_dir

    within oh_my_zsh_dir do
      execute :git, :remote, :add, :upstream, 'https://github.com/robbyrussell/oh-my-zsh.git'
      execute :git, :pull, :origin, :master
      capture :cp, 'templates/zshrc.zsh-template', '../.zshrc'
    end

    capture :sudo, 'apt-get -y install zsh' unless test('command -v zsh')
  end

  with_ssh do |ssh|
    ch = ssh.exec('chsh -s `which zsh`', &passwd_handler)
    ch.wait
  end unless capture('echo $SHELL') =~ /zsh$/
end
```

以上代码等价于以下几个过程。

首先，我们先更新下apt环境。

```sh
sudo apt-get -y update
sudo apt-get -y install python-software-properties
sudo apt-get -y upgrade'
sudo apt-get -y dist-upgrade'
```

安装Git和zsh

```sh
sudo apt-get -y install git zsh
git config --global user.name "James Zhan"
git config --global user.email "zhiqiangzhan@gmail.com"
```

配置Oh-My-Zsh

```sh
git clone https://github.com/jameszhan/oh-my-zsh.git /home/deploy/.oh-my-zsh
git remote add upstream https://github.com/robbyrussell/oh-my-zsh.git
git pull origin master
cp /home/deploy/.oh-my-zsh/templates/zshrc.zsh-template /home/deploy/.zshrc

chsh -s `which zsh`
```

### 安装rbenv

```sh
on "#{user}@#{host}", in: :sequence, wait: 5 do
  #Install rbenv
  within '/usr/local' do
    if test '[ -d /usr/local/rbenv ]'
      within 'rbenv' do
        execute :git, :pull
      end
    else
      execute :sudo, :git, :clone, 'https://github.com/sstephenson/rbenv.git rbenv'
      execute :sudo, 'chown -R deploy:sudo rbenv'
    end

    within 'rbenv' do
      if test '[ -d /usr/local/rbenv/plugins/ruby-build ]'
        within 'plugins/ruby-build' do
          execute :git, :pull
        end
      else
        execute :git, :clone, 'https://github.com/sstephenson/ruby-build.git plugins/ruby-build'
      end
    end

    if test '[ -f /etc/profile.d/rbenv.sh ]'
      puts 'rbenv.sh have already setup!'
    else
      rbenv_scripts = StringIO.new <<-SOURCE_CONTENT
# rbenv setup
export RBENV_ROOT=/usr/local/rbenv
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"
      SOURCE_CONTENT
      upload! rbenv_scripts, '/tmp/rbenv_scripts'
      execute 'chmod +x /tmp/rbenv_scripts'
      execute :sudo, :mv, '/tmp/rbenv_scripts', '/etc/profile.d/rbenv.sh' if test('[ -f /tmp/rbenv_scripts ]')
      execute 'echo "source /etc/profile.d/rbenv.sh" >> ~/.zshrc'
    end
  end

  unless test('source /etc/profile.d/rbenv.sh && ruby --version')
    execute :sudo, 'apt-get -y install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev'
    execute <<-ZSHRC
        source /etc/profile.d/rbenv.sh
        rbenv install --verbose 2.2.2
        rbenv global 2.2.2
        rbenv rehash
        gem install bundler
    ZSHRC
  end
end
```

以上自动化脚本描述了使用rbenv安装Ruby，等价于如下代码。

```sh
sudo git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
sudo chown -R deploy:sudo /usr/local/rbenv

git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
```

把以下的配置加入了/etc/profile.d/rbenv.sh中

```
# rbenv setup
export RBENV_ROOT=/usr/local/rbenv
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"
```

随后执行

```sh
echo "source /etc/profile.d/rbenv.sh" >> ~/.zshrc
```

安装Ruby

```sh
sudo apt-get -y install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev
rbenv install --verbose 1.9.3
rbenv global 1.9.3
rbenv rehash

gem install bundler
```

### 安装其他软件

```ruby
on "#{user}@#{host}", in: :sequence, wait: 5 do
  # nginx
  unless test('type nginx')
    execute :sudo, 'add-apt-repository ppa:nginx/stable'
    execute :sudo, 'apt-get -y update'
    execute :sudo, 'apt-get -y install nginx'
  end

  #docker
  execute :sudo, 'apt-get -y update'
  execute :sudo, 'apt-get -y install wget' unless test('type wget')
  with_ssh do |ssh|
    ch = ssh.exec('wget -qO- https://get.docker.com/ | sh', &passwd_handler)
    ch.wait
  end unless test('type docker')
end
```

安装其他的软件

```sh
sudo apt-get -y install wget rename

# Nginx
sudo add-apt-repository ppa:nginx/stable
apt-get -y update
apt-get -y install nginx
```


## 使用脚本自动部署

```sh
# 下载完整的部署脚本
wget https://raw.githubusercontent.com/jameszhan/prototypes/master/ruby/ubuntu_setup.rb

ruby ubuntu_setup.rb HOST_IP USERNAME PASSWORD
```


[linuxmirrors]: http://mirrors.kernel.org/ "Linux Kernel Archives"
[ubuntu163]: http://mirrors.163.com/ubuntu/ "网易开源镜像"
[rubyinstaller]: http://rubyinstaller.org/ "RubyIntaller"
[capistrano]: https://github.com/capistrano/capistrano "SSHKit"
[sshkit]: https://github.com/capistrano/sshkit "SSHKit"
[net-ssh]: https://github.com/net-ssh/net-ssh "Net::SSH"



