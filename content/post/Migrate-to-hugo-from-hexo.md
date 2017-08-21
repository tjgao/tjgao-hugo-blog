---
title: "Migrate to Hugo From Hexo"
date: 2017-08-21T13:04:34+10:00
tags: ["hugo", "blog"]
categories: ["技术"]
---

最近把静态 blog 的生成工具由 hexo 换成了 hugo。hexo 其实还是不错的，但是速度确实不行。

<!--more-->

一般人修改和写东西，总是要写一点，改改，然后看看效果，于是这就要求程序不断的 generate 静态页面。如果每次等超过两秒就会极大的影响使用感受，要是五秒以上，恐怕受得了的就不多了。

另一个，hexo 是用 js 写的，那意味着你如果要换台机器，你需要安装整套的工具链，nodejs, npm 等等，加上 hexo module 以及它所依赖的一切东西。老实说，还是麻烦的，因为我不写 nodejs 的程序。但是我倒是很有兴趣折腾 golang，所以机器上总是有 go 的环境，安装搞定 hugo 只需要一条命令：

```bash
go get github.com/gohugoio/hugo
```

而且，就算我不写 go 程序，hugo 也是一个静态链接的可执行文件，随便甩在 Linux，Mac 或者 Windows 上都跑得好好的，对于一般非开发者用户来说，其安装设置过程也非常简单。

我没几篇文章，用 hugo 做一次全新的 generate 页面，需要 200 多毫秒，如果只是刷新某一篇文章的更改，也就十几毫秒，确实有快到爽的感觉（或许以前用 hexo 导致对速度要求降低？）。


