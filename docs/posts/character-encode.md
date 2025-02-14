---
title: "字符编码简介"
author: "Kevin Wu"
date: "2014/12/31"
category: ["encode"]
---


## ASCII 编码简介

ASCII 编码称为美国信息交换标准代码，使用一个字节来编码，最高位始终为 0，所以总共可以表示 128 个字符，目前分配情况如下：

Range     | Description
--------- | ----------------------
0x00-0x1F | 控制字符（不可见）
0x20      | 空格字符（可见）
0x21-0x7E | 符号、字母和数字（可见）
0x7F      | 删除字符（不可见）

## ISO8859 编码简介

ASCII 编码最高位始终是 0，只使用低七位进行编码，总共编码 128 个字符，如果将最高位用上，可以再编码 128 个字符。ASCII 编码是美国标准，所以欧洲有些符号并未包含其中，于是利用字节的最高位对 ASCII 编码进行扩展便产生了 ISO8859 编码。

ISO8859 编码并不是一个标准，其包含 16 个编码标准，每个标准中 0x00-0x7F（即最高位是 0）区段表示的字符与 ASCII 编码相同，0x80-0xFF（即最高位是 1）区段表示的字符根据标准而异，其定义如下：

Range     | Description
--------- | ----------------------------------
0x00-0x7F | 保持与 ASCII 编码兼容
0x80-0x9F | 保留给扩充定义的 32 个控制码
0xA0      | 在各个 ISO8859 编码中都表示非换行空格
0xA1-0xFF | 扩充的字符，根据标准而异

## Unicode 简介

Unicode 也称为万国码，主要为了解决传统字符编码方案的局限性，它为每种语言中的每个字符分配统一并且唯一的编码，即定义一个整数来表示某字符。以解决跨平台信息交换的问题。Unicode 并不定义字形，字符的展示工作留给其它软件来处理。目前最新版本为第六版，已经收录了超过十万个字符，至今还在不断增加，具体内容可参考 Unicode Roadmaps。

Unicode 包含 17 个平面，平面可以理解为编码区段，每个平面有 65536（即 2^16）个代码点，即可以编码 65536 个字符，目前用到的只有少数平面。第 0 平面叫基本多文种平面，其它 16 个平面称为辅助平面。一个 Unicode 字符至少要用 21 位来编码，略少于 3 字节。目前用到的平面如下：

Name         | Range                   | Description
------------ | ----------------------- | --------------
Plane  0 BMP | U+0000 0000-U+0000 FFFF | 基本多文种平面
Plane  1 SMP | U+0001 0000-U+0001 FFFF | 多文种补充平面
Plane  2 SIP | U+0002 0000-U+0002 FFFF | 表意文字补充平面
Plane  3 TIP | U+0003 0000-U+0003 FFFF | 表意文字第三平面
Plane 14 SSP | U+000E 0000-U+000E FFFF | 特别用途补充平面

最常用到的是基本多文种平面，占用两个字节，基本多文种平面的分区情况可以参考[这里](https://unicode.org/roadmaps/bmp/)。

## Unicode 转换格式

Unicode 编码系统分为编码方式和实现方式两个层次。编码方式规定某字符的编码是什么，即代表此字符的整数值是什么；实现方式规定此整数值应该如何存储。编码方式已经通过 17 个平面来解决，下面讨论实现方式。

可以将 Unicode 编码值直接用于存储么？由于基本多文种平面字符的平面序号是 0，所以两个字节即可表示这些字符，而辅助平面字符要用三个字节来表示。如果一个文件包含 100 个 'N' 和 100 个 '七'，'N' 的 Unicode 编码是 0x004E，'七' 的 Unicode 编码是 0x4E04。要将这 200 个字符存储到文件中，字符的表示方式可以采用固定字节数，即不管是 ASCII 字符还是汉字字符都用相同的字节数来表示；也可以采用变长字节数，即有些高字节是 0 的字符可以将其省掉，从而减少该字符所占用的字节数。

如果采用第一种方式存储，比如用 4 个字节来表示一个字符，那么存储 'N' 的时候计算机会将 0x0000004E 写入文件，本来只需要 1 个字节即可表示，现在浪费掉 3 个字节，而一个 '七' 也会浪费 2 个字节。这个文件占用的空间将达到 800 个字节，浪费掉 500 个字节。

如果采用第二种方式存储，那么存储 'N' 的时候计算机会将 0x4E 写入文件，存储 '七' 的时候计算机会将 0x4E04 写入文件，不会存在任何的空间浪费。不过，当计算机读文件的时候遇到 0x4E 这个字节，它应该将其认为是字母 'N'，还是将其认为是汉字 '七' 的高位呢？

表示一个字符的时候，固定字节数可能会引起巨大的浪费，显然是不可取的，只能使用变长字节数，但 Unicode 编码值不能直接用来存储，所以必须将 Unicode 编码转换成另外一种编码。UTF（Unicode 转换格式）就是为了解决此问题而诞生的，主要包括 UTF-8、UTF-16、UTF-32，最常用到的是 UTF-8 编码，它使用一至六个字节来为某个字符编码，当计算机读到文件中某个字节的时候，其判定规则如下：

  * 当第一个 0 位之前 1 的个数等于 0 时，即此字节最高位是 0，那么此字节代表 ASCII 字符；
  * 当第一个 0 位之前 1 的个数大于 1 时，那么此字节代表多字节字符的开始，且 1 的个数表示此多字节字符的字节数；
  * 当第一个 0 位之前 1 的个数等于 1 时，那么此字节代表多字节字符的后部。

Unicode 编码的范围是 0x00000000-0x0010FFFF，Unicode 编码转换为 UTF-8 编码的详细规则如下：

~~~
            Unicode | UTF-8
      (hexadecimal) | (binary)
--------------------+------------------------------------
0000 0000-0000 007F | 0xxxxxxx
0000 0080-0000 07FF | 110xxxxx 10xxxxxx
0000 0800-0000 FFFF | 1110xxxx 10xxxxxx 10xxxxxx
0001 0000-0010 FFFF | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
~~~

## 组合字符序列

为了和已有的标准兼容，某些字符可以表示成两种形式：1)一个单一的码点；2)两个或多个码点组成的序列。例如，有重音符号的字母 'é' 可以直接表示成 U+00E9，也可以表示成由 U+0065（小写拉丁字母 'e'）再加 U+0301（尖音符号）组成的分解形式。组合字符序列不仅仅出现在西方文字里，在谚文（朝鲜、韩国的文字）中，'가' 这个字可以表示成一个码点 U+AC00，也可以表示成 U+1100（'ᄀ'）和 U+1161（'ᅡ'）序列。组合字符序列的英文术语叫 Combining Character Sequence 或 Composite Character Sequence，NSString 类中有部分类似名称的方法。

~~~
NSString *str1 = @"\u00E9";
NSLog(@"str1: [%@]", str1); // str1: [é]
NSString *str2 = @"e\u0301";
NSLog(@"str2: [%@]", str2); // str2: [é]

NSString *str3 = @"\uAC00";
NSLog(@"str3: [%@]", str3); // str3: [가]
NSString *str4 = @"\u1100\u1161";
NSLog(@"str4: [%@]", str4); // str4: [가]
~~~

标准等价（Canonically Equivalence），'é' 可以用一个码点（U+00E9）或两个码点（U+0065 U+0301）表示，'가' 可以用一个码点（U+AC00）或两个码点（U+1100 U+1161）表示。在 Unicode 的语境下，这两种形式并不相等（因为两种形式包含不同的码点），但是符合标准等价。总结起来，标准等价的定义就是：码点不同，但外观和意义完全相同。

## 重复的字符

### 假的重复

外观相同，意义不同。拉丁字母 'A'（U+0041）和西里尔字母 'A'（U+0410）完全同形，但事实上，它们是不同的字母，表达着不同的含义。此时 Unicode 会以不同的码点来编码这个字符，以此让 Unicode 的文本保留字符的含义。

### 真的重复

外观相同，意义相同。字母 'Å'（U+00C5）和长度单位埃米符号 'Å'（U+212B）完全同形，埃米符号就是定义为这个瑞典大写字母，因此这两个字符的外观和意义是完全相同的。想想标准等价的定义：码点不同，但外观和意义完全相同。

### 广义重复

相容等价（Compatibility Equivalence），相容等价的典型例子是连字（ligature），连字并不是一个字符，详见[维基百科](https://zh.wikipedia.org/wiki/%E5%90%88%E5%AD%97)。单个字母 'ﬀ'（U+FB00）和两个小写拉丁字母 'f' 的序列 "ff"（U+0066 U+0066）就符合相容等价但不符合标准等价，虽然它们也可能以完全一致的样子呈现出来，这取决于环境、字体以及文本的渲染系统。总结起来，相容等价的定义就是：码点不同，外观不一定相同，但意义完全相同。

~~~
NSString *str1 = @"\uFB00";
NSLog(@"str1: [%@]", str1); // str1: [ﬀ]

NSString *str2 = @"ff";
NSLog(@"str2: [%@]", str2); // str2: [ff]
~~~

## 正规形式

从上面可以看出，Unicode 字符串的等价性并不是一个简单的概念。通过逐个比较码点的方式可以判断两个字符串是否完全等价，另外，我们还需要鉴定两个字符串是否标准等价或相容等价。为此，Unicode 定义了几个正规化算法。正规化就是将字符串中的 `"\u00E9"` 和 `"e\u0301"` 统一转化为仅含 `"\u00E9"` 或 `"e\u0301"` 的字符串，对两个使用相同方式正规化的字符串进行逐字的二进制比较所得出的结果才是有意义的。

如果仅仅为了比较的话，先把字符串正规化成合成形式还是分解形式并不重要。但合成形式的算法会先分解字符再重新组合起来，因此分解形式要更快一些。如果一个字符序列里含有多个组合标记，那么组合标记的顺序在分解后会是唯一的。另一方面，Unicode 联盟推荐用合成形式来存储，因为它能和从旧编码系统转换过来的字符串更好地兼容。

两种等价对于字符串比较来说都很有用，尤其在排序和查找时。但是，如果要永久保存一个字符串，一般情况下不应该用相容等价的方式去将它正规化，因为这样会改变文本的含义。

## NSString 和 Unicode

### 字符串组成

Unicode 是一种 21 位的编码方案，NSString 的 `characterAtIndex:` 方法返回的类型是 unichar，unichar 被定义为无符号短整型（unsigned short），无符号短整型是 16 位的，显然无法表示所有的 Unicode，当我发现这些事实的时候完全刷新了以前的认识，以前的理解都是错的。用上边的组合字符来做个测试吧。

~~~
NSString *str = @"ae\u0301z";
NSLog(@"str = [%@]", str);                         // str = [aéz]
NSLog(@"length = %lu", [str length]);              // length = 4
NSLog(@"char_0 = [%c]", [str characterAtIndex:0]); // char_0 = [a]
NSLog(@"char_1 = [%c]", [str characterAtIndex:1]); // char_1 = [e]
NSLog(@"char_2 = [%c]", [str characterAtIndex:2]); // char_2 = []
NSLog(@"char_3 = [%c]", [str characterAtIndex:3]); // char_3 = [z]
~~~

从这个例子看出，NSString 的一部分方法并不会像我们想象的那样工作，其结果与实际相去甚远。为了确保 Unicode 字符不会从中间被分开，可以使用 `rangeOfComposedCharacterSequenceAtIndex:` 方法来取得该位置完整字符的范围。

~~~
NSRange range0 = [str rangeOfComposedCharacterSequenceAtIndex:0];
NSLog(@"range0 = (%lu %lu), char_0 = [%@]", range0.location, range0.length, [str substringWithRange:range0]);
// range0 = (0 1), char_0 = [a]

NSRange range1 = [str rangeOfComposedCharacterSequenceAtIndex:1];
NSLog(@"range1 = (%lu %lu), char_1 = [%@]", range1.location, range1.length, [str substringWithRange:range1]);
// range1 = (1 2), char_1 = [é]

NSRange range2 = [str rangeOfComposedCharacterSequenceAtIndex:2];
NSLog(@"range2 = (%lu %lu), char_2 = [%@]", range2.location, range2.length, [str substringWithRange:range2]);
// range2 = (1 2), char_2 = [é]

NSRange range3 = [str rangeOfComposedCharacterSequenceAtIndex:3];
NSLog(@"range3 = (%lu %lu), char_3 = [%@]", range3.location, range3.length, [str substringWithRange:range3]);
// range3 = (3 1), char_3 = [z]
~~~

### 字符串长度

计算字符串长度的正确方法如下：

~~~
__block NSUInteger length = 0;
[str enumerateSubstringsInRange:NSMakeRange(0, [str length])
                        options:NSStringEnumerationByComposedCharacterSequences
                     usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                       length += 1;
                     }];
NSLog(@"length = %lu", length); // length = 3
~~~

### 字符串比较

判断字符串是否相等，应先将它们正规化为同样的形式，再逐字比较。

~~~
// 标准等价比较
NSString *str1 = @"\u00C5";
NSString *str2 = @"\u212B";
NSLog(@"%d %d", [str1 isEqualToString:str2], [str1 tk_isCanonicallyEquivalentTo:str2]); // 0 1

// 相容等价比较
NSString *str3 = @"\uFB00";
NSString *str4 = @"ff";
NSLog(@"%d %d", [str3 isEqualToString:str4], [str3 tk_isCompatibilityEquivalentTo:str4]); // 0 1
~~~

## 最后的话

记住，BMP 里所有的字符在 UTF-16 里都可以用一个码元表示，BMP 以外的所有字符都需要两个码元（一个代理对）来表示。基本上所有现代使用的字符都在 BMP 里，因此在实际中很难遇到代理对。然而，这几年随着 emoji 被引入 Unicode（在 1 号平面），而且被广泛使用，遇到代理对的机会越来越大了，你的代码必须能够正确处理它们。

不过，当我们处理 URL 参数名字、某些交互协议命令名字或字典键名字的时候，还是可以不用正规化而直接进行比较、取长度等操作，因为大概不会有人用英文字符和阿拉伯数字字符以外的字符来定义这些字段吧，至于参数内容，自己看着办吧。