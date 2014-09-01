# Lambda演算之Y-Combinator的推导

上一节中，我们讲到了如何使用λ演算来描述自然数，可以看出λ演算的表现力确实非常强大，然而遗憾的是，由于lambda演算中使用的都是匿名函数，所以它无法很直观地表述递归。
如果缺少了递归，λ演算的能力无疑会大打折扣。

所有基于λ演算的语言中，其实都是支持对过程进行命名的，那为什么这里我们还需要探讨匿名函数的递归呢？
1. 为了保持纯洁性，我们希望仅仅通过λ演算的规则本身来解决递归的问题。
2. 部分语言对过程的命名必须等到该过程定义完成后才可以进行，这个时候我们必须找到一种方式使其能够很容易地获得递归的能力。

### 下面我们就是用factorial函数为原型，来看看如何使用lambda演算基本的规则，为其增加递归的能力。

传统定义方式，不过这个方式不符合我们的需求，因为它使用到了函数自身fact。
~~~clojure
(defn fact [n] (if (<= n 0) 1 (* n (fact (dec n)))))
(assert (= (fact 5) 120))
~~~

几乎所有的问题解决过程都可以通过分层来解决，既然它不允许我们直接使用fact，那我们是不是可以直接把fact作为函数传入呢？
~~~clojure
(defn fact2 [self n] (if (<= n 0) 1 (* n (self self (dec n)))))
(assert (= (fact2 fact2 5) 120))
~~~

为了后续处理方面，我们先对该函数进行currying。
~~~clojure
(defn fact3 [self] (fn [n] (if (<= n 0) 1 (* n ((self self) (dec n))))))
(assert (= ((fact3 fact3) 5) 120))
~~~

((self self) (dec n)) 是不是有点丑陋，我们知道λ演算是数学家们搞出来的，他们对构造形式是有很严重的洁癖的。既然我们就是函数本身，为什么还需要(self, self)这样多此一举呢。
如果我们的定义能变成下面这样就比较完美了。
~~~clojure
(defn fact3 [self] (fn [n] (if (<= n 0) 1 (* n (self (dec n))))))
~~~
或者换成二元形式
~~~clojure
(defn fact3 [f, n] (if (<= n 0) 1 (* n (f (dec n)))))
~~~
这样也许更符合数学家们的口味，但是该函数是无法被直接执行的，这个使我们暂时假定的factorial的理想函数形式。为了构造这个理想函数形式，我们不妨把它变成(f (dec n))，下面我们试着把(self self)拎出来，用作参数f传入。
~~~clojure
(defn fact4 [self]
  (fn [n] (letfn [(fac-gen [f] (if (<= n 0) 1 (* n (f (dec n)))))]
            (fac-gen (self self)))))
(assert (= ((fact4 fact4) 5) 120))
~~~

我们来看fac-gen的形式，其等价于<pre>(defn fac-gen [f] (if (<= n 0) 1 (* n (f (dec n)))))</pre>，是不是和我们理想中的fact形式已经很接近了，当然其中有一个自由变量n，没关系，我们给他加个帽子。
~~~clojure
(defn fact5 [self]
  (fn [n]
    (letfn [(fac-gen [f]
              (fn [n] (if (<= n 0) 1 (* n (f (dec n))))))]
      ((fac-gen (self self)) n))))
(assert (= ((fact5 fact5) 5) 120))
~~~

这次的fac-gen和我们的理想函数形式非常像了，换成二元就是<pre>(defn fac-gen [f, n] (if (<= n 0) 1 (* n (f (dec n)))))</pre>，这正是我们找寻的理想形式。
(defn fact6 [self]
  (letfn [(fac-gen [f]
            (fn [n] (if (<= n 0) 1 (* n (f (dec n))))))]
    (fn [n] ((fac-gen (self self)) n))))
(assert (= ((fact6 fact6) 5) 120))

让我们把fac-gen抽出来，作为一个单独的函数，它刚好就是我们要构造的factorial函数的理想形式，并给出fact7函数的定义。
~~~clojure
(defn fac-gen [f] (fn [n] (if (<= n 0) 1 (* n (f (dec n))))))
(defn fact7 [self]
  (fn [n] ((fac-gen (self self)) n)))
(assert (= ((fact7 fact7) 5) 120))
~~~

其实这个时候，fact7和factorial的计算过程已经没有什么关系了，换而言之，其实它可以更通用一些。
~~~clojure
(defn fact8 [gen]
  (fn [self]
    (fn [n] ((gen (self self)) n))))
;; (fact8 fac-gen) = fact7
(assert (= (((fact8 fac-gen) (fact8 fac-gen)) 5) 120))
~~~

fact8其实和factorial的计算过程没有任何关系，所以我们不妨给它换个名字
~~~clojure
(defn y [gen]
  (fn [self]
    (fn [n] ((gen (self self)) n))))
(assert (= (((y fac-gen) (y fac-gen)) 5) 120))
~~~

事实确是如此，该函数有一种神奇的能力，它不仅使可以计算factorial，它事实上可以计算所有形如factorial理想形式的函数递归。
~~~clojure
(defn fib-gen [f] (fn [n] (if (<= n 2) 1 (+ (f (dec n)) (f (- n 2))))))
(assert (= (((y fib-gen) (y fib-gen)) 1) 1))
(assert (= (((y fib-gen) (y fib-gen)) 2) 1))
(assert (= (((y fib-gen) (y fib-gen)) 3) 2))
(assert (= (((y fib-gen) (y fib-gen)) 4) 3))
(assert (= (((y fib-gen) (y fib-gen)) 5) 5))
(assert (= (((y fib-gen) (y fib-gen)) 6) 8))

(defn range-gen [f] (fn [n] (if (<= n 0) () (conj (f (dec n)) n))))
(assert (= (((y range-gen) (y range-gen)) 5) (list 5 4 3 2 1)))
~~~

我们看下我们的调用，都是形如：(((y *-gen) (y *-gen)) n)的形式，还是相当丑陋的，我们不如精简下，简化其调用过程。
~~~clojure
(defn y1 [gen]
  (letfn [(g [self] (fn [n] ((gen (self self)) n)))]
    (g g)))
(assert (= ((y1 range-gen) 5) (list 5 4 3 2 1)))
(assert (= ((y1 fib-gen) 6) 8))
(assert (= ((y1 fac-gen) 5) 120))
~~~
去除letfn，把self使用f替换。
~~~clojure
(defn Y [gen]
  ((fn [g] (g g))
    (fn [f]
      (fn [n] ((gen (f f)) n)))))
(assert (= ((Y range-gen) 5) (list 5 4 3 2 1)))
(assert (= ((Y fib-gen) 6) 8))
(assert (= ((Y fac-gen) 5) 120))
~~~

说了这么多，这个东西和Y Combinator又有什么关系？其实，我们最终得出的Y函数，其实就是我们所要苦苦找寻的Y Combinator函数，它具有性质Y(F) = F(Y(F)) = F(F(Y(F)))。
~~~clojure
(assert (= ((fac-gen (Y fac-gen)) 5) 120))
(assert (= ((fac-gen (fac-gen (Y fac-gen))) 5) 120))
~~~

### 不动点组合子(Y Combinator)
函数f的不动点是一个值x使得f(x) = x。例如，0和1是函数f(x) = x**2的不动点，因为0**2 = 0而1**2 = 1。鉴于一阶函数（在简单值比如整数上的函数）的不动点
是个一阶值，高阶函数f的不动点是另一个函数g使得f(g) = g。那么，不动点算子是任何函数fix使得对于任何函数f都有 f(fix(f)) = fix(f).

在无类型lambda演算中众所周知的（可能是最简单的）不动点组合子叫做Y组合子。它是Haskell B. Curry发现的，定义为Y = λf.(λx.f (x x)) (λx.f (x x))用一个例子函数g来展开它，我们可以看到上面这个函数是怎么成为一个不动点组合子的：
~~~
Y g = (λf.(λx. f (x x)) (λx. f (x x))) g
    = (λx. g (x x)) (λx. g (x x))            （λf的β-归约 - 应用主函数于g）
    = (λy. g (y y)) (λx. g (x x))            （α-转换 - 重命名约束变量）
    = g ((λx. g (x x)) (λx. g (x x)))        （λy的β-归约 - 应用左侧函数于右侧函数）
    = g (Y g)（Y的定义）
~~~




