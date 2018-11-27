---
layout: post
title:  定义返回函数指针的函数
author: 詹子知(James Zhan)
date:   2008-08-08 17:15:00
meta:   版权所有，转载须声明出处
category: pdl
tags: [c, pdt]
---

### 基础知识： 

##### 定义函数指针：

```c
return_type (*func_pointer)(parameter_list)
```

##### 定义返回函数指针的函数：

```c
return_type(*function(func_parameter_list))(parameter_list)
```

定义了一个函数`function`，该函数的参数列表是`(function_patameter_list)`，返回类型是一个函数指针，这个函数指针的原型是`return_type(*)(parameter_list)`。

### 经典例子

#### signal函数原型

Linux 2.0之前版本

```c
void (*signal (int signo, void (*func)(int))) (int);
```

Linux 2.6 版本

```c
typedef void (*__sighandler_t) (int);
extern __sighandler_t signal (int __sig, __sighandler_t __handler)
```

### 示例

可以用以下两种方式定义返回函数指针的函数。第二种方式是第一种方式的替换， 也更易理解。

```c
int (*OP(char))(int, int);
```

```c
typedef int OP(int, int);
OP* fun(char c); 
```

```c
#include<stdio.h>

int (*opp(char))(int, int);
typedef int OP(int, int);
OP* fun(char c);

int add(int a, int b){
    return (a + b);
}
int product(int a, int b){
    return (a * b);
}

int main(void){
    int a = 2, b = 23;
    printf("Hello World:%d, %d/n", opp('+')(a, b), opp('*')(a, b));
    printf("Hello World:%d, %d/n", fun('+')(a, b), fun('*')(a, b));
    return 0;
} 

int (*opp(char c))(int a, int b){
    if (c == '+'){
        return add;
    } else {
        return product;
    }
}

OP* fun(char c){
    if(c == '+'){
        return add;
    }else{
        return product;
    }
}
```