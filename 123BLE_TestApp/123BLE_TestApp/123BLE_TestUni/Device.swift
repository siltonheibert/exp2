//
//  Device.swift
//  BLEConnect
//
//  Created by Evan Stone on 8/15/16.
//  Copyright © 2016 Cloud City. All rights reserved.
//

import Foundation

internal struct Device {
    
    // UUIDs
    static let V5DataService = "08590F7E-DB05-467E-8757-72F6FAEB13D5"
    static let RXBrainAdminChar = "08590F7E-DB05-467E-8757-72F6FAEB13F5"
    static let TXBrainAdminChar = "08590F7E-DB05-467E-8757-72F6FAEB1306"
    static let RXBrainUserChar = "08590F7E-DB05-467E-8757-72F6FAEB1326"
    static let TXBrainUserChar = "08590F7E-DB05-467E-8757-72F6FAEB1316"
    static let RXBrainLockChar = "08590F7E-DB05-467E-8757-72F6FAEB13E5"
    
    
    static let JSService = "08590F7E-DB05-467E-8757-72F6FAEB13A5"
    static let JSDataChar = "08590F7E-DB05-467E-8757-72F6FAEB13B5"
    static let JSRateChar = "08590F7E-DB05-467E-8757-72F6FAEB13C5"
    static let JSData2Char = "08590F7E-DB05-467E-8757-72F6FAEB1336"
    static let DeviceStatusChar = "08590F7E-DB05-467E-8757-72F6FAEB1337"

    
    // Tags
    static let EOM = "{{{EOM}}}"
    
    // We have a 20-byte limit for data transfer
    static let notifyMTU = 20
    
    static let centralRestoreIdentifier = "io.cloudcity.BLEConnect.CentralManager"
    static let peripheralRestoreIdentifier = "io.cloudcity.BLEConnect.PeripheralManager"
    
}
