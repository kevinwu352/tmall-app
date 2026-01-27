// 这里 user 不能发送，注意理解这个编译错误，目前我也不太懂
// 这是 hackingwithswift.com 里的例子，我没复现出来
//
// class User {
//   let name: String
//   let password: String
//   init(name: String, password: String) {
//     self.name = name
//     self.password = password
//   }
// }
// @main
// struct App {
//   static func main() async {
//     // Non-sendable result type 'User' cannot be sent from nonisolated context in call to async function
//     async let user = User(name: "twostraws", password: "fr0st1es") // 这里出错
//     await print(user.name)
//   }
// }
