---
layout: post
title:  "回溯算法Ruby实现"
author: 詹子知(James Zhan)
date:   2011-02-14 10:52:00
meta:   版权所有，转载须声明出处
category: algorithm
tags: [algorithm, ruby, backtracking]
---

### 什么是回溯法
回溯法（探索与回溯法）是一种选优搜索法，又称为试探法，按选优条件向前搜索，以达到目标。但当探索到某一步时，发现原先选择并不优或达不到目标，就退回一步重新选择，这种走不通就退回再走的技术为回溯法，而满足回溯条件的某个状态的点称为“回溯点”。

包含问题的所有解的解空间树中，按照深度优先搜索的策略，从根结点出发深度探索解空间树。当探索到某一结点时，要先判断该结点是否包含问题的解，如果包含，就从该结点出发继续探索下去，如果该结点不包含问题的解，则逐层向其祖先结点回溯。（其实回溯法就是对隐式图的深度优先搜索算法）。 若用回溯法求问题的所有解时，要回溯到根，且根结点的所有可行的子树都要已被搜索遍才结束。 而若使用回溯法求任一个解时，只要搜索到问题的一个解就可以结束。

### 算法实现

#### 算法准备

准备一个默认的打印函数，把数组a中的数组转换成字母打印出来。

~~~ruby
ALPHABET = Array('A'..'Z')                       
DISPLAY = lambda {|a| p a.map{|i|ALPHABET[i]}}   
~~~

实现方式，在这里，我们设计回溯法的实现需要接受是个参数，分别是n, m, handle，以及block。

1. n, m决定我们搜索的解空间大小，比如，给定6， 3， 则整个解空间范围为111, 112, ..., 666（约定默认计数从1开始），整个解空间大小为6^3 = 216。
2. handle一般用于打印结果。
3. block则是我们要选择的约束函数。对于执行过程中某一个特定位置，如果当前的值满足要求，则继续找下一个位置的值，否则，把当前值加1，如果加1以后的结果超过n的值，则退回到上一位置，并把上一位置的值加1，继续往后查找。

#### 递归版本

~~~ruby
def backtrack(n, m, handle = DISPLAY) 
  dfs = lambda{|a, k|              
    (0...n).each do |i|               
      a[k] = i                        
      if yield(a, k)                  
        if k == m - 1                 
          handle.call(a)              
        else                          
          dfs.call(a, k + 1)          
        end                           
      end                             
    end                               
  }                                   
  a = Array.new(m, -1)                
  dfs.call(a, 0)                      
end                                   
~~~

#### 非递归版本实现

~~~ruby
def backtrack(n, m, handle = DISPLAY)  
  k, a = 0, Array.new(m, -1)           
  while k >= 0                         
    a[k] += 1                          
    while a[k] < n && !yield(a, k)     
      a[k] += 1                        
    end                                
    if a[k] == n || k == m             
      k -= 1                           
    else                               
      if k == m - 1                    
        handle.call(a)                 
      else                             
        k += 1                         
        a[k] = -1                      
      end                              
    end                                
  end                                  
end                                    
~~~

#### 使用回溯法实现其他算法

1. 列出全部解空间

    ~~~ruby
    def counter(n, m, &handle)             
      handle = DISPLAY unless handle       
      backtrace(n, m, handle) do |a, k|    
        true                               
      end                                  
    end                                    
    ~~~

2. 实现排列算法

    ~~~ruby
    def permutation(n, m, &handle)                       
      handle = DISPLAY unless handle                     
      backtrack(n, m, handle) do |a, k|                  
        succ = true                                      
        for i in (0...k) do                              
         if a[i] == a[k]                                 
           succ = false                                  
           break                                         
         end                                             
        end                                              
        succ                                             
      end                                                
    end
    ~~~                                                  

3. 实现组合算法  
  
    ~~~ruby                                                     
    def combination(n, m, &handle)                       
      handle = DISPLAY unless handle                     
      backtrace(n, m, handle) do |a, k|                  
        succ = true                                      
        (0...k).each do |i|                              
          if a[i] >= a[k]                                
            succ = false                                 
            break                                        
          end                                            
        end                                              
        succ                                             
      end                                                
    end                                                  
    ~~~
    
4. 解决n皇后问题 

    ~~~ruby                                                     
    def nqueen(n, &handle)                               
      backtrace(n, n, handle) do |a, k|                  
        succ = true                                      
        (0...k).each do |i|                              
          if a[i] == a[k] || (a[i] - a[k]).abs == k - i  
            succ = false                                 
            break                                        
          end                                            
        end                                              
        succ                                             
      end                                                
    end                                                  
    ~~~
    
事实上，回溯法能解决的算法问题远不仅于此，回溯法本质上是穷举法的一种，只要解包含特征：后一个位置的选择依赖于前面的选择状态，我们便可以使用回溯法来实现。尽管回溯法的时间复杂度为n^m，但是由于在搜索解空间树的过程中，很多分支在一早就被剪去了，所以在实际应用过程中，其往往什么高效。

#### 实例演示

~~~ruby
if __FILE__ == $0   
    puts 'counter =>'                              
    counter(3, 3)                                  
                                                   
    puts 'permutation =>'                          
    permutation(3, 3){|a|p a.map{|i| i + 1}}       
                                                   
    puts 'combination =>'                          
    combination(5, 2){|a|p a.map{|i| i + 1}}       
                                                   
    puts 'nqueue => '                              
    nqueen(5){|a|p a.map{|i| i + 1}}   
end                                                
~~~

[查看完整代码](https://github.com/jameszhan/rhea/blob/master/codes/ruby/algorithm/backtracking.rb)。

