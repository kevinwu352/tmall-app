//
//  HomeViewModel.swift
//  contest
//
//  Created by Kevin Wu on 1/29/26.
//

import Foundation

@MainActor
class HomeViewModel {

  var name: String?

  func getName() async -> String {
    print("begin get name")
    try? await Task.sleep(for: .seconds(2))
    print("end get name")
    name = "kevin"
    return name!
  }

  func getAge() async throws -> Int {
    print("begin get age")
    try? await Task.sleep(for: .seconds(4))
    print("end get age")
    throw Unicode.UTF8.ValidationError.Kind.truncatedScalar
    return 18
  }

}
