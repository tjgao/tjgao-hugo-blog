---
title: "Naive Promise Implementation in Javascript"
date: 2017-10-23T16:57:24+11:00
tags: ["javascript"]
categories: ["技术"]
---

最近一段时间看了一些 ES6 和 Typescript 的内容，感叹 Javascript 的发展日新月异，不好好了解和跟踪其进展就落伍了。在断断续续的阅读中，又看到了 Javascript 中的 Promise，感觉是个挺好的东西，必须要用熟用好。

<!--more-->

但是简单的看看文档，跑几个小例子，我感觉还不够，这个应该是可以由我们自己来实现的。我会尝试从零开始写一个自己的 Promise，一开始只有基本功能，然后再慢慢往上增加功能。

为什么 Promise 能够缓解 callback 造成的一些问题呢？ callback 的问题是，调用的地点和代码逻辑紧密关联，同时还暴露了很多状态，一旦状态多了，加上错误处理，管理起来非常麻烦，读起来也很困难。而 Promise，简单的说，能够把原先乱麻般的 callbacks 整理成线性的顺序执行，还能够 track 执行过程中的一些错误，使用上更加便利不用说，还能极大的减轻心智负担，提高可读性。

Javascript 带的 Promise 功能很完善，我自己先轮一个最简单的，能够链式的按照顺序的执行代码。我的想法挺简单，其实 Promise 就是提供一个场合，让你的 callback 能够都跳到它那里去，然后在它那里统一的执行回调代码，并检查是否有下一步，以及错误处理等等。你必须要在你的代码中执行一个 Promise 提供的桩子，因为只有这样你才能驱动整个事件链条。

一个初步的简单实现如下

```javascript
let NaivePromise = function(functor) {
	let resolve = () => {
		if (this.callbacks.length == 0) {
			this.state = 'resolved'
			return
		}
		var func = this.callbacks[0]
		this.callbacks.shift()
		func()
	}

	let reject = () => {
		this.state = 'rejected'
	}

	this.then = (funcall) => {
		if (typeof funcall !== 'function')
			return this

		let wrap = function () {
			funcall(resolve)
		}
		this.callbacks.push(wrap)
		return this
	}

	this.state = 'pending'
	this.callbacks = [] 
	functor(resolve, reject)
}

let job = new NaivePromise((resolve, reject) => {
	setTimeout(resolve, 1000)
})

job.then((resolve) => { console.log('cool '); resolve();})
.then((resolve) => { setTimeout(resolve, 1000);})
.then((resolve) => { console.log('awesome '); resolve()})
.then((resolve) => { setTimeout(resolve, 1000);})
.then((resolve) => { console.log('I am done '); resolve()})
```

这个 resolve 就是由 Promise 提供的桩子，它来看事情有没有处理完，以及跳到下一步的回调代码，它才是真正的执行者。一串串的 then 的调用只是在不断的塞入不同的回调代码，并未真正执行代码。

这个代码并没有考虑错误处理，其实正版的 Promise 的 then 调用还有个 reject 参数，当有错误发生时，可以调用 reject，并塞入个错误原因对象。此外，Promise 应该还有 cancel 的能力。这个以后再说，这段代码足够看清楚基本原理了。

