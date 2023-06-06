//
//  TestViewController.swift
//  123BLE_TestUni
//
//  Created by Levi Pope on 4/17/20.
//  Copyright © 2020 VEX. All rights reserved.
//

import Foundation
import UIKit
//import VEX123_BLEuni

extension StringProtocol {
    var hexa: [UInt8] {
        var startIndex = self.startIndex
        return stride(from: 0, to: count, by: 2).compactMap { _ in
            let endIndex = index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}


@available(iOS 13.4, *)
class TestViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate   {
    //private var myDevice:VEXBLEDeviceManager = VEXBLEDeviceManager()
    
    @IBOutlet weak var tblDeviceList: UITableView!
    @IBOutlet weak var lblRSSI: UILabel!
    @IBOutlet weak var lblConnected: UILabel!

    
    @IBOutlet weak var txtRobotName: UITextField!

    @IBOutlet weak var lblLockedStatus: UILabel!
    @IBOutlet weak var SendCodeTB: UITextField!
    
    var sentLockCodeArr:Array<UInt8>?

    @IBOutlet weak var swPairMode: UISwitch!
    @IBOutlet weak var txtCntUUID: UITextField!
    @IBOutlet weak var selProductType: UISegmentedControl!
    
    private var statusCount = 0
    private var lastMaxAccX = 0;
    private var replIndex = 0;
    
    var portPWMs:Array<Int> = Array<Int>()
    var portPositionss:Array<Int> = Array<Int>()
    var portVelocitys:Array<Int> = Array<Int>()
    var portPosErrors:Array<Int> = Array<Int>()
    
    var lastPWM:Array<Int> = [0,0,0,0]
    var lastPWMTime:Array<Int> = [0,0,0,0]
    
    var lastPosError:Array<Int> = [0,0,0,0]
    var lastPosErrorTime:Array<Int> = [0,0,0,0]
    
    var lastPos:Array<Int> = [0,0,0,0]
    var lastPosTime:Array<Int> = [0,0,0,0]
    
    var updateDeviceID:UInt32 = 0;
    var updateUseBeta:Bool = false;
    var updateUseDevel:Bool = false;
    
    var updateFirmwareString:String = ""
    
//    var lastProgramStatus:vexProgramStatus? = nil
//
//    var lastPortCmdStatus:vexBotCommandStatus? = nil
    
    //Declared at top of view controller
    var accessoryDoneButton: UIBarButtonItem!
    let accessoryToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
    
    let codeInput = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    
    let lblSingleCmdText = UILabel(frame: .zero)
    
    var listUpdateTimer = Timer()
    
    var loopCommands:Array<UInt32> = Array<UInt32>()
    var loopCommandIndex = 0
    var loopCommandGotAck = false
    
    var rebootTestDevID:UInt32 = 0
    var rebootTestCount = 0
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        //myDevice.delegate = self
        VEXDeviceManager.Device.delegate = self
        tblDeviceList.delegate = self
        tblDeviceList.dataSource = self

        swPairMode.setOn(false, animated: false)

        if(VEXDeviceManager.Device.Start(deviceName: "", adminConnection: true, userConnection: true))
        {
            print("Starting")
        }

        self.lblConnected.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        self.lblConnected.text = "Not Connected"

        self.lblRSSI.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        self.lblRSSI.text = String(0)

    //    self.txtREPL.delegate = self;
    //    self.txtREPL.vex_delegate = self;
        
    }
    
    //new function
    @objc func timerAction(){
        print("timer Fired")
        //DispatchQueue.main.async { self.tblDeviceList.reloadData() }
    }
    
    
    @IBAction func cmdConControllerOnClick(_ sender: Any) {
        
        var prodType = vexProductTypes.IQ2_Controller
        
        if(self.selProductType.selectedSegmentIndex == 1)
        {
            prodType = .EXP_Controller
        }
        
        let fwVer = VEXFirmwareVersion(major: 1, minor: 0, build: 0, beta: 26)
        
        let devMode = (self.swPairMode.isOn) ? vexDeviceMode.Pair : vexDeviceMode.Connect
        
        let uid = UInt32(self.txtCntUUID.text!, radix: 16) ?? 0
        
        VEXDeviceManager.Device.startAdvertising(prodType: prodType, version: fwVer, uid: uid, mode: devMode)
    }
    
    

    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

            textField.resignFirstResponder()
            
        
        return true
    }
    

    @IBAction func cmdReadLockOnClick(_ sender: Any) {
        if(VEXDeviceManager.Device.isAdminDataConnected())
        {
            VEXDeviceManager.Device.ReadLockCode()
        }
    }
    
    
    @IBAction func cmdWriteLockOnClick(_ sender: Any) {
        if(VEXDeviceManager.Device.isAdminDataConnected())
        {
            if(SendCodeTB.text!.count == 4)
            {
                var byteArr:Array<UInt8> = []
                
                for character in SendCodeTB.text!
                {
                    print(character)
                    print("\(character)".hexa[0])
                    byteArr.append("\(character)".hexa[0])
                }
                print(byteArr)

                VEXDeviceManager.Device.SendLockCode(code1: byteArr[0], code2: byteArr[1],code3: byteArr[2]  , code4: byteArr[3] )
                sentLockCodeArr = byteArr
            }
            if(SendCodeTB.text!.count == 8)
            {
                let byteArray = SendCodeTB.text!.hexa
                sentLockCodeArr = byteArray
                VEXDeviceManager.Device.SendLockCode(code1: byteArray[0], code2: byteArray[1], code3: byteArray[2], code4: byteArray[3])
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `2.0` to the desired number of seconds.
                VEXDeviceManager.Device.ReadLockCode()
            }
            
        }
    }
    
}



@available(iOS 13.4, *)
extension TestViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        let parts = cell?.textLabel?.text?.split(separator: ":")
        
        if(parts!.count > 2)
        {
            let ID = UInt32(parts![1], radix: 16)
//            if(VEXDeviceManager.Device.IsBroadcasting())
//            {
//                VEXDeviceManager.Device.StopBroadcasting()
//            }
//            else
//            {
//                VEXDeviceManager.Device.BroadcastLocate(deviceIDVal: ID!, duration: 500)
//            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(VEXDeviceManager.Device.IsConnected())
        {
            VEXDeviceManager.Device.Disconnect()
            self.tblDeviceList.deselectRow(at: indexPath, animated: true)
            self.txtRobotName.text = ""
        }
        else
        {
            
            //Get the ID from the text of this row
            let cell = tableView.cellForRow(at: indexPath)
            
            let parts = cell?.textLabel?.text?.split(separator: ":")
            
            if(parts!.count > 2)
            {
                let ID = UInt32(parts![1], radix: 16)
                
                for device in VEXDeviceManager.Device.GetDevices()
                {
                    if(device.value.DeviceIDValue == ID)
                    {
                        VEXDeviceManager.Device.Connect(device: device.value)
                        self.txtRobotName.text = device.value.Name
                    }
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VEXDeviceManager.Device.GetDevices().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblDeviceList.dequeueReusableCell(withIdentifier: "myCell")!
        
        if(indexPath.row < VEXDeviceManager.Device.GetDevices().count)
        {
            let dev = Array(VEXDeviceManager.Device.GetDevices().values)[indexPath.row]
            cell.textLabel?.text = (dev.Name ?? "NA")
            
            cell.textLabel?.text! += String(format: ":%X",  dev.DeviceIDValue)
            
            cell.textLabel?.text! += String(format: ":%d.%d.%d.%d", dev.BrainVersion.major, dev.BrainVersion.minor, dev.BrainVersion.build, dev.BrainVersion.beta)
            
            if(dev.DeviceMode == .Update)
            {
                cell.textLabel?.text! += ":Bootload"
            }
            else if(dev.DeviceMode == .Pair)
            {
                cell.textLabel?.text! += ":Pair"
            }
            
            cell.textLabel?.text! += ":\(dev.LastRSSI)"

            switch(dev.ProductType)
            {
            case .IQ2_Controller:
                cell.textLabel?.text! += ":IQ_C"
                break
            case .V5_Controller:
                cell.textLabel?.text! += ":V5_C"
                break
            case .EXP_Controller:
                cell.textLabel?.text! += ":EXP_C"
                break
            case .EXP_Brain:
                cell.textLabel?.text! += ":EXP"
                break
            case .IQ1_Controller:
                cell.textLabel?.text! += ":IQ1_C"
                break
            case .IQ2_Brain:
                cell.textLabel?.text! += ":IQ2"
                break
            case .V5_Brain:
                cell.textLabel?.text! += ":V5"
                break
            default:
                cell.textLabel?.text! += ":??"
                break
            }

//            cell.textLabel?.text! += ":\(dev.BatteryPercent)"
//            cell.textLabel?.text! += ":\(dev.ActiveConnections)"
            
            if(dev.DeviceMode == .Pair)
            {
                cell.backgroundColor = UIColor.systemYellow
            }
            else if(dev.DeviceMode == .Identify)
            {
                cell.backgroundColor = UIColor.systemPink
            }
            else if(dev.DeviceMode == .ProdTestFail)
            {
                cell.backgroundColor = UIColor.systemRed
            }
            else if(dev.DeviceMode == .ProdTest)
            {
                cell.backgroundColor = UIColor.systemBlue
            }
            else
            {
                cell.backgroundColor = UIColor.darkGray
            }
        }
        
        return cell
    }
    
    
}

@available(iOS 13.4, *)
extension TestViewController: VEXBLEDeviceManagerDelegate
{
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didUpdate state: vexConnectionState) {
        if( state == .Connected )
          {
              //self.cmdConnect.setTitle("Disconnect", for: .normal)
              self.lblConnected.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
              self.lblConnected.text = "Connected"
          }
            else if(state == .Connecting)
          {
              self.lblConnected.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
              self.lblConnected.text = "connecting"
          }
          else
          {
              //self.cmdConnect.setTitle("Connect", for: .normal)
              self.lblConnected.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
              self.lblConnected.text = "Not Connected"
              
              self.lblRSSI.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
              self.lblRSSI.text = String(0)

          }
    }
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didUpdateDataConnected state: VEX_DataConnectionState) {
        print("Did Update Data State \(state)")
        
        if(state == .AdminConnected || state == .BothConnected){
            if(!deviceMgr.ReadLockCode()){
                print("Failed To Read Lock")
            }
        }
      
    }
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didUpdateJSConnected state: VEX_JSConnectionState) {
        print("Did Update Controller State \(state)")
      
    }
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didReadlock key: Data) {
        print("Read Lock Code \(key)")
        let dataArr = Array<UInt8>(key)
        print("Read: \(dataArr)")
        print("Sent: \(sentLockCodeArr ?? [] )")
        print(VEXDeviceManager.Device.isAdminDataConnected())
        if(dataArr == [0xDE,0xAD,0xFA,0xCE] || dataArr == [0xFF,0xFF,0xFF,0xFF])
        {
            print("incorrect code")
            VEXDeviceManager.Device.SendLockCode(code1: 0xFF, code2: 0xFF, code3: 0xFF, code4: 0xFF)
            lblLockedStatus.text = "Locked"
//            isUnlocked = false
        }
        else if(dataArr == sentLockCodeArr ?? [0x00,0x00,0x00,0x00])
        {
            sentLockCodeArr = [0x00,0x00,0x00,0x00]
            print("correct code")
            lblLockedStatus.text = "Unlocked"
//            isUnlocked = true
        }
        
        SendCodeTB.text = String(key[0], radix: 16) + String(key[1], radix: 16) + String(key[2], radix: 16) + String(key[3], radix: 16)
    }
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didRXAdmin data: Data) {
        
    }
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didTXAdmin data: Data) {
        
    }
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didRXUser data: Data) {
        
    }
    
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didRXJSData data: JS_Data) {
        
        if((data.Buttons & vexEXPButtonValues.Up.rawValue) != 0){
            print("Up Button Pressing")
        }
        else if((data.Buttons & vexEXPButtonValues.Down.rawValue) != 0){
            print("Down Button Pressing")
        }
    }
 
    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didDiscover device: vexDevice) {
        DispatchQueue.main.async { self.tblDeviceList.reloadData() }
    }

    func VEXBLEDevMgr(deviceMgr: VEXBLEDeviceManager, didUpdate rssi: Int8) {
        self.lblRSSI.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        self.lblRSSI.text = String(rssi)
    }

}
