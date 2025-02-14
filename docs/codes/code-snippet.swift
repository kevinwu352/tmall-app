
func run() {
  let group = DispatchGroup()

  group.enter()
  job(2) { group.leave() }

  group.enter()
  job(4) { group.leave() }

  group.enter()
  job(6) { group.leave() }

  group.notify(queue: .main) {
    print("done")
  }
}

let list = [2, 3, 1, 4]
let res = list.sorted { $0 < $1 }
print(res)



public extension Collection where Self: MutableCollection & RangeReplaceableCollection {
  @discardableResult mutating func update(_ i: Int, _ e: Element) -> Element? {
    if let old = at(i) {
      self[idx(i)] = e // MutableCollection
      return old
    } else {
      if i == count {
        append(e) // RangeReplaceableCollection
      }
      return nil
    }
  }
}

