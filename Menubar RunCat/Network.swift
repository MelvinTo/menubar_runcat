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

typealias gwIPCallback = (String) -> Void // (SCDynamicStore, CFArray, UnsafeMutableRawPointer?) -> Void

var gwIP : String? = nil

let DynamicStore = SCDynamicStoreCreate(
  nil, "runcat" as CFString,
  { ( _, _, _ ) in PrimaryIPv4InterfaceChanged() }, nil)!

func PrimaryIPv4InterfaceChanged ( ) {
  guard let ipv4State = SCDynamicStoreCopyValue(DynamicStore,
                                                "State:/Network/Global/IPv4" as CFString) as? [CFString: Any]
  else {
    return
  }
  
  if let gw = ipv4State[kSCPropNetIPv4Router] as? String {
    gwIP = gw
  }
}

public class Network {
  public init() {
    SCDynamicStoreSetNotificationKeys(
        DynamicStore, [ "State:/Network/Global/IPv4" ] as CFArray, nil)

    SCDynamicStoreSetDispatchQueue(DynamicStore, DispatchQueue.main)
    
    // fetch gwIP manually during init
    PrimaryIPv4InterfaceChanged()
  }
  
  public func gatewayIP() -> String? {
    return gwIP
  }
  
}
