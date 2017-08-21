---
title: Suffix array I
date: 2015-08-11 23:00:33
categories: ["技术"]
tags: ["算法", "字符串", "algorithm", "string", "suffix array"]
---

Suffix array 是一种很奇妙的数据结构，在字符串处理中有很多重要的用途。很多看上去复杂的字符串问题，在已经创建了 suffix array之后，往往能够在线性时间之内解决。

<!--more-->

Suffix array 其实只是 suffix tree 的一种简化，而 suffix tree，只是 trie 的一个特例。如果有了 trie 的概念，那么所谓的 suffix tree， 其实只是用字符串 S 的所有后缀构建的一个 trie。所谓后缀，比如对于字符串 bananas, 其所有的后缀包括了 bananas, ananas, nanas, anas, nas, as, s。这些后缀构成的 trie 如下：


![suffix tree](http://facweb.cs.depaul.edu/mobasher/classes/csc575/Suffix_Trees/FIGURE1.gif)


而 suffix array 则是 S 的所有后缀的一个字典序的简洁记法。 比如 bananas 的所有后缀按照字典序排序为： ananas, anas, as, bananas, nanas, nas, s。如果再注意到只需要记录各个后缀的开头字母的索引就可以了，那么得到一个数组，结果为：1 3 5 0 2 4 6, 这就是 suffix array，它和 suffix tree 有着很紧密的联系。

根据这个定义，写一段代码来获取 suffix array 似乎颇为容易：

```cpp
//A very naive implementation
vector<int> getSA_naive(string s) {
    vector<int> v;
    int len = s.length();
    map<string, int> tmp;
    for( int i=0; i<len; i++ )
        tmp[s.substr(i, len-i)] = i;
    for( auto it = tmp.begin(); it!=tmp.end(); ++it )
        v.push_back(it->second);
    return v;
}
```

再看看运行时间，字符串长度为n，n个字串排序，运行时间应为$O(nlgn)$。而每个字符串的比较又是$O(n)$，则总体时间复杂度为$O(n^2lgn)$。此处使用了C++的map，自带排序，所以找不到字符串排序的部分。但无论这个隐藏的排序在哪里，总是避免不了的。

由于Suffix array的重要用途，近几十年很多研究者投入到其获取算法的改进中。最近的一篇论文"A taxonomy of suffix array construction algorithms"指出：

1) Practical space-efficient suffix array construction algorithms (SACAs) exist that require worst-case time linear in string length;
2) SACAs exist that are even faster in practice, though with supralinear worstcase construction time requirements;
3) Any problem whose solution can be computed using suffix trees is solvable with the same asymptotic complexity using suffix arrays.

这种改进也不知道最后会达到什么程度，总而言之，线性时间的Suffix array获得是没有问题的。任何能够用 suffix tree 来解决的问题，也可以通过高效的 suffix array 获取算法来解决。

最常见的几种求 suffix array 的有 prefix doubling 和 DC3 算法。 其中 prefix doubling (倍增算法)是最早的高效获取 suffix array 的尝试，也比较清晰，实现起来更容易。它基本思想是，naive 算法效率不好的原因是没有利用一个事实，即我们排序的一堆字符串是同一个字符串的后缀，而不是一堆随机的字符串，应该充分利用这一点。具体用语言来描述其算法是一个很困难的事情，我通过观察这张图最终理解了这个算法，并完成了一个实现。要注意，这个示意图中的示例字符串是 aabaaaab，求它的suffix array。
![prefix doubling](http://7xl1lv.com1.z0.glb.clouddn.com/imageda.JPG)
代码也附上。我相信还有各种可以优化的余地，但基本思路大致如此。

```cpp
//Prefix doubling
typedef struct tagENTRY {
    int pr[2];
    int idx;
    tagENTRY() {
       pr[0] = pr[1] = idx = -1;
    }
} ENTRY;

bool cmp(ENTRY& e1, ENTRY& e2 ) {
    return ( e1.pr[0] == e2.pr[0] ) ? ( e1.pr[1] < e2.pr[1] ) : ( e1.pr[0] < e2.pr[0] );
}

void update(vector<ENTRY>& entry, vector<int>& rank) {
    sort( entry.begin(), entry.end(), cmp );
    int n = 0, e1 = entry[0].pr[0], e2 = entry[0].pr[1];
    for( int i=0; i<entry.size(); i++ ) {
        if( e1 != entry[i].pr[0] || e2 != entry[i].pr[1] ) {
            n++;
            e1 = entry[i].pr[0];
            e2 = entry[i].pr[1];
        }
        rank[entry[i].idx] = n;
    }
    for( int i=0; i<entry.size(); i++ )  {
        entry[i].pr[0] = rank[entry[i].idx];
    }
}

vector<int> getSA_pd(string s) {
    int len = s.length();
    vector<int> rank(len);
    vector<ENTRY> entry(len);
    for( int i=0; i<len; i++ ) {
        entry[i].pr[0] = s[i];
        entry[i].idx = i;
    }
    update( entry, rank);
    for( int step=1; step<len; step*=2 ) {
        for( int i=0; i<len; i++ ) {
            if( entry[i].idx + step < len )
                entry[i].pr[1] = rank[entry[i].idx+step];
            else
                entry[i].pr[1] = -1;
        }
        update( entry, rank);
    }
    vector<int> v(len);
    for( int i=0; i<len; i++ ) {
        v[rank[i]] = i;
    }
    return v;
}
```

注意，rank是每次完成后的排名，其含义是，后缀索引为i的名次是rank[i]。我们需要的 suffix array，其含义是从小到大排出所有的后缀，所以这两正好是反的。假设 value = rank[i]， 则对于suffix array，有 sa[value] == i，所以最后求出suffix array并返回。

通过观察getSA_pd函数中的循环可以知道，最外层的循环次数为$lgn$，内部的for循环为$n$，update函数执行了一次sort，复杂度为$nlgn$，其余循环操作均为$n$，所以最终的复杂度为$n(lgn)^2$。
