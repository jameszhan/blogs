---
layout: post
title:  "牛顿法从放弃到入门"
author: 詹子知(James Zhan)
date:   2017-09-17 23:00:00
meta:   版权所有，转载须声明出处
category: ml
tags: [ml, mathematics, algorithm, python]
---

### 问题

科学或工程问题的求解和模拟最终往往都要解决求根或优化问题，前一种情形要求出方程或方程组的解；后一种情形则要找出使函数取极大或极小值的点，即使是对实验数据进行拟合或数值求解微分方程，也总是将问题简化成上述两类问题。

第一类问题本质是求出$f(x) = 0$的解，第二类问题则可以转化为求$g(x) = f^{'}(x) = 0$的解，其实本质我们都可以转化为求解方程根的问题。

### 对分法

在解方程的问题上，我们最容易会想到就是通过对分法迭代逐步逼近方程的根，最终达到求解方程的根的目的。他的基本思想如下：

如果$f$在所考虑的区间上连续，且$[x_0, x_1]$是有根区间，即$f(x_0) \cdot f(x_1) < 0$，则取

$$ x_2 = \frac{x_0 + x_1}{2} $$

并计算$f(x_2)$，如果$f(x_2) = 0$则结束，否则或者$f(x_2)$与$f(x_0)$符号相反，此时$[x_0, x_2]$是新的有根区间，长度为原来的一半，或者$f(x_2)$与$f(x_1)$符号相反，此时$[x_2, x_1]$是新的有根区间，长度也为原来的一半，不管哪种情形，都通过计算一个新的函数值（$f(x_2)$的计算）将零点$x^*$的不确定性降低了50%，接下来在新的区间上重复这一过程，直到有根区间的长度充分小。

算法描述如下：

```python
def solve(g, x0, x1, epsilon):
    i = 0
    while True:
        x = (x0 + x1) / 2.0
        gx = g(x)
        print '[ Epoch {0} ] guess = {1}'.format(i, x)
        if abs(gx) < epsilon:
            return x
        else:
            gx0, gx1 = g(x0), g(x1)
            if gx0 * gx < 0:
                x1 = x
            else:
                x0 = x
        i += 1
```

测试解方程

```python
# 求解f(x) = x^2 - 5 = 0
print solve(lambda x: x ** 2 - 5, 0, 5, 1e-8)
# [ Epoch 28 ] guess = 2.23606797867
# 2.23606797867
# 求解f(x) = x^2 - 2 = 0
print solve(lambda x: x ** 2 - 2, 0, 2, 1e-8)
# [ Epoch 27 ] guess = 1.41421356052
# 1.41421356052
```

可以看出求解$x^2 = 5$迭代了29次，求解$x^2 = 2$迭代了28次，具体的迭代次数与$[x_0, x_1]$的区间长度和精度$epsilon = 1e-8$有关，对于这样的收敛速度，实在是太慢了，通常需要几次迭代才可以增加一位正确的有效数字。

> 如果对分法第n次的迭代的误差是$\epsilon$，那么为了使误差降低为$\frac{\epsilon}{10}$，即使结果增加一位正确的有效数字，则需要再迭代$m$次，$m = log_2(10) = 3.3219$。

除此之外，对分法对初始区间$[x_0, x_1]$也有很高要求，需要保证该区间是有根区间。

那么有没有对初始值要求不高，收敛速度更快的算法呢？答案是有的，它就是下文要重点分析的牛顿法。

### 牛顿法

#### 算法描述

牛顿法（或称牛顿-拉弗森(Newton-Raphson)迭代）：对于可微函数$f$，选定一个点$x_0$，计算

$$ x_1 = x_0 - \frac{f(x_0)}{f^{'}(x_0)} $$


$$ x_2 = x_1 - \frac{f(x_1)}{f^{'}(x_1)} $$


$$ x_3 = x_2 - \frac{f(x_2)}{f^{'}(x_2)} $$


$$\vdots$$

直到满足某个判停准则，最终得到的$x_k$为$f$零点的近似值。

```python
# 根据导数公式求解函数g的导函数
def derivative(g, epsilon):
    dx = epsilon
    return lambda x: (g(x + dx) - g(x)) / dx

# 牛顿法代码实现
def solve(g, initial, epsilon):
    guess, i = initial, 0
    while abs(g(guess)) > epsilon:
        print '[ Epoch {0} ] guess = {1}'.format(i, guess)
        guess = guess - (g(guess) / (derivative(g, epsilon)(guess)))
        i += 1
    return guess
```

测试解方程

```python
# 求解f(x) = x^2 - 5 = 0
print solve(lambda x: x ** 2 - 5, 5, 1e-8)
# [ Epoch 4 ] guess = 2.23606889563
# 2.2360679775
# 求解f(x) = x^2 - 2 = 0
print solve(lambda x: x ** 2 - 2, 2, 1e-8)
# [ Epoch 0 ] guess = 2
# [ Epoch 1 ] guess = 1.49999999696
# [ Epoch 2 ] guess = 1.41666666616
# [ Epoch 3 ] guess = 1.41421568629
# 1.41421356237
```

可以看出求解$x^2 = 5$只迭代了5次，求解$x^2 = 2$迭代了4次，收敛速度非常快。

#### 几何意义

```python
# coding=UTF-8
import numpy as np
import matplotlib.pyplot as plt
X = np.linspace(-5, 20, 1000)
colors = ['r-.', 'g-.', 'b-.', 'y-.', 'c-.', 'm-.', 'k-.', 'w-.', 'r-.', 'g-.', 'b-.', 'y-.', 'c-.', 'm-.', 'k-.', 'w-.']
# 切线方程
def tangent(slope, x1, x):
    return slope * (x - x1)
# 求导函数
def derivative(g, epsilon):
    dx = epsilon
    return lambda x: (g(x + dx) - g(x)) / dx
# 绘制牛顿法逼近过程
def solve(g, initial, epsilon):
    guess, i = initial, 0
    while abs(g(guess)) > epsilon:
        print '[ Epoch {0} ] guess = {1}'.format(i, guess)
        slope = derivative(g, epsilon)(guess)
        guess = guess - (g(guess) / slope)
        plt.plot(X, tangent(slope, guess, X), colors[i])
        plt.scatter(guess, 0)
        i += 1
    return guess

def square(x):
    return x ** 2 - 5

plt.plot(X, square(X), 'k-')
solve(square, 10, 1e-6)

plt.grid(True)
plt.show()
```

输出：

```python
# [ Epoch 0 ] guess = 10
# [ Epoch 1 ] guess = 5.25000023439
# [ Epoch 2 ] guess = 3.10119077758
# [ Epoch 3 ] guess = 2.35673746512
# [ Epoch 4 ] guess = 2.23915725731
# [ Epoch 5 ] guess = 2.23607010927
```

![NewtonMethodGeometry](/assets/images/newton_method_geometry.png)

很容易看出，离零点越远的地方收敛速度越快，离零点越近的地方收敛速度越慢，每一次迭代，都比上一次的值更接近$f(x) = 0$。

#### 逼近序列的推导

$$ x_{n+1} = x_n - \frac{f(x_n)}{f^{'}(x_n)} $$

![NewtonMethod](/assets/images/newton_method.png)

通过上文中的几何意义，点$x_{n+1}$是$f(x)$在点$x_n$处的切线与$x$轴的交点，切线的直线方程为：

$$ y = f^{'}(x_n)(x - x_{n}) + f(x_n) $$

令$y = 0$，很容易计算出

$$ x = x_n - \frac{f(x_n)}{f^{'}(x_n)} $$

我们可以根据[泰勒公式](https://www.atatech.org/articles/90442)的一阶展开来推导出该公式。

$$ f(x) \approx f(x_n) + f^{'}(x_n)(x - x_n) = 0 $$

可以直接得出

$$ x = x_n - \frac{f(x_n)}{f^{'}(x_n)} $$

