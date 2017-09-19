---
layout: post
title:  "泰勒级数从放弃到入门"
author: 詹子知(James Zhan)
date:   2017-09-16 23:00:00
meta:   版权所有，转载须声明出处
category: ml
tags: [ml, mathematics, algorithm, python]
---


## 知识准备

#### 极限

<span>设函数$f(x)$在点$x_0$的某一去心邻域内有定义，如果存在常数$a$，对于任意给定的正数$\epsilon$，总存在正数$\delta$，使得当$x$满足不等式$0 < |x - x_0| < \delta$时，对应的函数值$f(x)$都满足不等式$|f(x) - a| < \epsilon$，那么常数$a$就叫做函数$f(x)$当$x \to x_0$时的极限，记作：</span>

$$ \lim_{x \to x_0} f(x) = a $$

#### 导数
设函数$y = f(x)$在点$x_)$的某个邻域内有定义，当自变量$x$在$x_0$处取得增量$\Delta x$（点$x_0 + \Delta x$仍在该邻域内）时，相应地函数$y$取得增量$\Delta y = f(x) - f(x_0)$；如果$\Delta y$与$\Delta x$之比当$\Delta x \to 0$时的极限存在，则称函数$y = f(x)$在点$x_0$处可导，并称这个极限为函数$y = f(x)$在点$x_0$处的导数，记为：

$$ f^{'}(x_0) = y^{'}|_{x=x_0} = \left. \frac{dy}{dx} \right|_{x=x_0} = \lim_{\Delta x \to 0} \frac{\Delta y}{\Delta x} = \lim_{\Delta x \to 0} \frac{f(x_0 + \Delta x) - f(x_0)}{\Delta x} = \lim_{x \to x_0} \frac{f(x) - f(x_0)}{x - x_0} $$

#### 函数极限和无穷小的关系
在自变量$x$的同一变化过程$x \to x_0$(或$x \to \infty$)中，函数$f(x)$具有极限A的充分必要条件$f(x) = A + a$，其中$a$是无穷小。

$$ \lim_{x \to x_0} f(x) = A \iff f(x) = A + a|_{a -> 0} $$

#### 洛必达法则

洛必达法则是在一定条件下通过分子分母分别求导再求极限来确定未定式值的方法。

##### $0/0$型不定式极限

若函数$f(x)$和$g(x)$满足下列条件：

1. $\lim_{x \to a} f(x) = 0, \lim_{x \to a} g(x) = 0$;
2. 在点$a$的某去心邻域内两者都可导，且$g^{'}(x) \not= 0$;
3. $\lim_{x \to a} \frac{f^{'}(x)}{g^{'}(x)} = A$(A可为实数，也可为$\pm \infty$)。

则

$$ \lim_{x \to a} \frac{f(x)}{g(x)} = \lim_{x \to a} \frac{f^{'}(x)}{g^{'}(x)} = A $$

##### $\infty/\infty$型不定式极限

若函数$f(x)$和$g(x)$满足下列条件：

1. $\lim_{x \to a} f(x) = \infty, \lim_{x \to a^+} g(x) = \infty$;
2. 在点$a$的某去心邻域内两者都可导，且$g^{'}(x) \not= 0$;
3. $\lim_{x \to a^+} \frac{f^{'}(x)}{g^{'}(x)} = A$(A可为实数，也可为$\pm \infty 或 \infty$)。

则

$$ \lim_{x \to a^+} \frac{f(x)}{g(x)} = \lim_{x \to a^+} \frac{f^{'}(x)}{g^{'}(x)} = A $$


## 泰勒级数

#### 定义 

设$n$是一个正整数。如果定义在一个包含$a$的区间上的函数$f$在$a$点处$n - 1$次可导，那么对于这个区间上的任意$x$都有：

$$ f(x) = \sum_{k = 0}^{n - 1} \frac{f^{(k)}(a)}{k!}(x - a)^k + R_n(x) $$

其中的多项式称为函数在$a$出的泰勒展开式，$R_n(x)$是泰勒公式的余项且是$(x - a)^n$的高阶无穷小。

泰勒公式是在局部，用一个多项式函数，近似地替代一个复杂函数。泰勒展开式与$f(x)$的每一阶导数值完全相等，而这种“各阶导数值相等”揭示了多项式函数和他要替代的复杂函数$f(x)$在每一个维度$(1,x,x^2,\cdots,x^{n-1})$上完全相同的事实。

#### 推导过程

假设函数$f(x)$在点$a$的邻域内有定义，且在点$a$处$n - 1$次可导。

根据导数定义及函数极限与无穷小的关系，易得：

$$ f^{'}(x_0) = \lim_{\Delta x \to 0} \frac{\Delta y}{\Delta x} \implies \frac{\Delta y}{\Delta x} = \left. f^{'}(x_0) + a_1 \right|_{a_1 \to 0} $$ 

给定点$x_0$邻域中的点$x$，$\Delta y = f(x) - f(x_0), \Delta x = x - x_0$，则有公式①

$$ f(x) = f(x_0) + f^{'}(x_0)\Delta x + a_1 \Delta x $$ 

比较无穷小量$a_1$和$\Delta x$的关系。

$$ a_1 = \frac{f(x) - f(x_0) - f^{'}(x_0)(x - x_0)}{x - x_0} \implies \lim_{\Delta x \to 0} \frac{a_1}{\Delta x} = \lim_{x \to x_0} \frac{f(x) - f(x_0) - f^{'}(x_0)(x - x_0)}{(x - x_0)^2} $$

根据$0/0$洛必达法则

$$ \lim_{\Delta x \to 0} \frac{a_1}{\Delta x} = \lim_{x \to x_0} \frac{f^{'}(x) - f^{'}(x_0)}{2(x - x_0)} = \frac{1}{2}f^{''}(x_0) $$

根据极限与无穷小的关系，得到：

$$ \frac{a_1}{\Delta x} = \left. \frac{1}{2}f^{''}(x_0) + a_2 \right|_{a_2 \to 0} $$

代入公式①，得到公式②：

$$ f(x) = f(x_0) + f^{'}(x_0)\Delta x + \frac{1}{2}f^{''}(x_0)\Delta^2 x + a_2\Delta^2 x $$ 

同理，可以求得

$$ a_2 = \frac{f(x) - f(x_0) - f^{'}(x_0) \Delta x - \frac{1}{2}f^{''}(x_0)\Delta^2 x}{\Delta^2 x} \implies \lim_{\Delta x \to 0} \frac{a_2}{\Delta x} = \lim_{x \to x_0} \frac{f(x) - f(x_0) - f^{'}(x_0)(x - x_0) - \frac{1}{2}f^{''}(x_0)(x - x_0)^2}{(x - x_0)^3} $$

连续应用洛必达法则可得：

$$ \lim_{\Delta x \to 0} \frac{a_2}{\Delta x} = \lim_{x \to x_0} \frac{f^{'}(x) - f^{'}(x_0) - f^{''}(x_0)(x - x_0)}{3(x - x_0)^2} = \lim_{x \to x_0} \frac{f^{''}(x) - f^{''}(x_0)}{3!(x - x_0)} = \frac{1}{3!} f^{'''}(x_0)$$

<span>把$a_2 = \left. (\frac{1}{3!}f^{'''}(x_0) + a_3)\Delta x \right|_{a_3 \to 0}$代入公式②，得到公式③：</span>

$$ f(x) = f(x_0) + f^{'}(x_0)\Delta x + \frac{1}{2!}f^{''}(x_0)\Delta^2 x + \frac{1}{3!}f^{'''}(x_0) \Delta^3 x + a_3\Delta^3 x $$ 

以此类推，根据数学归纳法，易证明泰勒公式最后结论。



#### 应用

在数值计算方面，利用多项式函数近似、去逼近一个复杂函数，是研究实际问题的一个非常重要的方式，也即是把质的困难转化为量的复杂。比如$e$和$\pi$的计算，机器学习中的优化算法当中，也大量利用到了泰勒公式。

##### 数值计算

$ e^x \approx 1 + x + \frac{x^2}{2!} + \frac{x^3}{3!} +  \cdots + \frac{x^n}{n!} $

$ \frac{\pi}{4} \approx \sum_{i=0}^n \frac{(-1)^i}{2 \cdot i + 1}$

```python
def factorial(n):
    i, f = 0, 1.0
    while i < n:
        f *= (i + 1)
        i += 1
    return f

# Count e
e = np.sum([1.0 / factorial(i) for i in range(0, 1000)])
print e     # 2.71828182846

# Count π 这个公式收敛很慢
pi = 4 * np.sum([(1.0 * np.power(-1, i))/ (2 * i + 1) for i in range(0, 1000000)])
print pi    # 3.14159165359
```

##### 渐进演示

利用泰勒级数展开逼近$e^x$

```python
import matplotlib.pyplot as plt
import numpy as np

def factorial(n):
    c, f = 0, 1.0
    while c < n:
        f *= (c + 1)
        c += 1
    return f

def item(x, n):
    return np.power(x, n) / factorial(n)

def taylor(x, n):
    return np.sum([item(x, k) for k in range(0, n)])

X = np.linspace(0, 5, 1000)
plt.grid(True)

plt.plot(X, [taylor(i, 2) for i in X], 'r:')
plt.plot(X, [taylor(i, 3) for i in X], 'g:')
plt.plot(X, [taylor(i, 5) for i in X], 'b-.')
plt.plot(X, [taylor(i, 7) for i in X], 'r--')
plt.plot(X, [taylor(i, 9) for i in X], 'y-.')
plt.plot(X, np.exp(X), 'r:')

plt.show()
```

![TaylorAsEX](/assets/images/taylor_as_e.png)


