---
layout: post
title:  "简单谈下 Ruby 中的代码块"
author: 詹子知(James Zhan)
date:   2018-02-02 22:00:00
category: ruby
tags: [ruby, metaprogramming, dsl, pdt]
---

## 简介

**Block** 是 **Ruby** 的一个独特特性，它本质上就是一组代码，通过它，可以很容易实现回调，或传递一组代码（远比C的函数指针灵活），以及实现迭代器。这是一个不可思议的功能强大的特性。

语法表现上，**Block** 是花括号或者`do`和`end`之间的一组代码，按照社区约定，我们可以通过以下两种方式来书写 **Block**

- 多行，使用`do`和`end`作为开始和结束。
- 单行，使用花括号


```ruby
[1, 2, 3].each do |i|
  puts i
end

[1, 2, 3].each{ |i| puts i }
```

    1
    2
    3
    1
    2
    3


## 概念

**Block** 相关的一些术语

- 闭包，`proc`，`lambda`, 函数，函数指针，匿名函数
- 回调，`callable`，`functor`，`delegate`

我们介绍下其中的几个概念。

#### 闭包

> 一个包含了自由变量的开放表达式，它和该自由变量的约束环境组合在一起后，实现了一种封闭的状态。 ──  Functional programming using standard ML, Prentice- Hall, 1987. 15

在计算机科学中，闭包（Closure）是词法闭包（Lexical Closure）的简称，是引用了自由变量的表达式（通常是函数）。这些被引用的自由变量将和这个函数一同存在，即使已经离开了创造它的环境也不例外。 词法作用域(lexical scope)也叫静态作用域(static scope)。所谓的词法作用域其实是指作用域在词法解析阶段既确定了，不会改变，简单理解，就是代码块定义在哪里，就引用哪里的上下文环境。

闭包的数据结构可以定义为，包含一个函数定义 f 和它定义时所在的环境 (struct Closure (f env))

- 全局函数是一个有名字但不会捕获任何值的闭包。
- 嵌套函数是一个有名字并可以捕获其封闭函数域内值得闭包。
- Lambda(闭包表达式)是一个利用轻量级语法所写的可以捕获其上下文中变量值的匿名闭包。

#### 函数指针

函数指针在`C`语言中用的比较多，本质上，它就是一个内存地址，只不过指向的是一块可执行代码的首地址。和闭包相比，它并没有附带定义该函数的上下文信息，也不负责指针类型检查。

#### functor

在`C++`中，**functor** 是行为类似函数的对象，可以拥有成员函数和成员变量，即 **functor** 拥有状态，其本质和闭包很接近，只是用起来比较繁琐。

#### delegate

`C#`中的 `delegate` 类似于 `C` 或 `C++` 中的函数指针。使用 `delegate` 使程序员可以将方法引用封装在委托对象内。然后可以将该 ``delegate`` 对象传递给可调用所引用方法的代码，而不必在编译时知道将调用哪个方法。与C或C++中的函数指针不同，`delegate` 是面向对象、类型安全的，并且是安全的。

## 可调用对象(`callable object`)

**Ruby** 中，可调用对象是可执行的代码片段，它们都有自己的作用域，可调用对象有以下几种方式：

- **block**，在定义它们的作用域中执行，它是闭包的一种。
- **proc**，`Proc` 类的对象，和块一样，它们也在定义自身的作用域中执行，它也是闭包的一种。
- **lambda**，也是 `Proc` 类的对象，和块一样，它们也在定义自身的作用域中执行，它和 `proc` 用法有细微的区别，也是闭包的一种。
- **method**，绑定于对象，在所绑定对象的作用域中执行。

### `block`

`block` 闭包测试要麻烦一些，因为很多时候，很多时候都是在定义它的作用域中直接执行它，达不到逃逸的效果，为了验证 `block` 的闭包特性，我们需要先把 `block` 捕获起来，然后再调用。


```ruby
def capture_block(&block)
  block
end

def clean_room
  level_0 = "level0"
  lambda do
    level_1 = 'level_1'
    proc do
      level_2 = 'level_2'
      capture_block do
        level_3 = 'level_3'
        puts "block locals: #{local_variables}"
        self
      end 
    end
  end
end

callable = clean_room
block0 = callable.call.call
block0.call
```

    block locals: [:level_3, :level_2, :level_1, :level_0]


上面的例子中其实有一个不严谨的地方，捕获块的时候，其实有一个隐式的转换。

上例中，`&block` 对应的就是代码块：

```ruby
do
    level_3 = 'level_3'
    puts "block locals: #{local_variables}"
end 
```

当去掉 `&` 直接访问 `block` 的时候，**Ruby** 会自动把 `&block` 对应的代码块封装成一个 `Proc` 对象。


```ruby
block0.class
```




    Proc



`&block` 应该算是 **Ruby** 中的唯一一个不是对象的实体，它代表的是一组可以执行的代码，无法直接访问它，下面的代码会抛 `SyntaxError`。

```ruby
proc0 = Proc.new{ puts "hello world" }
obj = &proc0
```

通过 `&` 运算符，我们可以在 `&block` 和 `Proc` 对象之间进行转换。


```ruby
proc0 = Proc.new{ "Hello World" }

def run
  yield
end

run &proc0
```




    "Hello World"



### proc


```ruby
def clean_room
  level_0 = "level0"
  lambda do
    level_1 = 'level_1'
    proc do
      level_2 = 'level_2'
      proc do
        level_3 = 'level_3'
        puts "proc locals: #{local_variables}"
      end 
    end
  end
end

callable = clean_room
proc0 = callable.call.call

puts proc0.call
```

    proc locals: [:level_3, :level_2, :level_1, :level_0]
    


### lambda


```ruby
def clean_room
  level_0 = "level0"
  lambda do
    level_1 = 'level_1'
    proc do
      level_2 = 'level_2'
      lambda do
        level_3 = 'level_3'
        puts "lambda locals: #{local_variables}"
      end 
    end
  end
end

callable = clean_room
lambda0 = callable.call.call

puts lambda0.call
```

    lambda locals: [:level_3, :level_2, :level_1, :level_0]
    


**ruby 1.9** 之后，`lambda`还可以使用更简便的 `->` 记法。


```ruby
->{ puts "Hello World!" }.call
->(a, b){ puts a + b }.call(1, 2)
```

    Hello World!
    3


`block`，`proc` 和 `lambda` 的区别，后面再重点介绍。

再来看一个例子：


```ruby
def make_counter(n)
    lambda{ n -= 2 }
end

c1 = make_counter(9)
c2 = make_counter(6)

puts "c1 = #{c1.call}, c2 = #{c2.call}"
puts "c1 = #{c1.call}, c2 = #{c2.call}"
puts "c1 = #{c1.call}, c2 = #{c2.call}"
```

    c1 = 7, c2 = 4
    c1 = 5, c2 = 2
    c1 = 3, c2 = 0



```ruby
def make_counter(n)
    proc{ n -= 1 }
end

c1 = make_counter(9)
c2 = make_counter(6)

puts "c1 = #{c1.call}, c2 = #{c2.call}"
puts "c1 = #{c1.call}, c2 = #{c2.call}"
puts "c1 = #{c1.call}, c2 = #{c2.call}"
```

    c1 = 8, c2 = 5
    c1 = 7, c2 = 4
    c1 = 6, c2 = 3


## yield

有别于其他语言，**Ruby** 中的 `yield` 是一种调用闭包的快捷方式。**Ruby** 有一种特殊的语法把匿名函数传递给一个方法，这种语法就是`block`。


```ruby
def twice
   yield
   yield
end

twice do
  puts "hi!"
end
```

    hi!
    hi!


**Ruby** 中对于所有方法，无论它的参数列表长什么样，它都可以在后面跟上一个可选的 `&block`。

```ruby
def func(a, b, *args, *kwargs, &block)
...
end
```

`&block` 严格来说不是一个参数，更像是一个声明，它指示一组执行代码的地址，如果直接访问 `block` 则会把这组代码封装在 `Proc` 对象当中，并把引用赋值给 `block`。这个块也可以使用 `yield` 来调用，这样可以不用关心代码块的名称。

如果显式地指定 `&block` 参数，则 `yield` 调用的就是 `&block` 传入的代码块。

直观理解，`yield` 可以理解是一个占位，指示 `&block` 被调用的位置，并把 `&block` 所需参数传递过去。


```ruby
def op(a, b, &block)
  puts block.call(a, b)
  puts yield a, b
end

op(1, 2) do|i, j|
  i + j
end
```

    3
    3


一个方法只能有一个 `&block` 参数，`&block` 只可以是最后一个方法参数。

以下的方法定义，都会抛 `SyntaxError`。

```ruby
def multi_block(&block1, &block2); end      # 超过一个 block 参数
```

```ruby
def block_first(&block, arg); end           # 出错，block 不是最后一个参数
```

如果需要传入多个代码块到同一个方法，则其它对象需要使用 **可调用对象**


```ruby
def ifthen(predict, *args)
  if predict.call(*args)
    yield
  else
    puts "Ignore"
  end
end

ifthen(lambda{ |m, n| m < n }, 1, 3) do
  puts "lambda is executed"
end

ifthen(proc{ |i, j, k| i + j < k }, 1, 2, 8) do
  puts "proc is executed"
end

def my_method(a, b)
  a > b
end

ifthen(method(:my_method), 3, 1) do
  puts "method is executed"
end
```

    lambda is executed
    proc is executed
    method is executed


## block_given?

任何方法在调用的时候后面都可以挂载一个**代码块**，尽管有时完全用不上这个**代码块**。


```ruby
def add(a, b)
  a + b
end

add(1, 2) do
  puts "This code never called without yield!"
end
```




    3



如果你定义的方法想使用**代码块**做点事情，那么你需要使用 `yield` 关键字或者 `&block`。

但是一旦方法中使用了 `yield` 关键字或者 `block.call`，则方法在调用的时候必须跟上一个代码块，哪怕这个代码块什么都不做。


```ruby
def f1(a, b)
  yield a, b
end

f1(1, 2){}

begin
  f1(1, 2)
rescue LocalJumpError => e
  puts "LocalJumpError: #{e.message}"
end
```

    LocalJumpError: no block given (yield)



```ruby
def f2(a, b, &block)
  block.call a, b
end

f2(1, 2){}

begin
  f2(1, 2)
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
end
```

    NoMethodError: undefined method `call' for nil:NilClass


如下两种方法定义是等效的：

```ruby
def f2(a, b, &block); yield a, b; end

def f2(a, b); yield a, b; end
```

如果方法实现中，使用 `yield` 调用代码块的话，方法声明可以省掉 `&block`。如果单看方法声明，使用方完全意识不到使用该方法还必须挂一个代码块，否则就会抛出 `LocalJumpError`。

基于以上原因， **Ruby** 提供了 `block_given?` 方法来判断方法后面是否挂了代码块，方便开发者在定义方法时能够考虑调用方忘记带上代码块的情形。


```ruby
def f1(a, b)
  yield a, b if block_given?
end

def f2(a, b, &block)
  block.call a, b if block_given?
end

f1(1, 2)
f2(1, 2)
```

## `yield` vs `block.call`

理论上，`yield` 比 `block.call` 执行起来要高效一些，因为在调用之前需要先将 `&block` 转换成 `Proc` 对象。


```ruby
def f2(a, b, &block)
  block.call a, b if block_given?
end

f2(1, 2){ puts "Hello World" }
```

    Hello World


上面的代码，如果把过程展开，等价于：


```ruby
def f2(a, b, &block)
  if block_given?
    blk = Proc.new &block 
    blk.call a, b
  end
end

f2(1, 2){ puts "Hello World" }
```

    Hello World


另外，使用匿名代码块的写法也要简洁一些，不过显式的代码块要灵活一些，你可以显式把 `block` 传递给其他被调用方法。


```ruby
def ls_files
  Dir.glob("*.ipynb") do |ipynb|
    yield ipynb
  end
end

ls_files{ |file| puts file }
```

    03.02-conditional-statements.ipynb
    03.04-iterators.ipynb
    03.10-ruby-meta-programming.ipynb
    03.11-ruby-style-guide.ipynb
    03.03-loop-statements.ipynb
    03.07-scope.ipynb
    03.01-assignment-statements.ipynb
    03.05-functions.ipynb
    03.06-blocks.ipynb
    03.09-exceptions.ipynb



```ruby
def ls_files2(&block)
  Dir.glob("*.ipynb", &block)
end

ls_files2{ |file| puts file }
```

    03.02-conditional-statements.ipynb
    03.04-iterators.ipynb
    03.10-ruby-meta-programming.ipynb
    03.11-ruby-style-guide.ipynb
    03.03-loop-statements.ipynb
    03.07-scope.ipynb
    03.01-assignment-statements.ipynb
    03.05-functions.ipynb
    03.06-blocks.ipynb
    03.09-exceptions.ipynb


## `Symbol#to_proc`

这种有点诡异的法术在Ruby程序员中很流行，请看下面的代码：


```ruby
names = ['bob' , 'bill' , 'heather' ]
names.map { |name| name.capitalize }
```




    ["Bob", "Bill", "Heather"]



更简洁的写法


```ruby
names = ['bob' , 'bill' , 'heather' ]
names.map(&:capitalize)
```




    ["Bob", "Bill", "Heather"]



当`&`操作符作用于一个对象时，它会调用该对象的`to_proc`方法，先将其转化为一个`proc`对象，再把他转换为对应的代码块。

`:capitalize` 是 `Symbol` 类的实例, `Symbol` 中的 `to_proc` 方法的实现类似于：

```ruby
class Symbol
    def to_proc
        Proc.new {|x| x.send(self) }
    end
end
```

上面的代码等价于：


```ruby
names = ['bob' , 'bill' , 'heather' ]
block = :capitalize.to_proc
names.map(&block)
```




    ["Bob", "Bill", "Heather"]



## `proc` vs. `lamba`

`proc` 和 `lambda` 之间的差异可能是 **Ruby** 中最令人费解的特性。


```ruby
def run(callable)
  puts callable.call
end

p = proc{ "Proc called" }
l = lambda{ "Lambda called" }

run(p)
run(l)
```

    Proc called
    Lambda called


在 **Ruby** 中，最后一行的 `return` 关键字是经常可以省略的，但是在 `proc` 和 `lambda` 当中，加上 `return` 关键字后，他们的行为是不一致的。

在 `lambda` 中，`return` 仅仅表示从这个 `lambda` 中返回，在 `proc` 当中，它不是从 `proc` 中返回，而是从定义 `proc` 的上下文中返回。


```ruby
def run(callable)
  puts "before callable called"
  puts callable.call
  puts "after callable called"
end
```




    :run




```ruby
l = lambda{ return "Lambda called" }
run(l)
```

    before callable called
    Lambda called
    after callable called


`proc` 的行为比较诡异，更好的设计应该是从 `run` 方法返回，`lambda` 更像是一个方法调用，而 `proc` 则相当于把代码块插入到调用的位置去执行，上面的执行代码等价于：


```ruby
def run(code, binding)
  puts "before callable called"
  puts eval(code, binding)
  puts "after callable called"
end

p = proc{ return "Proc called" }

begin 
  run('return "Proc called"', p.binding)  
rescue LocalJumpError => e
  puts "proc executed error #{e.message}."
end
```

    before callable called
    proc executed error unexpected return.


当执行到 `return "Proc called"` 的时候，原本应该返回到 `run` 的返回地址，但是因为 `proc` 记录的确是定义它的 `main` 返回地址，因此报错，如果不考虑绑定，更直观的展开如下。

```ruby
def run()
  puts "before callable called"
  puts return "Proc called"
  puts "after callable called"
end

run
```


```ruby
def run(callable)
  puts "before callable called"
  callable.call
  puts "after callable called"
end

p = proc{ return "proc called" }
  
begin 
  run(p)  
rescue LocalJumpError => e
  puts "proc executed error #{e.message}."
end
```

    before callable called
    proc executed error unexpected return.



```ruby
begin 
  return "Proc called"
rescue LocalJumpError => e
  puts "proc executed error #{e.message}."
end
```

    proc executed error unexpected return.


不过只要我们弄明白了这个坑点，倒是可以用来做一些有意思的事情。


```ruby
def count_down_to(n)
  sentry = proc do|n|
    if n <= 0
      return "count down finished by sentry!"
    end
  end
  
  l = lambda{ |i| sentry.call(i) }
  
  10.downto(n) do|i|
    print i, ', '
    lambda{ l.call(i) }.call
  end
  
  return "count down finish!"
end

puts count_down_to(3)
puts count_down_to(-3)
```

    10, 9, 8, 7, 6, 5, 4, 3, count down finish!
    10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, count down finished by sentry!


`proc` 和 `lambda` 还有点重要的区别来自他们检查参数的方式，`lambda` 总是检查传入的参数数量，如果和定义的不匹配，会抛出一个 `ArgumentError`。而 `proc` 则会把传递进来的参数调整为自己期望的参数形式，如果参数比期望的要多，`proc` 会忽略多余的参数，如果参数数量不足，那么对未指定的参数，proc会赋一个 `nil` 值。

我们再来看 `block`，它的行为更像 `proc`，所以一般我们最好不要在 `block` 块中使用 `return`，除非你明确知道自己在干什么。


```ruby
def run()
  puts "before callable called"
  puts yield
  puts "after callable called"
end

run{ "Block called" }
run{ |arg1, arg2| "Do not check the arguments" }

begin 
  run{ return "Block called" }
rescue LocalJumpError => e
  puts "block executed error #{e.message}."
end
```

    before callable called
    Block called
    after callable called
    before callable called
    Do not check the arguments
    after callable called
    before callable called
    block executed error unexpected return.


整体而言，`lambda` 更直观，也更像一个方法，它不仅对参数数量要求严格，而且在调用 `return` 时，只在 `lambda` 的代码块返回。基于这些原因，如没有使用到某些 `proc` 的特殊功能，应该总是优先选择使用 `lambda`。

更多 **Ruby** 资料整理，移步[Ruby 编程手札](https://github.com/jameszhan/notes-ruby)