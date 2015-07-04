---
layout: post
title:  "Y-Combinator不同语言实现方案"
author: 詹子知(James Zhan)
date:   2014-09-19 19:00:00
meta:   版权所有，转载须声明出处
category: pdt
tags: [lambda, fp, javascript, pdt]
---

## 递归和定点
纯λ演算的一大特色是可以通过使用一种自应用技巧来书写递归函数。

~~~
f(n) = if n = 0 then 1 else n*f(n-1) 
f = λn.if n = 0 then 1 else n*f(n-1)
~~~
把f移到等式的后面，得到函数G

~~~
G = λf.λn.if n = 0 then 1 else n*f(n-1)
~~~
很显然有：

~~~
f = G(f)
~~~
这表明递归声明涉及找出定点。
函数G的定点是指满足f=G(f)的f的值。在λ演算中，定点由定点操作符Y来定义。
具体的推导过程可以参考我的上一篇文章[Y-Combinator的推导][2]。

~~~
Y = λf.(λx.f(x x))(λx.f(x x))
~~~



### Ruby 版本

~~~ruby
def y(&gen)
    lambda {|g| g[g] }.call(lambda{|f| lambda {|*args| gen[f[f]][*args] }})
end

factorial = y do |recurse|
    lambda do |x|
        x.zero? ? 1 : x * recurse[x-1]
    end
end
puts factorial.call(10)
~~~


### Python 版本

~~~python
def y_combinator(gen):    
    return (lambda g: g(g))(lambda f: (lambda *args: (gen(f(f)))(*args)))

ret = y_combinator(lambda fab: lambda n: 1 if n < 2 else n * fab(n - 1))(10)
print(ret)
~~~

### JavaScript 版本

~~~javascript
function y(gen) {
    return (function(g) {
        return g(g);
    })(function(f) {
        return function(args){
            return gen(f(f))(args);
        };
    });
}

var fact = y(function (fac) {
    return function (n) {
        return n <= 2 ? n : n * fac(n - 1);
    };
});
console.log(fac(5));
~~~

### Clojure 版本

~~~clojure
(defn Y [gen]
  ((fn [g] (g g))
    (fn [f]
      (fn [n] ((gen (f f)) n)))))
      
(defn fac-gen [f] (fn [n] (if (<= n 0) 1 (* n (f (dec n))))))
(assert (= ((Y fac-gen) 5) 120))
~~~




### 参考

1. [Lambda演算之自然数][1]
2. [Y-Combinator的推导(Clojure描述)][2]
3. [Y-Combinator的推导(JavaScript描述)][3]

[1]: http://jameszhan.github.io/2014/09/10/lambda-church-number.html "Lambda演算之自然数"
[2]: http://jameszhan.github.io/2014/09/18/lambda-y-combinator.html "Lambda演算之Y-Combinator的推导"
[3]: http://jameszhan.github.io/2014/09/18/lambda-y-combinator-javascript.html "Y-Combinator的推导(JavaScript版)"
