---
title: Configuration of nginx and tomcat on Linux
date: 2016-02-23 16:55:10
tags: ["linux", "nginx", "tomcat", "技术", "technology"]
categories: ["技术"]
---

配置`nginx`和什么`php`啊， `tomcat`啊， 我干了也无数次了，总是记不住，结果每次要弄了都要现查。 痛定思痛，好记性不如烂笔头，还是大致写写过程以后方便些，何况我这绝对算不上好记性。

以下针对的都是`ubuntu`，估摸`debian`也差不多。

<!--more-->

### 权限
为了能够彻底排除权限问题，最好使用一个统一的用户来运行 nginx 和 tomcat。通过包安装的`nginx`默认的运行用户是`www-data`，而`tomcat7`则偏要弄个叫做`tomcat7`的用户。所以，我首先就把`tomcat7`的运行用户改成`www-data`，统一号令。

打开`/etc/default/tomcat7`就看到了运行用户的配置，我直接改成了`www-data`：

```bash
# Run Tomcat as this user ID. Not setting this or leaving it blank will use the
# default of tomcat7.
TOMCAT7_USER=www-data

# Run Tomcat as this group ID. Not setting this or leaving it blank will use
# the default of tomcat7.
TOMCAT7_GROUP=www-data
```
不过这还没完，原有的文件仍然归属于用户`tomcat7`，这些都得一一改掉。如`/var/lib/tomcat7`，`/var/log/tomcat7`，`/etc/tomcat7`，要把其所有权给`www-data`：

```bash
chown -R www-data:www-data /var/lib/tomcat7
```
这些东西都改完了`tomcat7`的运行用户修改才算完事。
### 路径
这两的默认服务路径都颇为奇葩，我还是习惯于使用`/var/www`，和以前的`apache`一样。到`tomcat`的`server.xml`中修改`Host`项里的`appBase`，使之指向`/var/www`即可。对于`nginx`修改其`/etc/site-enabled/`下面的配置文件，修改`root`指向的路径，也使之指向`/var/www`，大致就这些。
### 反向代理
`nginx`的长处在于提供静态内容的服务，效率极高，而和应用相关的请求则应该直接发给`tomcat`，所以，修改`nginx`的配置文件如下：

```
    location ~* ^(/api/|/admin/) {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
    }
```
这个意思是，凡是 URL 路径以`/api/`和`/admin/`开头的请求，一律丢给`tomcat`。至于其他的请求，都默认由`nginx`挡了，`tomcat`毫不知情，这两各司其职。

