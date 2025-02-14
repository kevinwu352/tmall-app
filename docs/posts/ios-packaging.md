---
title: "iOS 项目自动打包教程"
author: "Kevin Wu"
date: "2015/10/22"
category: ["ios"]
---

## 基础理论

给测试人员打包的时候，有时候需要使用测试环境，有时候需要使用生产环境。如果在代码中用宏来确定使用哪个环境，这样在每次打包的时候都要修改宏，且程序员必须等打包完成，再将宏改回来并继续开发，这样机械化的操作有时候会有疏漏。这里我们使用脚本自动完成此功能。

程序本身已经定义了一个 DEBUG 宏，代码中可以用它来检测是否是测试版本，这远远不够，我们还要根据需要定义 DAILY_DEBUG 和 DAYLY_RELEASE 两个宏。如果在代码中检测到 DAILY_DEBUG 宏，表示正在编译的版本是给测试人员使用的测试环境版本；如果在代码中检测到 DAILY_RELEASE 宏，表示正在编译的版本是给测试人员使用的生产环境版本；如果在代码中检测到 DEBUG 宏，表示正在编译的版本是程序员自己用 Xcode 运行的版本，这种情况下，程序员可以在登录页面填入帐号和密码，以省去开发期间不断重复的登录操作；如果在代码中检测到没有这几个宏，表示正在编译的版本是准备发布到 App Store 的版本，当然，程序员也可以用 Release 模式运行代码。

~~~
#ifdef DAILY_DEBUG

// 用命令行打包，release 配置，debug 服务器
#define BASE_URL @"http://daily.debug"

#elif defined DAILY_RELEASE

// 用命令行打包，release 配置，release 服务器
#define BASE_URL @"http://daily.release"

#elif defined DEBUG

// 用 xcode 运行，debug 配置，debug 服务器
#define BASE_URL @"http://debug"

#else

// 用 xcode 运行，release 配置，release 服务器
// App Store 发布，release 配置，release 服务器
#define BASE_URL @"http://release"

#endif
~~~

理论上，如果命令行打包的时候使用 Debug 配置，定义 DEBUG 宏的同时新加两个宏的其中一个也会被定义。只不过我们给测试人员的包都是 Release 包，所以避免了这种情况出现。

## 安装 xctool

xctool 是 facebook 开源的一个命令行工具，用来替代 xcodebuild，它的用法与 xcodebuild 比较相似。

~~~
brew install xctool
~~~

## 准备编译参数

根据脚本参数确定编译所要使用的环境，继而确定编译参数。

~~~
WORKSPACE_NAME="GenericProj.xcworkspace"
SCHEME_NAME="GenericProj"
BUILD_ROOT="`pwd`/build"
PACKAGE_NAME="${SCHEME_NAME}-$1-`date +"%m%d%H%M"`"

if [[ $1 = "debug" ]]; then
BUILD_SETTING="DAILY_DEBUG=1"
elif [[ $1 = "release" ]]; then
BUILD_SETTING="DAILY_RELEASE=1"
else
BUILD_SETTING="DAILY_DEBUG=1"
fi
~~~

## 开始编译

~~~
// 编译 workspace
xctool build \
  -workspace ${WORKSPACE_NAME} \
  -scheme ${SCHEME_NAME} \
  -destination generic/platform=iOS \
  -configuration Release \
  -sdk iphoneos \
  OBJROOT=${BUILD_ROOT} SYMROOT=${BUILD_ROOT} GCC_PREPROCESSOR_DEFINITIONS='${inherited}'" ${BUILD_SETTING}"

// 编译 project
xctool build \
  -project ${PROJECT_NAME} \
  -scheme ${SCHEME_NAME} \
  -destination generic/platform=iOS \
  -configuration Release \
  -sdk iphoneos \
  OBJROOT=${BUILD_ROOT} SYMROOT=${BUILD_ROOT} GCC_PREPROCESSOR_DEFINITIONS='${inherited}'" ${BUILD_SETTING}"
~~~

## 开始打包

~~~
cd ${BUILD_ROOT}
mkdir Payload
cp -r Release-iphoneos/${SCHEME_NAME}.app Payload
zip -rq ${PACKAGE_NAME}.ipa Payload
~~~

## 上传 FTP

~~~
ftp -u ftp://user:password@ftp.xxx.com/dist/${PACKAGE_NAME}.ipa ${PACKAGE_NAME}.ipa
~~~

## 发送邮件

~~~
import sys, smtplib, email

# Settings
SMTP_SERVER = 'smtp.exmail.qq.com'
SMTP_PORT = 25

SMTP_USERNAME = 'aaa@xxx.com'
SMTP_PASSWORD = '123456'

SMTP_FROM = 'aaa@xxx.com'
SMTP_TO = 'bbb@xxx.com'
SMTP_CC = 'ccc@xxx.com,ddd@xxx.com'

ADDR_TO = ['bbb@xxx.com', 'ccc@xxx.com', 'ddd@xxx.com']


# Build message
message = email.MIMEMultipart.MIMEMultipart()
body = email.MIMEText.MIMEText(open(sys.argv[2]).read())
message.attach(body)
message.add_header('From', SMTP_FROM)
message.add_header('To', SMTP_TO)
message.add_header('Cc', SMTP_CC)
message.add_header('Subject', sys.argv[1])


# Send the message
mailer = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
mailer.login(SMTP_USERNAME, SMTP_PASSWORD)
mailer.sendmail(SMTP_FROM, ADDR_TO, message.as_string())
mailer.quit()
~~~

以上代码是 python 脚本，是笔者通过网上代码修改而成，它将第一个参数作为邮件主题，第二个参数作为邮件内容文件。笔者没学过 python，不过，天下武功出少林，大部分程序的代码都是差不多的。使用此脚本的时候要注意一点，`SMTP_TO` 和 `SMTP_CC` 是用来定义邮件头部信息，并不作为真正接收者，真正的接收者放到 `ADDR_TO` 中，且不分收件人和抄送人。
