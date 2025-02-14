---
title: "常用 Linux 命令参考"
author: "Kevin Wu"
date: "2017/02/14"
category: ["linux"]
---


## 用户管理

~~~
# 添加用户
useradd -m kevin

# 修改用户密码
passwd kevin

# 删除用户
userdel -r kevin
~~~

## 文件系统

~~~
# 修改 file 文件的权限
chmod 664 file

# 符号模式，用户类型ugoa，操作类型+-=，权限rwx
chmod ug+rw file

# 对 file 的所有用户增加读写权限
chmod +rw file

# 对目录 dir 和其子目录层次结构中的所有文件增加用户的读权限
chmod -R u+r dir


# 拷贝文件或文件夹
cp -rf source destination


# 列出当前目录下的所有目录
ls -al | grep "^d"

# 列出当前目录下的所有文件
ls -al | grep -v "^d"

# 列出其它目录下所有名称中带 sys 的文件或目录
ls -al /etc/ | grep "sys"
~~~

## 下载文件

~~~
# 用 wget 下载文件，指定文件名
wget -O filename http://kevinsblog.cn/archive.html

# 用 wget 下载文件，使用原始文件名
wget http://kevinsblog.cn/archive.html


# 用 curl 下载文件，指定文件名
curl http://kevinsblog.cn/archive.html -o filename

# 用 curl 下载文件，使用原始文件名
curl http://kevinsblog.cn/archive.html -O
~~~

## 压缩/解压

~~~
# 递归压缩目录
zip -r blog.zip ./blog

# 删除压缩包内某个文件
zip -d blog.zip blog/_config.yml


# 解压到当前目录
unzip blog.zip

# 解压到指定目录
unzip -n blog.zip -d /var/www


# tar.gz 压缩
tar -zcvf blog.tar.gz ./blog

# tar.gz 解压
tar -zxvf blog.tar.gz


# tar.bz2 压缩
tar -jcvf blog.tar.bz2 ./blog

# tar.bz2 解压
tar -jxvf blog.tar.bz2
~~~

## Locale

~~~
# 查看当前系统 locale
locale

# 列出系统中所有可用 locale
locale -a

# 如果没有特定的 locale，可以生成 locale
locale-gen zh_CN.UTF-8

# 修改 locale
vi /etc/default/locale
~~~

## apt 用法

~~~
# 搜索包
apt-cache search packagename

# 显示包信息
apt-cache show packagename

# 显示依赖关系
apt-cache depends packagename

# 查看该包被哪些包依赖
apt-cache rdepends packagename


# 更新源
apt-get update

# 更新已经安装的包
apt-get upgrade


# 安装包
apt-get install packagename

# 重新安装包
apt-get install packagename --reinstall


# 卸载软件包（保留配置文件）
apt-get remove packagename

# 卸载软件包（删除配置文件）
apt-get –-purge remove packagename

# 清理无用的包
apt-get clean
apt-get autoclean
~~~

## 其它

~~~
# 获取 IP，以前是：ip.gs
curl ip.sb
~~~
