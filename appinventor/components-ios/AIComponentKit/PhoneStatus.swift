//
//  PhoneStatus.swift
//  AIComponentKit
//
//  Created by Evan Patton on 9/21/16.
//  Copyright © 2016 MIT Center for Mobile Learning. All rights reserved.
//

import Foundation
import CoreFoundation

open class PhoneStatus : NonvisibleComponent {
  // MARK: PhoneStatus Methods
  @objc open class func GetWifiIpAddress() -> String {
    return NetworkUtils.getIPAddress()
  }

  @objc open class func isConnected() -> Bool {
    return NetworkUtils.getIPAddress() != "error"
  }

  @objc open func setHmacSeedReturnCode(_ seed: String) -> String {
    AppInvHTTPD.setHmacKey(seed)
    return seed.sha1
  }

  @objc open func isDirect() -> Bool {
    // iOS Companion only runs via Wifi
    return false
  }

  @objc open func startHTTPD(_ secure: Bool) {
    ReplForm.topform?.startHTTPD(secure)
  }

  @objc open func setAssetsLoaded() {
    if _form is ReplForm {
      (_form as! ReplForm).setAssetsLoaded()
    }
  }

  @objc open class func doFault() throws {
    throw NSError(domain: "AIComponentKit", code: -1)
  }

  @objc open func getVersionName() -> String {
    let info = Bundle.main.infoDictionary
    if let versionString = info?["CFBundleShortVersionString"] as? String {
      return versionString
    } else {
      return ""
    }
  }

  @objc open func installUrl(_ url: String) {
    // not implemented for iOS
    _form?.dispatchErrorOccurredEvent(self, "installUrl",
        ErrorMessage.ERROR_IOS_INSTALLING_URLS_NOT_SUPPORTED.code,
        ErrorMessage.ERROR_IOS_INSTALLING_URLS_NOT_SUPPORTED.message)
  }

  @objc open func shutdown() {
    exit(0)
  }

  // MARK: PhoneStatus Events
  @objc open func OnSettings() {
    EventDispatcher.dispatchEvent(of: self, called: "OnSettings")
  }
}
