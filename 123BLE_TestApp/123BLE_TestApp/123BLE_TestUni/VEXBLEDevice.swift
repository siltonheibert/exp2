//
//  VEXBLEDevice.swift
//  BLEConnect
//
//  Created by levi_pope on 2/28/19.
//  Copyright © 2019 Cloud City. All rights reserved.
//

import Foundation
import CoreBluetooth
import os.log

public struct vexDeviceInfo: Codable {
    
    /// Advertised name
    public var  Name: String?
    
    /// VEXos Major Version
    public var  VersionMajor: UInt8
    
    /// VEXos Minor Version
    public var  VersionMinor: UInt8
    
    /// VEXos Build Version
    public var  VersionBuild: UInt8
    
    /// VEXos Beta Version
    public var  VersionBeta: UInt8
    
    /// IQ2 hardware version
    public var  HardwareVersion: UInt8
    
    /// IQ2 System Status flags (Defenition TBD)
    public var  SysStatusFlags: UInt32
    
    /// IQ2 Brain's 32bit Unique ID
    public var  DeviceID: Array<UInt8>
    
    /// Currently running slot. 0 means no user program is running
    public var  ActiveProgram: UInt8
    
    /// Current battery capacity in %
    public var  BatteryLevel: UInt8
    
    public init()
    {
        self.Name = ""
        self.VersionMajor = 0
        self.VersionMinor = 0
        self.VersionBuild = 0
        self.VersionBeta = 0
        self.DeviceID = Array<UInt8>(repeating: 0, count: 4)
        self.ActiveProgram = 0
        self.HardwareVersion = 0
        self.SysStatusFlags = 0
        self.BatteryLevel = 0
    }
    
    /// UInt32 version of the brain's unique ID
    public var DeviceIDValue: UInt32 {
        return CDCUtils.byteToUInt32(bytes: self.DeviceID)
    }
}


public enum VEX_JSConnectionState{
    /// Not connected
    case Off,
    
    /// Looking for connection
    Scanning,
    
    /// Looking for Joystick service
    Connecting,
    
    /// Joystick connected
    Connected
}
  

public enum VEX_DataConnectionState: UInt8, Codable{
    
    /// No conection
    case Off = 0
    
    /// Looking for connection
    case Scanning = 0x01
    
    /// Looking for data service
    case Connecting = 0x02
    
    /// Connected to admin data channel only
    case AdminConnected = 0x04
    
    /// Connected to user data channel only
    case UserConnected = 0x08
    
    /// Connected to both admin and user data channels
    case BothConnected = 0x0C
    
    /// Is true when both or admin only status
    public var isAdminConnected: Bool {
        switch self {
        case .AdminConnected,
             .BothConnected:
            return true
        default:
            return false
        }
    }
    
    /// Is true when both or user only status
    public var isUserConnected: Bool {
        switch self {
        case .UserConnected,
             .BothConnected:
            return true
        default:
            return false
        }
    }
    
    public var numValue: UInt8 {
        return self.rawValue
    }
}

public enum vexProductTypes:UInt8, Codable{
    /// Unknown product type
    case Unknown = 0
    
    /// VEX Go brain
    case VEX_GO = 0x31
    
    /// VEX 123 Robot
    case VEX_123_Puck = 0x41
    
    /// VEX Coder
    case VEX_Coder = 0x42
    
    /// VEX Pilot retail brain with Gyro
    case Pilot_Smart = 0x4A
    
    /// VEX Pilot retail brain without Gyro
    case Pilot = 0x4B
    
    /// VEX Gen2 pilot brain without Gyro
    case Pilot_V2_Retail = 0x4C
    
    /// VEX Gen2 pilot brain with Gyro
    case Pilot_V2_Retail_Smart = 0x4D
    
    /// This should not be used
    case Pilot_V2_Edu = 0x4E
    
    /// VEX V5 Brain
    case V5_Brain = 0x10
    
    /// VEX V5 Controller
    /// NOTE: This ID is in the scan response data after Mfg ID 0x1111
    case V5_Controller = 0x02
    
    /// VEX IQ2 Brain
    case IQ2_Brain = 0x20
    
    /// VEX IQ2 Controller
    case IQ2_Controller = 0x21
    
    /// VEX IQ1 Controller
    case IQ1_Controller = 0x2A
    
    /// VEX EXP Brain
    case EXP_Brain = 0x60
    
    /// VEX EXP Controller
    case EXP_Controller = 0x61
}

//public enum vexDeviceMode:UInt8, Codable{
//    /// Unknown pair mode
//    case Unknown = 0
//
//    /// Device is looking to pair
//    case Pair = 0xAA
//
//    /// Device is ready to connect to paired device
//    case Connect = 0x1F
//
//    /// Device is in OAD mode
//    case Update = 0x2F
//}

public enum VEX_WriteCharacteristic
{
    case AdminRX
    case UserRX
    case DataCode
}

public enum VEX_ReadCharacteristic
{
    case DataCode
}



public enum vexConnectionState{
    /// No connection
    case Off,
    
    /// Scanning for devices
    Scanning,
    
    /// Connected to device searching for services
    Connecting,
    
    /// Device is connected and ready
    Connected
}

/// These are a list of device modes that can be advertised by the robot.
public enum vexDeviceMode:UInt8, Codable{
    /// Should not be used
    case Unknown = 0
    /// This robot is wanting to pair
    case Pair = 0xA0
    /// This robot is ready to connect to its pair
    case Connect = 0x10
    /// This robot is in bootload mode
    case Update = 0x20
    /// This is a robot in production test mode
    case ProdTest = 0xF0
    /// This is a robot in special Identify mode
    case Identify = 0xB0
    /// This is a robot in production test mode but failed
    case ProdTestFail = 0xE0
}

public struct vexDevice: Codable {
    
    /// Device advertised name
    public var  Name: String?
    
    /// Device product type
    public var  ProductType: vexProductTypes
    
    /// Brain firmware version
    public var  BrainVersionMajor: UInt8
    
    /// Brain firmware version
    public var  BrainVersionMinor: UInt8
    
    /// Brain firmware version
    public var  BrainVersionBuild: UInt8
    
    /// Brain firmware version
    public var  BrainVersionBeta: UInt8
    
    /// Radio firmware version
    public var  RadioVersionMajor: UInt8
    
    /// Radio firmware version
    public var  RadioVersionMinor: UInt8
    
    /// Radio firmware version
    public var  RadioVersionBuild: UInt8
    
    /// Radio firmware version
    public var  RadioVersionBeta: UInt8
    
    /// The timestamp for the last advertising packet recived from this robot
    public var  DiscoverTime: Date = Date.init(timeIntervalSinceNow: 0)
    
    /// The RSSI for the last advertising packet recived from this robot
    public var  LastRSSI:Int8 = -99
    
    /// Battery percentage from adv data
    public var BattPercent:UInt8 = 100
    
    /// Brain's 32bit Unique ID
    public var  DeviceID: Array<UInt8>
    
    /// Current device pairing mode
    public var  DeviceMode: vexDeviceMode
    
    public init(Name: String, ProductType: vexProductTypes, BrainVersionMajor: UInt8, BrainVersionMinor: UInt8, BrainVersionBuild: UInt8, BrainVersionBeta: UInt8,RadioVersionMajor: UInt8, RadioVersionMinor: UInt8, RadioVersionBuild: UInt8, RadioVersionBeta:UInt8 ,  DeviceID: Array<UInt8>, DeviceMode: vexDeviceMode)
    {
        self.Name = Name
        self.ProductType = ProductType
        self.BrainVersionMajor = BrainVersionMajor
        self.BrainVersionMinor = BrainVersionMinor
        self.BrainVersionBuild = BrainVersionBuild
        self.BrainVersionBeta = BrainVersionBeta
        self.RadioVersionMajor = RadioVersionMajor
        self.RadioVersionMinor = RadioVersionMinor
        self.RadioVersionBuild = RadioVersionBuild
        self.RadioVersionBeta = RadioVersionBeta
        self.DeviceID = DeviceID
        self.DeviceMode = DeviceMode
    }
    
    /// Integer representation of this robot's unique ID
    public var DeviceIDValue : UInt32
    {
        return CDCUtils.byteToUInt32(bytes: self.DeviceID)
    }
    
    /// Radio Firmware version for this device as object
    public var RadioVersion : VEXFirmwareVersion
    {
        return VEXFirmwareVersion(major: self.RadioVersionMajor, minor: self.RadioVersionMinor, build: self.RadioVersionBuild, beta: self.RadioVersionBeta)
    }
    
    /// Brain Firmware version for this device as object
    public var BrainVersion : VEXFirmwareVersion
    {
        return VEXFirmwareVersion(major: self.BrainVersionMajor, minor: self.BrainVersionMinor, build: self.BrainVersionBuild, beta: self.BrainVersionBeta)
    }
    
    public var ProductName : String
    {
        switch self.ProductType {
        case .IQ2_Brain:
            return "IQ2"
        case .IQ2_Controller:
            return "IQ2_C"
        case .IQ1_Controller:
            return "IQ_C"
        case .V5_Brain:
            return "V5"
        case .V5_Controller:
            return "V5_C"
        case .EXP_Brain:
            return "EXP"
        case .EXP_Controller:
            return "EXP_C"
        default:
            return "Unknown"
        }
    }
    
    public var ProductIsController : Bool
    {
        switch self.ProductType {
        case .IQ1_Controller, .EXP_Controller, .IQ2_Controller, .V5_Controller:
            return true
        default:
            return false
        }
    }
};

/// Object that describes a firmware version
public struct VEXFirmwareVersion: Codable, Comparable{
    public var major: UInt8 = 0
    public var minor: UInt8 = 0
    public var build: UInt8 = 0
    public var beta: UInt8 = 0
    
    public init(major: UInt8, minor: UInt8, build: UInt8, beta: UInt8){
        self.major = major
        self.minor = minor
        self.build = build
        self.beta = beta
    }
    
    public func toString() -> String
    {
        return "\(self.major).\(self.minor).\(self.build).B\(self.beta)"
    }
    
    public static func == (lhs: VEXFirmwareVersion, rhs: VEXFirmwareVersion) -> Bool {
        return (lhs.major == rhs.major) && (lhs.minor == rhs.minor) && (lhs.build == rhs.build) && (lhs.beta == rhs.beta)
    }
    
    public static func < (lhs: VEXFirmwareVersion, rhs: VEXFirmwareVersion) -> Bool {
        
        if(lhs.major != rhs.major)
        {
            return lhs.major < rhs.major
        }
        else if(lhs.minor != rhs.minor)
        {
            return lhs.minor < rhs.minor
        }
        else if(lhs.build != rhs.build)
        {
            return lhs.build < rhs.build
        }
        else if(lhs.beta != rhs.beta)
        {
            //Special case for 0
            //For beta 0 is greater than any other value
            if(rhs.beta == 0)
            {
                return true
            }
            else
            {
                return lhs.beta < rhs.beta
            }
        }
        
        return false
    }
    
    public static func > (lhs: VEXFirmwareVersion, rhs: VEXFirmwareVersion) -> Bool {
        if(lhs.major != rhs.major)
        {
            return lhs.major > rhs.major
        }
        else if(lhs.minor != rhs.minor)
        {
            return lhs.minor > rhs.minor
        }
        else if(lhs.build != rhs.build)
        {
            return lhs.build > rhs.build
        }
        else if(lhs.beta != rhs.beta)
        {
            //Special case for 0
            //For beta 0 is greater than any other value
            if(rhs.beta == 0)
            {
                return false
            }
            else
            {
                return lhs.beta > rhs.beta
            }
        }
        
        return false
    }
}

internal struct vexBLEDeviceInfo{
    public var version: VEXFirmwareVersion
    public var productType: vexProductTypes
    
    public init(version: VEXFirmwareVersion, productType: vexProductTypes){
        self.version = version
        self.productType = productType
    }
}

internal struct PayloadInfo
{
    public var Data:Array<UInt8>   // Msg
    public var MaxTransferSize:Int // Packet Transfer Size
    public var Rate: Int           // Rate To send at
    public var Async:Bool          // Send async or sync
    public var WriteCharacteristic:CBCharacteristic? = nil //Write Characteristic (UserRX,AdminRX,Data)
    public init(msg: Array<UInt8>,maxTransferSize: Int ,rate:Int,async:Bool, writeCharacteristic:CBCharacteristic?)
    {
        self.Data = msg
        self.MaxTransferSize = maxTransferSize
        self.Rate = rate
        self.Async = async
        self.WriteCharacteristic = writeCharacteristic
    }
}

/// These are a list of device modes that can be advertised by the robot.
public enum vexEXPButtonValues:UInt16, Codable{
    case B = 0x01
    case Down = 0x02
    case A = 0x04
    case Up = 0x08
    case L2 = 0x10
    case L1 = 0x20
    case R2 = 0x40
    case R1 = 0x80
    case L3 = 0x0100
    case R3 = 0x0200
    case Power = 0x0400
}

/// These are a list of device modes that can be advertised by the robot.
public enum vexIQButtonValues:UInt16, Codable{
    case F_Down = 0x01
    case E_Down = 0x02
    case F_UP = 0x04
    case E_Up = 0x08
    case L_Down = 0x10
    case L_Up = 0x20
    case R_Down = 0x40
    case R_Up = 0x80
    case L3 = 0x0100
    case R3 = 0x0200
    case Power = 0x0400
}

public struct JS_Data
{
    public var rawData:Array<UInt8>?     // Msg
    public var LeftX_Axis:UInt8 = 0         // Left X Axis
    public var LeftY_Axis:UInt8 = 0         // Left Y Axis
    public var RightX_Axis:UInt8 = 0        // Right X Axis
    public var RightY_Axis:UInt8 = 0        // Right Y Axis
    public var BatteryVolts:UInt16 = 0      // Battery voltage in mV
    public var DeviceStateFlags:UInt16 = 0  // Device flags
    public var Buttons: UInt16 = 0          // JS Buttons
    public var BatteryPercent:UInt8 = 0     // Battery level as a percentage
    public var MainPower:UInt8 = 0          // Main Power ???
    public var IdleTime:UInt8 = 0           // Controller idle time in seconds
    public var PowerOffDelay:UInt8 = 0      // Power off countdown ???
    public var ContinuityCount:UInt8 = 0    // Incrementing number
    public var ClockTime:UInt32 = 0         // System clock from radio
}


public protocol VEXBLEDeviceManagerDelegate: AnyObject {
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didDiscover device: vexDevice)
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didUpdate state: vexConnectionState)
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didUpdateDataConnected state: VEX_DataConnectionState)
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didUpdateJSConnected state: VEX_JSConnectionState)
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didUpdate rssi: Int8)
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didReadlock key: Data)
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didRXAdmin data: Data)
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didTXAdmin data: Data)
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didRXUser data: Data)
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didRXJSData data: JS_Data)
    
}

public class VEXBLEDeviceManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate
{
    
    public weak var delegate: VEXBLEDeviceManagerDelegate?
    
    public var ConnectionState: vexConnectionState = vexConnectionState.Off
    
    public var ConnectedDevice: vexDevice = vexDevice(Name: "", ProductType: vexProductTypes.Unknown, BrainVersionMajor: 0, BrainVersionMinor: 0, BrainVersionBuild: 0, BrainVersionBeta: 0, RadioVersionMajor: 0,RadioVersionMinor: 0,RadioVersionBuild: 0, RadioVersionBeta: 0, DeviceID: [0,0,0,0], DeviceMode: vexDeviceMode.Unknown)
    
    var adminTimer: Timer?
    var userTimer: Timer?
    var dataTimer: Timer?
    
    private var contKeepAliveTimer: Timer!
    
    private var centralManager:CBCentralManager!
    
    private var peripheralMgr:CBPeripheralManager!
    
    private var peripheral:CBPeripheral?
    private var dataBuffer:NSMutableData!
    private var scanAfterDisconnecting:Bool = true
    private var dataCodeChar:CBCharacteristic? = nil
    
    private var brainRXAdminChar:CBCharacteristic? = nil
    private var brainTXAdminChar:CBCharacteristic? = nil
    private var brainRXUserChar:CBCharacteristic? = nil
    private var brainTXUserChar:CBCharacteristic? = nil
    
    private var JSDataChar:CBCharacteristic? = nil
    private var JSData2Char:CBCharacteristic? = nil
    private var JSRateChar:CBCharacteristic? = nil
    
    
    private var payloadSize = 0
    private var oadNextAddress:Int = 0
    private var started:Bool = false
    private var ble_On:Bool = false;
    
    private var vexDevices: [CBPeripheral:vexDevice] = [:]
    
    private var subscribeAdmin:Bool = false
    private var subscribeUser:Bool = false
    
    private var AdminQ:Array<PayloadInfo>! = []
    private var UserQ:Array<PayloadInfo>!  = []
    private var DataQ:Array<PayloadInfo>!  = []
    
    private var currentAdminPayload:PayloadInfo? = nil
    private var currentUserPayload:PayloadInfo? = nil
    private var currentDataPayload:PayloadInfo? = nil
    
    
    private var downloadState:Int = 0
    
    private let defaults = UserDefaults.standard
    
    private var jsStateData = JS_Data()
    
    
    private var currentDeviceInfo: vexDeviceInfo?
    private var currentBotHealth:Int = 100
    private var vexDeviceName:String = ""
    public var  DeviceKey: Array<UInt8> = [0,0,0,0]
    
    private var adminWriteData:Array<UInt8>? = nil
    private var userWriteData:Array<UInt8>? = nil
    
    public var DataConnectionState: VEX_DataConnectionState = VEX_DataConnectionState.Off
    
    public var JSConnectionState: VEX_JSConnectionState = VEX_JSConnectionState.Off
    
    
    
    public override init()
    {
        super.init();
        started = false;
        self.adminWriteData = Array<UInt8>()
        self.userWriteData = Array<UInt8>()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralMgr = CBPeripheralManager(delegate: self, queue: nil)
        dataBuffer = NSMutableData()
        
        //        BLE_TEST.setTestPoperties(testRead:false,testWrite:false, minInterval_ms: 1000, maxInterval_ms: 2000)
        
    }
    
    public func Start(deviceName: String, adminConnection: Bool, userConnection: Bool) -> Bool
    {
        if(!started)
        {
            subscribeAdmin = adminConnection
            subscribeUser = userConnection
            vexDeviceName = deviceName
            scanAfterDisconnecting = true;
            if(ble_On)
            {
                startScanning()
            }
            started = true;
        }
        
        return (centralManager != nil && centralManager.state != .poweredOff)
    }
    
    public func Stop()
    {
        stopScanning();
        scanAfterDisconnecting = false;
        disconnect();
        started = false;
    }
    
    public func isBLEEnabled() -> Bool
    {
        if(self.centralManager != nil)
        {
            return self.centralManager.state != .poweredOff
        }
        
        return false;
    }
    
    public func isStarted() ->Bool
    {
        return started
    }
    
    public func isAdminDataConnected() -> Bool
    {
        return self.brainTXAdminChar != nil
    }
    
    public func isUserDataConnected() -> Bool
    {
        return self.brainTXUserChar != nil
    }
    
    public func Connect(device: vexDevice)
    {
        self.setState(newState: vexConnectionState.Connecting)
        print("Trying to Connect to \(device.DeviceID)")
        for (key,value) in vexDevices
        {
            print("key:\(key) value:\(value)")
            if(value.DeviceID == device.DeviceID)
            {
                let peripheral = key as CBPeripheral?
                
                if(peripheral == nil)
                {
                    print("Peripheral object has not been created yet.")
                    return
                }
                
                self.peripheral = peripheral
                // Stop scanning
                //                centralManager.stopScan()
                //                print("Scanning Stopped!")
                
                // connect to the peripheral
                print("Connecting to peripheral: \(String(describing: peripheral))")
                DispatchQueue.main.async {
                    self.centralManager?.connect(self.peripheral!, options: nil)
                }
                
                self.ConnectedDevice = device
                
                break;
                
            }
            
        }
        
    }
    
    
    @discardableResult public func Read(characteristic: VEX_ReadCharacteristic) -> Bool
    {
        switch characteristic {
            
        case VEX_ReadCharacteristic.DataCode:
            if(self.dataCodeChar != nil){
                self.peripheral?.readValue(for: self.dataCodeChar!)
            }
            
            
            //default:
            //<#code#>
        }
        //}
        
        return true
        
        
        
        
    }
    let macos3_queue = DispatchQueue.global(qos:.utility)
    
    
    func WritePacket( ploadInfo: inout PayloadInfo? )
    {
        var packet:Data
        
        let async  = ploadInfo!.Async
        let characteristic = ploadInfo?.WriteCharacteristic
        
        
        // Return is no Data left transfer or if data nil
        if(ploadInfo?.Data.count == 0 || ploadInfo?.Data == nil)
        {
            ploadInfo = nil
            return
        }
        // Only remove remain bytes if less than max transfer size
        else if(ploadInfo!.Data.count < ploadInfo!.MaxTransferSize)
        {
            //            VEX_LogManager.OSLogMsg(level: .debug, catagory: OSLog.BLETEST, msg: "Final Packet SENT")
            packet = Data(Array<UInt8>(ploadInfo!.Data[0...(ploadInfo!.Data.count - 1)]))
            ploadInfo!.Data.removeSubrange(0...(ploadInfo!.Data.count - 1))
            ploadInfo = nil
            
            
        }
        //         Remove Max Transfer size
        else
        {
            //             VEX_LogManager.OSLogMsg(level: .debug, catagory: OSLog.BLETEST, msg: "MTU SENT")
            packet = Data(Array<UInt8>(ploadInfo!.Data[0...(ploadInfo!.MaxTransferSize - 1)]))
            ploadInfo!.Data.removeSubrange(0...(ploadInfo!.MaxTransferSize - 1))
        }
        
        //        if(BLE_TEST.WRITE_TEST(msg: packet as Data))
        //        {
        if((characteristic) != nil)
        {
            var tempString:String = "[ "
            for byte in Array<UInt8>(Data(packet))
            {
                tempString += String(format:"%02X, ",byte)
            }
            tempString += "]"
            
            //                VEX_LogManager.OSLogMsg(level: .debug, catagory: OSLog.BLETEST, msg: "Chunk Write [\(packet.count)]: \(tempString)")
            self.peripheral!.writeValue(packet as Data, for: characteristic!, type: async ? CBCharacteristicWriteType.withoutResponse : CBCharacteristicWriteType.withResponse)
        }
        //        }
        
    }
    
    
    
    private var startTime:Int64 = 0
    private var elapsedTime:Int64 = 0
    public func Write(characteristic: VEX_WriteCharacteristic, msgData: NSData, async:Bool, transferSize:Int=0,msSendRate:Int=1 )
    {
        //self.delegate?.VEXBLEDevMgr(deviceMgr: self, didTXAdmin: (msgData as Data))
        //VEX_VEX_LogManager.OSLogMsg(level: .debug, catagory: OSLog.BLETEST, msg: "Data Write: \(Array<UInt8>(Data(msgData)))")
        
        let packetSize = (transferSize == 0) ? self.peripheral?.maximumWriteValueLength(for: .withoutResponse) : transferSize
        
        // Create Payload Struct
        switch(characteristic)
        {
        case .UserRX:
            let payload = PayloadInfo(msg: Array<UInt8>(msgData as Data),maxTransferSize: packetSize ?? 244 ,rate: msSendRate,async: async, writeCharacteristic: self.brainRXUserChar )
            DataQ.append(payload)
            break
            
        case .AdminRX:
            let payload = PayloadInfo(msg: Array<UInt8>(msgData as Data),maxTransferSize: packetSize ?? 244 ,rate: msSendRate,async: async, writeCharacteristic:  self.brainRXAdminChar)
            DataQ.append(payload)
            break
            
        case .DataCode:
            let payload = PayloadInfo(msg: Array<UInt8>(msgData as Data),maxTransferSize: packetSize ?? 244 ,rate: msSendRate,async: async, writeCharacteristic: self.dataCodeChar)
            DataQ.append(payload)
            break
        }
        
        if(self.currentDataPayload == nil)
        {
            
            self.currentDataPayload = self.DataQ.remove(at: 0)
            
            
            dataTimer = Timer.scheduledTimer(withTimeInterval: Double((currentDataPayload?.Rate ?? Int(10.0)))/1000.0, repeats: true)
            { timer in
                
                if(self.currentDataPayload == nil && self.DataQ.count == 0)
                {
                    
                }
                else if(self.currentDataPayload == nil && self.DataQ.count > 0)
                {
                    self.dataTimer?.invalidate()
                }
                else{
                    self.elapsedTime = Int64(Date().timeIntervalSince1970 * 1000) - self.startTime
                    self.WritePacket(ploadInfo: &self.currentDataPayload)
                }
                
            }
        }
    }
    
    
    
    public func SendLockCode(code1: UInt8, code2: UInt8, code3: UInt8, code4: UInt8)
    {
        print("Sending Bot Config:")
        
        let data = NSData(bytes: [code1, code2, code3, code4], length: 4)
        if(dataCodeChar != nil)
        {
            peripheral!.writeValue(data as Data, for: self.dataCodeChar!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    public func Disconnect()
    {
        if let _ = self.peripheral {
            //scanAfterDisconnecting = false
            disconnect()
        } else {
            //  startScanning()
        }
    }
    
    public func IsConnected() -> Bool
    {
        return (self.peripheral != nil)
    }
    
    public func GetMTUSize() -> Int
    {
        return self.peripheral?.maximumWriteValueLength(for: .withoutResponse) ?? 0
    }
    
    public func GetDevices() -> Dictionary<CBPeripheral, vexDevice>
    {
        return self.vexDevices
    }
    
    public func ReadLockCode() -> Bool
    {
        if(dataCodeChar != nil)
        {
            self.peripheral?.readValue(for: self.dataCodeChar!)
            return true;
        }
        return false;
    }
    
    private func setState(newState: vexConnectionState)
    {
        if(self.ConnectionState != newState)
        {
            self.ConnectionState = newState
            self.delegate?.VEXBLEDevMgr(deviceMgr: self, didUpdate: self.ConnectionState)
        }
    }
    
    private func setDataState(newState: VEX_DataConnectionState)
    {
        var nextState = newState
        
        if(self.isAdminDataConnected() && self.isUserDataConnected() && self.dataCodeChar != nil){
            nextState = VEX_DataConnectionState.BothConnected
        }
        else if(self.isAdminDataConnected() && self.dataCodeChar != nil){
            nextState = VEX_DataConnectionState.AdminConnected
        }
        else if(self.isUserDataConnected()) {
            nextState = VEX_DataConnectionState.UserConnected
        }
        
        if(self.DataConnectionState != nextState)
        {
            self.DataConnectionState = nextState
            self.delegate?.VEXBLEDevMgr(deviceMgr: self, didUpdateDataConnected: self.DataConnectionState)
        }
    }
    
    private func setJSState(newState: VEX_JSConnectionState)
    {
        if(self.JSConnectionState != newState)
        {
            self.JSConnectionState = newState
            self.delegate?.VEXBLEDevMgr(deviceMgr: self, didUpdateJSConnected: self.JSConnectionState)
        }
    }
    
    
    
    /*
     Call this when things either go wrong, or you're done with the connection.
     This cancels any subscriptions if there are any, or straight disconnects if not.
     (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
     */
    internal func disconnect() {
        if contKeepAliveTimer != nil
        {
            contKeepAliveTimer.invalidate();
            contKeepAliveTimer = nil;
        }
        
        self.ConnectedDevice = vexDevice(Name: "", ProductType: vexProductTypes.Unknown, BrainVersionMajor: 0, BrainVersionMinor: 0, BrainVersionBuild: 0, BrainVersionBeta: 0, RadioVersionMajor:0,RadioVersionMinor:0, RadioVersionBuild:0,RadioVersionBeta:0, DeviceID: [0,0,0,0], DeviceMode: vexDeviceMode.Unknown)
        
        self.dataCodeChar = nil
        self.brainRXAdminChar = nil
        self.brainTXAdminChar = nil
        self.brainRXUserChar = nil
        self.brainTXUserChar = nil
        
        self.JSDataChar = nil
        self.JSRateChar = nil
        self.JSData2Char = nil
        
        // verify we have a peripheral
        guard let peripheral = self.peripheral else {
            print("Peripheral object has not been created yet.")
            return
        }
        
        // check to see if the peripheral is connected
        if peripheral.state != .connected {
            print("Peripheral exists but is not connected.")
            self.peripheral = nil
            return
        }
        
        // We have a connection to the device but we are not subscribed to the Transfer Characteristic for some reason.
        // Therefore, we will just disconnect from the peripheral
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    internal func stopScanning() {
        centralManager.stopScan()
    }
    
    internal func startScanning() {
        if centralManager.isScanning {
            print("Central Manager is already scanning!!")
            //return;
            
            //Resetart scanning work around:
            centralManager.stopScan();
        }
        self.vexDevices.removeAll()
        
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        self.setState(newState: vexConnectionState.Scanning)
        print("Scanning Started!")
    }
    
    
    /// Send Controller updates
    @objc func controllerUpdate()
    {
        if(self.JSRateChar != nil)
        {
            let data = Data([UInt8(0), UInt8(0)])
            peripheral!.writeValue(data as Data, for: self.JSRateChar!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    
    /*
     Invoked when the central manager’s state is updated.
     This is where we kick off the scanning if Bluetooth is turned on and is active.
     */
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central Manager State Updated: \(central.state.rawValue) == \(CBManagerState.unsupported.rawValue)")
        
        // We showed more detailed handling of this in Zero-to-BLE Part 2, so please refer to that if you would like more information.
        // We will just handle it the easy way here: if Bluetooth is on, proceed...
        if central.state != .poweredOn {
            self.peripheral = nil
            self.setState(newState: vexConnectionState.Off)
            return
        }
        
        
        
        ble_On = true;
        
        if(started)
        {
            startScanning()
        }
        
    }
    
    
    
    // State Preservation and Restoration
    // This is the FIRST delegate method that will be called when being relaunched -- not centralManagerDidUpdateState
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
        //---------------------------------------------------------------------------
        // We don't need these, but it's good to know that they exist.
        //---------------------------------------------------------------------------
        // Retrive array of service UUIDs (represented by CBUUID objects) that
        // contains all the services the central manager was scanning for at the time
        // the app was terminated by the system.
        //
        //let scanServices = dict[CBCentralManagerRestoredStateScanServicesKey]
        
        // Retrieve dictionary containing all of the peripheral scan options that
        // were being used by the central manager at the time the app was terminated
        // by the system.
        //
        //let scanOptions = dict[CBCentralManagerRestoredStateScanOptionsKey]
        //---------------------------------------------------------------------------
        
        /*
         Retrieve array of CBPeripheral objects containing all of the peripherals that were connected to the central manager
         (or that had a connection pending) at the time the app was terminated by the system.
         
         When possible, all the information about a peripheral is restored, including any discovered services, characteristics,
         characteristic descriptors, and characteristic notification states.
         */
        
        if let peripheralsObject = dict[CBCentralManagerRestoredStatePeripheralsKey] {
            let peripherals = peripheralsObject as! Array<CBPeripheral>
            if peripherals.count > 0 {
                // Just grab the first one in this case. If we had maintained an array of
                // multiple peripherals then we would just add them to our array and set the delegate...
                peripheral = peripherals[0]
                peripheral?.delegate = self
            }
        }
    }
    
    /*
     Invoked when the central manager discovers a peripheral while scanning.
     
     The advertisement data can be accessed through the keys listed in Advertisement Data Retrieval Keys.
     You must retain a local copy of the peripheral if any command is to be performed on it.
     In use cases where it makes sense for your app to automatically connect to a peripheral that is
     located within a certain range, you can use RSSI data to determine the proximity of a discovered
     peripheral device.
     
     central - The central manager providing the update.
     peripheral - The discovered peripheral.
     advertisementData - A dictionary containing any advertisement data.
     RSSI - The current received signal strength indicator (RSSI) of the peripheral, in decibels.
     
     */
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        if(vexDeviceName == "" || peripheral.name != nil && (peripheral.name?.contains(vexDeviceName))!)
        {
            //print("Discovered \(String(describing: peripheral.name)) at \(RSSI) \(peripheral)  \(peripheral.hashValue)")
            //rssiLabel.text = RSSI.stringValue
            
            //peripheral.identifier
            //print("AdvData: \(advertisementData[CBAdvertisementDataManufacturerDataKey])")
            
            if(advertisementData[CBAdvertisementDataManufacturerDataKey] != nil)
            {
                
                if var vexDev = parseAdvData(advData: advertisementData[CBAdvertisementDataManufacturerDataKey] as! NSData)
                    
                {
                    //print("Man Data Len: \((advertisementData[CBAdvertisementDataManufacturerDataKey] as! NSData).length)")
                    //                    vexDev.Name = peripheral.name?.trimmingCharacters(in: CharacterSet.init(charactersIn: " "))
                    //
                    
                    vexDev.LastRSSI = RSSI.int8Value
                    
                    if let name = advertisementData[CBAdvertisementDataLocalNameKey] {
                        print("ADV NAME  = \(name)")
                        vexDev.Name = "\(name) "
                        vexDev.Name = vexDev.Name!.trimmingCharacters(in: CharacterSet.init(charactersIn: " "))
                    }
                    else
                    {
                        print("DEVICE NAME  = \(peripheral.name ?? " ")")
                        vexDev.Name = peripheral.name?.trimmingCharacters(in: CharacterSet.init(charactersIn: " "))
                    }
                    
                    if(vexDev.Name == "")
                    {
                        //If for some reason the name is all spaces we need
                        vexDev.Name = "***"
                    }
                    
                    //print("Lib: Found VEX Device: \(vexDev)")
                    //rssiLabel.textColor = UIColor.green
                    
                    //We have an issue with the older firmware where the scan data has the device mode in it.
                    //The scan data comes in later than the advert data so we get an updated advert data section
                    //first and then later get scan data. Becuase of this the app will think that the device is found and
                    //in the wrong mode so we have to wait until the second event before we send the info to the app.
                    //So what we do is delay the app event long enough to know that we got the scan response then we will
                    //be good to go.
                    self.vexDevices[peripheral] = vexDev
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        self.sendFoundDevice(peripheral: peripheral)
                    })
                    
                }
            }
            
            
        }
        
        
    }
    
    
    /*
     Invoked when a connection is successfully created with a peripheral.
     
     This method is invoked when a call to connectPeripheral:options: is successful.
     You typically implement this method to set the peripheral’s delegate and to discover its services.
     */
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected!!!")
        
        //connectionIndicatorView.layer.backgroundColor = UIColor.green.cgColor
        
        // Stop scanning
        //        centralManager.stopScan()
        //        print("Scanning Stopped!")
        
        // Clear any cached data...
        dataBuffer.length = 0
        
        self.peripheral = peripheral
        
        // IMPORTANT: Set the delegate property, otherwise we won't receive the discovery callbacks, like peripheral(_:didDiscoverServices)
        self.peripheral?.delegate = self
        
        // Now that we've successfully connected to the peripheral, let's discover the services.
        // This time, we will search for the transfer service UUID
        //print("Looking for Transfer Service...")
        //peripheral.discoverServices([CBUUID.init(string: Device.TransferService)])
        peripheral.discoverServices(nil)
        
        self.setState(newState: vexConnectionState.Connected)
    }
    
    
    /*
     Invoked when the central manager fails to create a connection with a peripheral.
     
     This method is invoked when a connection initiated via the connectPeripheral:options: method fails to complete.
     Because connection attempts do not time out, a failed connection usually indicates a transient issue,
     in which case you may attempt to connect to the peripheral again.
     */
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral) (\(error?.localizedDescription ?? "Unknown"))")
        //connectionIndicatorView.layer.backgroundColor = UIColor.red.cgColor
        self.disconnect()
        
        //LKP need to call delegate and tell them we failed to connect
        self.setState(newState: vexConnectionState.Off)
    }
    
    
    /*
     Invoked when an existing connection with a peripheral is torn down.
     
     This method is invoked when a peripheral connected via the connectPeripheral:options: method is disconnected.
     If the disconnection was not initiated by cancelPeripheralConnection:, the cause is detailed in error.
     After this method is called, no more methods are invoked on the peripheral device’s CBPeripheralDelegate object.
     
     Note that when a peripheral is disconnected, all of its services, characteristics, and characteristic descriptors are invalidated.
     */
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // set our reference to nil and start scanning again...
        print("Disconnected from Peripheral: \(String(describing: error))")
        //connectionIndicatorView.layer.backgroundColor = UIColor.red.cgColor
        self.peripheral = nil
        if contKeepAliveTimer != nil
        {
            contKeepAliveTimer.invalidate();
            contKeepAliveTimer = nil;
        }
        
        
        self.dataCodeChar = nil
        self.brainRXAdminChar = nil
        self.brainTXAdminChar = nil
        self.brainRXUserChar = nil
        self.brainTXUserChar = nil
        
        self.JSDataChar = nil
        self.JSRateChar = nil
        self.JSData2Char = nil
        
        setDataState(newState: VEX_DataConnectionState.Off)
        
        self.ConnectedDevice = vexDevice(Name: "", ProductType: vexProductTypes.Unknown, BrainVersionMajor: 0, BrainVersionMinor: 0, BrainVersionBuild: 0, BrainVersionBeta: 0, RadioVersionMajor:0,RadioVersionMinor:0, RadioVersionBuild:0,RadioVersionBeta:0, DeviceID: [0,0,0,0], DeviceMode: vexDeviceMode.Unknown)
        
        if scanAfterDisconnecting {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.startScanning()
            })
            self.setState(newState: vexConnectionState.Scanning)
        }
        else{
            self.setState(newState: vexConnectionState.Off)
        }
    }
    
    //MARK: - CBPeripheralDelegate methods
    
    /*
     Invoked when you discover the peripheral’s available services.
     
     This method is invoked when your app calls the discoverServices: method.
     If the services of the peripheral are successfully discovered, you can access them
     through the peripheral’s services property.
     
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure.
     */
    // When the specified services are discovered, the peripheral calls the peripheral:didDiscoverServices: method of its delegate object.
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        print("Discovered Services!!!")
        
        if error != nil {
            print("Error discovering services: \(String(describing: error?.localizedDescription))")
            disconnect()
            return
        }
        
        // Core Bluetooth creates an array of CBService objects —- one for each service that is discovered on the peripheral.
        if let services = peripheral.services {
            for service in services {
                print("Discovered service \(service)")
                peripheral.discoverCharacteristics(nil, for: service)
                
            }
        }
    }
    
    /*
     Invoked when you discover the characteristics of a specified service.
     
     If the characteristics of the specified service are successfully discovered, you can access
     them through the service's characteristics property.
     
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure.
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("Error discovering characteristics: \(String(describing: error?.localizedDescription))")
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Found Char: \(characteristic.uuid)")
                // Transfer Characteristic
                //                if (characteristic.uuid == CBUUID(string: Device.ResetCharacteristic) || characteristic.uuid == CBUUID(string: Device.NewResetCharacteristic)) {
                //
                //                }
                if characteristic.uuid == CBUUID(string: Device.TXBrainAdminChar) {
                    // subscribe to dynamic changes
                    self.brainTXAdminChar = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                    if(self.dataCodeChar != nil){
                        setDataState(newState: VEX_DataConnectionState.AdminConnected)
                    }
                }
                else if characteristic.uuid == CBUUID(string: Device.TXBrainUserChar) {
                    // subscribe to dynamic changes
                    self.brainTXUserChar = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                    setDataState(newState: VEX_DataConnectionState.UserConnected)
                }
                else if( characteristic.uuid == CBUUID(string: Device.RXBrainLockChar))
                {
                    print("Found Lock Char")
                    self.dataCodeChar = characteristic
                    if(self.brainTXAdminChar != nil){
                        setDataState(newState: VEX_DataConnectionState.AdminConnected)
                    }
                    //                    self.delegate?.VEXBLEDevMgrCanUpdateControls(deviceMgr: self)
                    //gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(readCode), userInfo: nil, repeats: true)
                }
                else if characteristic.uuid == CBUUID(string: Device.RXBrainAdminChar) {
                    // subscribe to dynamic changes
                    self.brainRXAdminChar = characteristic
                    
                }
                else if characteristic.uuid == CBUUID(string: Device.RXBrainUserChar) {
                    // subscribe to dynamic changes
                    self.brainRXUserChar = characteristic
                    
                }
                else if characteristic.uuid == CBUUID(string: Device.JSDataChar) {
                    // subscribe to dynamic changes
                    self.JSDataChar = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                    setJSState(newState: .Connected)
                    
                }
                else if characteristic.uuid == CBUUID(string: Device.JSRateChar) {
                    // subscribe to dynamic changes
                    self.JSRateChar = characteristic
                    
                    contKeepAliveTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(controllerUpdate), userInfo: nil, repeats: true)
                    
                }
                else if characteristic.uuid == CBUUID(string: Device.JSData2Char) {
                    // subscribe to dynamic changes
                    self.JSData2Char = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                    setJSState(newState: .Connected)
                }
                
            }
        }
    }
    
    
    /*
     Invoked when you retrieve a specified characteristic’s value,
     or when the peripheral device notifies your app that the characteristic’s value has changed.
     
     This method is invoked when your app calls the readValueForCharacteristic: method,
     or when the peripheral notifies your app that the value of the characteristic for
     which notifications and indications are enabled has changed.
     
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure.
     */
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("didUpdateValueForCharacteristic: \(Date())")
        
        // if there was an error then print it and bail out
        if error != nil {
            print("Error updating value for characteristic: \(characteristic) - \(String(describing: error?.localizedDescription))")
            return
        }
        
        // make sure we have a characteristic value
        guard let value = characteristic.value else {
            print("Characteristic Value is nil on this go-round")
            return
        }
        
        //print("Bytes transferred: \(value.count)")
        //dump(value)
        
        
        if characteristic.uuid == CBUUID(string: Device.RXBrainLockChar)
        {
            self.delegate?.VEXBLEDevMgr(deviceMgr: self, didReadlock: value)
        }
        else if characteristic.uuid == CBUUID(string: Device.TXBrainAdminChar)
        {
            //            if(BLE_TEST.READ_TEST(msg: value))
            //            {
            self.elapsedTime = Int64(Date().timeIntervalSince1970 * 1000) - self.startTime
            //                VEX_LogManager.OSLogMsg(level: OSLogType.debug, catagory: .BLETEST, msg: "Time: \(self.elapsedTime)")
            self.startTime = Int64(Date().timeIntervalSince1970 * 1000)
            self.delegate?.VEXBLEDevMgr(deviceMgr: self, didRXAdmin: value)
            //            }
            
        }
        else if characteristic.uuid == CBUUID(string: Device.TXBrainUserChar)
        {
            self.delegate?.VEXBLEDevMgr(deviceMgr: self, didRXUser: value)
        }
        else if characteristic.uuid == CBUUID(string: Device.JSData2Char)
        {
            self.jsStateData.RightX_Axis = value[0]
            self.jsStateData.RightY_Axis = value[1]
            self.jsStateData.LeftX_Axis = value[2]
            self.jsStateData.LeftY_Axis = value[3]
            self.jsStateData.BatteryVolts = (UInt16(truncatingIfNeeded: value[5]) << 8) + UInt16(truncatingIfNeeded: value[4])
            self.jsStateData.DeviceStateFlags = (UInt16(truncatingIfNeeded: value[7]) << 8) + UInt16(truncatingIfNeeded: value[6])
            self.jsStateData.Buttons = (UInt16(truncatingIfNeeded: value[9]) << 8) + UInt16(truncatingIfNeeded: value[8])
            self.jsStateData.BatteryPercent = value[10]
            self.jsStateData.ContinuityCount = value[11]
            self.jsStateData.ClockTime = (UInt32(truncatingIfNeeded: value[15]) << 24) + (UInt32(truncatingIfNeeded: value[14]) << 16) + (UInt32(truncatingIfNeeded: value[13]) << 8) + UInt32(truncatingIfNeeded: value[12])
            
            //build struct
            self.delegate?.VEXBLEDevMgr(deviceMgr: self, didRXJSData: self.jsStateData)
            
            
        }
        else if characteristic.uuid == CBUUID(string: Device.JSDataChar)
        {
            self.jsStateData.RightX_Axis = value[0]
            self.jsStateData.RightY_Axis = value[1]
            self.jsStateData.LeftX_Axis = value[2]
            self.jsStateData.LeftY_Axis = value[3]
            
            self.jsStateData.Buttons = UInt16(value[4])
            self.jsStateData.BatteryPercent = UInt8((Float(value[5])/255.0)*100.0)
            self.jsStateData.MainPower = value[6]
            self.jsStateData.IdleTime = value[7]
            self.jsStateData.PowerOffDelay = value[8]
            self.jsStateData.ContinuityCount = value[9]
            self.jsStateData.ClockTime = (UInt32(truncatingIfNeeded: value[13]) << 24) + (UInt32(truncatingIfNeeded: value[12]) << 16) + (UInt32(truncatingIfNeeded: value[11]) << 8) + UInt32(truncatingIfNeeded: value[10])
            
            //build struct
            self.delegate?.VEXBLEDevMgr(deviceMgr: self, didRXJSData: self.jsStateData)
        }
        
    }
    
    /*
     Invoked when the peripheral receives a request to start or stop providing notifications
     for a specified characteristic’s value.
     
     This method is invoked when your app calls the setNotifyValue:forCharacteristic: method.
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure.
     */
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // if there was an error then print it and bail out
        if error != nil {
            print("Error changing notification state: \(String(describing: error?.localizedDescription))")
            return
        }
        
        if characteristic.isNotifying {
            // notification started
            print("Notification STARTED on characteristic: \(characteristic)")
        } else {
            // notification stopped
            print("Notification STOPPED on characteristic: \(characteristic)")
            //self.centralManager.cancelPeripheralConnection(peripheral)
        }
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error? )
    {
        // if there was an error then print it and bail out
        if error != nil {
            print("Error updating value for characteristic: \(characteristic) - \(String(describing: error?.localizedDescription))")
            return
        }
        
        
        if characteristic.uuid == CBUUID(string: Device.RXBrainAdminChar)
        {
            print("Just Wrote RXBrain Admin")
            //self.WritePacket(ploadInfo: )
        }
        else if characteristic.uuid == CBUUID(string: Device.RXBrainUserChar)
        {
            print("Just Wrote RXBrain User")
        }
        else if characteristic.uuid == CBUUID(string: Device.RXBrainLockChar)
        {
            print("Just Wrote RXBrain Lock")
        }
        else
        {
            //print("Just Wrote Something")
        }
        
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if error != nil {
            print("Error reading RSSI state: \(String(describing: error?.localizedDescription))")
            return
        }
        
        self.delegate?.VEXBLEDevMgr(deviceMgr: self, didUpdate: RSSI.int8Value)
        //rssiLabel.text = String(RSSI.int32Value);
    }
    
    
    internal func parseAdvData(advData: NSData) -> vexDevice?{
        let bytes = [UInt8](advData as Data)
        //print(bytes)
        //let savedAddr = defaults.object(forKey: "SavedBotID") as? [UInt8] ?? [UInt8]()
        // Check to see if we what to connect to this
        
        var retVal = vexDevice(
            Name: "",
            ProductType: vexProductTypes.Unknown,
            BrainVersionMajor: 0,
            BrainVersionMinor: 0,
            BrainVersionBuild: 0,
            BrainVersionBeta: 0,
            RadioVersionMajor: 0,
            RadioVersionMinor: 0,
            RadioVersionBuild: 0,
            RadioVersionBeta: 0,
            DeviceID: [0,0,0,0],
            DeviceMode: vexDeviceMode.Unknown
        )
        
//        print("MFGData: \(bytes[0]) \(bytes[1]) \(peripheral?.name ?? "NA")")
        
        if(bytes.count < 13)
        {
            return nil;
        }
        
        if(bytes[0] == 0x11 && bytes[1] == 0x11 ||
           bytes[0] == 0x06 && bytes[1] == 0x77 ||
           bytes[0] == 0x77 && bytes[1] == 0x06 /*This should eventually be removed*/
        )
        {
            //This is a Vex product
            // Check divice Type
            retVal.ProductType = vexProductTypes(rawValue: bytes[2]) ?? vexProductTypes.Unknown
            
            switch(retVal.ProductType)
            {
            case .IQ2_Brain, .IQ2_Controller, .EXP_Brain, .EXP_Controller, .IQ1_Controller:
                retVal.RadioVersionMajor = bytes[3]
                retVal.RadioVersionMinor = bytes[4]
                retVal.RadioVersionBuild = bytes[5]
                retVal.RadioVersionBeta = bytes[6]
                
                retVal.DeviceMode = vexDeviceMode(rawValue: bytes[7]) ?? vexDeviceMode.Unknown
                
                retVal.DeviceID = [bytes[8], bytes[9], bytes[10], bytes[11]]
                
                retVal.BattPercent = bytes[12]
                
                retVal.BrainVersionMajor = 0
                retVal.BrainVersionMinor = 0
                retVal.BrainVersionBuild = 0
                retVal.BrainVersionBeta = 0
                break;
            case .V5_Brain:
                retVal.RadioVersionBeta = bytes[3]
                retVal.DeviceID = [bytes[4], bytes[5], bytes[6], bytes[7]]
                
                retVal.BattPercent = 100
                retVal.DeviceMode = .Connect
                
                retVal.BrainVersionMajor = bytes[8] & 0x0C >> 6
                retVal.BrainVersionMinor = bytes[8] & 0x3F
                retVal.BrainVersionBuild = bytes[9] & 0xFF
                retVal.BrainVersionBeta = bytes[10] & 0xFF
                
                retVal.RadioVersionMajor = (bytes[11] << 6) & 0x0C
                retVal.RadioVersionMinor = bytes[11] & 0x3F
                retVal.RadioVersionBuild = bytes[12] & 0xFF
                break;
            case .V5_Controller:
                return nil;
            default:
                break;
            }
            
            
            
            
            //            retVal.RadioVersionMajor = (bytes[11] << 6) & 0x0C
            //            retVal.RadioVersionMinor = bytes[11] & 0x3F
            //            retVal.RadioVersionBuild = bytes[12] & 0xFF
            
            
            //retVal.VersionMajor = bytes[8] & 0x0C
            //retVal.VersionMinor = bytes[9] & 0x3F
            //retVal.VersionBuild = bytes[10]
            
            
            
            return retVal
            
        }
        
        return nil;
    }
    
    
    
    
    
    private func sendFoundDevice(peripheral: CBPeripheral)
    {
        if(self.vexDevices[peripheral] != nil)
        {
            self.delegate?.VEXBLEDevMgr(deviceMgr: self, didDiscover: self.vexDevices[peripheral]!)
        }
    }
    
}


extension VEXBLEDeviceManager: CBPeripheralManagerDelegate
{
    
    public func startController(prodType: vexProductTypes, version: VEXFirmwareVersion, uid: UInt32, mode: vexDeviceMode)
    {
        // Make sure services are setup
        if(self.peripheralMgr.state != .poweredOn){
            return
        }
        
        //Start advertising
        startAdvertising(prodType: prodType, version: version, uid: uid, mode: mode);
        
    }
    
    
    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("Advertise Start:")
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
    }
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unknown:
            print("Bluetooth Device is UNKNOWN")
        case .unsupported:
            print("Bluetooth Device is UNSUPPORTED")
        case .unauthorized:
            print("Bluetooth Device is UNAUTHORIZED")
        case .resetting:
            print("Bluetooth Device is RESETTING")
        case .poweredOff:
            print("Bluetooth Device is POWERED OFF")
        case .poweredOn:
            print("Bluetooth Device is POWERED ON")
            addServices()
        @unknown default:
            fatalError()
        }
    }
    
    func addServices() {
        
        if(self.peripheralMgr == nil)
        {
            
            //Start fresh
            self.peripheralMgr.removeAllServices()
            
            /**** Characteristics for Brain RX ****/
            let brain_rx_characteristicUUID                             = CBUUID(string: Device.RXBrainAdminChar)
            let brain_rx_properties: CBCharacteristicProperties         = [.read, .notify]
            let brain_rx_permissions: CBAttributePermissions            = [.readable]
            let adminBrainRXChar                                     = CBMutableCharacteristic(type: brain_rx_characteristicUUID,
                                                                                                  properties: brain_rx_properties,
                                                                                                  value: nil,
                                                                                                  permissions: brain_rx_permissions)

            /**** Characteristics for Brain TX ****/
            let brain_tx_characteristicUUID                             = CBUUID(string: Device.TXBrainAdminChar)
            let brain_tx_properties: CBCharacteristicProperties         = [.read, .write, .writeWithoutResponse]
            let brain_tx_permissions: CBAttributePermissions            = [.readable, .writeable]
            let adminBrainTXChar                                     = CBMutableCharacteristic(type: brain_tx_characteristicUUID,
                                                                                                  properties: brain_tx_properties,
                                                                                                  value: nil,
                                                                                                  permissions: brain_tx_permissions)

            /**** Characteristics for User RX ****/
            let user_rx_characteristicUUID                              = CBUUID(string: Device.RXBrainUserChar)
            let user_rx_properties: CBCharacteristicProperties          = [.read, .notify]
            let user_rx_permissions: CBAttributePermissions             = [.readable]
            let userBrainRXChar                                      = CBMutableCharacteristic(type: user_rx_characteristicUUID,
                                                                                                  properties: user_rx_properties,
                                                                                                  value: nil,
                                                                                                  permissions: user_rx_permissions)

            /**** Characteristics for User TX ****/
            let user_tx_characteristicUUID                              = CBUUID(string: Device.TXBrainUserChar)
            let user_tx_properties: CBCharacteristicProperties          = [.read, .write, .writeWithoutResponse]
            let user_tx_permissions: CBAttributePermissions             = [.readable, .writeable]
            let userBrainTXChar                                      = CBMutableCharacteristic(type: user_tx_characteristicUUID,
                                                                                                  properties: user_tx_properties,
                                                                                                  value: nil,
                                                                                                  permissions: user_tx_permissions)


            let dataService = CBMutableService(type: CBUUID(string: Device.V5DataService), primary: true)

            self.peripheralMgr.add(dataService)
            
            
            /**** Characteristics for Brain RX ****/
            let jsData2_characteristicUUID                             = CBUUID(string: Device.JSData2Char)
            let jsData2_properties: CBCharacteristicProperties         = [.read, .notify]
            let jsData2_permissions: CBAttributePermissions            = [.readable]
            let jsData2Char                                     = CBMutableCharacteristic(type: jsData2_characteristicUUID,
                                                                                                  properties: jsData2_properties,
                                                                                                  value: nil,
                                                                                                  permissions: jsData2_permissions)

            /**** Characteristics for Brain TX ****/
            let jsRate_characteristicUUID                             = CBUUID(string: Device.JSRateChar)
            let jsRate_properties: CBCharacteristicProperties         = [.read, .write, .writeWithoutResponse]
            let jsRate_permissions: CBAttributePermissions            = [.readable, .writeable]
            let jsRateChar                                     = CBMutableCharacteristic(type: jsRate_characteristicUUID,
                                                                                                  properties: jsRate_properties,
                                                                                                  value: nil,
                                                                                                  permissions: jsRate_permissions)

            /**** Characteristics for User RX ****/
            let jsDevStatus_characteristicUUID                              = CBUUID(string: Device.DeviceStatusChar)
            let jsDevStatus_properties: CBCharacteristicProperties          = [.read, .notify]
            let jsDevStatus_permissions: CBAttributePermissions             = [.readable]
            let jsDevStatusChar                                      = CBMutableCharacteristic(type: jsDevStatus_characteristicUUID,
                                                                                                  properties: jsDevStatus_properties,
                                                                                                  value: nil,
                                                                                                  permissions: jsDevStatus_permissions)

            
            let jsService = CBMutableService(type: CBUUID(string: Device.JSService), primary: true)
            
            self.peripheralMgr.add(jsService)
        }
    }
    
    func startAdvertising(prodType: vexProductTypes, version: VEXFirmwareVersion, uid: UInt32, mode: vexDeviceMode) {

        if(self.peripheralMgr.isAdvertising)
        {
            self.peripheralMgr.stopAdvertising()
        }
        
        // create an array of bytes to send
        var byteArray = [UInt8]()
        byteArray.append(0x77)
        byteArray.append(0x06)                  //VEX MFG ID
        byteArray.append(prodType.rawValue)     //PROD Type
        byteArray.append(version.major)
        byteArray.append(version.minor)
        byteArray.append(version.build)
        byteArray.append(version.beta)
        byteArray.append(mode.rawValue)         //Connection mode
        byteArray.append(contentsOf: CDCUtils.UInt32_2ByteArr(data: uid, endian: true))
        byteArray.append(0x64)                  //Batt Percent

        // convert that array into an NSData object
        let manufacturerData = NSData(bytes: byteArray,length: byteArray.count)

        // build the bundle of data
        let dataToBeAdvertised =
        [
            CBAdvertisementDataLocalNameKey : "VEX_CTRL",
            CBAdvertisementDataManufacturerDataKey : manufacturerData,
        ] as [String : Any]
        
        peripheralMgr.startAdvertising(dataToBeAdvertised)
        print("Started Advertising")
        
    }
        
        
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
//            messageLabel.text = "Data getting Read"
//            readValueLabel.text = value
      
        // Perform your additional operations here
        
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
//            messageLabel.text = "Writing Data"
//
//            if let value = requests.first?.value {
//               writeValueLabel.text = value.hexEncodedString()
//                //Perform here your additional operations on the data you get
//            }
    }
}
