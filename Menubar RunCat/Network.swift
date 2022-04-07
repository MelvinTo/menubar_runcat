//
//  Network.swift
//  Menubar RunCat
//
//  Created by Melvin Tu on 07/04/2022.
//  Copyright © 2022 Takuto Nakamura. All rights reserved.
//

import Foundation
import Darwin
import SystemConfiguration


public class Network {
  static func gatewayIP() -> String? {
    
    let ds = SCDynamicStoreCreate(kCFAllocatorDefault, "runcat" as CFString, nil, nil)
    
    guard let dr = SCDynamicStoreCopyValue(ds, "State:/Network/Global/IPv4" as CFString) else {return nil}
    
    if let gw = dr[kSCPropNetIPv4Router] as? String {
      print(gw)
      return gw
    }
    
    return nil
  }
}
