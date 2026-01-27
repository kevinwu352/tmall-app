//
//  contestTests.swift
//  contestTests
//
//  Created by Kevin Wu on 1/29/26.
//

import Testing
@testable import contest

// HomeViewModel 创建的时候，不用添加到 Tests 目标内

// 加上这个，下面捕捉到异常后的提示信息变了
// 之前：Caught error: .truncatedScalar
// 之后：Caught error: err truncatedScalar
// 这个 extension 只能加在 Test Target 里面
extension Unicode.UTF8.ValidationError.Kind: @retroactive CustomTestStringConvertible {
  public var testDescription: String {
    switch self {
    case .truncatedScalar: "err truncatedScalar"
    case .surrogateCodePointByte: "err surrogateCodePointByte"
    default: "err other"
    }
  }
}

@MainActor // 也能放在下面的方法前面
struct contestTests {

  @Test func testName() async {
    let vm = HomeViewModel()
    _ = await vm.getName()
    #expect(vm.name == "kevin", "name should be kevin")
  }

  // 对于异常，那边正常抛出，这边不用 do-catch，如果有异常，Tests 就失败了
  // 当然也能添加 do-catch，如果加了就不用加 throws 了
  // 如果这个测试能抛出异常，要添加 throws，上面那个测试则不用加
  @Test func testAge() async throws {
    let vm = HomeViewModel()
    let age = try await vm.getAge()
    #expect(age == 18, "age should be 18")
  }

}

// 如果是 Completion-Handler 这样的函数，用 Continuation 来测试
// @Test("Loading view model readings")
// func loadReadings() async {
//   let viewModel = ViewModel()
//   await withCheckedContinuation { continuation in
//     viewModel.loadReadings { readings in
//       #expect(readings.count >= 10, "At least 10 readings must be returned.")
//       continuation.resume()
//     }
//   }
// }
