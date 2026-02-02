// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

// package 加依赖，然后在 app 里 import 并使用
//   能成功，且依赖会出现在左侧已解决列表里
// app 加依赖，然后在 package 里 import 并使用
//   会失败

import PackageDescription

let package = Package(
  // > The name of the Swift package, or `nil` to use the package's Git URL to deduce the name.
  // 感觉这名字没啥用，因为使用这个包的时候，用的是它的 url 里的名字
  // 这里不能传 nil，文档里那句话不适用
  // 难道在本地包的时候才有用？
  // Xcode 左侧已解决的依赖，显示的是这个名字
  name: "CoreBase",
  // > The list of products that this package makes available for clients to use.
  // 外面可用的包列表
  products: [
    .library(
      // 其它库 import 时用的名字
      // 选择 Embed 哪些库时，列表里的名字
      name: "CoreBase",
      // 文档说，这是要包含到这个库里面的 target
      // 但我试了，如果整个 package 定义了多个 target，我想定义一个 library 包含两个 target，没成功
      // 我还试了，下面的 target 取名 abc，这里填 abc，也没成功
      // 我感觉，Package.name 可以乱取，但这里不行
      targets: ["CoreBase"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/kevinwu352/myrand.git", branch: "main"),
    // 如果依赖位于自己目录下，已加入到工程，不需要给名字
    .package(path: "../pngg"),
    // 如果依赖位于其它目录下，要给名字，Xcode 左侧还会列出已解决的依赖
    .package(name: "rands", path: "../../../rand-dir")
    // 我建议，对于包的名字，目录名字/Package.name/.library.name，这三者都一样，甚至 target.name 也是
    // 经过我验证
    //   当目录名字和其它名字相同时，.package(path:) / .package(name:path:) 效果一样
    //   当目录名字和其它名字不同时，前都有错误，后者能成功
    // 其它效果还是一样，工程里的依赖不会列表已解决列表，工程之外的会列出来
  ],
  targets: [
    .target(
      // 这个名字也是代码文件夹的名字，Sources/CoreBase
      name: "CoreBase",
      dependencies: [
        // name 是包里面的 products 列表里的名字
        // package 是 myrand.git 去掉 .git
        .product(name: "libranda", package: "myrand"),
        // 如果是工程里的依赖，可以直接用这个名字
        "pngg"
      ]
    ),
    .testTarget(
      name: "CoreBaseTests",
      dependencies: ["CoreBase"]
    ),
    // 定义一个 target: jpgg，可以直接在另外一个 target.dependencies: ["jpgg"] 里引用
    // 在代码里直接 import jpgg，而不需要在最上面定义 library
    // 又试了一下，还能在 AppDelegate 里使用，太离谱了
    // 关闭 Xcode 再打开，清除缓存，又报错了，过一会又行了
    // 感觉不要这样用
  ]
)
