---
layout: post
title:  "梯度下降从放弃到入门"
author: 詹子知(James Zhan)
date:   2017-09-17 23:00:00
meta:   版权所有，转载须声明出处
category: ml
tags: [ml, mathematics, algorithm, python]
---


### 梯度

在向量微积分中，标量场的梯度是一个向量场。标量场中某一点上的梯度指向标量场增长最快的方向，梯度的长度是这个最大的变化率。

在三维直角坐标系中表示为：

$$ 
\nabla \varphi = \left( \frac{\partial \varphi}{\partial x}, \frac{\partial \varphi}{\partial y}, \frac{\partial \varphi}{\partial z}\right) 
= \frac{\partial \varphi}{\partial x}\vec{i} + \frac{\partial \varphi}{\partial y}\vec{j} + \frac{\partial \varphi}{\partial z}\vec{k}
$$

### 梯度下降

梯度下降是一个用来求函数最小值的算法，在机器学习所有优化算法当中，梯度下降应该算是最受关注并且用的最多的一个算法。

梯度下降背后的思想是：开始时我们随机选取一个参数的组合$(\theta_0,\theta_1,\cdots,\theta_n)$，计算代价函数$J(\theta)$，然后我们寻找下一个能让代价函数值下降最多的参数组合。我们持续这么做，直到找到一个局部最小值，因为我们并没有尝试完所有的参数组合，所以不能确定我们得到局部最小值是否便是全局最小值，不同的初始参数组合，可能会找到不同的局部最小值。如果我们知道代价函数是一个凸函数，那么我们就可以保证我们找到的局部最小点就是全局最小点。

通过梯度的定义，我们知道，梯度的方向是增长（上升）最快的方向，那么梯度的反方向便是让代价函数下降程度最大的方向。

定义$\alpha$为学习率（learning rate），它决定了我们沿着能让代价函数下降程度最大的方向更新的步长。

$$ \theta_j = \theta_j - \alpha \frac{\partial J(\theta)}{\partial \theta_j}$$

每走一步，我们都要重新计算函数在当前点的梯度，然后选择梯度的反方向作为走下去的方向。随着每一步迭代，梯度不断地减小，到最后减小为零。

### 线性回归


假定我们有一批数据点，需要根据这些点找出最适合的线性方程$y = ax + b$。

```python
X = [1, 2, 3, 4, 5, 6, 7, 8, 9]
Y = [0.199, 0.389, 0.580, 0.783, 0.980, 1.177, 1.380, 1.575, 1.771]
```

![GDPoints](/assets/images/gd_points.png)

也就是要找出最合适的参数$(a, b)$，使得直线到所有点的距离尽可能小。他可以转化为求解代价函数1

$$ J(a, b) = \sum_{i=1}^m\left(ax^{(i)} + b - y^{(i)}\right)^2 $$

的最小值。

我们也可以令$J(a, b)$为误差平方和（SSE）的平均数，为了后续求导计算方便，我们还可以再把他除以2，即代价函数2

$$ J(a, b) = \frac{1}{2m}\sum_{i=1}^m\left(ax^{(i)} + b - y^{(i)}\right)^2 $$

如果$(a, b)$在代价函数2上取得最小值，也必在代价函数1上取的最小值。

其中$$x^{(i)}, y^{(i)}$$为已知数。

$$ 
\frac{\partial}{\partial a}J(a,b)
=  \frac{\partial}{\partial a}\left(\frac{1}{2m}\sum_{i=1}^m\left(ax^{(i)} + b - y^{(i)}\right)^2\right)
= \frac{1}{m}\sum_{i=1}^m\left(ax^{(i)} + b - y^{(i)}\right)x^{(i)}
$$

$$ 
\frac{\partial}{\partial b}J(a,b)
=  \frac{\partial}{\partial b}\left(\frac{1}{2m}\sum_{i=1}^m\left(ax^{(i)} + b - y^{(i)}\right)^2\right)
= \frac{1}{m}\sum_{i=1}^m\left(ax^{(i)} + b - y^{(i)}\right)
$$

利用梯度下降法，我们很容易实现对应的迭代解法。

$$ a := a - \alpha \frac{\partial}{\partial a}J(a,b) $$

$$ b := b - \alpha \frac{\partial}{\partial b}J(a,b) $$

```python
def gd(X, Y, alpha = 0.01, epsilon = 1e-8):
    m = len(X)
    a, b = 0, 0
    sse0 = 0
    while True:
        grad_a, grad_b = 0, 0
        for i in range(m):
            diff = a * X[i] + b - Y[i]
            grad_a += X[i] * diff
            grad_b += diff

        grad_a = grad_a / m
        grad_b = grad_b / m

        a -= alpha * grad_a
        b -= alpha * grad_b

        sse1 = 0
        for j in range(m):
            sse1 += (a * X[j] + b - Y[j]) ** 2 / (2 * m)

        if abs(sse0 - sse1) < epsilon:
            break
        else:
            sse0 = sse1
    return a, b
```

测试代码如下:

```python
a, b = gd(X, Y, 0.05, 1e-6)

print 'y = {0} * x + {1}'.format(a, b)
# y = 0.193958973089 * x + 0.0161212366801
x = np.array(X)
plt.plot(x, Y, 'o', label='Original data', markersize=5)
plt.plot(x, a * x + b, 'r', label='Fitted line')
plt.show()
```
![GDPointsFit](/assets/images/gd_points_fit.png)


### 多变量线性回归

上例，我们演示了一元线性回归梯度下降的迭代解法，更一般地，我们考虑n个变量的情况，我们有m条记录。

$$
\begin{bmatrix}
x_{10} & x_{11} & x_{12} & \cdots & x_{1n} \\
x_{20} & x_{21} & x_{22} & \cdots & x_{2n} \\
\vdots & \vdots & \vdots & \ddots & \vdots \\
x_{m0} & x_{m1} & x_{m2} & \cdots & x_{mn} \\
\end{bmatrix} 
\cdot
\begin{bmatrix}
\theta_0    \\
\theta_1    \\
\theta_2    \\
\vdots      \\
\theta_n    \\
\end{bmatrix} 
=
\begin{bmatrix}
y_1     \\
y_2     \\
\vdots      \\
y_m     \\
\end{bmatrix} 
$$

<span>为了不失一般性和简化公式，我们令$x_{i0}|_{i \in (1,2,\cdots,m)} = 1$</span>

我们需要找到一个假设$h$，使得应用到上述数据，其代价函数最小。

$$ h_{\theta}(x) = \theta_0x_0 + \theta_1x_1 + \theta_2x_2 + \cdots + \theta_nx_n $$

或者

$$ 
h_{\theta}(x) = \sum_{j=0}^n\theta_jx_j
= 
\begin{bmatrix}
\theta_0 & \theta_1 & \cdots & \theta_n
\end{bmatrix}
\cdot
\begin{bmatrix}
x_0 \\
x_1 \\
\vdots \\
x_n \\
\end{bmatrix}
= \theta^TX
$$

其中，$x_0 = 1$, $\theta_0$为偏置。

$$ J(\theta) = \frac{1}{2m}\sum_{i=1}^m\left(h_{\theta}\left(x^{(i)}\right) - y^{(i)}\right)^2 $$

则$J(\theta)$梯度为

$$ \nabla J(\theta) = 
\begin{bmatrix}
\frac{\partial J(\theta)}{\partial\theta_0} \\
\frac{\partial J(\theta)}{\partial\theta_1} \\
\frac{\partial J(\theta)}{\partial\theta_2} \\
\vdots                              \\ 
\frac{\partial J(\theta)}{\partial\theta_n} \\
\end{bmatrix}
$$

$$ 
\frac{\partial J(\theta)}{\partial\theta_j} 
= \frac{\partial}{\partial\theta_j}\left(\frac{1}{2m}\sum_{i=1}^m\left(h_{\theta}\left(x^{(i)}\right) - y^{(i)}\right)^2\right) 
= \frac{1}{m}\sum_{i=1}^m\left(h_{\theta}\left(x^{(i)}\right) - y^{(i)}\right)x_j^{(i)}
$$

利用梯度下降法，我们很容易实现对应的迭代解法。

$$ \theta_j := \theta_j - \alpha \frac{\partial}{\partial\theta_j}J(\theta) $$

```python
def gd(X, Y, alpha, epsilon):
    m, n = len(X), len(X[0])
    theta = [1 for i in range(n)]
    sse0, cnt = 0, 0
    while True:
        gradient = [0 for i in range(n)]
        for j in range(n):
            for i in range(m):
                hypothesis = sum(X[i][jj] * theta[jj] for jj in range(n))
                loss = hypothesis - Y[i]
                gradient[j] += X[i][j] * loss
            gradient[j] = gradient[j] / m
        for j in range(n):
            theta[j] = theta[j] - alpha * gradient[j]

        sse1 = 0
        for i in range(m):
            loss = sum(X[i][jj] * theta[jj] for jj in range(n)) - Y[i]
            sse1 += loss ** 2
        sse1 = sse1 / (2 * m)
        
        print "[ Epoch {0} ] theta = {1}, gd = {2}, sse = {3})".format(cnt, theta, gradient, sse1)
        cnt += 1
        if abs(sse1 - sse0) < epsilon:
            break
        else:
            sse0 = sse1
    return theta
```

之所以不在同一个循环里面同时计算梯度和更新$\theta$，是因为正确的做法需要保证$\theta$同时更新。


```python
# 取x_0 = 1
X = [(1, 1.), (1, 2.), (1, 3.), (1, 4.), (1, 5.), (1, 6.), (1, 7.), (1, 8.), (1, 9.)]
Y = [0.199, 0.389, 0.580, 0.783, 0.980, 1.177, 1.380, 1.575, 1.771]

b, a = gd(X, Y, 0.05, 1e-6)

print 'y = {0} * x + {1}'.format(a, b)
# y = 0.193953964855 * x + 0.01615274985
```


### 更优雅的实现

之前一直有个疑问，不清楚为什么用显卡可以提高优化算法的执行效率，直到我接触到了如下代码：

```python
loss = np.dot(X, theta) - Y
gradient = np.dot(X.T, loss) / m
theta -= alpha * gradient
```

利用矩阵运算，代码可以变的相当简洁，而且可以利用显卡多核的优势。

推导过程如下：

$$ 
LOSS 
= 
\begin{bmatrix}
loss_1 \\
loss_2 \\
\vdots \\
loss_m \\
\end{bmatrix}
=
\begin{bmatrix}
h_{\theta}(x_1) - y_1 \\
h_{\theta}(x_2) - y_2 \\
\vdots \\
h_{\theta}(x_m) - y_m \\
\end{bmatrix}
=
\begin{bmatrix}
\sum_{j=0}^nx_{1j}\theta_j \\
\sum_{j=0}^nx_{2j}\theta_j \\
\vdots \\
\sum_{j=0}^nx_{mj}\theta_j \\
\end{bmatrix}
-
\begin{bmatrix}
y_1 \\
y_2 \\
\vdots \\
y_m \\
\end{bmatrix}
=
\begin{bmatrix}
x_{1} \cdot \theta \\
x_{2} \cdot \theta \\
\vdots \\
x_{m} \cdot \theta \\
\end{bmatrix}
-
\begin{bmatrix}
y_1 \\
y_2 \\
\vdots \\
y_m \\
\end{bmatrix}
$$

$$
= \begin{bmatrix}
x_{10} & x_{11} & x_{12} & \cdots & x_{1n} \\
x_{20} & x_{21} & x_{22} & \cdots & x_{2n} \\
\vdots & \vdots & \vdots & \ddots & \vdots \\
x_{m0} & x_{m1} & x_{m2} & \cdots & x_{mn} \\
\end{bmatrix}
\cdot
\begin{bmatrix}
\theta_0 \\
\theta_1 \\
\vdots \\
\theta_n \\
\end{bmatrix}
-
\begin{bmatrix}
y_0 \\
y_1 \\
\vdots \\
y_m \\
\end{bmatrix}
= X \cdot \theta - Y
$$



$$ 
GRADIENT = 
\begin{bmatrix}
\frac{\partial}{\partial\theta_0}J(\theta) \\
\frac{\partial}{\partial\theta_1}J(\theta) \\
\vdots \\
\frac{\partial}{\partial\theta_n}J(\theta) \\
\end{bmatrix} 
=
\begin{bmatrix}
\sum_{i=1}^m(h_\theta(x_i) - y_i)x_{i0} \\
\sum_{i=1}^m(h_\theta(x_i) - y_i)x_{i1} \\
\vdots \\
\sum_{i=1}^m(h_\theta(x_i) - y_i)x_{in} \\
\end{bmatrix} 
=
\begin{bmatrix}
\sum_{i=1}^mloss_ix_{i0} \\
\sum_{i=1}^mloss_ix_{i1} \\
\vdots \\
\sum_{i=1}^mloss_ix_{in} \\
\end{bmatrix} 
$$

$$ 
= \begin{bmatrix}
x_{10} & x_{20} & \cdots & x_{m0} \\
x_{11} & x_{21} & \cdots & x_{m1} \\
\vdots \\
x_{1n} & x_{2n} & \cdots & x_{mn} \\
\end{bmatrix} 
\cdot
\begin{bmatrix}
loss_1 \\
loss_2 \\
\vdots \\
loss_m \\
\end{bmatrix} 
= X^T \cdot LOSS
$$

完整代码如下

```python
import numpy as np

def gd(X, Y, alpha, epsilon):
    m, n = np.shape(X)
    theta = np.ones(n)
    sse0, sse1, cnt = 0, 0, 0
    Xt = np.transpose(X)
    while True:
        hypothesis = np.dot(X, theta)
        loss = hypothesis - Y
        gradient = np.dot(Xt, loss) / m
        theta -= alpha * gradient

        loss2 = np.dot(X, theta) - Y
        sse1 = sum(l ** 2.0 for l in loss2) / (2 * m)
        print "[ Epoch {0} ] theta = {1}, gradient = {2}, sse = {3})".format(cnt, theta, gradient, sse1)
        cnt += 1
        if abs(sse1 - sse0) < epsilon:
            break
        else:
            sse0 = sse1
    return theta
```

```python
# 取x_0 = 1
X = [(1, 1.), (1, 2.), (1, 3.), (1, 4.), (1, 5.), (1, 6.), (1, 7.), (1, 8.), (1, 9.)]
Y = [0.199, 0.389, 0.580, 0.783, 0.980, 1.177, 1.380, 1.575, 1.771]

b, a = gd(X, Y, 0.05, 1e-6)

print 'y = {0} * x + {1}'.format(a, b)
# y = 0.193953964855 * x + 0.01615274985
```