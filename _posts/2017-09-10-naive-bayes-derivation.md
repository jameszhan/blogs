---
layout: post
title:  "朴素贝叶斯从放弃到入门"
author: 詹子知(James Zhan)
date:   2017-09-10 23:00:00
meta:   版权所有，转载须声明出处
category: ml
tags: [ml, mathematics, algorithm, python]
---

## 理论基础

### 联合概率

联合概率表示两个事件共同发生的概率。A与B的联合概率表示为$P(AB)$，$P(A,B)$或者$P(A \bigcap B)$。

联合概率可以推广到任意又穷多个事件出现的情况，设（$A_1,A_2,\cdots,A_n$）为任意n个事件（$n\ge2$），事件$A_1,A_2,\cdots,A_n$共同发生的概率记为$P(A_1A_2 \dots A_n)$，$P(A_1,A_2,\dots,A_n)$或者$P(A_1 \bigcap A_2 \bigcap \dots \bigcap A_n)$

### 条件概率

<p>设A，B 是两个事件，且$P(A) > 0$，则称$P(B|A) = \frac{P(AB)}{P(A)}$为在事件A发生的条件下，事件B发生的条件概率。一般地，$P(B|A) \not= P(B)$ ，且它满足以下三条件：（1）非负性；（2）规范性；（3）可列可加性。</p>

<p>设E为随机试验，Ω为样本空间，A，B为任意两个事件，设$P(A)>0$，称$P(B|A) = \frac{P(AB)}{P(A)}$为在事件A发生的条件下事件B的条件概率。</p>

<p>上述乘法公式可推广到任意有穷多个事件时的情况。
设（$A_1,A_2,\cdots,A_n$）为任意n个事件（$n\ge2$）且$P(A_1,A_2,\cdots,A_n)>0$，则$P(A_1A_2 \cdots A_n)=P(A_1)P(A_2|A_1) \cdots P(A_n|A_1A_2 \cdots A_{n-1}) = \prod_{i=1}^n P(A_i|A_1 \cdots A_{i-1})$。</p>

对于一段文本序列$S=w_1,w_2,\cdots,W_T$，它的概率可表示为：
$$P(S) = P(w_1,w_2,\cdots,W_T) = \prod_{t=1}^T(w_t|w_1 \cdots w_{t-1}) = P(w_1) \cdot P(w_2|w_1) \cdot P(w_3|w_1w_2) \cdots P(w_T|w_1w_2 \cdots w_{T-1})$$

#### Ngram模型

1.Ngram模型

<span>$$P(w_t|w_1w_2 \cdots w_{t-1}) \approx P(w_t|w_{t-n+1} \cdots w_{t-1})$$</span>

2.bigram

<span>$$P(w_t|w_1w_2 \cdots w_{t-1}) \approx P(w_t|w_{t-1})$$</span>

3.trigram

<span>$$P(w_t|w_1w_2 \cdots w_{t-1}) \approx P(w_t|w_{t-1}w_{t-2})$$</span>

#### 独立性假设

$$P(S) = P(w_1,w_2,\cdots,w_T) \approx \prod_{t=1}^T P(w_t) = P(w_1)P(w_2) \cdots P(w_T)$$

#### 其他

$$ 先验概率 = P(原因)；后验概率 = P(原因|结果) $$

$$ P(a,b|c) = \frac{P(a,b,c)}{P(c)} = \frac{P(a,b,c)}{P(b,c)} \cdot \frac{P(b,c)}{P(c)} = P(a|b,c) \cdot P(b|c)$$


### 完备事件组/样本空间的划分

设（$A_1,\cdots,A_i,\cdots,A_n$）是一组事件，若

1. $\forall_{i\not=j} A_i \bigcap A_j = \emptyset; i,j\in(1,2,\cdots,n)$
2. $\sum_{i=1}^n A_i = \Omega$

则称（$A_1,\cdots,A_i,\cdots,A_n$）是样本空间Ω的一个划分，或称为样本空间Ω 的一个完备事件组。

### 全概率公式

<span>设（$A_1,\cdots,A_i,\cdots,A_n$）施一个完备事件组，则有$P(B) = \sum_{i=1}^n P(A_i) \cdot P(B|A_i) = \sum_{i=1}^n P(A_iB)$</span>

### 贝叶斯公式

设（$A_1,\cdots,A_i,\cdots,A_n$）是一组完备事件组，则有
$$P(A_i|B) = \frac{PA_iB}{P(B)} = \frac{P(A_i)P(B|A_i)}{\sum_{j=1}^nP(A_j)P(B|A_j)}$$

> 根据条件概率和全概率公式，很容易得出贝叶斯公式。


## 贝叶斯定理的应用

### 贝叶斯定理在艾滋病检测上的应用

假设艾滋病在人群中的发病率为万分之一，艾滋病检测假阴性的概率千分之一（假阴性的意思是本来有病应该呈现阳性，但是呈现了阴性）；艾滋病检测假阳性的概率为万分之一（假阳性意思是本来没病应该呈现阴性，但是呈现了阳性）。假设某人在某次检测当中结果呈现阳性，那么他真正感染艾滋病的概率是多少？

```python
# 艾滋病在人群中的发病概率P(T)
p(T) = 0.0001
# 在有艾滋病的场景下，检测为阳性的概率P(检测为阳性|患病)，即1-P(假阴性)
p(fT) = 0.999
# 在没有艾滋病的场景下，检测为阳性的概率P(检测为阳性|不患病)，即假阳性
p(f_T) = 0.0001
```

<p>根据贝叶斯公式，检测为阳性，感染艾滋病的概率

$$P(患病|检测为阳性) = \frac{P(检测为阳性|患病) \cdot P(患病)}{P(检测为阳性)}$$

$$P(检测为阳性)= P(检测为阳性|患病) \cdot P(患病) + P(检测为阳性|不患病) \cdot P(不患病)$$
</p>

```python
def bayes(pT, pfT, pf_T):
    return (pfT * pT) / (pfT * pT + pf_T * (1 - pT))

print bayes(pT, pfT, pf_T)
```

<p>将数据代入公式，计算得出P(患病|检测为阳性)=49.977%，看起来还是不能确定该被试是否感染艾滋病（被试的感染艾滋病的几率从万分之一上升到近50%）。为了确定被试是否真正感染艾滋病，我们只需再进行一次检测，如果下一次检测还呈阳性，再一次应用贝叶斯定理，则该被试感染艾滋病的几率瞬间提升到99.99%，基本可以确定该被试感染艾滋病了。</p>

```python
pT = 49.977
print bayes(pT, pfT, pf_T)
# 0.999899817803
```

### 贝叶斯定理在垃圾邮件过滤上的应用

给定训练集，垃圾邮件和正常邮件各5000封，假定词$w_1$，$w_2$出现的频率如下。

| 词 | 邮件类别 | 词在该邮件类别中的数量 |
| -- | ------ | ------------------- |
| $w_1$ | Spam | 250 |
| $w_1$ | Health | 5 |
| $w_2$ | Spam | 495 |
| $w_2$ | Health | 5 |


```python
# P(垃圾邮件)
pS = 0.5
# P(正常邮件)
pH = 1 - pS # 0.5
# P(w1|垃圾邮件)
pw1S = 250.0 / 5000 # 0.05
# P(w1|正常邮件)
pw1H = 5.0 / 5000 # 0.001
```

根据贝叶斯定理，我们很容易计算$P(垃圾邮件|w_1)$的概率。

```python
def bayes(pS, pwS, pwH):
    return (pwS * pS) / (pwS * pS + pwH * (1 - pS))

# P(垃圾邮件|w1)
pSw1 = bayes(pS, pw1S, pw1H) # 0.980392156863
```

其实根据样本分布，我们也很容易计算<b>$P(垃圾邮件|w_1)$</b>的概率。

$$ P(垃圾邮件|w_1) = \frac{P(w_1,垃圾邮件)}{P(w_1)} = \frac{250}{250 + 5} = 98.04% $$

我们可以看出样本中包含$w_1$的邮件是垃圾邮件的概率超过98%，如果样本的分布和总体的分布一致，可以看出$w_1$的推断能力很强，尽管如此，我们依然不能根据单个词来明确的判断一封包含$w_1$的新邮件就是垃圾邮件。我们需要更多的证据。

一封邮件由多个词组成，如果一封邮件不只是包含$w_1$，还包含$w_2$，那么这封邮件的是垃圾概率是多少呢。

$$ P(垃圾邮件|w_1,w_2) = \frac{P(垃圾邮件,w_1,w_2)}{P(w_1,w_2)} $$

$$ P(w_1,w_2) = P(w_1,w_2|垃圾邮件) \cdot P(垃圾邮件) + P(w_1,w_2|正常邮件) \cdot P(正常邮件) = P(w_1,w_2,垃圾邮件) + P(w_1,w_2,正常邮件) $$

也即：

$$ P(垃圾邮件|w_1,w_2) = \frac{P(垃圾邮件,w_1,w_2)}{P(w_1,w_2,垃圾邮件) + P(w_1,w_2,正常邮件)} $$

这里涉及两个联合概率事件。

1. 已知$w_1$，$w_2$的情况下，该邮件是垃圾邮件的概率，即$P(w_1,w_2,垃圾邮件)$，记为 $E_1$。
2. 已知$w_1$，$w_2$的情况下，该邮件是正常邮件的概率，即$P(w_1,w_2,正常邮件)$，记为 $E_2$。

| 事件 | $w_1$ | $w_2$ | 垃圾邮件 |
| -- | ------ | ------ | ------ |
| $E_1$ | 出现 | 出现 | 是 |
| $E_2$ | 出现 | 出现 | 不是 |

$$ P(E_1) = P(w_1,w_2,垃圾邮件) = P(垃圾邮件) * P(w_1|垃圾邮件) * P(w_2|垃圾邮件,w_1) $$

然而<b>$P(w_2|垃圾邮件,w_1)$</b>该怎么计算呢？现在是朴素贝叶斯出场的时候了，基于独立性假设，$w_1$，$w_2$之间相互独立。则有：

$$ P(w_2|垃圾邮件,w_1) = P(w_2|垃圾邮件) $$ 

```python
# P(S,w1,w2) = P(S) * P(w1|S) * P(w2|S,w1)
# Independence hypothesis => P(S,w1,w2) = P(S) * P(w1|S) * P(w2|S)
def joint(pS, pw1S, pw2S):
    return pS * pw1S * pw2S
```

<span>$P(E_1) = P(垃圾邮件) * P(w_1|垃圾邮件) * P(w_2|垃圾邮件)$</span>

<span>$P(E_2) = P(正常邮件) * P(w_1|正常邮件) * P(w_2|正常邮件)$</span>

<span>目标概率：$P(垃圾邮件|w_1,w_2) = \frac{P(E_1)}{P(E_1) + P(E_2)}$</span>


```python
# P(w2|垃圾邮件)
ps2W = 495.0 / 5000 # 0.001
# P(w2|正常邮件) 
pw2H = 5.0 / 5000 # 0.099

# P(E1)
pE1 = joint(pS, pw1S, pw2S) # 0.002475
pE2 = joint(pH, pw1H, pw2H) # 5e-07

# P(垃圾邮件|w_1,w_2)
print pE1 / (pE1 + pE2) # 0.999798020602
```

### 黑客与画家中的疑问

Paul Graham在他的《黑客与画家》当中，有举过朴素贝叶斯的例子，他的做法是选出区分度最高的15个词，并计算其联合概率，并给出了最终公式。

$$ P_{spam|w_1,w_2,\cdots,w_{15}} = \frac{\prod_{i=1}^{15} P_{spam|w_i}}{\prod_{i=1}^{15} P_{spam|w_i} + \prod_{i=1}^{15} (1 - P_{spam|w_i})} $$

那么这个公式是怎么推导出来的呢？为了方便，我们取$w_1$，$w_2$两个词来尝试推导出这个公式，简化以后，公式变为：

$$ P_{spam|w_1,w_2} = \frac{P_{spam|w_1} \cdot P_{spam|w_2}}{P_{spam|w_1} \cdot P_{spam|w_2} + (1 - P_{spam|w_1}) \cdot (1 - P_{spam|w_2})} $$

下面我们开始推导过程。

根据贝叶斯定理有：

$$ P_{spam|w_1,w_2} = \frac{P_{w_1,w_2|spam} \cdot P_{spam}}{P_{w_1,w_2}} = \frac{P_{w_1,w_2|spam} \cdot P_{spam}}{P_{w_1,w_2|spam} \cdot P_{spam} + P_{w_1,w_2|\tilde{spam}} \cdot P_{\tilde{spam}}} $$

<span>根据独立性假设$P_{w_1,w_2|spam} = P_{w_1|w_2,spam} \cdot P_{w_2|spam} = P_{w_1|spam} \cdot P_{w_2|spam}$，得到：</span>

$$ P_{spam|w_1,w_2} \approx \frac{P_{w_1|spam} \cdot P_{w_2|spam} \cdot P_{spam}}{P_{w_1|spam} \cdot P_{w_2|spam} \cdot P_{spam} + P_{w_1|\tilde{spam}} \cdot P_{w_2|\tilde{spam}} \cdot P_{\tilde{spam}}} $$

<span>根据贝叶斯公式$P_{w|S} = \frac{P_{S|w} \cdot P_w}{P_S}$，得到：</span>

$$ P_{spam|w_1,w_2} \approx \frac{P_{spam|w_1} \cdot P_{w_1} \cdot P_{spam|w_2} \cdot P_{w_2}}{P_{spam|w_1} \cdot P_{w_1} \cdot P_{spam|w_2} \cdot P_{w_2} + \frac{P_{\tilde{spam}|w_1} \cdot P_{w_1} \cdot P_{\tilde{spam}|w_2} \cdot P_{w_2} \cdot P_{spam}}{P_{\tilde{spam}}}} = \frac{P_{spam|w_1} \cdot P_{spam|w_2}}{P_{spam|w_1} \cdot P_{spam|w_2} + \frac{P_{\tilde{spam}|w_1} \cdot P_{\tilde{spam}|w_2} \cdot P_{spam}}{P_{\tilde{spam}}}} $$

<span>取$P_{spam}=P_{\tilde{spam}}=0.5$，得到：</span>

$$ P_{spam|w_1,w_2} \approx \frac{P_{spam|w_1} \cdot P_{spam|w_2}}{P_{spam|w_1} \cdot P_{spam|w_2} + P_{\tilde{spam}|w_1} \cdot P_{\tilde{spam}|w_2}} $$

又因为：

$$P_{\tilde{spam}|w} = \frac{P_{w|\tilde{spam}} \cdot P_{\tilde{spam}}}{P_w} = \frac{P_{w|\tilde{spam}} \cdot P_{\tilde{spam}}}{P_{w|\tilde{spam}} \cdot P_{\tilde{spam}} + P_{w|spam} \cdot P_{spam}} = 1 - \frac{P_{w|spam} \cdot P_{spam}}{P_{w|\tilde{spam}} \cdot P_{\tilde{spam}} + P_{w|spam} \cdot P_{spam}} = 1 - P_{spam|w} $$

最终可得：

$$ P_{spam|w_1,w_2} = \frac{P_{spam|w_1} \cdot P_{spam|w_2}}{P_{spam|w_1} \cdot P_{spam|w_2} + (1 - P_{spam|w_1}) \cdot (1 - P_{spam|w_2})} $$

```python
pSw1 = bayes(pS, pw1S, pw1H)
pSw2 = bayes(pS, pw2S, pw2H)
e1 = pS * pSw1 * pSw2
e2 = pH * (1 - pSw1) * (1 - pSw2)
print e1 / (e1 + e2) # 0.999798020602
```

可见，在$P_{spam}=P_{\tilde{spam}}=0.5$的情况下，结果和之前是一样的。

推广到15个词，就得到：

$$ P_{spam|w_1,w_2,\cdots,w_{15}} = \frac{\prod_{i=1}^{15} P_{spam|w_i}}{\prod_{i=1}^{15} P_{spam|w_i} + \prod_{i=1}^{15} (1 - P_{spam|w_i})} $$


### 实战垃圾邮件过滤

#### 公式推导

给定一个邮件M，它由文本序列$S=w_1,w_2,\ldots,w_n$组成，则给定邮件为垃圾为垃圾邮件的概率为：
 
$$ P(spam|M) = P(spam|w_1,w_2,\cdots,w_n) = \frac{P(w_1,w_2,\cdots,w_n|spam) \cdot P(spam)}{P(w_1,w_2,\ldots,w_n|spam) \cdot P(spam) + P(w_1,w_2,\ldots,w_n|\tilde{spam}) \cdot P(\tilde{spam}) } $$

根据朴素贝叶斯的独立性假设，则有：

$$ P(spam|M) \approx \frac{\prod_{i=1}^n P(w_i|spam)}{\prod_{i=1}^n P(w_i|spam) \cdot P(spam) + \prod_{i=1}^n P(w_i|\tilde{spam}) \cdot P(\tilde{spam}) } $$

#### 概率计算

* 垃圾邮件概率：$P(spam) = \frac{count(mc[spam])}{count(mc[spam]) + count(mc[health])}$
* 正常邮件概率：$P(\tilde{spam}) = 1 - P(spam)$
* $w_i$在正常邮件中的概率：<span>$P(w_i|\tilde{spam}) = \frac{count(wc[w_i][health])}{count[mc[health]]}$，也就是 $\frac{w_i关联的正常邮件数量}{正常邮件的数量}$</span>
* $w_i$在垃圾邮件中的概率：<span>$P(w_i|spam) = \frac{count(wc[w_i][spam])}{count[mc[spam]]}$，也就是 $\frac{w_i关联的垃圾邮件数量}{垃圾邮件的数量}$</span>

#### 代码演示

```python
import numpy as np
class AntiSpam:
    def __init__(self):
        self.wc = {} # 记录每个词在垃圾邮件和正常邮件中出现的次数
        self.mc = {} # 记录垃圾邮件和正常邮件中出现的次数

    def incw(self, word, category):
        self.wc.setdefault(word, {})
        self.wc[word].setdefault(category, 0)
        self.wc[word][category] += 1

    def incm(self, category):
        self.mc.setdefault(category, 0)
        self.mc[category] += 1

    def train(self, words, category):
        for w in words:
            self.incw(w, category)
        self.incm(category)

    def show(self):
        print "mc: %s \nwc:%s\n\n\n" % (self.mc, self.wc)

    def wcount(self, word, category):
        if word in self.wc and category in self.wc[word]:
            return float(self.wc[word][category])
        return 1.0

    def wprob(self, word, category):
        return self.wcount(word, category) / self.mc[category]

    def cprob(self, category):
        return float(self.mc[category]) / sum(self.mc.values())

    # 利用对数来计算
    def safe_prob(self, words):
        s, h = 0.0, 0.0
        for w in words:
            s += np.log(self.wprob(w, 'spam'))
            h += np.log(self.wprob(w, 'health'))
        s += np.log(self.cprob('spam'))
        h += np.log(self.cprob('health'))
        return np.exp(s) / (np.exp(s) + np.exp(h))

    # 利用乘法来计算
    def prob(self, words):
        sprob, hprob = 1.0, 1.0
        for w in words:
            sprob *= self.wprob(w, 'spam')
            hprob *= self.wprob(w, 'health')
        sprob *= self.cprob('spam')
        hprob *= self.cprob('health')
        return sprob / (sprob + hprob)
```

模拟样本训练

```python
antiSpam = AntiSpam()
for i in range(4989):
    antiSpam.train(['hello', 'world', 'todo'], 'health')

for k in range(4901):
    antiSpam.train(['invoice', 'bill', 'todo'], 'spam')

antiSpam.train(['discount', 'promotion', 'cool'], 'health')
for k in range(10):
    antiSpam.train(['spam', 'mail', 'attention'], 'health')

for k in range(9):
    antiSpam.train(['discount', 'promotion', 'cool'], 'spam')

for k in range(90):
    antiSpam.train(['spam', 'mail', 'attention'], 'spam')

antiSpam.show()
# mc: {'health': 5000, 'spam': 5000} 
# wc: {'attention': {'health': 10, 'spam': 90}, 'spam': {'health': 10, 'spam': 90}, 'bill': {'spam': 4901}, 'discount': {'health': 1, 'spam': 9}, 'invoice': {'spam': 4901}, 'mail': {'health': 10, 'spam': 90}, 'world': {'health': 4989}, 'promotion': {'health': 1, 'spam': 9}, 'todo': {'health': 4989, 'spam': 4901}, 'hello': {'health': 4989}, 'cool': {'health': 1, 'spam': 9}}
```

垃圾邮件过滤

```python
print antiSpam.prob(['discount', 'spam', 'todo'])         # 0.987588626017
print antiSpam.safe_prob(['discount', 'spam', 'todo'])    # 0.987588626017

print antiSpam.prob(['hello', 'mail', 'todo'])            # 0.00176901392183
print antiSpam.safe_prob(['hello', 'mail', 'todo'])       # 0.00176901392183

print antiSpam.prob(['hello', 'mail', 'todo'])            # 0.999999995374
print antiSpam.safe_prob(['hello', 'mail', 'todo'])       # 0.999999995374
```