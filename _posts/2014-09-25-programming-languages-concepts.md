---
layout: post
title:  "编程语言的一些概念"
author: 詹子知(James Zhan)
date:   2014-09-25 11:00:00
meta:   版权所有，转载须声明出处
category: pdl
tags: [Lambda, 函数式编程, JavaScript, Java, Ruby, Clojure, Swift, 程序设计语言, 元编程, DSL]
---


## 编程语言分类

### 什么是类型？
* Latent typing是一种你不需要在源码中的明确的声明你的变量的类型的类型系统.而与之相反的是manifest typing,它需要你在源码中明确的声明你的变量的类型。
* Static typing(静态类型)类型系统指的是你的源码中的任何独立的表达式都必须有类型，不管它的类型是直接写在源码中，或者是通过编译器来推断.Dynamic typing(动态类型)是运行时的值才有类型的一种类型系统，因此在它里面程序的表达式能够有任意的类型.
* overlap 是一种类型推断系统，像haskell和ocaml用的就是overlap,他们是 statically而且还是latently,他们的编译器能够推断出你的变量的类型。 理论上，这里还有另外一种overlap,它是把变量的类型写在源代码中，可是会直到运行时才会检测类型的是否正确. python3000已经被提议使用这种系统，Common Lisp 和Dylan 使用的就是这种系统.
* structural subtyping(结构化子类型)意味着对象或者表达式能够基于他们的结构(比如他们的方法，变量等等)来进行比较他们的类型的兼容性.相比较而言，nominal subtyping(名义子类型)意味着对象基于通过程序员来做的显示的子类声明来进行比较他们的类型的兼容性(比如java的接口).Haskell, ML, 和大部分的动态类型的语言是 structurally-subtyped.工业语言大多数都是nominal subtyping的.
* 这里还有一个strong vs. weak 类型，他们的区别是是否在运行时动态的转换变量的值 （也就是说要不要到不同的类型)的类型.
* 下面是类型系统的4种不同的维度：      
    1. Static (表达式有类型) vs. dynamic (值有类型)
    2. Strong (没有一个显示的强制转换，这个值的类型就不能被转换为另外的类型) vs. weak (运行时会转换值类型到合适的类型)
    3. Latent (没有类型声明) vs. manifest (有类型声明)
    4. Nominal (子类型需要被显式的声明) vs. structural (子类型是由操作可利用的的类型来进行推断的)

类型的本质在于它所定义的操作以及操作之间的关系和不变式。类型的实现关键在于满足类型规范的要求，而具体实现是可以变化的，使用者和测试用例都应该只依赖于类型规范而不依赖于具体实现。函数式的类型实现往往和类型规范是直接对应的，简单通用，但可能有性能问题，而命令式的类型实现往往会引入复杂的内部数据结构，但是其优点是高效。这两种实现并不是完全互斥的，有时候可以将二者相结合达到简单与高效的结合。

### 强类型 vs 弱类型
弱/强类型指的是语言类型系统的类型检查的严格程度。大部分编程语言都属于强类型语言，弱类型语言的典型代表有C，JavaScript。

### 静态语言 vs 动态语言
静态/动态语言指的是变量与类型的绑定方法，静态类型指的是编译器在compile time执行类型检查，动态类型指的是编译器（虚拟机）在runtime执行类型检查。简单地说，在声明了一个变量之后，不能改变它的类型的语言，是静态语言；能够随时改变它的类型的语言，是动态语言。因为动态语言的特性，一般需要运行时虚拟机支持。

### 脚本语言 vs 通用的编程语言

什么是脚本语言？

对于脚本语言的看法，我比较赞同王垠同学的观点，有兴趣的同学可以参考[什么是“脚本语言”](http://www.yinwang.org/blog-cn/2013/03/29/scripting-language/)


## 编程范型
![pl_paradigm](http://img2.tbcdn.cn/L1/461/1/c11213395dcfa71224df4e978557790b8059856c)

### 命令式
命令“机器”如何去做事情(how)，这样不管你想要的是什么(what)，它都会按照你的命令实现。

### 声明式
告诉“机器”你想要的是什么(what)，让机器想出如何去做(how)。

#### 函数式编程语言
![fp_features](http://img1.tbcdn.cn/L1/461/1/f2ff7728518730327be67cfd42302d5c5d0f1451)

##### 偏函数应用 vs Currying
* 偏函数应用是找一个函数，固定其中的几个参数值，从而得到一个新的函数。
* 函数Currying是一种使用匿名单参数函数来实现多参数函数的方法。
* 函数Currying能够让你轻松的实现某些偏函数应用。
* 有些语言(例如 Haskell, OCaml)所有的多参函数都是在内部通过函数Currying实现的。

##### Fisrt Class（一等公民）
* 可以用变量命名
* 可以提供给过程作为参数
* 可以由过程作为结果返回
* 可以包含在数据结构中


### LOP范式
LOP范式的基本思想是从问题出发，先创建一门描述领域模型的DSL，再用DSL去解决问题，它具有高度的声明性和抽象性。SQL、make file、CSS等DSL都可以被认为是LOP的具体实例。
LOP是一种面向领域的，高度声明式的编程方式，它的抽象维度与领域模型的维度完全一致。LOP能让程序员从复杂的实现细节中解脱出来，把关注点集中在问题的本质上，从而提高编程的效率和质量。

#### 外部的DSL
典型的例子有Protocol Buffer，avro。

1. 优点：可以自由设计语法
2. 缺点：需要为其单独开发编译器或解释器

#### 内部的DSL
例如：[Korma](http://sqlkorma.com/)，[Compojure](https://github.com/weavejester/compojure)

1. 优点：不用单独开发编译器或解释器
2. 缺点：无法自由设计语法

这里要重点说下Lisp，Lisp并不限制你用S表达式来表达什么语义，同样的S表达式语法可以表达各种不同领域的语义，这就是语法和语义解耦。如果说普通语言的刚性源于“语法和语义紧耦合”，那么Lisp的柔性正是源于“语法和语义解耦”！“语法和语义解耦”使得Lisp可以随意地构造各种领域的DSL，而不强制用某一种范式或是领域视角去分析和解决问题。本质上，Lisp编程是一种超越了普通编程范式的范式。
实际上，LISP几乎可以支持任何的编程范型


### 编程范型本质

归根结底，编程是寻求一种机制，将指定的输入转化为指定的输出。三种范式对此提供了截然不同的解决方案：

命令式把程序看作一个自动机，输入是初始状态，输出是最终状态，编程就是设计一系列指令，通过自动机执行以完成状态转变；
函数式把程序看作一个数学函数，输入是自变量，输出是因变量，编程就是设计一系列函数，通过表达式变换以完成计算；
逻辑式把程序看作一个逻辑证明，输入是题设，输出是结论，编程就是设计一系列命题，通过逻辑推理以完成证明。
绘成表格如下：

范式  | 程序   |  输入  | 输出  | 程序设计 | 程序运行 
----- | ----- | ----- | ----- | ----- | ----- 
命令式  | 自动机   | 初始状态 | 最终状态 | 设计指令 | 命令执行 
函数式  | 数学函数 | 自变量 | 因变量 | 设计函数 | 表达式变换 
逻辑式  | 逻辑证明 | 题设 | 结论 | 设计命题| 逻辑推理 


## 语言与生态系统

### 大公司和基金会主导
例如Java，他们会告诉你，多重继承是邪恶的，因为大家都这么说; 运算符重载是邪恶的，诸如此类。我甚至有点模糊地知道为什么是邪恶的，但实际上不知道。后来我明白了，这些都不邪恶，不是烂玩意儿，烂的是开发者。

### 社区主导语言的发展方向
语法灵活性高，开发者们共同参与，沉淀出好的实践习惯，一起推动语言和社区向前发展。

## 编程语言的常见特性


### 类型推断
对任何语言，具体是哪些地方有必要加上类型标记呢？其实有一个很简单的方法来判断：观察信息进出函数的“接口”，把这些接口都做上标记。直观一点说，函数就像是一个电路模块，只要我们知道输入和输出是什么，那么中间的导线里面是什么，我们其实都可以推出来。类型推导的过程，就像是模拟这个电路的运行。这里函数的输入就是参数，输出就是返回值，所以基本上把这两者加上类型标记，里面的局部变量的类型都可以推出来。另外需要注意的是，如果函数使用了全局变量，那么全局变量就是函数的一个“隐性”的输入，所以如果程序有全局变量，都需要加上类型标记。

### Structural subtyping vs Nominal Subtyping
Go语言中，只要有Interface中定义的方法，就算实现了该接口，不声不响地把静态语言的Duck Type给做了！
Swift尽管用的是Nominal Subtyping，但是swift中有extension，可以在类型定义后，再声明class实现protocol，虽然繁琐点，但依然不失灵活性。
动态语言如Ruby，Python，JavaScript，一般不需要考虑这些，因为他们天然就支持duck type。

### 闭包
在计算机科学中，闭包（Closure）是词法闭包（Lexical Closure）的简称，是引用了自由变量的表达式（通常是函数）。这些被引用的自由变量将和这个函数一同存在，即使已经离开了创造它的环境也不例外。
词法作用域(lexical scope)等同于静态作用域(static scope)。所谓的词法作用域其实是指作用域在词法解析阶段既确定了，不会改变。

闭包的数据结构可以定义为，包含一个函数定义 f 和它定义时所在的环境 (struct Closure (f env))

1. 全局函数是一个有名字但不会捕获任何值的闭包。
2. 嵌套函数是一个有名字并可以捕获其封闭函数域内值得闭包。
3. Lambda(闭包表达式)是一个利用轻量级语法所写的可以捕获其上下文中变量值的匿名闭包。

#### 什么是Lambda Calculus？
现在让我们过渡到一种更强大的语言：lambda calculus。它虽然名字看起来很吓人，但是其实非常简单。它的三个元素分别是是：变量，函数，调用。用传统的表达法，它们看起来就是：
变量：x
函数：λx.t
调用：t1 t2

每个程序语言里面都有这三个元素，只不过具体的语法不同，所以你其实每天都在使用 lambda calculus。用 Scheme 作为例子，这三个元素看起来就像：
变量：x
函数：(lambda (x) e)
调用：(e1 e2)

lambda calculus 的程序和机器有这样的一一对应关系：一个变量就是一根导线。一个函数就是某种电子器件的“样板”，有它自己的输入和输出端子，自己的逻辑。一个调用都是在设计中插入一个电子器件的“实例”，把它的输入端子连接到某些已有的导线，这些导线被叫做“参数”。所以一个 lambda calculus 的解释器实际上就是一个电子线路的模拟器。

关于lambda演算的相关知识，可以参考我之前的2篇文章。

* [Lambda演算之自然数(Clojure描述)](http://jameszhan.github.io/pdl/2014/09/10/lambda-church-number.html)
* [Lambda演算之Y-Combinator的推导(Clojure描述)](http://jameszhan.github.io/pdl/2014/09/18/lambda-y-combinator.html)

闭包 vs 函数指针?

### 垃圾回收
1. 标记清除(根可达)
2. 复制收集(根可达并有效利用空间)
3. 引用计数

### Mixin
Ruby 优雅的Mixin方案

~~~ruby
module Foo
    def foo
        "foo"
    end
end
module Bar
    def bar
        "bar"
    end
end
class Demo
    include Foo, Bar
end
~~~

Python，C++允许多重继承。
Java8 也支持接口方法有默认实现（感觉怪怪的，不过好歹也是一种进步）

### Open Class

* Ruby

~~~ruby
class Numeric
    def square
        self * self
    end
end
3.square
~~~

* Python

~~~python
class int(int):
    def square(self):
        return self * self

int(3).square()
~~~

* Swift

~~~swift
extension Int {
    func square(){
        self * self
    }
}
3.square()
~~~

* C#

~~~c#
namespace ExtensionMethods {
    public static class MyExtensions {
        public static int square(this Int32 value) {
            return value * value;
        }
    }
}
using ExtensionMethods;
3.square
~~~

### 多返回值函数

### Optional
optional 作为一个非常关键的特性加入到了Swift当中，经过Guava的实践，Optional也被正式引入了Java8，配合上Stream API也可以摆脱恼人的不断的判空逻辑。

~~~swift
puts person.contact?.address?.city!
~~~
Ruby默认也不支持Optional，但是要加入该功能也非常简单。

~~~ruby
class Optional
  def initialize(value)
    @value =  value
  end

  def method_missing(method, *args, &block)
    if @value != nil
      @value.send method, *args, &block
    else
      if method.to_s =~ /^.+!$/
        nil
      else
        Optional.new(nil)
      end
    end
  end
end

require './optional'

class Module

  def define_attr(*attrs)
    attrs.each{|attr| define_attr_internal attr }
  end

  private
    def define_attr_internal(attr)
      if attr.to_s =~ /^[\w_]+$/
        class_eval do

          define_method "#{attr}=" do |value|
            instance_variable_set("@#{attr}", value)
          end

          define_method "#{attr}" do
            instance_variable_get("@#{attr}")
          end

          define_method "#{attr}?" do
            Optional.new(self.send attr.to_sym)
          end

          define_method "#{attr}!" do
            val = self.send attr.to_sym
            if val
              val
            else
              raise Error.new("#{attr} is not found")
            end
          end

        end
      else
        puts "Invalid attr name #{attr}"
      end
    end

end
class Person
  define_attr :contact
end

class Contact
  define_attr :address
end

class Address
  define_attr :province, :city, :street
end

addr = Address.new
addr.province = 'Guangdong'
addr.city = 'Shenzhen'
addr.street = '699'

contact = Contact.new
contact.address = addr

person = Person.new
person.contact = contact

person2 = Person.new

puts person2.contact?.address?.city!
puts person.contact?.address?.city!
~~~




## 元编程与DSL

### 元编程

元编程作为超级范式的一个体现是,它能提升语言的级别。
如果说 OOP 的关键在于构造对象的概念,那么 LOP 的关键在于构造语言的语法。
既然有重复的代码,不能从语法上提炼,不妨退一步从文字上提炼。
元程序将程序作为数据来对待,能自我发现、自我赋权和自我升级,有着其他 程序所不具备的自觉性、自适应性和智能性,可以说是一种最高级的程序。

1. 元编程是编写、操纵程序的程序。在传统的编程中,运算是动态的,但 程序本身是静态的;在元编程中,二者都是动态的。
2. 元编程能减少手工编程,突破原语言的语法限制,提升语言的抽象级别 与灵活性,从而提高程序员的生产效率。
3. 元编程有诸多应用:许多开发工具、框架引擎之类的基础软件都有自动 生成源代码的功能;创造 DSL 以便更高效地处理专门领域的业务;自动 生成重复代码;动态改变程序的语句、函数,类,等等。
4. IDE 下自动生成的代码通常局限性大且可读性差,小操作可能造成的源 码上的大差异,削弱了版本控制的意义。用自编的无需人机交互的元程 序来生成代码,只须将元程序的数据来源版本化,简明而直观。同时由 于元程序可以随时修改,因此局限性小,更加灵活。
5. 语言导向式编程(LOP)通过创建一套专用语言 DSL 来编写程序。相比 通用语言,DSL 更简单、更抽象、更专业、更接近自然语言和声明式语 言、开发效率更高,同时有助于专业程序员与业务分析员之间的合作。
6. 语言导向式编程一般通过元编程将专用语言转化为通用语言。
7. 产生式编程与静态元编程都能自动生成源代码。产生式编程强调代码的 生成,元编程强调生成代码的可执行性。此外,动态元编程并不生成源 代码,但能在运行期间修改程序。
8. 元程序将程序作为数据来对待,有着其他程序所不具备的自觉性、自适 应性和智能性,可以说是一种最高级的程序。


#### 常见的元编程工具

##### 模板元编程

C++模板是一个非常强大的元编程工具，配上预处理宏，其几乎可以伪装成任何形式的DSL，当然要稍微受一点语法的限制。

##### 万能的eval

Python, JavaScript都只含有全局的eval，只能解析字符串，尽管也可以完成想要的功能，确是相当不便和不安全。
Ruby 中不仅有传统的eval，还有class\_eval，instance\_eval，不仅可以解析字符串，还允许执行代码块。
上例中的Ruby Optional的例子就用到了class\_eval，把eval限制在了类的内部。

##### 强大的宏

CLOS（Common Lisp面向对象系统）就是直接用宏编写而成。

Lisp并不真正区分读取期、编译期和运行期。你可以在读取期编译或运行代码，也可以在编译期读取或运行代码，还可以在运行期读取或者编译代码。

S-表达式的实质是用抽象语法树(AST)表达程序，无论是编译时还是运行时，我们都可以修改，注入，加载，或者生成新的程序 — 这些无非是在AST里修改或添加节点而已。我们甚至可以改动或添加新的句法。


##### Read Macro之殇

![clojure_read_macro](http://img1.tbcdn.cn/L1/461/1/bb9e36c175641922375d3613bf736677deaff174)

Read Macro使得程序员可以为一些特定字符定义一些特殊的行为，当碰到该字符后，解释器会先把其展开为S-Expression，以达到简化代码量或者达到某种格式的目的。Read Macro可是编写DSL的利器啊，但正是由于其过于强大，使得LISP分裂成不同的方言，由于各人的约定不一样，代码也比较晦涩难懂，所以在Clojure中就取消了自定义Read Macro的功能，这究竟是一种进步还是倒退呢？

Clojure宏例子
以下两段代码是等价的，利用宏可以很轻松地把嵌套调用转换为Pipeline调用。

~~~clojure
(prn (filter even? (reverse (cons 1 [2 3 4]))))

(->> [2 3 4] (cons 1) reverse (filter even?) prn)
~~~

##### Ruby类宏

Ruby中的宏，功能相比Lisp中宏的用法当然要弱了许多，但是依然可以满足大部分的元编程需求。熟悉ruby的同学肯定都很熟悉attr_accessor，它可以很方便地帮类成员生成set和get方法。

~~~ruby
class Module
  def attr_accessor(*syms)
    syms.each do|sym|
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{sym}
          @#{sym}
        end
        def #{sym}=(val)
          @#{sym} = val
        end
      RUBY_EVAL
    end
  end
end
~~~

##### 动态语言的 method_missing

~~~ruby
class Hasie
  def initialize(hash)
    @hash = hash
  end

  def method_missing(method, *args, &block)
    if @hash.include?(method)
      self.class.__send__ :define_method, method do|*args, &block|
        @hash[method]
      end
      self.__send__(method, *args, &block)
    else
      super
    end
  end

end

hash = {:a => 1, :b => 2}
h = Hasie.new(hash)
puts h.a()
puts h.b()
~~~

python __getattr__  （Python中一切对象上的一切都是属性，很灵活地添加，删除以及重定义，可以玩出各种Trick，不过在代码即数据和Ruby及Lisp还差很远。）

~~~python
class Hasie(object):
    def __init__(self, _hash):
        self.hash = _hash

    def __getattr__(self, name):
        if name in self.hash:
            func = lambda: self.hash[name]
            self.__setattr__(name, func)
            return func
        else:
            raise AttributeError(name)

hash = {'a': 1, 'b': 2}
h = Hasie(hash)
print(h.a())
print(h.b())
~~~


### DSL

#### 外部DSL

* awk是一个很典型外部DSL例子，其语法为 awk 'pattern {action}'，其做的事情非常简单，扫描所有的行，一旦发现符合pattern的行，则执行action。

以下例子用于找出所有sugou.search.com所有来源链接。

~~~sh
less cookie_log | awk '/sugou\.search\.com/{print $13;}' | sort | uniq
~~~

* make 一个更典型的外部DSL例子

~~~makefile
hello:hello.o
    gcc -o hello hello.o
hello.o:hello.c
    gcc -c hello.c
clean:
    rm -f *.o hello
~~~

* 由于Java语言的特性，Java中使用的DSL一般都用XML来描述，例如ANT和Maven，下面看下Maven Project管理例子。

~~~xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <groupId>com.prometheus.shared</groupId>
    <modelVersion>4.0.0</modelVersion>
    <artifactId>kindle</artifactId>
    <version>1.0-SNAPSHOT</version>

    <dependencies>
        <dependency>
            <groupId>com.google.guava</groupId>
            <artifactId>guava</artifactId>
        </dependency>

        <dependency>
            <groupId>org.ow2.asm</groupId>
            <artifactId>asm</artifactId>
            <version>4.2</version>
        </dependency>
    </dependencies>
</project>
~~~


#### 内部DSL
* Clojure Project管理

~~~clojure
(defproject hello-world "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.6.0"]
                 [ring/ring-core "1.3.0"]
                 [ring/ring-jetty-adapter "1.3.0"]])
~~~

* Ruby Gem file

~~~ruby
source 'https://ruby.taobao.org/'

gem 'rails', '4.1.1'

group :development do
  gem 'pry'
end

group :development, :test do
  gem 'rspec-rails'
end

group :test do
  gem 'faker'
  gem 'capybara'
end
~~~


* RSpec例子(是不是很优雅)

~~~ruby
describe Post do
  it { should belong_to(:user) }
  it { should validate_presence_of(:title) }
end
~~~
还是必须遵循Ruby的语法，有点小遗憾！






## 编程语言趋势猜想

### 编写新语言更加简单

程序语言设计者将不需要关注具体的目标机器，也即不需要关心编译后端及代码优化这一块，目标代码将会是某一成熟的虚拟机字节码或者其他语言源文件。

* ClojureScript，CoffeeScript 生成 JavaScript源码
* Scala，Clojure，Groovy 生成 Java字节码
* Swift，Object-C 生成 LLVM字节码

### 语言生态
多语言协同，不要拘泥于编程语言本身，既然行业里面已经有很成熟的解决方案在那里，换一种语言又何妨。每个成熟的语言都有自己的生态，也都有自己擅长的领域。

### 程序员分工更明晰
以往，有经验的程序员设计库和框架，普通程序员开发上层应用，以后的趋势可能是这样的，资深的程序员设计DSL语言的实现，普通的开发人员使用该DSL构建应用。


## 编程语言历史
![pl_history](http://img1.tbcdn.cn/L1/461/1/0964c49a88040dc69666487c6cbb6159d0dfd7e0)

从汇编语言发展到现在，编程语言层出不穷，具体数目已经无法考证，比较流行的至少超过200种以上，上图列出了比较流行编程语言或者是对编程语言产生过重大影响的编程语言。

* 1951 – Regional Assembly Language
* 1952 – Autocode
* 1954 – IPL (LISP语言的祖先)
* 1955 – FLOW-MATIC (COBOL语言的祖先)
* 1957 – FORTRAN (第一个编译型语言)
* 1957 – COMTRAN (COBOL语言的祖先)
* 1958 – LISP
* 1958 – ALGOL 58
* 1959 – FACT (COBOL语言的祖先)
* 1959 – COBOL
* 1959 – RPG
* 1962 – APL
* 1962 – Simula
* 1962 – SNOBOL
* 1963 – CPL (C语言的祖先)
* 1964 – BASIC
* 1964 – PL/I
* 1966 – JOSS
* 1967 – BCPL (C语言的祖先)
* 1968 – Logo
* 1969 – B (C语言的祖先)
* 1970 – Pascal
* 1970 – Forth
* 1972 – C
* 1972 – Smalltalk
* 1972 – Prolog
* 1973 – ML
* 1975 – Scheme
* 1978 – SQL
* 1980 – C++ (既有类的C语言，更名于1983年7月)
* 1983 – Ada
* 1984 – Common Lisp
* 1984 – MATLAB
* 1985 – Eiffel
* 1986 – Objective-C
* 1986 – Erlang
* 1987 – Perl
* 1988 – Tcl
* 1988 – Mathematica
* 1989 – FL
* 1990 – Haskell
* 1991 – Python
* 1991 – Visual Basic
* 1993 – Ruby
* 1993 – Lua
* 1994 – CLOS (ANSI Common Lisp的一部分)
* 1995 – Java
* 1995 – Delphi (Object Pascal)
* 1995 – JavaScript
* 1995 – PHP
* 1996 – WebDNA
* 1997 – Rebol
* 1999 – D
* 2000 – ActionScript
* 2001 – C#
* 2001 – Visual Basic .NET
* 2002 – F#
* 2003 – Groovy
* 2003 – Scala
* 2007 – Clojure
* 2009 – Go
* 2010 - CoffeeScript
* 2011 – Dart
* 2014 - Swift



## 参考资料
* [程序设计语言概念](http://pan.baidu.com/s/1gdHzPQj) 75fh
* [程序设计语言理论基础](http://pan.baidu.com/s/14cRJw) 61f8
* [编程语言实现模式](http://pan.baidu.com/s/1i3mRLyt) riav
* [七周七语言](http://pan.baidu.com/s/11tl3S) l5nx
* [C++模板元编程](http://pan.baidu.com/s/1gdACzIj) pmcs
* [Ruby元编程](http://pan.baidu.com/s/1eQEInPg) o3r7
* [黑客与画家](http://pan.baidu.com/s/1i3gNUPf) e6bu
* [中文版Apple官方Swift教程](https://github.com/numbbbbb/the-swift-programming-language-in-chinese)
* [LLVM](http://llvm.org/)






