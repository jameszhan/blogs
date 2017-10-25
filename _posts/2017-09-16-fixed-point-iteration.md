---
layout: post
title:  "不动点迭代及其收敛性"
author: 詹子知(James Zhan)
date:   2017-09-16 23:00:00
meta:   版权所有，转载须声明出处
category: ml
tags: [ml, mathematics, algorithm, python]
---

### 什么是不动点迭代法

函数$f$的不动点是一个值$x$使得$f(x) = x$。例如，0和1是函数$f(x) = x^2$的不动点，因为$0^2 = 0$而$1^2 = 1$，即曲线$y = f(x)$与直线$y = x$存在交点$P(x^{\ast}, x^{\ast})$。

对于某些函数，通过某些初始猜测出发，反复地应用$f$，

$$ f(x), f(f(x)), f(f(f(x))),\cdots $$

直到值的变化不大时，就可以找到它的一个不动点。

算法描述如下：

```python
def solve(f, guess, epsilon):
    i = 0
    while abs(guess - f(guess)) > epsilon:
        guess = f(guess)
        print '[ Epoch {0} ] guess = {1}'.format(i, guess)
        i += 1
    return guess
```

下面示例演示了

1. 求解$f(x) = \frac{x + \frac{5}{x}}{2} = x$也即求解$x^2=5$。
2. 求解$f(x) = \frac{x + \frac{8}{x^2}}{2} = x$也即求解$x^3=8$。

```python
print solve(lambda x: (x + 5 / x) / 2.0, 10.0, 1e-8)
# [ Epoch 5 ] guess = 2.2360679775
print solve(lambda x: (x + 8 / (x ** 2)) / 2.0, 10.0, 1e-8)
# [ Epoch 27 ] guess = 2.00000000337
```

### 不动点迭代法的收敛性

一般地，将非线性方程$f(x) = 0$化为一个同解方程

<div>$$ \varphi(x) = x　　　① $$</div> 

并且假设$\varphi(x)$是一个连续函数，选定一个点$x_0$，计算

$$ x_1 = \varphi(x_0) $$

$$ x_2 = \varphi(x_1) $$

$$ x_3 = \varphi(x_2) $$

$$ \vdots $$

<div>$$ \left. x_{k+1} = \varphi(x_k) \right|_{k \in (1, 2, 3,\cdots)}　　　② $$ </div>

②式为求解非线性方程①的迭代公式，$\varphi(x)$为迭代函数，$x_k$为第$k$步的迭代值。
如果存在一点$x^*$，使得序列${x_k}$满足，

$$ \lim_{k \to \infty} x_k = x^* $$

称②式收敛，否则为发散。

上例中，我们求解了方程$f(x) = x^2 - 5 = 0$，给出的同解方程是$\varphi(x) = \frac{x + \frac{5}{x}}{2} = x$和。

为什么我们不使用更简单的$\varphi(x) = \frac{5}{x} = x$？答案是，因为它不收敛，它关于直线$y = x$对称，易得$x_1 = \varphi(x_0)$及$x_2 = \varphi(x_1) = x_0$，$x$值总在$x_0$和$\varphi(x_0)$之间摆动。

一般地，我们有两种类型的收敛迭代。

![fixed_point_01](/assets/images/fixed_point_01.png)
![fixed_point_02](/assets/images/fixed_point_02.png)

对应有两种类型的发散

![fixed_point_03](/assets/images/fixed_point_03.png)
![fixed_point_04](/assets/images/fixed_point_04.png)

通过观察我们发现，在曲线$y = \varphi(x)$与直线$y = x$交点$P(x^{\ast}, x^{\ast})$处，$x^{\ast}$对应的曲线切线斜率的绝对值小于1（y=x的斜率）时，迭代收敛。一旦交点对应的曲线切线的斜率大于1，迭代就会无法收敛。


$\varphi(x)$要收敛，必须满足如下不动点定理。

设迭代函数$\varphi(x)$在区间$[a, b]$上连续，且满足

(1). 当$x \in [a, b]$时，$a \leq \varphi(x) \leq b$；

(2). 存在一正数$L$，满足$0 < L < 1$，且$\forall x \in [a, b]$，有
<div>$$ \left| \varphi^{'}(x) \right| \leq L $$</div>

则：

a). 方程$\varphi(x) = x$在$[a, b]$内有唯一解$x^*$

b). 对于任意初值$x_0 \in [a, b]$，迭代法$x_{k+1} = \varphi(x_k)$均收敛于$x^{\ast}$

c). <span>$\left| x_k - x^* \right| \leq \frac{L}{1 - L}\left| x_k - x_{k - 1} \right|$</span>

d). <span>$\left| x_k - x^* \right| \leq \frac{L^k}{1 - L}\left| x_1 - x_0 \right|$</span>

证明过程如下：

设 $f(x) = x - \varphi(x)$，则$f(x)$在[a, b]上连续可导，根据条件(1)，

$$ f(a) = a - \varphi(a) \leq 0 $$

$$ f(b) = b - \varphi(b) \geq 0 $$

由根的存在定理，方程$f(x) = 0$在$[a, b]$上至少存在一个根(存在性)。

根据条件(2)， 

$$ \left|\varphi^{'}(x)\right| \leq L < 1 $$

$$ f^{'}(x) = 1 - \varphi^{'}(x) > 0 $$

则函数$f(x)$在$[a, b]$上单调递增，a).方程$f(x) = 0$在$[a, b]$内有唯一解$x^{\ast}$(唯一性)

由微分中值定理

$$ x_{k+1} - x^{\ast} = \varphi(x_k) - \varphi(x^{\ast}) = \varphi^{'}(\xi)(x_{k} - x^{\ast}) $$

$$ x_{k+1} - x_k = \varphi(x_k) - \varphi(x_{k-1}) = \varphi^{'}(\overline \xi)(x_{k} - x_{k-1}) $$

$$ \varphi^{'}(x) \leq L $$


$$ \implies \left| x_{k + 1} - x^{\ast} \right| \leq L \left| x_k - x^{\ast} \right| = L \left| x_{k + 1} - x^{\ast} - (x_{k + 1} - x_k) \right| \leq  L \left| x_{k + 1} - x^{\ast} \right| + L \left| x_{k + 1} - x_k \right| $$

$$ \implies c). \left| x_{k + 1} - x^{\ast} \right| \leq \frac{L}{1-L}\left| x_{k + 1} - x_k \right| $$

$$ \implies d). \left| x_{k + 1} - x^{\ast} \right| \leq \frac{L^k}{1-L}\left| x_1 - x_0 \right| $$

即 

$$ \left| x_{k + 1} - x^{\ast} \right| \leq \frac{L}{1-L}\left| x_{k + 1} - x_k \right| \leq \frac{L^k}{1-L}\left| x_1 - x_0 \right|  $$

因为$L < 1$, 因此对于任意初值$x_0$，迭代法$x_{k+1} = \varphi(k)$均收敛于$x^{\ast}$。

$$\lim_{k \to \infty}(x_k - x^{\ast}) = 0$$




<!-- $\varphi(x) = \frac{5}{x}$的导函数为$\varphi^{'}(x) = -\frac{5}{x^2} < 0$，不满足条件(2)，因此它不收敛。同样$\varphi(x) = \frac{8}{x^2}$的导函数为$\varphi^{'}(x) = -\frac{16}{x^3}$。 -->


