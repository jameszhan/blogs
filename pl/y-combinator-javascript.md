# Lambda演算之Y-Combinator的推导

上一节中，我们讲到了如何使用λ演算来描述自然数，可以看出λ演算的表现力确实非常强大，然而遗憾的是，由于lambda演算中使用的都是匿名函数，所以它无法很直观地表述递归。
如果缺少了递归，λ演算的能力无疑会大打折扣。

所有基于λ演算的语言中，其实都是支持对过程进行命名的，那为什么这里我们还需要探讨匿名函数的递归呢？
1. 为了保持纯洁性，我们希望仅仅通过λ演算的规则本身来解决递归的问题。
2. 部分语言对过程的命名必须等到该过程定义完成后才可以进行，这个时候我们必须找到一种方式使其能够很容易地获得递归的能力。

### 下面我们就是用factorial函数为原型，来看看如何使用lambda演算基本的规则，为其增加递归的能力。

传统定义方式，不过这个方式不符合我们的需求，因为它使用到了函数自身fact。
~~~javascript
var fact = function(n){
    return n <= 1 ? 1 : n * fact(n - 1);
};
~~~

几乎所有的问题解决过程都可以通过分层来解决，既然它不允许我们直接使用fact，那我们是不是可以直接把fact作为函数传入呢？
~~~javascript
var fac = function(f, n){
    return n <= 1 ? 1 : n * f(f, n - 1);
};
~~~

为了后续处理方便，我们先对该函数进行currying。
~~~javascript
var fac1 = function(f){
    return function(n) {
        return n <= 1 ? 1 : n * f(f)(n - 1);
    };
};
~~~

((self self) (dec n)) 是不是有点丑陋，我们知道λ演算是数学家们搞出来的，他们对构造形式是有很严重的洁癖的。既然我们就是函数本身，为什么还需要f(f)这样多此一举呢。
如果我们的定义能变成下面这样就比较完美了。
~~~
var fac = function(f){
    return function(n) {
        return n <= 1 ? 1 : n * f(n - 1);
    };
};
~~~
这样也许更符合数学家们的口味，但是该函数是无法被直接执行的，这个使我们暂时假定的factorial的理想函数形式。为了构造这个理想函数形式，我们不妨把它变成f(n - 1)，下面我们试着把f(f)拎出来，用作参数f传入。
~~~javascript
var fac2 = function(f) {
    return function(n) {
        var h = function(g){
            return n <= 1 ? 1 : n * g(n - 1);
        };
        return h(f(f));
    };
};
~~~

可以看出h已经是fac函数的理想形式，不过它还包含自由变量n，没关系，我们可以把它先约束起来。
~~~javascript
var fac3 = function(f) {
    return function(n) {
        var h = function(g){
            return function(m){
                return m <= 1 ? 1 : m * g(m - 1);
            };
        };
        return h(f(f))(n);
    };
};
~~~

让我们把h抽出来，作为一个单独的函数，它刚好就是我们要构造的factorial函数的理想形式，并给出fac4函数的定义。
~~~javascript
var fac_gen = function(g){
    return function(m){
        return m <= 1 ? 1 : m * g(m - 1);
    };
};
var fac4 = function(f){
    return function(n) {
        return fac_gen(f(f))(n);
    };
};
~~~

其实这个时候，fact4和factorial的计算过程已经没有什么关系了，换而言之，其实它可以更通用一些，我们不妨给它取个通用些的名字。
~~~javascript
var y = function(gen){
    return function(f){
        return function(n){
            return gen(f(f))(n);
        };
    };
};
var fac5 = y(fac_gen);
~~~

事实确是如此，该函数有一种神奇的能力，它不仅使可以计算factorial，它事实上可以计算所有形如factorial理想形式的函数递归。
~~~javascript
var fib_gen = function(f){
    return function(n){
        return n <= 2 ? 1 : f(n - 1) + f(n - 2);
    };
};
y(fac_gen)(y(fac_gen))(5) //120
y(fib_gen)(y(fib_gen))(6) //8
~~~


我们看下我们的调用，都是形如：y(*_gen)(y(*_gen))(n)的形式，还是相当丑陋的，我们不如精简下，简化其调用过程。
~~~javascript
var y1 = function(gen) {
    var g = function(f) {
        return function(n){
            return gen(f(f))(n);
        };
    };
    return g(g);
};
~~~
更常规的写法
~~~javascript
var Y = function(gen){
    return (function(g){
        return g(g);
    })(function(f){
        return function(n){
            return gen(f(f))(n);
        };
    });
};

Y(fac_gen)(5) //120
~~~

说了这么多，这个东西和Y Combinator又有什么关系？其实，我们最终得出的Y函数，其实就是我们所要苦苦找寻的Y Combinator函数，它具有性质Y(F) = F(Y(F)) = F(F(Y(F)))。


### 参考
1. [Lambda演算之自然数](https://github.com/jameszhan/blogs/blob/master/pl/lambda-calculation.md)
2. [Lambda演算之Y-Combinator的推导](https://github.com/jameszhan/blogs/blob/master/pl/y-combinator.md)
3. [Y-Combinator相关代码](https://raw.githubusercontent.com/jameszhan/simplifyjs/master/fp/y_combinator_deriving.js)
