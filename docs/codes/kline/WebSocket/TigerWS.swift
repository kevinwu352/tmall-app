//
//  TigerWS.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit
import Combine

public class TigerWS: WebSocketManager {

  public static let shared = TigerWS("ws://192.168.50.127:8080")

}
