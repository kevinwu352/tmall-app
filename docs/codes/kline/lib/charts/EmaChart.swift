//
//  EmaChart.swift
//  ModHomePage
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Charts
import AppCommon

class EmaChart: RangeChart {

  struct Config {
    var period: Int
    var color: UIColor?
  }
  let configs: [Config]

  init(_ list: [KlineModel], _ configs: [Config]) {
    self.configs = configs
    super.init(list)
  }
  override func setup() {
    super.setup()
    dataSets.append(contentsOf: emaLineSets)
  }
  override func add(_ index: Int, _ model: KlineModel) {
    super.add(index, model)

    emaLineSets.enumerated().forEach { idx, set in
      set.removeEntry(index: index)
      if let entry = lineEntry(1+idx, index, model) {
        set.append(entry)
      }
    }
  }


  override func reloadResults() {
    super.reloadResults()
    let res = configs.map { index_ema(list.map({ [$0.close.dbl ?? 0] }), $0.period) }
    results += res
  }

  lazy var emaLineSets: [LineChartDataSet] = {
    let ret = configs.enumerated().map { idx, config -> LineChartDataSet in
      let set = lineSet("ema\(config.period)-line",
                        list.enumerated().compactMap { lineEntry(1+idx, $0.offset, $0.element) },
                        .right,
                        config.color)
      return set
    }
    return ret
  }()


  override var legendValues: [NSAttributedString] {
    let index = (highlight?.x ?? highestX).int
    return configs.enumerated().compactMap { idx, config -> NSAttributedString? in
      if let vals = results[idx+1][index],
         let str = Num(vals[0]).scaleBankers(decimals)
      {
        return NSAttributedString(string: "EMA(\(config.period)):\(str)", attributes: [.font: UIFont.kline_legend, .foregroundColor: config.color as Any])
      }
      return nil
    }
  }

}
