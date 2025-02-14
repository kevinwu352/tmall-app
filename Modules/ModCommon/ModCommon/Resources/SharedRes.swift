//
//  SharedRes.swift
//  ModCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import RswiftResources

public struct Res {

  public struct img {
    public static var alien: RswiftResources.ImageResource { R.image.shared.alien }
    public static var hill: RswiftResources.ImageResource { R.image.shared.hill }
    public static var icon_navbar_back_day: RswiftResources.ImageResource { R.image.shared.icon_navbar_back_day }
    public static var icon_navbar_back_ngt: RswiftResources.ImageResource { R.image.shared.icon_navbar_back_ngt }
  }

  public struct str {
    public static var alert_cancel: RswiftResources.StringResource { R.string.shared.alert_cancel }
    public static var alert_confirm: RswiftResources.StringResource { R.string.shared.alert_gotit }
    public static var alert_gotit: RswiftResources.StringResource { R.string.shared.alert_confirm }
  }

}
