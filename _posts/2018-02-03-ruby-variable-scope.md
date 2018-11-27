---
layout: post
title:  "理解 Ruby 中的变量作用域"
author: 詹子知(James Zhan)
date:   2018-02-03 22:00:00
category: ruby
tags: [ruby, metaprogramming, dsl, pdt]
---

在冯·诺依曼计算机体系结构的内存中，变量的属性可以视为一个六元组：（名字，地址，值，类型，生命期，作用域）。地址属性具有明显的冯·诺依曼体系结构的色彩，代表变量所关联的存储器地址。类型规定了变量的取值范围和可能的操作。生命期表示变量与某个存储区地址绑定的过程。根据生命期的不同，变量可以被分为四类：静态、栈动态、显式堆动态和隐式堆动态。作用域表征变量在语句中的可见范围，主要分为静态作用域和动态作用域两种。

作用域是所有编程语言都需要了解的基础概念之一，它是是为了解决开发过程中变量名冲突发展起来的概念。

## **Ruby** 变量

**Ruby** 中的变量主要有以下四种。

- 局部变量（a_var）: 可见范围取决于作用域。
- 全局变量（$a_var）：在程序的任何地方可见。
- 实例变量（@a_var）：对定义该变量的类的实例及其实例方法可见，但不可以直接被类使用。
- 类变量（@@a_var）：仅对定义该类变量的类及其子类可见。

## 局部变量

> `Kernel#local_variables` 方法可以方便我们查看当前作用域中定义了哪些变量。


```ruby
begin
  puts a_var              # NameError，需要先声明才可以访问
rescue NameError => e
  puts "#{e.message}\nlocals is #{local_variables}"
end
```

    undefined local variable or method `a_var' for main:Object
    locals is [:e, :_oh, :_ih, :title]


**Ruby** 语言是赋值即变量声明的语言，他没有与 **JavaScript** 语言的 `var x` 和 **Java** 的 `String str` 相当的变量声明。只能通过赋值语句来声明变量，但是却不需要该赋值语句真正被执行。


```ruby
if false
  a_var = 100
end

puts a_var.nil?
```

    true


### Scope Gates

每个 **Ruby** 作用域包含一组绑定，并且不同的作用域之间被 **Scope Gate** 分割开来。**Scope Gate** 的作用是关闭前一个作用域，同时打开一个新的作用域。**Ruby** 中使用 `class`，`module` 或 `def` 关键字来隔离作用域，也就是充当 **Scope Gate**。

先来看个例子：


```ruby
x = 1
def change_x
  x = 2
end

change_x
x
```




    1




```ruby
%%file change_x.py

x = 1
def change_x():
  x = 2

change_x()
print("x = {0}".format(x))
```

    Writing change_x.py



```ruby
puts `python change_x.py`
```

    x = 1
    


如你所料，`x` 的值并没有真正被修改。这和 **Python** 表现是一致的，但是其深层的原理却有比较大的差别。

在 **Python** 中，`change_x` 是一个闭包，它可以看到外部的 `x`，之所以没有修改成功，是因为 `change_x` 重新定义了本地变量 `x`，并把 `2` 赋值给了 `x`。

在 **Ruby** 中，`change_x` 则是打开了一个全新的作用域，它是无法访问到外部的变量 `x` 的。


```ruby
%%file check_x.py

x = 1
def check_x():
  print("I can see x = {0} in check_x.".format(x))

check_x()
```

    Writing check_x.py



```ruby
puts `python check_x.py`
```

    I can see x = 1 in check_x.
    


我们再来看一个多层 **Scope Gate** 的例子：


```ruby
main0 = 'main0'

module MyModule
  module1 = 'module1'
  puts "enter MyModule locals: #{local_variables}"
  
  class MyClass
    class2 = 'class2'
    puts "enter MyClass locals: #{local_variables}"
    
    def my_method
      method_3 = 'method3'
      puts "my_method locals: #{local_variables}"
    end
    
    puts "exit MyClass locals: #{local_variables}"
  end
  
  puts "exit MyModule locals: #{local_variables}"
end
    
obj = MyModule::MyClass.new
obj.my_method
obj.my_method
  
puts "main locals: #{local_variables}"
```

    enter MyModule locals: [:module1]
    enter MyClass locals: [:class2]
    exit MyClass locals: [:class2]
    exit MyModule locals: [:module1]
    my_method locals: [:method_3]
    my_method locals: [:method_3]
    main locals: [:main0, :obj, :_i7, :_7, :_i6, :_6, :_i5, :_5, :_i4, :_4, :_i3, :_3, :x, :_i2, :_2, :a_var, :_i, :_ii, :_iii, :_, :__, :___, :_i1, :_1, :e, :_oh, :_ih, :title]


容易看出程序打开了五个独立的作用域

- 顶级作用域（`main0` 所在的作用域）
- 进入 `MyModule` 时创建的作用域
- 进入 `MyClass` 时创建的作用域
- 第一次调用 `my_method()` 方法时创建的一个作用域
- 第二次调用 `my_method()` 方法时创建的一个作用域

如何知道每次调用同一方法时会重新创建新的作用域而不是重用已有的，我们通过一个程序来验证。


```ruby
class MyClass
  def my_method
    v = rand(1..100)
    puts "my_method locals: #{local_variables}"
    binding
  end 
end

obj = MyClass.new
binding1 = obj.my_method
binding2 = obj.my_method

puts "v in binding1 is #{binding1.local_variable_get(:v)}"
puts "v in binding2 is #{binding2.local_variable_get(:v)}"

binding1.local_variable_set(:v2, 1)

puts "binding1 variables is #{binding1.local_variables}"
puts "binding2 variables is #{binding2.local_variables}"
```

    my_method locals: [:v]
    my_method locals: [:v]
    v in binding1 is 25
    v in binding2 is 36
    binding1 variables is [:v2, :v]
    binding2 variables is [:v]


`class` / `module` 与 `def` 之间还有一点微妙的差别，在类和模块定义中的代码会被立即执行，相反，方法定义中的代码只有在方法被调用的时候才会被执行。

### 顶级上下文（Top Level Context）

当开始运行 **Ruby** 程序时，**Ruby** 虚拟机会创建一个名为 `main` 的对象作为当前对象，这个对象被称为顶级上下文，这个名字的由来是因为这时处在调用栈的顶层，这时要么还没调用任何方法，要么调用的所有方法都已经返回了。


```ruby
puts self
puts self.class
puts local_variables
```

    main
    Object
    [:_i9, :_9, :binding1, :binding2, :_i8, :_8, :main0, :obj, :_i7, :_7, :_i6, :_6, :_i5, :_5, :_i4, :_4, :_i3, :_3, :x, :_i2, :_2, :a_var, :_i, :_ii, :_iii, :_, :__, :___, :_i1, :_1, :e, :_oh, :_ih, :title]


我们现在运行代码的作用域就是顶级实例变量 `main` 所在的作用域。

### 词法作用域

词法作用域(lexical scope)也叫静态作用域(static scope)。它其实是指作用域在词法解析阶段既确定了，不会改变。在 每个 **Scope Gate** 内部，**Ruby** 局部变量遵循词法作用域规则，代码块的开始和结束会开启和关闭一个新的词法作用域。


```ruby
module CleanRoom2
  
  outer1 = lambda do
    outer1_v = 0
    inner1 = lambda do
      inter1_v = 0
      local_variables
    end
  end

  outer2 = lambda do
    outer2_v = 0
    inner2 = lambda do 
      inner2_v = 0
      outer1.call.call
    end
  end

  outer2.call.call
end
```




    [:inter1_v, :outer1_v, :inner1, :outer1, :outer2]



可以看到 `inner1` 是在 `outer1` 中定义，调用是在 `inner2` 块中，可以看到在 `inner1` 中的可见的变量有定义在 `CleanRoom` 中的所有变量`[:outer1, :outer2]`，定义在 `outer1` 中的 `[:outer1_v, :inner1]` 和定义在 `inner1` 中的 `[:inner1_v]`。尽管执行是在 `outer2` 和 `inner2` 的内部，但是 `inner1` 并不能访问它们的变量定义。

通俗地说，代码块会在定义时获取周围的绑定，也可以在代码块中定义额外的绑定，但这些绑定会在块结束时消失。


```ruby
module CleanRoom
  
  outer1 = lambda do
    outer1_v = 0
    inner1 = lambda do
      inter1_v = 0
      puts "inner1 locals: #{local_variables}"
    end
    puts "outer1 locals: #{local_variables}"
    inner1
  end
  
  puts "CleanRoom locals: #{local_variables}"

  outer2 = lambda do
    outer2_v = 0
    inner2 = lambda do 
      inner2_v = 0
      outer1.call.call
    end
  end

  outer2.call.call
end
```

    CleanRoom locals: [:outer1, :outer2]
    outer1 locals: [:outer1_v, :inner1, :outer1, :outer2]
    inner1 locals: [:inter1_v, :outer1_v, :inner1, :outer1, :outer2]


在代码块中，声明变量前，总是先往上查找上层环境是不是已经有该变量，如有，则直接重用，若没有则在当前块中声明该变量。


```ruby
def foo()
  x = 'old'
  lambda do 
    x = 'new' 
  end.call
  x
end

foo()
```




    "new"



### 动态作用域

与词法作用域中作用域是源代码级别上的一块完整独立的范围不同，在动态作用域中，作用域则是进入该作用域开始直至离开这一时间轴上的完整独立的范围。与此相同的特征也体现在其他好多地方。比如，在某处理进行期间，一时改变某变量的值随后将原值返回的代码编写方式就相当于创建了自己专属的动态作用域。又如，异常处理与动态作用域也很相似，函数抛出异常时的处理方式受到调用函数的 try/ catch语句的影响。

- 词法作用域：讨论代码的组织结构上的抽象，讨论的是“圈地”的问题（形式上的规范）。
- 动态作用域：变量的可见性，完成对信息的隐藏，也就是处理“割据”问题（实际的占有）。

现在局部变量很少会使用动态作用域，因为动态作用域中被改写的值会影响到被调用的函数，因此在引用变量时它是什么样的值，不看调用方的代码是无从得知的。如果只是为了获取调用处的值，完全可以通过参数传递来解决。动态作用域和词法作用域实现上的差别，可以参考[我之前的文章](https://www.atatech.org/articles/33571#7)。  

由于 **Ruby** 局部变量不支持动态作用域，下面的例子，我们使用 **Perl** 语言来演示，它同时支持词法作用域和动态作用域。


```ruby
%%file dynamic_scope.pl
sub invoker {
    local $x = 'invoker';
    &func();
}

sub invoker2 {
    local $x = 'invoker2';
    &func();
}

$x = 'global';
sub func {
    print "$x\n";
}

invoker();
invoker2();
```

    Writing dynamic_scope.pl



```ruby
puts `perl dynamic_scope.pl`
```

    invoker
    invoker2
    


## 全局变量


```ruby
global_variables
```




    [:$_, :$~, :$;, :$-F, :$@, :$!, :$SAFE, :$&, :$`, :$', :$+, :$=, :$KCODE, :$-K, :$,, :$/, :$-0, :$\, :$stdin, :$stdout, :$stderr, :$>, :$<, :$., :$FILENAME, :$-i, :$*, :$:, :$-I, :$LOAD_PATH, :$", :$LOADED_FEATURES, :$?, :$$, :$VERBOSE, :$-v, :$-w, :$-W, :$DEBUG, :$-d, :$0, :$PROGRAM_NAME, :$-p, :$-l, :$-a, :$fileutils_rb_have_lchmod, :$fileutils_rb_have_lchown, :$my_var]



**Ruby** 中只要变量名称以 `$` 开头，这个变量就是全局变量。全局变量可以再任何作用域中访问。


```ruby
def scope1
  $my_var = 100
end

def scope2
  puts "$my_var is #{$my_var}"
end

scope2
scope1
scope2

global_variables
```

    $my_var is 100
    $my_var is 100





    [:$_, :$~, :$;, :$-F, :$@, :$!, :$SAFE, :$&, :$`, :$', :$+, :$=, :$KCODE, :$-K, :$,, :$/, :$-0, :$\, :$stdin, :$stdout, :$stderr, :$>, :$<, :$., :$FILENAME, :$-i, :$*, :$:, :$-I, :$LOAD_PATH, :$", :$LOADED_FEATURES, :$?, :$$, :$VERBOSE, :$-v, :$-w, :$-W, :$DEBUG, :$-d, :$0, :$PROGRAM_NAME, :$-p, :$-l, :$-a, :$fileutils_rb_have_lchmod, :$fileutils_rb_have_lchown, :$my_var]



全局变量的问题在于系统中的任何部分都可以修改它们，我们几乎没法追踪谁把他们改成了什么。因此，基本的原则是：如非必要，尽可能少使用全局变量。

## 实例变量

**Ruby** 中只要变量名称以 `@` 开头，这个变量就是实例变量，它总是属于某个实例。实例变量作用域本质是**动态作用域**，是进入该作用域开始直至离开这一时间轴上的完整独立的范围，也就进入这个实例开始，到离开这个实例结束。


```ruby
@a_var = 1
puts "self: #{self}, instance_variables: #{instance_variables}，@a_var = #{instance_variable_get(:@a_var)}"
class AClass
  @a_var = 2
  puts "self: #{self}, instance_variables: #{instance_variables}，@a_var = #{instance_variable_get(:@a_var)}"
  
  def a_method(init_var)
    @a_var = init_var
    puts "self: #{self}, instance_variables: #{instance_variables}，@a_var = #{instance_variable_get(:@a_var)}"
  end
  
  puts "self: #{self}, instance_variables: #{instance_variables}，@a_var = #{instance_variable_get(:@a_var)}"
end
puts "self: #{self}, instance_variables: #{instance_variables}，@a_var = #{instance_variable_get(:@a_var)}"


obj = AClass.new
obj2 = AClass.new

obj.a_method(3)
obj2.a_method(6)

puts self.instance_variable_get(:@a_var)
puts AClass.instance_variable_get(:@a_var)
puts obj.instance_variable_get(:@a_var)
puts obj2.instance_variable_get(:@a_var)
```

    self: main, instance_variables: [:@a_var, :@my_var]，@a_var = 1
    self: AClass, instance_variables: [:@a_var]，@a_var = 2
    self: AClass, instance_variables: [:@a_var]，@a_var = 2
    self: main, instance_variables: [:@a_var, :@my_var]，@a_var = 1
    self: #<AClass:0x007fefe3a04bc0>, instance_variables: [:@a_var]，@a_var = 3
    self: #<AClass:0x007fefe3a04b98>, instance_variables: [:@a_var]，@a_var = 6
    1
    2
    3
    6


一般地，我们可以认为 **Ruby** 所有的东西都是对象，也就是 `VALUE` 的实例，包括 `Class` 和 `Module`，接下来我们来分析一下上面的代码。

代码开始，我们是在顶级上下文对象 `main` 当中，`@a_var = 1` 也就是给 `main` 对象声明一个 `@a_var` 的一个实例变量。

执行完 `class AClass` 后，进入对象 `AClass` (`Class` 的实例)，`@a_var = 2` 也就是给 `AClass` 对象声明一个 `@a_var` 的一个实例变量。

`def a_method ... end` 为AClass新增一个实例方法 `a_method`，注意，方法定义中的代码块这个时候并不会被执行。

继续执行，执行完 `end` 后，离开对象 `AClass` 重新进入对象 `main`。

`obj = AClass.new` 创建 `AClass` 实例 `obj`，`obj.a_method(3)` 执行过程简单来说，是先进入对象 `obj`，接着执行 `a_method` 中的代码块，最后退出对象 `obj`，重新进入 `main`。

**Ruby** 中的所有方法都是实例方法，执行方法的时候它总有一个接收者，也就是执行该方法的当前实例，如果不指定接收者，隐含的接收者总是 `self`。


```ruby
def my_method1
  @my_var = 1
  puts "self: #{self} with instance_variables: #{instance_variables}"
end

def my_method2
  puts @my_var
  puts "self: #{self} with instance_variables: #{instance_variables}"
end

my_method1
my_method2
```

    self: main with instance_variables: [:@a_var, :@my_var]
    1
    self: main with instance_variables: [:@a_var, :@my_var]


实例变量的作用域属于实际占有它的对象，一旦进入该对象，该对象的所有方法都可以对它进行访问，而不用管它定义在哪里。


```ruby
class ASuper
  def initialize()
    @my_var = 100
  end
end

class ASubClass < ASuper
  def show_my_var
    @my_var
  end
end

ASubClass.new.show_my_var
```




    100



## 类变量

**类变量** 顾名思义就是类独有的变量，但是其作用域，不同语言之间还是有一些差别。

**Java** 中，类变量可以被类本身，类实例访问（不推荐），不能被子类本身或子类实例访问，读取修改的都是同一变量。

**Python** 中，类变量可以被类本身，子类，类实例及子类实例访问，但是修改只可以通过类本身来修改，通过子类，类实例，或者子类实例赋值，不会修改类变量本身，等价于为子类，类实例，子类实例创建一个同名的变量。

**Ruby** 中，类变量的作用域与 **Python** 比较类似，但是对同名修改的处理方式不一样。


```ruby
class A
  @@a_var = 6
  
  class AA
    @@aa_var = 1
    
    def self.show
      puts "#{self} variables: #{class_variables}"
    end
    puts "#{self} variables: #{class_variables}"
  end
  
  def self.show
    puts "#{self} variables: #{class_variables}"
  end
  
  puts "#{self} variables: #{class_variables}"
end

A.show
A::AA.show
```

    A::AA variables: [:@@aa_var]
    A variables: [:@@a_var]
    A variables: [:@@a_var]
    A::AA variables: [:@@aa_var]


从这个例子可以看出，类变量是类间隔离的，即使它们存在嵌套定义关系。


```ruby
class B < A
  
  class BB < AA
    puts "#{self} variables: #{class_variables}"
  end
  
  puts "#{self} variables: #{class_variables}"
end

B.show
B::BB.show
```

    B::BB variables: [:@@aa_var]
    B variables: [:@@a_var]
    B variables: [:@@a_var]
    B::BB variables: [:@@aa_var]


父类中定义的类变量，子类中可以访问。


```ruby
class C
  @@c_var = 1
  
  def self.show_c
    @@c_var
  end
  
end

class D < C
  def self.set_c(v)
    @@c_var = v
  end
end

puts C.show_c
puts D.show_c

D.set_c(11)

puts C.show_c
puts D.show_c
```

    1
    1
    11
    11


可以看到，子类中可以修改父类中的类变量，初看起来，这也不是什么大问题，我们接着再来看另外的例子。


```ruby
class CC; end

class DD < CC
  @@d_var = 1
  
  def self.show_d
    @@d_var
  end

end

puts DD.show_d
puts CC.class_variables(false)
puts DD.class_variables(false)
```

    1
    [:@@d_var]
    []



```ruby
class CC
  def self.set(v)
    @@d_var = v
  end
end

CC.set(100)
puts DD.show_d

puts CC.class_variables(false)
puts DD.class_variables(false)
```

    100
    [:@@d_var]
    []


调用父类的修改方法，声明了一个同名类变量，居然把子类的同名变量给改了。不仅如此，类变量在继承树的位置也上升到了父类，说明如果继承树上有几个类含有同名类变量，**Ruby** 会强制统一这些同名类变量。

**Ruby** 中类变量陷阱还不止此，我们再来看一个例子：


```ruby
class CCC
  @@c_var = 'C'
end

class DDD
  @@d_var = 'D'
end

class CCC
  def DDD.value
    @@c_var
  end
end

class DDD
  def CCC.value
    @@d_var
  end
end

puts CCC.value
puts DDD.value

puts CCC.class_variables
puts DDD.class_variables
```

    D
    C
    [:@@c_var]
    [:@@d_var]


通过**Open Class**，我们很轻松地打破了类隔离的规则。

我们再来看看类变量与实例之间的关系：


```ruby
class C
  @@value = 'c'
  
  def show
    @@value
  end
  
  def set(v)
    @@value = v
  end
    
end

obj = C.new
puts obj.show
obj.set('new')
puts obj.show
```

    c
    new



```ruby
class CC 
  @@value = 'c'
  
  def self.value
    @@value
  end
  
end

class DD < CC
  def show
    @@value
  end
  
  def set(v)
    @@value = v
  end
end

obj = DD.new
puts obj.show
obj.set('new')
puts obj.show
puts CC.value
```

    c
    new
    new


类实例和子类实例都可以访问和修改类变量，如果使用不小心，特别容易造成错误的修改，错误很难追踪。

正是由于 **Ruby** 类变量的这些特性，特别容易导致错误，尤其是在元编程的时候，所以一般都不推荐在程序中使用类变量。

其实类变量主要的功能还是类间隔离，父子类之间共享类变量其实是没有必要的，上类中 `D` 继承 `C`，只是表明 `D` 的实例也是 `C` 的实例，但是 `D` 和 `C` 之间并没有从属关系，他们都是 `Class` 的实例。

其实 **Ruby** 也可以轻松实现类似 **Java** 类变量的方案，那就是借助实例变量来模拟。


```ruby
class MyClass
  class << self
    
    def val
      @val
    end
    
    def set(v)
      @val = v
    end
    
  end
end

puts MyClass.val
MyClass.set(100)
puts MyClass.val
```

    100
    100


只所以可以这么做，是因为 `MyClass` 本身也是一个对象，它是 `Class` 的实例，因为实例变量只可以被对象自身访问。即便是 `MyClass` 的子类，也不能访问 `@val`。

基于以上的事实，用 **Ruby** 编程的时候，如果不是有特殊的需求，尽量不要使用类变量，尤其是在 **Open Class** 的场景。

更多 Ruby 资料整理，移步[Ruby 编程手札](https://github.com/jameszhan/notes-ruby)