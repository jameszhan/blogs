---
layout: post
title:  "数学分析笔记"
author: 詹子知(James Zhan)
date:   2017-11-01 23:00:00
meta:   版权所有，转载须声明出处
category: mathematics
tags: [mathematics, algorithm, latex]
---


#### $\ln x$ 导数的推导


$$ \frac{d}{dx}\ln x 
= \lim_{h \to 0} \frac{\ln(x + h) - \ln(x)}{h} 
= \lim_{h \to 0} \frac{\ln\left(\frac{x + h}{x}\right)}{h} 
= \lim_{h \to 0} \frac{\ln\left(1 + \frac{h}{x}\right)}{h} $$


$$ = \lim_{h \to 0} \frac{\ln(x + h) - \ln(x)}{x \cdot \left(\frac{h}{x}\right)} 
= \frac{1}{x} \cdot \lim_{h \to 0} \frac{\ln\left(1 + \left(\frac{h}{x}\right)\right)}{\frac{h}{x}} 
= \frac{1}{x} \cdot \lim_{h \to 0} \ln\left(1 + \frac{h}{x}\right)^{\frac{x}{h}} $$


因为：

$$ \lim_{u \to 0}\left(1 + u\right)^{\frac{1}{u}} = e $$

则有：

$$ \frac{d}{dx}\ln x 
= \frac{1}{x} \cdot \ln\left(\lim_{\frac{h}{x} \to 0} \left(1 + \frac{h}{x}\right)^{\frac{x}{h}}\right)
= \frac{1}{x} \cdot \ln e
= \frac{1}{x} $$


#### 逻辑回归损失函数导数

$$ J(\theta) = \frac{1}{m}\sum_{i=1}^m Cost\left(h_{\theta}\left(x^{(i)}\right),y^{(i)}\right) 
= -\frac{1}{m}[\sum_{i=1}^m y^{(i)}\log h_{\theta}\left(x^{(i)}\right) 
+ \left(1 - y^{(i)}\right)\log\left(1 - h_{\theta}\left(x^{(i)}\right)\right)] $$

因为：$ y = \frac{1}{1 + e^{-x}} $, $(1 - y) = \frac{e^{-x}}{1 + e^{-x}} $ 
可知
$ \frac{dy}{dx} = y \cdot (1 - y) = \frac{e^{-x}}{(1 + e^{-x})^2} $，
则有：

$$ \frac{\partial}{\partial\theta_j}J(\theta) = -\frac{1}{m}[\sum_{i=1}^m 
y^{(i)} \frac{h_{\theta}^{'}\left(x^{(i)}\right)}{h_{\theta}\left(x^{(i)}\right)}\cdot x_j^{(i)}
- \left(1 - y^{(i)}\right)\frac{h_{\theta}^{'}\left(x^{(i)}\right)}{1 - h_{\theta}\left(x^{(i)}\right)}\cdot x_j^{(i)}] $$

$$ = -\frac{1}{m}\sum_{i=1}^m \left(y^{(i)}\left(1 - h_{\theta}(x^{(i)})\right) 
- \left(1 - y^{(i)}\right)h_{\theta}(x^{(i)})\right) x_j^{(i)} $$

$$ = -\frac{1}{m}\sum_{i=1}^m \left(y^{(i)} - h_{\theta}(x^{(i)})\right)x_j^{(i)} 
= \frac{1}{m}\sum_{i=1}^m \left(h_{\theta}(x^{(i)}) - y^{(i)}\right)x_j^{(i)} 
$$
