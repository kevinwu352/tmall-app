//
//  CollectionExt.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

// 1..<2 // Range<Int>
//
// 1...2 // ClosedRange<Int>
//
// 1...  // PartialRangeFrom<Int>
// ...2  // PartialRangeThrough<Int>
//  ..<2 // PartialRangeUpTo<Int>

public extension Range where Bound == Int {
  func `in`<C: Collection>(_ c: C) -> Range<C.Index> {
    c.index(lowerBound)..<c.index(upperBound)
  }
}
public extension NSRange {
  func `in`<C: Collection>(_ c: C) -> Range<C.Index> {
    c.index(location)..<c.index(end)
  }
}
public extension NSRange {
  var end: Int { location + length }
}


public extension ArraySlice {
  var ary: Array<Element> { Array(self) }
}

public extension Collection {

  var notEmpty: Bool { !isEmpty }


  // MARK: 获取子内容 - 索引

  // [ ] startIndex / endIndex / ...

  func at(_ i: Int) -> Element? {
    idxIn(i) ? self[index(i)] : nil
  }

  // 能否用于 []
  func idxIn(_ i: Int) -> Bool {
    i >= 0 && i < count
  }
  // 能否用于 insert
  func idxInn(_ i: Int) -> Bool {
    i >= 0 && i <= count
  }
  // 正负方向，最后位置是 -1
  func idxUni(_ i: Int) -> Int {
    i < 0 ? i + count : i
  }

  // 越界以后，返回首或尾
  func index(_ i: Int) -> Index {
    i < 0 ? startIndex : index(startIndex, offsetBy: i, limitedBy: endIndex) ?? endIndex
  }


  // MARK: 获取子内容 - 规则

  // [ ] min / min(by: xxx)
  // [ ] max / max(by: xxx)

  // [ ] first / last
  // [ ] randomElement

  // [ ] prefix                     [0...∞]
  // [ ] prefix(upTo: xxx)          前 n 个，效果同上
  // [ ] prefix(through: xxx)       前 n+1 个
  // [ ] prefix(while: xxx)         第一次 false 之前所有的
  // [ ] suffix                     [0...∞]
  // [ ] suffix(from: xxx)          去掉前 n 个，剩下的

  // [ ] first(where: xxx)
  // [ ] firstIndex(of: xxx)
  // [ ] firstIndex(where: xxx)
  // [ ] last(where: xxx)
  // [ ] lastIndex(of: xxx)
  // [ ] lastIndex(where: xxx)


  // MARK: 检查子内容

  // [ ] contains(xxx)
  // [ ] allSatisfy(xxx)
  //
  // [S] hasPrefix(xxx)
  // [S] hasSuffix(xxx)

  func some(_ h: (Element)->Bool) -> Bool { // CLOS
    contains(where: h)
  }
  // 空集合一定是 true
  func every(_ h: (Element)->Bool) -> Bool { // CLOS
    allSatisfy(h)
  }
  // 空集合一定是 true
  func none(_ h: (Element)->Bool) -> Bool { // CLOS
    !some(h)
  }


  // MARK: 增删内容

  // [ ] a = a + [x]
  // [ ] a += [x]
  // [ ] append(x)
  // [ ] append(contentsOf: [x])

  // [ ] insert(x, at: a.startIndex)                    [0...count]
  // [ ] insert(contentsOf: [x], at: a.startIndex)      [0...count]

  // [ ] remove(at: n)                                  [0..<count]
  // [ ] removeFirst() / removeLast()                   crash on empty collection
  // [ ] removeFirst(n) / removeLast(n)                 [0...count]
  // [ ] dropFirst(n)   / dropLast(n)                   不改变原集合
  // [ ] removeAll      / removeAll(where: xxx)         筛掉所有为 true 的，会改变原集合
  // [ ]                / drop(while: xxx)              筛掉为 true 的，直到第一个 false 出现，停止，不会改变原集合
  // [ ] removeSubrange(1...3)                          [0..<0, count..<count]

  // [ ] replaceSubrange                                [0..<0, count..<count]
  // [S] replacingOccurrences(of:, with:)


  // MARK: 高阶方法

  // [ ] forEach
  // [ ] map / compactMap
  // [ ] filter / drop(while: xxx) / removeAll(where: xxx)
  // [ ] reduce
  // [ ] flatMap


  // MARK: 重排顺序

  // [A] sort / sorted
  // [A] reverse / reversed
  // [A] shuffle / shuffled
  // [A] swapAt                   [0..<count]
}

// MARK: 字典

// [D] updateValue(_,forKey:)    // 返回旧值，能判断新加或更新
// [D] removeValue(forKey:)      // 返回旧值
// [D] removeAll(keepingCapacity:)

// [D] merge(_:uniquingKeysWith:)     // 改变原集合
// [D] merging(_:uniquingKeysWith:)   // 返回新集合

// [D] forEach(_:)
// [D] map(_:) / compactMap(_:)                // 返回数组
// [D] mapValues(_:) / compactMapValues(_:)    // 返回字典
// [D] filter(_:)
// [D] reduce(_:_:)
// [D] flatMap(_:)

// [D] first(where:)     // 返回元组 (key,value)
// [D] min(by:)
// [D] max(by:)

// [D] contains(where:)
// [D] allSatisfy(_:)

public extension Collection {
  func removeDuplicates<P: Equatable>(_ h: (Element)->P?) -> [Element] { // CLOS
    reduce([Element]()) { ret, item in
      var ret = ret
      if !ret.contains(where: { h($0) == h(item) }) {
        ret.append(item)
      }
      return ret
    }
  }
}


public extension Dictionary {
  func set(_ v: Value?, _ k: Key?) -> Self {
    guard let k = k else { return self }
    var ret = self
    ret[k] = v
    return ret
  }
  // removeValue(forKey:)
  // updateValue(_:forKey:) return old value
  // ~~~                    return new value
  @discardableResult
  mutating func assignValue(_ v: Value?, _ k: Key?) -> Value? {
    guard let k = k else { return nil }
    self[k] = v
    return v
  }
}


public extension Array {
  var toDict: [Int:Element] {
    enumerated()
      .reduce([Int:Element]()) { $0.set($1.element, $1.offset) }
  }
}
public extension Dictionary where Key == Int {
  var toList: [Value] {
    enumerated()
      .sorted { $0.element.key < $1.element.key }
      .map { $0.element.value }
  }
}
