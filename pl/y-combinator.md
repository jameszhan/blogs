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

((self self) (dec n)) 是不是有点丑陋，我们知道λ演算是数学家们搞出来的，他们对构造形式是有很严重的洁癖的。我们不妨把它变成(f (dec n))，
这样也许更符合数学家们的口味，下面我们试着把(self self)拎出来，用作参数f传入。
~~~clojure
(defn fact4 [self]
  (fn [n] (letfn [(fac-gen [f] (if (<= n 0) 1 (* n (f (dec n)))))]
            (fac-gen (self self)))))
(assert (= ((fact4 fact4) 5) 120))
~~~
