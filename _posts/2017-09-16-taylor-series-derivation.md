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

### 导数
<span>对任意的$\epsilon > 0$, 都存在一个$\delta > 0$， 使得对任意的$\left| x - x_0 \right| <\delta$，都有$\left|\frac{f(x) - f(x_0)}{x - x_0} - A  \right| < \epsilon$，也即：$\lim_{x \to x_0} \frac{f(x) - f(x_0) }{x - x_0} = A$，那么称函数$y = f(x)$在点$x_0$处可导，并称这个极限为函数$y = f(x)$在点$x_0$处的导数。记作：</span>

设函数$y = f(x)$在点$x_)$的某个邻域内有定义，当自变量$x$在$x_0$处取得增量$\Delta x$（点$x_0 + \Delta x$仍在该邻域内）时，相应地函数$y$取得增量$\Delta y = f(x) - f(x_0)$；如果$\Delta y$与$\Delta x$之比当$\Delta x \to 0$时的极限存在，则称函数$y = f(x)$在点$x_0$处可导，并称这个极限为函数$y = f(x)$在点$x_0$处的导数，记为：

$$ f^{'}(x_0) = y^{'}|_{x=x_0} = \left. \frac{dy}{dx} \right|_{x=x_0} = \lim_{\Delta x \to 0} \frac{\Delta y}{\Delta x} = \lim_{\Delta x \to 0} \frac{f(x_0 + \Delta x) - f(x_0)}{\Delta x} = \lim_{x \to x_0} \frac{f(x) - f(x_0)}{x - x_0} $$

其中：$\Delta x = x - x_0$, $\Delta y = f(x) - f(x_0)$


