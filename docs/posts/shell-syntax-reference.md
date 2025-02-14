---
title: "Shell 语法参考（一）"
author: "Kevin Wu"
date: "2016/10/21"
category: ["linux"]
---


## 变量

~~~
# 声明变量
name="tom"

# 使用变量
echo $name
echo ${name}

# 给变量重新赋值
name="john"
echo $name

# 只读变量
url="http://www.google.com/"
readonly url
url="http://www.apple.com/"

# 删除变量
url="http://www.google.com"
unset url
echo $url
~~~

## 字符串

字符串可以用单引号、双引号，也可以不用引号。单引号里的任何字符都会原样输出，不能出现单独的单引号，转义后也不行；双引号里可以使用变量、转义字符。

~~~
# 字符串拼接
echo "hello "$name"!"
echo "hello ${name}!"
echo 'hello '$name'!'
echo 'hello ${name}!'

# 字符串长度
len=${#name}
echo ${len}

# 提取子字符串
str=${name:1:2}
echo ${str}
~~~

## 数组

Shell 仅支持一维数组，并且没有限定数组大小，初始化时也不需要定义数组大小。

~~~
# 数组定义
names=(Andy Bob Louis)

# 用下标访问数组元素
echo ${names[0]}

# @ 或 * 作下标可以获取数组中的所有元素
echo ${names[@]}
echo ${names[*]}

# 获取数组长度
echo ${#names[@]}
echo ${#names[*]}

# 获取单个元素长度
echo ${#names[2]}

# 遍历数组中所有元素
for name in ${names[@]}; do
  echo ${name}
done
~~~

## 运算符

### 算术运算符

Shell 不支持简单的算术运算，但可以用 expr 或 awk 命令来实现，expr 是最常见的选择。expr 表达式的值和运算符之间要有空格，而乘法运算的符号要进行转义才能避免语法错误。

~~~
var=`expr $a + $b`  # 加 23
var=`expr $a - $b`  # 减 3
var=`expr $a \* $b` # 乘 130
var=`expr $a / $b`  # 除 1
var=`expr $a % $b`  # 模 3
~~~

### 关系运算符

关系运算只支持数字，不支持字符串，除非字符串的值是数字。

~~~
if [[ $a == $b ]]; then   # 相等
if [[ $a != $b ]]; then   # 不等
if [[ $a -eq $b ]]; then  # 相等
if [[ $a -ne $b ]]; then  # 不等
if [[ $a -gt $b ]]; then  # 大于
if [[ $a -lt $b ]]; then  # 小于
if [[ $a -ge $b ]]; then  # 大于等于
if [[ $a -le $b ]]; then  # 小于等于
~~~

### 字符串运算符

~~~
if [[ $a = $b ]]; then    # 值相同
if [[ $a != $b ]]; then   # 不相同
if [[ -z $a ]]; then      # 长度为0
if [[ -n $a ]]; then      # 长度非0
~~~

### 逻辑运算符

~~~
if [[ ! $a -gt 100 ]]; then               # 非
if [[ $a -lt 100 && $b -gt 100 ]]; then   # 且
if [[ $a -lt 100 || $b -gt 100 ]]; then   # 或
~~~

### 文件测试运算符

~~~
if [[ -b file ]]; then  # 块设备文件
if [[ -c file ]]; then  # 字符设备文件
if [[ -d file ]]; then  # 目录
if [[ -f file ]]; then  # 普通文件（非目录和设备文件）

if [[ -r file ]]; then  # 可读
if [[ -w file ]]; then  # 可写
if [[ -x file ]]; then  # 可执行

if [[ -s file ]]; then  # 文件大小大于 0
if [[ -e file ]]; then  # 文件或目录存在

if [[ -g file ]]; then  # 是否设置了 SGID 位
if [[ -u file ]]; then  # 是否设置了 SUID 位
if [[ -k file ]]; then  # 是否设置了粘着位（Sticky Bit）
if [[ -p file ]]; then  # 是否是有名管道
~~~

## 流程控制

### if 语句

~~~
if [[ $a -gt $b ]]; then
  xxx
fi

if [[ $a -gt $b ]]; then xxx; fi

if [[ $a -gt $b ]]; then
  xxx
else
  yyy
fi

if [[ $a -gt $b ]]; then
  xxx
elif [[ $a -lt $b ]]; then
  yyy
else
  zzz
fi
~~~

### for 语句

~~~
# 遍历值集合
for var in item1 item2 item3; do
  echo ${var}
done

# 遍历目录：`ls blog`、blog/*、blog/*.html
for file in `ls /etc`; do
  echo ${file}
done
~~~

### while 语句

~~~
it=0
while [[ $it -lt 5 ]]; do
  echo $it
  let "it++"
done
~~~

### untile 语句

until 循环执行一系列命令直至条件为 true 才停止，它与 while 循环的处理方式刚好相反，一般 while 循环优于 until 循环，但在某些极少数情况下，until 循环更加有用。

~~~
it=0
until [[ ! $it -lt 5 ]]; do
  echo $it
  it=`expr $it + 1`
done
~~~

### case 语句

~~~
type="bb"
case $type in
  aa)
    echo "aas"
  ;;
  bb)
    echo "bbs"
  ;;
  cc)
    echo "ccs"
  ;;
  *)
    echo "**s"
  ;;
esac
~~~

### 无限循环

~~~
while true; do
  xxx
done

while :; do
  xxx
done

for (( ; ; )); do
  xxx
done
~~~

### 跳出循环

~~~
# break 跳过所有循环
while true; do
  echo -n "Enter number between 1-5:"
  read num
  case $num in
    1|2|3|4|5)
      echo "The number is: $num"
    ;;
    *)
      echo "Game Over"
      break
    ;;
  esac
done

# continue 跳过本次循环
while true; do
  echo -n "Enter number between 1-5:"
  read num
  case $num in
    1|2|3|4|5)
      echo "The number is: $num"
    ;;
    *)
      continue
      echo "Game Over"
    ;;
  esac
done
~~~

## 函数

  * `$#` 参数个数（不包括函数名）；
  * `$$` 脚本运行的当前进程 ID 号；
  * `$!` 后台运行的最后一个进程 ID 号；
  * `$?` 最后命令的退出状态；
  * `$-` 显示 Shell 使用的当前选项，与 set 命令功能相同；
  * `$*` 引用所有参数，被双引号括起来时传递 "1 2 3"（一个参数）；
  * `$@` 引用所有参数，被双引号括起来时传递 "1" "2" "3"（三个参数）。

~~~
function func1() {
  echo "in func1"
  # 无 return 语句，将以最后一条命令运行结果作为返回值
}

func2() {
  echo "in func2"
  return 101
}

func3() {
  echo "arg1: $1"
  echo "arg2: $2"
  echo "arg3: $3"
}

func1
echo "return code: $?"

func2
echo "return code: $?"

func3 1 2 3 4 5
echo "return code: $?"
~~~

## 脚本参数

  * `$0` 脚本文件名；
  * `$1` 第一个参数；
  * `$#` 参数个数（不包括脚本名）；
  * `$$` 脚本运行的当前进程 ID 号；
  * `$!` 后台运行的最后一个进程 ID 号；
  * `$?` 最后命令的退出状态；
  * `$-` 显示 Shell 使用的当前选项，与 set 命令功能相同；
  * `$*` 引用所有参数，被双引号括起来时传递 "1 2 3"（一个参数）；
  * `$@` 引用所有参数，被双引号括起来时传递 "1" "2" "3"（三个参数）。

~~~
for name in "$*"; do
  echo ${name}
done
# 1 2 3

for name in "$@"; do
  echo ${name}
done
# 1
# 2
# 3
~~~

## 文件包含

文件包含可以使用两种方式：`source filename` 或 `. filename`。

~~~
# defines.sh file
#!/bin/bash
url="http://www.google.com/"

# test.sh file
#!/bin/bash
source defines.sh
echo "Site is: ${url}"
~~~

## 重定向

### 输出重定向

~~~
# 输出重定向到文件，覆盖文件内容
command >file

# 输出重定向到文件，追加到文件末尾
command >>file

# 错误输出重定向到文件
command 2>file
command 2>>file
~~~

### 输入重定向

~~~
# 输入重定向为文件
command <file

# 同时将输入和输出重定向
command <infile >outfile

# 将输出和错误输出合并后重定向
command >file 2>&1
command >>file 2>&1
~~~

### Here Document

Here Document 是 Shell 中一种特殊的重定向方式，用来将输入重定向到一个交互式 Shell 脚本或程序。

~~~
command <<delimiter
  document
delimiter
~~~

开始 delimiter 前后的空格会被忽略掉，结尾 delimiter 一定要顶格写，前面不能有任何字符，后面也不能有任何字符。

~~~
cat >/etc/xxx.conf <<EOF
aaaa bbbb
cccc
EOF
~~~

### /dev/null 文件

/dev/null 是一个特殊的文件，写入到它的内容都会被丢弃。如果尝试从该文件读取内容，那么什么也读不到。如果希望执行某个命令，但又不希望在屏幕上显示输出结果，那么可以将输出重定向到 /dev/null。

~~~
command >/dev/null
~~~
