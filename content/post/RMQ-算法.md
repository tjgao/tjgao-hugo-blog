---
title: RMQ 算法
date: 2015-08-17 20:56:51
categories: ["技术"]
tags: ["算法", "algorithm", "动态规划", "dynamic programming"]
---

RMQ (Range Minimum/Maximum Query，区间最值) 问题，是指给定一个区间，然后询问在区间某一局部区域的最值是什么。比如给出一个长度为$n$的数组$N$，然后每次给出索引号$i$和$j$，问：$N[i]$和$N[j]$之间的最大（小）值是什么。


<!--more-->

一个简单的办法是，逐个扫描，复杂度为$O(n)$。问题在于，如果询问的次数非常多，每次都逐个扫描，性能一定很差。显然，如果能预先准备好数据，然后直接查询会快多了。这里，又是一个使用动态规划的理想场所。其解决办法被称为 Sparse Table (稀疏表)。

准备一个二维数组$A[n][m]$，$n$为数组长度，而$m$则为$1+log_2{n}$。对于数组中任何一个元素$A[i][j]$，记录了起始于索引$i$，长度为$2^j$的区间的最值。$A[i][j]$可以被均分为$A[i][j-1]$以及$A[i+2^{j-1}][j-1]$，从动态规划的观点看，已经找到了最为关键的递推关系(假设求的是最小值)：
$$A[i][j] = min(A[i][j-1], A[i+2^{j-1}][j-1])$$

很显然，$A[i][0]$就是$N[i]$，只有一个值，最值就是这个值。于是乎，其他值也就相应求出即可。准备好这个二维数组的时间是$O(nlogn)$。

怎么使用这个表呢？假设给出的区间是$u$和$v$，则$u$和$v$之间的长度为$v-u+1$，可得出$k=log_2(v-u+1)$，则以下两个区间一定覆盖了所求区间，即$A[u][k]$和$A[1+v-2^k][k]$。有重叠区域也无所谓，它们的最小值中较小的那个仍然是最后所求的值。即：
$$RMQ(u,v) = min(A[u][k], A[1+v-2^k][k])$$
时间复杂度为$O(1)$。

```cpp
vector<vector<int>> st(vector<int>& v) {
    int sz = v.size();
    int k = int(log(sz)/log(2)) + 1;
    vector<vector<int>> table(sz, vector<int>(k));
    for( int i=0; i<sz; i++ )
        table[i][0] = v[i];
    int j = 1;
    while( pow(2,j-1) < sz) {
        for( int i=0; i<sz; i++ )
            if( (i + pow(2,j-1)) < sz )
                table[i][j] = min(table[i][j-1], table[i+pow(2, j-1)][j-1]);
        j++;
    }
    return table;
}

int rmq(vector<vector<int>>& table, int u, int v) {
    int len = v - u + 1, k = int(log(len)/log(2));
    return min(table[u][k], table[1+v-pow(2,k)][k]);
}
```
