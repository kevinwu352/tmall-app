Future
Deferred
Just
Empty(completeImmediately: true, outputType: Int.self, failureType: Never.self) 默认是马上完成
Fail
Record<Int,PlainError>(output: [1,2,3,4], completion: .finished) 重放这个数组中的元素

Future<Int,Never> { res in
    print("fut 111")      // 创建时开始执行
    DispatchQueue.main.delay(2.0) {
        print("fut 222")
        res(.success(101))
    }
}
Deferred<Future<Int,Never>> {
    print("def 000")      // 有人订阅时开始执行
    return Future { res in
        print("def 111")
        DispatchQueue.main.delay(2.0) {
            print("def 222")
            res(.success(202))
        }
    }
}


在某 Publisher 上调用 sink，Publisher 会开始产生数据，如果再 sink 一次，可能得不到数据。所以产生了 ConnectablePublisher，调用 makeConnectable / connect。
connect 的返回值要保留，用来取消 publishing，产生数据要时间，connect 时开始请求网络，如果 cancel 掉就不会产生结果了。
Multicast 和 Timer 已经是 ConnectablePublisher。如果我们明确知道只有一个 sink，不用等待多个 sink，让程序员主动去 connect 反而麻烦，所以可以用 autoconnect 将其转化回正常 Publisher，即有人 sink 就开始产生数据。

The @Published attribute is class constrained. Use it with properties of classes, not with non-class types like structures.


searchBar.rx.text.orEmpty
    .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
    .distinctUntilChanged()
    .flatMapLatest { query -> Observable<[Repository]> in
        if query.isEmpty {
            return .just([])
        }
        return searchGitHub(query)
            .catchAndReturn([])
    }
    .observe(on: MainScheduler.instance)
    .bind(to: tableView.rx.items(cellIdentifier: "Cell")) {
        (index, repository: Repository, cell) in
        cell.textLabel?.text = repository.name
        cell.detailTextLabel?.text = repository.url
    }
    .disposed(by: disposeBag)

flatMapLatest 等于下面两句
.map { publisher }
.switchToLatest() 只要 map 上面有新的数据过来，map 将它转化为一个流，就会切换到这个新的流
而
flatMap(maxPublishers:_:) 只会降维，不能选择只保留最后的



哪个线程发，后续就在哪个线程，除非手动改改
  pub.send(xxx)

URLSession.shared.dataTaskPublisher(for: url)
  .sink { _ in } // false com.apple.NSURLSession-delegate 任何队列发起都如此

URLSession.shared.dataTaskPublisher(for: url)
  .timeout(.seconds(3), scheduler: DispatchQueue.utility) // 会修改后续响应的队列，不超时也会改，就算在 map 里面也能改外面
  .sink { _ in } // false com.apple.root.utility-qos

.subscribe(on: xxx)
  修改 subscribe / request / cancel 这些操作的线程，改改自定义的还行，UI 相关的还是不要改了，会报警告
  数据的分发还是遵守原来的规则：哪个线程发，后续就在哪个线程
  改不了 URLSession 的发送队列
  放在 sink 前面任何位置都行


## 映射

map(_:) / tryMap(_:)
  如果遇到错误，会结束流

mapError(_:)
  把流中出现的错误转变成另外一种错误

replaceNil(with:)
  用默认值替换流中出现的 nil

scan(_:_:) / tryScan(_:_:)
  提供一个初始值，回调会收到新值和上次返回的值，reduce 累加后回调一次，scan 每次都回调

setFailureType(to:)
  当错误类型是 Never 时，可以用此方法将流转成会失败的流


## 筛选

filter(_:) / tryFilter(_:)

compactMap(_:) / tryCompactMap(_:)
  转换值，并且筛选掉 nil 值

removeDuplicates()
  和前一个元素比较，不管前前元素是否相等

removeDuplicates(by:) / tryRemoveDuplicates(by:)
  和前一个元素比较，不管前前元素是否相等

replaceEmpty(with:)
  如果一个流结束之前，没有产生任何元素，提供一个

replaceError(with:)
  把流中出现的错误转变成正常值，相当于把错误的 finished 换成了一个元素，再无 finished 了
  catch(_:) 是在错误发生时提供一个新的 Publisher


## 累加

collect() 所有元素，一个数组
collect(_:) n个元素一组，多个数组
collect(.byTime(RunLoop.main, .seconds(5)))           // 时间到
collect(.byTimeOrCount(RunLoop.main, .seconds(5), 3)) // 时间到 / 缓冲区满

ignoreOutput()
  忽略元素，只把成功或失败发下去

reduce(_:_:) / tryReduce(_:_:)


## 数学操作符

count()

max() / max(by:) / tryMax(by:)

min() / min(by:) / tryMin(by:)


## 匹配规则

contains(_:) / contains(where:) / tryContains(where:)

allSatisfy(_:) / tryAllSatisfy(_:)


## 序列操作

drop(untilOutputFrom:)
  忽略所有发出的元素，直到第二个流发出一个元素，然后取订第二个流，应用场景？
dropFirst(_:)
  忽略前 n 个元素
drop(while:) / tryDrop(while:)
  一直忽略，直到闭包返回 false，且后面不忽略了

prefix(untilOutputFrom:)
  提取所有发出的元素，直到第二个流发出一个元素
prefix(_:)
  提取前 n 个元素
prefix(while:) / tryPrefix(while:)
  一直提取，直到闭包返回 false，且后面不再取了

append(_:) / append(_:) / append(_:)
  流结束后，追加新的元素，元素可以来自序列或另一个流
prepend(_:) / prepend(_:) / prepend(_:)
  流启动前，添加新的元素，元素可以来自序列或另一个流


## 选择指定的元素

first()
  只取第一个元素，然后结束
first(where:) / tryFirst(where:)
  只取符合条件的第一个元素

last()
  等流正常结束，取最后一个元素，失败结束则不取
last(where:) / tryLast(where:)
  只取符合条件的最后一个元素

output(at:)
  只取第 n 个元素
output(in:)
  只取区间内的元素


## 多序列

combineLatest(pub1)
combineLatest(pub1, transform)
combineLatest(pub1, pub2)
combineLatest(pub1, pub2, transform)
combineLatest(pub1, pub2, pub3)
combineLatest(pub1, pub2, pub3, transform)
  self 和 pub 发出一个元素，则与另一流的上一个元素组合并发下去，所以另一个流至少要发过一个元素
  后面收到的是元组，也可以用 transform 闭包将元组转化为单个元素

merge(with:)
merge(with:_:_:_:_:_:_:)
  将两个相同元素的流合并成一个流，相当于两个自来水管合并成一个
  能合并的个数非常多，够用

zip(pub1)
zip(pub1, transform)
zip(pub1, pub2)
zip(pub1, pub2, transform)
zip(pub1, pub2, pub3)
zip(pub1, pub2, pub3, transform)
  配对再发出，当一个流发出一个元素时，combineLatest 是与另一个流的最新元素组成元组并发出，zip 是严格序号配对再发出


## 时间

debounce(for:scheduler:options:)  一直推后推行
  触发 n 秒后再执行回调，如果在这 n 秒内又被触发，则重新计时
throttle(for:scheduler:latest:)   某时间段执行一次
  每隔一段时间，只执行一次函数，第一个值会收到，后续根据 latest 值取最新或最旧
latest = true
send: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
val:   1           5               10           12
latest = false
send: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
val:   1           2               6             11

measureInterval(using:options:)
  两个元素产生的时间差

delay(for:tolerance:scheduler:options:)
  延迟流后面订阅者收到元素的时间

timeout(_:scheduler:options:customError:)
  某个时间内未有新元素，则超时


## 共享

不知道这两种方式有什么特别的用处
multicast(_:)
  参数是返回 subject 的闭包，每个订阅会创建新的 subject
multicast(subject:)
  参数是 subject，每个订阅共享这个 subject

share()
  相当于 Multicast + PassthroughSubject + autoconnect()


## 其它

encode(encoder:)
decode(type:decoder:)

buffer(size:prefetch:whenFull:)

map(_:)
map(_:_:)
map(_:_:_:)
  把某值的属性作为元素发出来
  struct DiceRoll {
    let die: Int
  }
  let dr = DiceRoll(die: 4)
  Just(dr)
    .map(\.die)
    .sink { print($0) }
    .store(in: &disposables)
  // 4
