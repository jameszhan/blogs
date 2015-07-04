---
layout: post
title:  "Ruby元编程技巧"
author: 詹子知(James Zhan)
date:   2014-09-01 12:00:00
category: ruby
tags: [ruby, metaprogramming, dsl, pdl]
---
（摘自ruby元编程原书附录）

## 常见惯用法

### A.1 拟态方法（Mimic Methods）

~~~ruby
puts "Hello,world!"
~~~

这里的 puts 实际上是个方法，完整写法

~~~ruby
puts("Hello,world!")
~~~

去掉括号的写法使得它像个关键字，同时也更为简洁，因此称之为拟态方法。

属性的问题：

~~~ruby
class C
    def my_attr=(value)
        @p = value
    end
    def my_attr
        @p
    end
end
obj = C.new
obj.my_attr = 'some value'
obj.my_attr         # => 'some value'
~~~

代码obj.my_attr = 'some value'的功能与代码obj.my_attr=('some value')的功能是相同的，不过前者看起来更清爽。

来自 Camping 的例子，这里的 R 实际上是一个方法，'/help' 是它的参数，返回值是一个 Class的实例。

~~~ruby
class Help < R '/help'
    def get
        # rendering for HTTP GET...
    end
end
~~~


### A.2 空指针保护（Nil Guards）

~~~ruby
a ||= []
~~~

以上代码等价于

~~~ruby
a = a || []
~~~

空指针保护常用于初始化实例变量，看看下面这个类：

~~~ruby
class C
    def initialize(value)
        @a = []
    end
    def elements
        @a
    end
end
~~~

使用空指针保护，可以更简练地重写以上这段代码：

~~~ruby
class C
    def elements
        @a ||= []
    end
end
~~~
上面的代码会在最后它要被访问的时候才进行初始化，这种惯用法被称为**惰性实例变量(Lazy Instance Variable)**。



### A.3 关于方法参数的技巧（Tricks with Method Arguments）

####具名参数(Named Arguments)

当在Ruby中调用方法时，你不得不按照特定的顺序输入参数。如果顺序错误，则会引入一个bug：

~~~ruby
def login(name, password, message)
    #...
end
login('james', 'just doing some administration', '123456') #bug
~~~

当有一大串参数要输入时，这种错误非常常见。
Ruby 2.0 以后，可以使用关键字参数，Ruby 2.0可以使用Hash参数来解决这个问题。

~~~ruby
login(name: 'bill', message: 'just doing some administration', password: '123456')
~~~

#### 参数数组和默认值(Argument Arrays and Default Values)

*操作符可以把多个参数收集到一个数组中；

~~~ruby
def my_method(*args)
    args
end

my_method(1, '2' , 'three' ) # =]]> [1, "2", "three"]
~~~

Ruby 也支持如下参数默认值：

~~~ruby
def my_method(x, y = "a default value" )
    "#{x} and #{y}"
end
my_method("a value" ) # => "a value and a default value"
~~~

#### 混合使用参数的惯用法(Mixing Arguments Idioms)

Ruby 2.0以前

~~~ruby
def my_method(arg, hash)
  lots = hash[:lots] || "default"
  args = hash[:args] || "another"
  hand = hash[:by_hand] || "annoying"
  ...
end
my_method "with", lots: "of", args: "in", by_hand: "form"
~~~

Ruby 2.0以后

~~~ruby
def my_method(arg, lots: "default", args: "another", by_hand: "annoying")
  lots = hash[:lots] || "default"
  args = hash[:args] || "another"
  hand = hash[:by_hand] || "annoying"
  ...
end
my_method "with", lots: "of", args: "in", by_hand: "form"
~~~

### A.4 Self Yield
当给方法传入一个块时，你会期望这个方法通过yield对块进行回调。这种回调有一种有用的变形，就是对象可以把自身传给这个块。下面的例子来自于RubyGems包管理器。

#### 传统写法

~~~ruby
spec = Gem::Specification.new
spec.name = "My Gem name"
spec.version = "0.0.1"
# ...
~~~

#### Self Yield 写法

~~~ruby
spec = Gem::Specification.new do |s|
    s.name = "My Gem name"
    s.version = "0.0.1"
    # ...
end
~~~


#### Gem::Specification 源代码

~~~ruby
module Gem
    class Specification
        def initialize
            yield self if block_given?
            # ...
        end
        #...
    end
end
~~~

#### 来自 tap() 的例子
在Ruby中，长长的方法调用链很普遍

~~~ruby
['a', 'b', 'c'].push('d' ).shift.upcase.next # => "B"
~~~

但是某一步出错，你将不得不如下调试

~~~ruby
temp = ['a' , 'b' , 'c' ].push('d' ).shift
puts temp
x = temp.upcase.next
~~~

这非常笨拙；Ruby 1.9 中引入了 tap() 方法，我们可以这样做

~~~ruby
['a' , 'b' , 'c' ].push('d' ).shift.tap {|x| puts x }.upcase.next
~~~

老版本的 Ruby ，我们也可以很容易的实现一个

~~~ruby
class Object
    def tap
        yield self
        self
    end
end
~~~


### A.5 Symbol#to_proc() 方法
这种有点诡异的法术在Ruby程序员中很流行，请看下面的代码

~~~ruby
names = ['bob' , 'bill' , 'heather' ]
names.map {|name| name.capitalize } # => ["Bob", "Bill", "Heather"]
~~~

更简洁的写法

~~~ruby
names = ['bob' , 'bill' , 'heather' ]
names.map(&:capitalize) # => ["Bob", "Bill", "Heather"]
~~~

当&操作符作用于一个对象时，它会调用该对象的to_proc方法，将其转化为一个proc对象。

~~~ruby
class Symbol
    def to_proc
        Proc.new {|x| x.send(self) }
    end
end
~~~


## 法术手册
### 法术集 (The Spells)

#### 数组参数(Argument Array)
把一组参数压入到一个数组中。

~~~ruby
def my_method(*args)
    args.map {|arg| arg.reverse }
end
my_method('abc' , 'xyz' , '123' ) # =]]> ["cba", "zyx", "321"]
~~~

#### 环绕别名(Around Alias)
从一个重新定义的方法中调用原始的、被重命名的版本。
三个基本步骤：
    1. 通过 alias 对原有方法定义一个别名
    2. 覆写原有方法
    3. 在该方法中调用别名方法
通过此方式可以改写原来方法，又不破坏原有功能。

~~~ruby
class String
    alias :old_reverse :reverse
    def reverse
        "x#{old_reverse}x"
    end
end

"abc".reverse # => "xcbax"
~~~

#### 白板(Blank Slate)
移除一个对象中的所有方法，以便通过method_missing添加幽灵方法。主要目的避免原有类中的方法同新增方法产生冲突。注意以__开头的方法不能移除，比如__send__等。

~~~ruby
class C
    def method_missing(name, *args)
        "a Ghost Method"
    end
end

obj = C.new
obj.to_s # => "#<C:0x357258>"

class C
    instance_methods.each do |m|
        undef_method m unless m.to_s =~ /method_missing|respond_to?|^__/
    end
end

obj.to_s # => "a Ghost Method"
~~~

#### 类扩展(Class Extension)
通过向eigenclass中混入模块来定义类方法（是对象扩展的一个特例）。
扩展的方法存在于eigenclass类中，对类来说就是类方法，对对象实例来说就是单件方法。
提示：一个类，如class C具有双重身份。本身是个类，同时又是Class类的一个实例。类混入实际上是针对他作为Class类的一个实例对象的身份来进行的。
因此类扩展的方式一样适用于对象实例的扩展，那就是对象扩展了。

~~~ruby
class C; end

module M
    def my_method
        'a class method'
    end
end

class << C
    include M
end

C.my_method # => "a class method"
~~~

#### 类扩展混入(Class Extension Mixin)
使一个模块可以通过钩子方法扩展它的包含者。
同上面基本类似，差别主要有：
  1. 通过 extend 方法，避免手工打开 eigenclass (即class << C; end)操作。
  2. 通过 included 钩子方法触发。
  3. 可以同时添加实例方法跟类方法（这个例子没有演示）

基本编写方式：
  1. 定义一个模块，如 MyMixin
  2. 在 MyMixin 中定义一个内部模块，通常叫 ClassMethods，并定义一些方法，这些方法会成为包含者的类方法。
  3. 覆写 MyMixin#included() 方法，extend ClassMethods。

~~~ruby
module M
    def self.included(base)
        base.extend(ClassMethods)
    end

    module ClassMethods
        def my_method
            'a class method'
        end
    end
end

class C
    include M
end
C.my_method # => "a class method"
~~~

#### 类实例变量(Class Instance Variable)
在一个 Class 对象的实例变量中存储类级别的状态。
核心提示：
  1. 这里的class C要当做Class类的一个实例对象看待。普通实例对象如何创建实例变量，类实例对象就如何创建实例变量。
  2. class ... end 实际上是在运行一段代码，不要用常规的关键字理解。
  3. 访问类实例变量，只能通过类方法（因为其 self 就是类名），或者加上类名前缀。

想一想如果我们运行时类名动态变化，如何处理，显然我们还有 eval 工具组（使用 instance_eval ，class_eval，eval 均可）

~~~ruby
class C
    @my_class_instance_variable = "some value"
    def self.class_attribute
        @my_class_instance_variable
    end
end
C.class_attribute # => "some value"
~~~

#### 类宏(Class Macro)
在类定义中使用一个类方法。
就是一个伪装成关键字的类方法。如attr_accessor :a, :b，类宏一般结合类扩展混入技术进行。

~~~ruby
class C; end
class << C
    def my_macro(arg)
        "my_macro(#{arg}) called"
    end
end
class C
    my_macro :x # => "my_macro(x) called"
end
~~~

#### 洁净室(Clean Room)
使用对象作为执行块的上下文环境
实际上就是通过 instance_eval 限定执行块的作用域。

~~~ruby
class CleanRoom
    def a_useful_method(x); x * 2; end
end

CleanRoom.new.instance_eval { a_useful_method(3) } # => 6
~~~

#### 代码处理器(Code Processor)
处理从外部获得的字符串代码

~~~ruby
File.readlines("a_file_containing_lines_of_ruby.txt" ).each do |line|
    puts "#{line.chomp} ==> #{eval(line)}"
end

#>> 1 + 1 ==> 2
#>> 3 * 2 ==> 6
#>> Math.log10(100) ==> 2.0
~~~

#### 上下文探针(Context Probe)
执行块来获取对象上下文中的信息。
其实就是通过 instance_eval 将对象内部的作用域暴露出来。

~~~ruby
class C
    def initialize
        @x = "a private instance variable"
    end
end
obj = C.new
obj.instance_eval { @x } # => "a private instance variable"
~~~

#### 延迟执行(Deferred Evaluation)
在proc或lambda中存储一段代码及其上下文，用于以后执行。

~~~ruby
class C
    def store(&block)
        @my_code_capsule = block
    end
    def execute
        @my_code_capsule.call
    end
end

obj = C.new
obj.store { $X = 1 }
$X = 0
obj.execute
$X # => 1
~~~

#### 动态派发(Dynamic Dispatcher)
在运行时决定调用哪个方法
通过send发送消息，等价于方法调用。但通过send可以发送符号或字符串，灵活性大为增强。

~~~ruby
method_to_call = :reverse
obj = "abc"
obj.send(method_to_call) # => "cba"
~~~

#### 动态方法(Dynamic Method)
在运行时才决定如何定义一个方法
动态方法还有一个特性：不会开启一个新的作用域。
我们知道def，module，class会开启新的作用域，扁平化作用域的办法就是用define_method，Module.new，Class.new等方法调用取代关键字。

~~~ruby
class C
end

C.class_eval do
    define_method :my_method do
        "a dynamic method"
    end
end
obj = C.new
obj.my_method # => "a dynamic method"
~~~

#### 动态代理(Dynamic Proxy)
把不能对应某个方法名的消息转发给另外一个对象。
method_missing结合send技术，另外可以辅助respond_to?谓词。

~~~ruby
class MyDynamicProxy
    def initialize(target)
        @target = target
    end
    def method_missing(name, *args, &block)
        "result: #{@target.send(name, *args, &block)}"
    end
end
obj = MyDynamicProxy.new("a string")
obj.reverse # => "result: gnirts a"
~~~

#### 扁平作用域(Flat Scope)
使用闭包在两个作用域之间共享变量(以下用例不典型)

~~~ruby
class C
    def an_attribute
        @attr
    end
end
obj = C.new
a_variable = 100

# flatscope:
obj.instance_eval do
    @attr = a_variable
end

obj.an_attribute # => 100
~~~

#### 幽灵方法(Ghost Method)
响应一个没有关联方法的消息

~~~ruby
class C
    def method_missing(name, *args)
        name.to_s.reverse
    end
end
obj = C.new
obj.my_ghost_method # => "dohtem_tsohg_ym"
~~~

#### 钩子方法(Hook Method)
通过覆写某个特殊方法来截获对象模型事件。

~~~ruby
$INHERITORS = []
class C
    def self.inherited(subclass)
        $INHERITORS << subclass
    end
end
class D < C
end

class E < C
end

class F < E
end

$INHERITORS # => [D, E, F]
~~~

#### 内核方法(Kernal Method)
在 Kernel 模块中定义一个方法，使之对所有对象都可用。

~~~ruby
module Kernel
    def a_method
        "a kernel method"
    end
end
a_method # => "a kernel method"
~~~

#### 惰性实例变量(Lazy Instance Variable)
当第一次访问一个实例变量时才对之进行初始化。

~~~ruby
class C
    def attribute
        @attribute ||= "some value"
    end
end
obj = C.new
obj.attribute # => "some value"
~~~

#### 拟态方法(Mimic Method)
把一个方法伪装成另外一种语言构件。

~~~ruby
def BaseClass(name)
    name == "string" ? String : Object
end
class C < BaseClass "string" # a method that looks like a class
    attr_accessor :an_attribute # 伪装成关键字的方法
end

obj = C.new
obj.an_attribute = 1 # 伪装成属性的方法
~~~

#### 猴子打补丁(Monkeypatch)
修改已有类的特性。

~~~ruby
"abc".reverse # => "cba"
class String
    def reverse
        "override"
    end
end
"abc".reverse # => "override"
~~~

#### 有名参数(Named Arguments)
把方法参数收集到一个哈希表中，以便通过名字访问（Ruby2.0+直接支持）。

~~~ruby
def my_method(args)
    args[:arg2]
end

my_method(:arg1 => "A" , :arg2 => "B" , :arg3 => "C") # => "B"
~~~

#### 命名空间(Namespace)
在一个模块中定义常量，以防止命名冲突。

~~~ruby
module MyNamespace
    class Array
        def to_s
            "my class"
        end
    end
end
Array.new # => []
MyNamespace::Array.new # => my class
~~~

#### 空指针保护(Nil Guard)
用“或”操作符覆写一个空应用。

~~~ruby
x = nil
y = x || "a value" # => "a value"
~~~

#### 对象扩展(Object Extension)
通过给一个对象 eigenclass 混入模块来定义单件方法。

~~~ruby
obj = Object.new

module M
    def my_method
        'a singleton method'
    end
end

class << obj
    include M
end
obj.my_method # => "a singleton method"
~~~

#### 打开类(Open Class)
修改已有的类

~~~ruby
class String
    def my_string_method
        "my method"
    end
end
"abc".my_string_method # => "my method"
~~~

#### 模式派发(Pattern Dispatch)
根据名字来选择需要调用的方法。

~~~ruby
$x = 0
class C
    def my_first_method
        $x += 1
    end
    def my_second_method
        $x += 2
    end
end

obj = C.new
obj.methods.each do |m|
    obj.send(m) if m.to_s =~ /^my_/
end
$x # => 3
~~~

#### 沙盒(Sandbox)
在一个安全的环境中执行为授信的代码

~~~ruby
def sandbox(&code)
    proc {
        $SAFE = 2
        yield
    }.call
end

begin
    sandbox { File.delete 'a_file' }
rescue Exception => ex
    ex # => #<SecurityError: Insecure operation `delete' at level 2>
end
~~~

#### 作用域门(Scope Gate)
用class，module或def关键字来隔离作用域

~~~ruby
a = 1
defined? a # => "local-variable"

module MyModule
    b = 1
    defined? a # => nil
    defined? b # => "local-variable"
end

defined? a # => "local-variable"
defined? b # => nil
~~~

#### Self Yield
把self传给当前块

~~~ruby
class Person
    attr_accessor :name, :surname
    def initialize
        yield self
    end
end

joe = Person.new do |p|
    p.name = 'Joe'
    p.surname = 'Smith'
end
~~~

#### 共享作用域(Shared Scope)
在同一个扁平作用域的多个上下文中共享变量。

~~~ruby
lambda {
    shared = 10
    self.class.class_eval do
        define_method :counter do
            shared
        end
        define_method :down do
            shared -= 1
        end
    end
}.call

counter # => 10
3.times { down }
counter # => 7
~~~

#### 单件方法(Singleton Method)
在一个对象上定义一个方法，其实是在该对象eigenclass中定义了一个实例方法。

~~~ruby
obj = "abc"

class << obj
    def my_singleton_method
        "x"
    end
end
obj.my_singleton_method # => "x"
~~~

#### 代码字符串(String of Code)
执行一段表示 Ruby 代码的字符串。

~~~ruby
my_string_of_code = "1 + 1"
eval(my_string_of_code) # => 2
~~~

#### 符号到Proc(Symbol To Proc)
把一个符号转换为调用单个方法的代码块。

~~~ruby
[1, 2, 3, 4].map(&:even?) # => [false, true, false, true]
~~~