---
layout: post
title:  "归并排序(C语言描述)"
author: 詹子知(James Zhan)
date:   2009-10-10 16:52:00
meta:   版权所有，转载须声明出处
categories: algorithm
tags: [算法, C]
---

归并排序是建立在归并操作上的一种有效的排序算法。
该算法是采用分治法（Divide and Conquer）的一个非常典型的应用。归并排序算法以O（nlogn）最坏情形运行时间运行，而所使用的比较次数几乎是最优的。但它的一个显著问题就是需要额外的存储空间来辅助排序，空间复杂度是O(n)的，与quicksort和heapsort相比就逊色了不少，不过也可以实现空间复杂度为O（1）的归并排序，这将增加比较操作和交换操作的次数。归并排序可以使用在外部排序上：一般两路的外部排序是从源文件里读出内存大小的一块，然后在内存中排序，在放回文件里，这样生成若干文件。然后在从其中两个文件中读数据，按照merge的方式写到另一个文件中去。这一步根本用不到辅助空间。唯一可能用到辅助空间的地方是前面的一步，即将一块数据在内存中排序。
  
### 归并操作

归并操作(merge)，也叫归并算法，指的是将两个已经排序的序列合并成一个序列的操作。

归并操作的工作原理如下：

1. 申请空间，使其大小为两个已经排序序列之和，该空间用来存放合并后的序列
2. 设定两个指针，最初位置分别为两个已经排序序列的起始位置
3. 比较两个指针所指向的元素，选择相对小的元素放入到合并空间，并移动指针到下一位置
4. 重复步骤3直到某一指针达到序列尾
5. 将另一序列剩下的所有元素直接复制到合并序列尾
 
### 归并排序
归并排序具体工作原理如下（假设序列共有n个元素）:

1. 将序列每相邻两个数字进行归并操作（merge），形成floor(n / 2)个序列，排序后每个序列包含两个元素
2. 将上述序列再次归并，形成floor(n / 4)个序列，每个序列包含四个元素
3. 重复步骤2，直到所有元素排序完毕  


算法演示1 （非递归版本）: 

~~~c
#include<stdio.h>
#include<stdlib.h> 
void merge(int[], int[], int, int);
void mergeSort(int[], int); 
int main(void){
       int a[] = {26, 5, 37, 1, 61, 11, 59, 15, 48, 19};
       int i, len = 10;
       printf("source data is: ");
       for(i = 0; i < len; i++){
              printf("[%2d]", a[i]);
       }
       printf("/n");
       mergeSort(a, len);
       printf("/n");
       printf("after sort, the data is: ");
       for(i = 0; i < len; i++){
              printf("%4d", a[i]);
       }
       printf("/n");
       return 0;
} 
void display(int a[], int k, int n){  
       int i, count = 1;
       for(i = 1; i <= n; i++){
              if((i == n) && (i % (2 * k) != 0)){
                     printf("%4d]", a[i - 1]);
              }else{
                     if((i % (2 * k)) == 1){
                            printf("[%2d", a[i - 1]);
                     }else if(i % (2 * k) == 0){
                            printf("%4d]", a[i -1]);
                     }else{
                            printf("%4d", a[i - 1]);
                     }
              }    
       }
       printf("/n");
} 
void mergeSort(int a[], int n){
       int *t, k = 1;
       if((t = malloc(sizeof(int) * n)) == NULL){
              printf("allocate array space failure!");
              exit(1);
       }    
       while(k < n){
              merge(a, t, k, n);
              display(a, k, n);
              k <<= 1;
       }
       free(t);
} 
void merge(int src[], int dest[], int k, int n){
       int i, j;
       int s1 = 0, s2 = k, e1, e2;
       int m = 0;
       while(s1 + k < n){
              e1 = s2;
              e2 = (s2 + k < n) ? s2 + k : n;
              for(i = s1, j = s2; i < e1 && j < e2; m++){
                     if(src[i] <= src[j]){
                            dest[m] = src[i++];
                     }else{
                            dest[m] = src[j++];
                     }                  
              }
              while(i < e1){
                     dest[m++] = src[i++];
              }
              while(j < e2){
                     dest[m++] = src[j++];
              }
              s1 = e2;
              s2 = s1 + k;
       }
       for(i = 0; i < n; i++){
              src[i] = dest[i];
       }
} 
~~~

算法演示2（递归版本）:

~~~c
#include<stdio.h>
#include<stdlib.h>  
void merge(int a[], int l, int m, int r){
       int* t;
       int i = l, j = m + 1, k = 0;
       if((t = malloc(sizeof(int) * (r - l + 1))) == NULL){
              printf("Allocate memory failure!");
              exit(1);
       }
       while(i <= m && j <= r){
              if(a[i] > a[j]){
                     t[k++] = a[j++];
              }else{
                     t[k++] = a[i++];
              }
       }
       if(i > m){
              while(j <= r){
                     t[k++] = a[j++];
              }
       }else{
              while(i <= m){
                     t[k++] = a[i++];
              }
       }
       for(i = l, k = 0; i <= r; i++, k++){
              a[i] = t[k];
       }
       free(t);
}
void sort(int a[], int l, int r){
       int m;
       if(l < r){
              m = (l + r) / 2;      
              sort(a, l, m);
              sort(a, m + 1, r);
              merge(a, l, m, r);
       }
}  
void mergeSort(int a[], int n){
       sort(a, 0, n-1);
}
~~~
 