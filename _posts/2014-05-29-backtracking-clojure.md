---
layout: post
title:  "回溯算法Clojure实现"
author: 詹子知(James Zhan)
date:   2014-05-29 19:52:00
meta:   版权所有，转载须声明出处
category: algorithm
tags: [algorithm, clojure, backtracking, fp]
---

### 什么是回溯法
回溯法（探索与回溯法）是一种选优搜索法，又称为试探法，按选优条件向前搜索，以达到目标。但当探索到某一步时，发现原先选择并不优或达不到目标，就退回一步重新选择，这种走不通就退回再走的技术为回溯法，而满足回溯条件的某个状态的点称为“回溯点”。

包含问题的所有解的解空间树中，按照深度优先搜索的策略，从根结点出发深度探索解空间树。当探索到某一结点时，要先判断该结点是否包含问题的解，如果包含，就从该结点出发继续探索下去，如果该结点不包含问题的解，则逐层向其祖先结点回溯。（其实回溯法就是对隐式图的深度优先搜索算法）。 若用回溯法求问题的所有解时，要回溯到根，且根结点的所有可行的子树都要已被搜索遍才结束。 而若使用回溯法求任一个解时，只要搜索到问题的一个解就可以结束。

### 算法实现

#### 算法准备

准备一个默认的打印函数，把数组a中的数组转换成字母打印出来。

~~~clojure
(defn display [c]
  (println (map #(char (+ 65 %)) c)))
~~~

实现方式，在这里，我们设计回溯法的实现需要接受是个参数，分别是n, m, handle，以及block。

1. n, m决定我们搜索的解空间大小，比如，给定6， 3， 则整个解空间范围为111, 112, ..., 666（约定默认计数从1开始），整个解空间大小为6^3 = 216。
2. handle一般用于打印结果。
3. block则是我们要选择的约束函数。对于执行过程中某一个特定位置，如果当前的值满足要求，则继续找下一个位置的值，否则，把当前值加1，如果加1以后的结果超过n的值，则退回到上一位置，并把上一位置的值加1，继续往后查找。

#### 算法实现

~~~clojure
(defn backtrack [n m pred? handle]
  (letfn [(dfs [ref-a k]
            (doseq [i (range n)] (do
                                   (dosync (alter ref-a assoc k i))
                                   (if (pred? @ref-a k)
                                     (if (= k (- m 1))
                                       (handle @ref-a)
                                       (dfs ref-a (inc k)))))))]
    (let [ref-a (ref (vec (repeat m 0)))] (dfs ref-a 0))))                              
~~~


#### 使用回溯法实现其他算法

1. 列出全部解空间

    ~~~clojure
    (defn counter [n, m]
      (backtrack n m
        (fn [c k]
          true)
        display))                                 
    ~~~

2. 实现排列算法

    ~~~clojure
    (defn permutation [n m]
      (backtrack n m
        (fn [c k]
          (let [a (subvec c 0 k)
                i (nth c k)]
            (->> a (filter (partial = i)) empty?)))
        display))
    ~~~                                                  

3. 实现组合算法  
  
    ~~~clojure                                                     
    (defn combination [n m]
      (backtrack n m
        (fn [c k]
          (let [a (subvec c 0 k)
                i (nth c k)]
            (->> a (filter (partial <= i)) empty?)))
        display))
                                              
    ~~~
    
4. 解决n皇后问题 

    ~~~clojure                                                     
    (defn nqueue [n]
      (backtrack n n
        (fn [c k]
          (let [a (map #(vector %1 %2) (subvec c 0 k) (range))
                i (nth c k)]
            (->> a (filter #(or (= i (nth % 0)) (= (- k (nth % 1)) (abs (- i (nth % 0)))))) empty?)))
        (fn [c] (println (map #(inc %) c)))))                                              
    ~~~
    
事实上，回溯法能解决的算法问题远不仅于此，回溯法本质上是穷举法的一种，只要解包含特征：后一个位置的选择依赖于前面的选择状态，我们便可以使用回溯法来实现。尽管回溯法的时间复杂度为n^m，但是由于在搜索解空间树的过程中，很多分支在一早就被剪去了，所以在实际应用过程中，其往往什么高效。

#### 实例演示

~~~clojure
(println "counter=>")
(counter 3 3)

(println "permutation=>")
(permutation 3 3)

(println "combination=>")
(combination 4 2)

(println "nqueue => ")
(nqueue 4)                                              
~~~

[查看完整代码](https://github.com/jameszhan/rhea/blob/master/codes/clojure/calculation/backtrack.clj)。

