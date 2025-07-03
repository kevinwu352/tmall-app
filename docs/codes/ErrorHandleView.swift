//
//  ContentView.swift
//  testabc
//
//  Created by Kevin Wu on 9/17/25.
//

import SwiftUI

// 使用 defer 保障最后的清理工作
// let file = open(filename)
// defer { close(file) }

// 限定异常类型
func summarize() throws(NetworkError) {}
func call1() {
    do throws(NetworkError) { // 就算不写这个类型，后边也能推断出来，这里只会抛出一种异常类型
        try summarize()
    } catch {
        switch error { // error 的类型被限定了
        case .network: break
        case .status: break
        case .decode: break
        }
    }
}

// 捕捉异常
// catch is VendingMachineError
// catch VendingMachineError.invalidSelection, VendingMachineError.insufficientFunds, VendingMachineError.outOfStock

// 重新抛出异常
// 单语句 catch 有个隐含的变量 error。而其它有条件的 catch 貌似没
// 所以，对于一个枚举异常，估计只能每种情况 catch 一次，然后每个分支抛出来。否则，如果用 is NetworkError 来捕捉，就抛不出来了
//
//func handleAndRethrow() throws {
//    do {
//        try performOperation()
//    } catch MyError.specificError(let message) {
//        print("Caught a specific error: \(message). Performing some local handling...")
//        // Perform specific error handling here, e.g., logging, partial recovery
//        throw MyError.generalError // Rethrow a different error
//    } catch {
//        print("Caught a general error: \(error). Rethrowing the original error.")
//        throw error // Rethrow the original caught error
//    }
//}

// ================================================================================
struct NetworkExec: Error { }
struct StatusExec: Error { }
struct DecodeExec: Error { }
func networkWork(_ value: Bool) throws {
    if value {
        print("network done")
    } else {
        throw NetworkExec()
    }
}
func statusWork(_ value: Bool) throws {
    if value {
        print("status done")
    } else {
        throw StatusExec()
    }
}
func decodeWork(_ value: Bool) throws {
    if value {
        print("decode done")
    } else {
        throw DecodeExec()
    }
}
enum NetworkError: Error {
    case network
    case status
    case decode
}
// ================================================================================

func pack1(_ value1: Bool, _ value2: Bool) throws {
    do {
        throw NetworkError.decode
        try networkWork(value1)
        try statusWork(value2)
    } catch is NetworkExec {
        print("pack1: NetworkExec")
    } catch NetworkError.network, NetworkError.status {
        print("pack1: .network | .status")
    } catch {
        print("pack1: other, \(error)")
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button {
                do {
                    try pack1(false, true)
                } catch {
                    print("got: \(error)")
                }
            } label: {
                Text("run")
            }

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
