---
title: "Variadic Functions in Go"
date: 2017-11-21T19:13:27+11:00
tags: ["go", "golang"]
categories: ["技术"]
---

Go 是一个挺不错的语言，但是有一些地方不太对我胃口，比如没有 Generic。按照 Rob Pike 的意思是，“你们用不着的，反正我们没发现有用模板的需求，你们肯定也不会有”。所以，结果就是写一些东西有点罗里吧嗦的。有人说用 interface{}，这个跟用 C\C++ 里的 void* 有什么区别？说好的类型安全呢？


<!--more-->


有一些横空出世的函数，这些函数倒是什么都认，工作起来跟模板似的，就是不让用户用 generic ，什么“我们没有用模板的需求，你们肯定也不会有”。不过这些是由编译器来特殊处理的。如果从开始就不考虑 Generic 的可能性，我有点担心以后也不太可能有了。如果我觉得有用的一些 feature 都能够加上的话，那么从实用好用角度讲，我觉得 Go 几乎是无敌了。

好了回到正题，说说变长参数函数 (Variadic functions)。比如像这样：

```golang
func iDoIntegers(first int, others ...int) {
	fmt.Print(first)
	for _, value := range others {
		fmt.Print(value)
	}
	fmt.Println()
}
```
这个函数接受至少一个整数参数，不设上限，那省略号有点像 C\C++ 中的类似用法。你会发现，其实传入整数 slice 也是可以的，比如

```golang
iDoIntegers(1, []int{55,66,77,88}...)
```
注意，这里对传入的 slice 用了省略号，表示对 slice 解包了，所以传进去的其实是一个一个整数。非常像 Python 里的 *args 和 *kwargs 对不对?

但 iDoIntegers 函数内部对 others 使用了 range。这似乎说明在编译期根据实际的参数个数生成了一个数组，并用 slice 来引用之。你可以对 others 使用 len 函数，没有问题。要确认的话，就给这函数加一句

```golang
func iDoIntegers(first int, others ...int) {
	fmt.Println(reflect.TypeOf(others))
	fmt.Print(first)
	for _, value := range others {
		fmt.Print(value)
	}
	fmt.Println()
```

而返回的类型也确实是 []int。有点多此一举了是不是？不知道为啥不干脆直接接受一个不解包的 slice。

反过来，如果函数写成接受一个整数 slice，指望输入多个整数是不行的。从这一点上说，确实不如 Python 的 *args 灵活。

