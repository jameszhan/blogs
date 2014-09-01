# Lambda演算之自然数

λ演算（英语：lambda calculus，λ-calculus）是一套用于研究函数定义、函数应用和递归的形式系统。它由阿隆佐·邱奇和他的学生斯蒂芬·科尔·克莱尼在20世纪30年代引入。这种演算可以用来清晰地定义什么是一个可计算函数。

## λ演算规则
~~~
  <expression> := <name> | <function> | <application>
  <function> := λ<name>.<expression>
  <application> := <expression><expression>
~~~

### α--变换
α变换规则表达的是，被绑定变量的名称是不重要的。
α变换规则陈述的是，若v与w均为变量，E是一个lambda表达式，同时E[v/w]是指把表达式E中的所有的v的自由出现都替换成w，那么在w不是E中的一个自由出现，且如果w替换了v，w不会被E中的λ绑定的情况下，有
  λv.E == λw.E[v/w]
  例如：λx.(λx.x)x <=> λy.(λx.x)y

### β--规约
β规约规则表达的是函数作用的概念，它陈述了所有的E‘的自由出现在E[v/E']中仍然是自由的情况下，有 ((λv.E)E') == E[v/E'] 成立。

### η--变换
η变换表达的是外延性的概念，在这里外延性指的是，两个函数对于所有的参数得到的结果一致，当且仅当它们是同一个函数，η变换可以令 λx.fx和f相互交换，只要x不是f中的自由出现。


## λ演算的应用
在lambda演算系统中，一切事物都可以使用过程来描述。那么在函数式编程系统中，我们需要如何来描述一种类型呢？类型的本质在于它所定义的操作以及操作之间的关系和不变式。类型的实现关键在于满足类型规范的要求，而具体实现是可以变化的，使用者和测试用例都应该只依赖于类型规范而不依赖于具体实现。函数式的类型实现往往和类型规范是直接对应的，简单通用，但可能有性能问题，而命令式的类型实现往往会引入复杂的内部数据结构，但是其优点是高效。这两种实现并不是完全互斥的，有时候可以将二者相结合达到简单与高效的结合。

### 形式定义
在lambda演算中有许多方式都可以定义自然数，但最常见的还是邱奇数，下面是它们的定义：

~~~
  0 := λf.λx.x
  1 := λf.λx.f x
  2 := λf.λx.f (f x)
  3 := λf.λx.f (f (f x))
~~~
以此类推。直观地说，lambda演算中的数字n就是一个把函数f作为参数并以f的n次幂为返回值的函数。换句话说，邱奇整数是一个高阶函数 -- 以单一参数函数f为参数，返回另一个单一参数的函数。

~~~
  SUCC  := λn.λf.λx.f (n f x)
  PLUS  := λm.λn.m SUCC n
  PLUS  := λm.λn.λf.λx.m f (n f x)
  MULT  := λm.λn.m (PLUS n) 0
  MULT  := λm.λn.λf.m (n f)
  PRED  := λn.λf.λx.n (λg.λh.h (g f)) (λu.x) (λu.u)
  SUB   := λm.λn.n PRED m
  EXP   := λa.λn.n a
~~~


### Clojure描述

~~~clojure
(defn zero [f] (fn [x] x))
(defn succ [n] (fn [f] (fn [x] (f ((n f) x)))))
~~~
其实只要定义出zero和succ两个，我们就可以定义出所有的自然数。

你可以使用如下的方式给出zero和succ的定义。
~~~clojure
(defn zero [f x] x)
(defn succ [n] (fn [f x] (f (n f x))))
~~~
是不是简洁了许多，但是不要被表面的简洁所迷惑，lambda演算基于的都是单参数的函数，这样函数可以很方便地得到一致性的处理。如果你使用Haskell来使用上述定义，这不会有什么问题，
因为其底层本身就是使用currying来描述多参函数的。然而Clojure却是严格区分函数的入参个数的，一旦你使用上述定义，自然数的许多操作将无法很容易地推论得到。事实上，使用currying，
我们可以很方便地使用单参函数模拟多参函数，但是反过来却不一定。有兴趣的朋友可以参考：[多参描述自然数](https://raw.githubusercontent.com/jameszhan/rhea/master/codes/clojure/calculation/church-number.clj).

我们可以根据代数变换的形式得出one, two, three的定义。
~~~
one = (succ zero)
    = (fn [f] (fn [x] (f (((zero) f) x))))
    = (fn [f] (fn [x] (f ((fn [x] x) x))))
    = (fn [f] (fn [x] (f x)))

two = (succ one)
    = (fn [f] (fn [x] (f (((one) f) x))))
    = (fn [f] (fn [x] (f ((fn [x] (f x)) x))))
    = (fn [f] (fn [x] (f (f x))))
~~~

根据以上的推导过程，我们可以很容易地发现规律，我们可以很发现数字n的定义为(defn n [f] (fn[x] (f...(f x))))，其中(f...(f x))中有n个f。
~~~clojure
(defn one [f] (fn [x] (f x)))
(defn two [f] (fn [x] (f (f x))))
(defn three [f] (fn [x] (f (f (f x)))))
~~~

根据定义，我们可以很容易地给出plus，mult，exp的定义，因为+，*，**在自然数的操作里面是封闭的，所以其定义还是相当简洁和直观的。
~~~clojure
(defn plus [m] (fn [n] (fn [f] (fn [x] ((m f) ((n f) x))))))
(defn mult [m] (fn [n] (fn [f] (n (m f)))))
;(defn mult [m n] (fn [f] (fn [x] ((n (m f)) x))))
(defn exp [a] (fn [n] (n a)))
;(defn exp [a] (fn [n] (fn [f] (fn [x] (((n a) f) x)))))
~~~
1. plus可以理解为，对于初始值x，先对于其调用n次f，再对其运算后的结果再调用m次f，总共调用了(m + n)次f。
2. mult可以理解为，把(m f)展开n次，最终作用于x上，总共调用了(m * n)次f。
3. exp可以理解为，把a展开n次，得到(a (a...(a)))，当给定函数f和初始值x时，可以很容易得出其总共调用了(a ** n)次f。

前驱和减法的定义不是很直观，毕竟其在自然数域里面操作并不封闭。
~~~clolure
(defn pred [n]
  (fn [f]
    (fn [x]
      (((n (fn [g] (fn [h] (h (g f)))))
         (fn [u] x))
        (fn [u] u)))))

(defn sub [n] (fn [m] ((m pred) n)))
~~~

通过下面的函数，我们很容易把我们的邱奇数转换为我们熟悉的自然数表示。
~~~clojure
(defn church->int [n] ((n (fn [x] (inc x))) 0))
~~~

### 用例演示

~~~clojure
(assert (= (church->int zero) 0))
(assert (= (church->int one) 1))
(assert (= (church->int two) 2))
(assert (= (church->int three) 3))

(println "SUCC")
(assert (= (church->int (succ zero)) 1))
(assert (= (church->int (succ one)) 2))
(assert (= (church->int (succ two)) 3))

(println "PLUS")
(assert (= (church->int ((plus zero) zero)) 0))
(assert (= (church->int ((plus one) one)) 2))
(assert (= (church->int ((plus one) two)) 3))
(assert (= (church->int ((plus three) three)) 6))

(println "MUL")
(assert (= (church->int ((mult zero) three)) 0))
(assert (= (church->int ((mult one) two)) 2))
(assert (= (church->int ((mult one) three)) 3))
(assert (= (church->int ((mult three) two)) 6))
(assert (= (church->int ((mult three) (succ two))) 9))

(println "EXP")
(assert (= (church->int ((exp zero) zero)) 1))
(assert (= (church->int ((exp one) zero)) 1))
(assert (= (church->int ((exp two) zero)) 1))
(assert (= (church->int ((exp two) three)) 8))
(assert (= (church->int ((exp three) two)) 9))

(println "PRED")
(assert (= (church->int (pred zero)) 0))
(assert (= (church->int (pred one)) 0))
(assert (= (church->int (pred two)) 1))
(assert (= (church->int (pred three)) 2))
(assert (= (church->int (pred (succ three))) 3))

(println "SUB")
(assert (= (church->int ((sub zero) zero)) 0))
(assert (= (church->int ((sub two) two)) 0))
(assert (= (church->int ((sub two) one)) 1))
(assert (= (church->int ((sub three) one)) 2))
(assert (= (church->int ((sub (succ three)) one)) 3))


(println "\nEVEN RULES")
(defn church->even [n] ((n #(+ % 2)) 0))
(assert (= (church->even zero) 0))
(assert (= (church->even (succ zero)) 2))
(assert (= (church->even ((plus (succ zero)) (succ (succ zero)))) 6))
(assert (= (church->even ((mult three) three)) 18))

(println "\nEGATIVE NUMBER")
(defn church->neg [n] ((n dec) 0))
(assert (= (church->neg zero) 0))
(assert (= (church->neg (succ zero)) -1))
(assert (= (church->neg ((plus (succ zero)) (succ (succ zero)))) -3))
(assert (= (church->neg ((mult three) three)) -9))
~~~



### 参考
1. [Lambda演算之自然数](https://github.com/jameszhan/blogs/blob/master/pl/lambda-calculation.md)
2. [Lambda演算之Y-Combinator的推导](https://github.com/jameszhan/blogs/blob/master/pl/y-combinator.md)
3. [lambda演算示例代码](https://raw.githubusercontent.com/jameszhan/rhea/master/codes/clojure/calculation/lambda.clj)