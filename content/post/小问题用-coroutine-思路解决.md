---
title: 小问题用 coroutine 思路解决
date: 2017-08-21 01:54:43
tags: ["算法", "algorithm"]
categories: ["技术"]
---

前阵子在水木上看到有人贴了个问题，问怎么用程序实现。即，给你一堆等式，你的程序边接受输入边求值，并打印出来。

<!--more-->

```
a = 3
===> a = 3
b = 2 + 4
===> b = 6
c = a
===> c = 3
d = b + 7
===> d = 13
A = b + c + d
===> A = 22
f = g
g = 1 + 2 + 3
===> g = 6
===> f = 6
h = i + A + lemon
lemon = k + lima
i = A + 5
===> i = 27
k = a + b
===> k = 9
lima = k + k
===> lima = 18
===> lemon = 27
===> h = 76
```
See? 能求值的就输出结果，不能的就无输出。经过观察，它左边只有一个变量，还算简化的情况呢。

我先用 C++ 撸了个，说实话，不好撸，绕来绕去的。

```cpp
#include <iostream>
#include <sstream>
#include <cctype>
#include <vector>
#include <unordered_set>
#include <unordered_map>
#include <functional>
 
class executor {
public:
    typedef std::unordered_map<std::string, int> smap;
    typedef std::unordered_map<std::string, std::vector<std::function<void(executor*)>>> cmap;
    typedef std::unordered_map<std::string, int> vmap;
 
    void process(const std::string& equation) {
        std::cout << equation << std::endl;
        std::unordered_set<std::string> deps;
        std::string left;
        int value = 0;
        if (parse(equation, left, deps, value)) {
            print(left, value);
            cache[left] = value;
            auto it = cb.find(left);
            if (it != cb.end()) {
                for (auto& callback: it->second) callback(this);
            }
            cb.erase(left);
        } else {
            cache.erase(left);
            int& current_version = version[left];
            current_version++;
            for (auto& s : deps) {
                cb[s].push_back([left, deps, value, current_version](executor* e){
                    if (e->version[left] > current_version) return;
                    int result = value;
                    for (auto& key : deps) {
                        auto it = e->cache.find(key);
                        if (it == e->cache.end()) return;
                        result += it->second;
                    }
                    e->print(left, result);
                    e->cache[left] = result;
                    auto it = e->cb.find(left);
                    if (it != e->cb.end()) {
                        for (auto& callback : it->second) callback(e);
                        e->cb.erase(left);
                    }
                });
            }
        }
    }
private:
    bool parse(const std::string& equation, std::string& left, std::unordered_set<std::string>& deps, int& value) {
        size_t pos = equation.find('=');
        left = trim(equation.substr(0, pos));
        std::stringstream ss(equation.substr(pos + 1));
        std::string token, stripped;
        int evaluated = 0;
        bool good = true;
        while (std::getline(ss, token, '+')) {
            stripped = trim(token);
            if (isalpha(stripped[0]) == 0) {
                value += stoi(stripped); 
            } else {
                auto it = cache.find(stripped);
                if (it != cache.end()) evaluated += it->second;
                else good = false; 
                deps.insert(stripped);
            }
        }
        if (good) value += evaluated;
        return good;
    }
    void print(const std::string& key, int value) { std::cout << "===> " << key << " = " << value << std::endl; }
    std::string trim(const std::string& s) {
        size_t start = s.find_first_not_of(" \t\n");
        return s.substr(start, s.find_last_not_of(" \t\n") - start + 1);
    }
    smap cache;
    cmap cb;
    vmap version;
};
 
int main() {
    std::vector<std::string> data {
        "a = 3"
        , "b = 2 + 4"
        , "c = a"
        , "d = b + 7"
        , "A = b + c + d"
        , "f = g"
        , "g = 1 + 2 + 3"
        , "h = i + A + lemon"
        , "lemon = k + lima"
        , "i = A + 5"
        , "k = a + b"
        , "lima = k + k"
    };
    executor e;
    for (auto& a : data) e.process(a);
}
```
这许多行，看上去很勉强很痛苦。

最近接触了一些 python 的 coroutine 的思路，发现这个问题用 generator/coroutine 的路子来考虑就很直观自然。每次给你个东西求值，你能求就求，不能就算了，不行就 yield 投降，就直接躺地上不干了。最重要的是下次如果某变量求值成功了，再继续这个未完成的 generator/coroutine 就行了。

在 async programming 中总会有个 event loop 来驱动所有的 coroutine，我们这个就自己轮一个简单的 loop 就行了。上 python 代码：

```python
input = [
"a = 3"
, "b = 2 + 4"
, "c = a"
, "d = b + 7"
, "A = b + c + d"
, "f = g"
, "g = 1 + 2 + 3"
, "h = i + A + lemon"
, "lemon = k + lima"
, "i = A + 5"
, "k = a + b"
, "lima = k + k"	
]
 
variable_map = {}
co_table = {}
 
def value(num):
	try:
		return int(num)
	except:
		while True:
			result = variable_map.get(num)
			if result is not None:
				co_table[num] = None
				run()
				return result 
			yield 	
 
def evaluate(left, right):
	result = 0
	for r in right:
		result += yield from value(r)
	variable_map[left] = result
	print('===> ' + left + ' = ' + str(result))
	run()
 
def run():
	for k in co_table:
		if co_table[k] is None: continue
		try:
			co_table[k].send(None)
		except:
			pass
 
def main():
	for line in input:
		print(line)
		left = line.split('=')[0].strip() 
		right = [i.strip() for i in line.split('=')[1].split('+')]
		co_table[left] = evaluate(left, right)
		run()
 
main()
```

是不是清楚多了？ 

