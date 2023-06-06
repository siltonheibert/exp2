//
//  CDCUtilitys.swift
//  VEXRobotLink
//
//  Created by Levi Pope on 3/11/20.
//  Copyright © 2020 VEX. All rights reserved.
//

import Foundation



internal class CDCUtils: NSObject
{

    /*
     * ----------------------------------------------------------------------
     * Most of the below is debug related for decoding replies into human readable
     * information.
     */
    
    /**
     * Utility function to create a hex string from the given number
     * @param  (number} value the number to be formatted into a string with %02X format
     * @return {string}
     */
    public static func hex2( value:UInt8 ) -> String {
        let str = (String(format:"%02X",value))
        return(str)
    }
    
    
    public static func hex2(arr:Array<UInt8>) -> String
    {
        var tempStr:String = ""
        for byte in arr
        {
            tempStr += (String(format:"%02X ",byte))
        }
        
        return tempStr
    }
    
    public static func hex8(value:UInt32) -> String {
        let str = (String(format:"%08X",value))
        return(str)
    }
    
    /**
     * Utility function to create a decimal string from the given number
     * @param  (number} value the number to be formatted into a string with %02d format
     * @return {string}
     */
    public static func dec2( value: UInt8 ) -> String {
        let str = String(value)
        return(str)
    }
    
    public static func byteToUInt32(bytes:Array<UInt8>) -> UInt32
    {
        var value:UInt32 = 0
        var count = 0
        for byte in bytes {
            let newValue = UInt32(byte) << (8 * count)
            value = value + UInt32(newValue)
             count += 1
        }
        
        return value
    }
    
    
    public static func UInt32_2ByteArr(data:UInt32, endian:Bool) -> Array<UInt8>
    {
        //print(String(format:"%08X",data))
        var tempData:UInt32 = 0
        if(endian)
        {
            tempData = data.littleEndian
        }
        else
        {
            tempData = data.bigEndian
        }
        
        let byte0:UInt8 = UInt8(tempData & 0x000000FF)
        let byte1:UInt8 = UInt8((tempData & 0x0000FF00) >> 8  )
        let byte2:UInt8 = UInt8((tempData & 0x00FF0000) >> 16 )
        let byte3:UInt8 = UInt8((tempData & 0xFF000000) >> 24 )
        //print(self.hex2(arr: Array<UInt8>([byte0,byte1,byte2,byte3])))
        return (Array<UInt8>([byte0,byte1,byte2,byte3]))
        
        
    }
    
    // Pass in
    // UInt16 Data
    // endian true for little endian
    // retuen byte array
    public static func UInt16_2ByteArr(data:UInt16, endian:Bool) -> Array<UInt8>
    {
        //print(String(format:"%04X",data))
        var tempData:UInt16 = 0
        if(endian)
        {
            tempData = data.littleEndian
        }
        else
        {
            tempData = data.bigEndian
        }
        
        let byte0:UInt8 = UInt8(tempData & 0x000000FF)
        let byte1:UInt8 = UInt8((tempData & 0x0000FF00) >> 8  )
        
        //print(self.hex2(arr: Array<UInt8>([byte0,byte1])))
        return (Array<UInt8>([byte0,byte1]))
    }
    
    public static func byteToUInt16(bytes:Array<UInt8>) -> UInt16
    {
        var value:UInt16 = UInt16(bytes[0])
        value = value + UInt16(bytes[1]<<8)
        
        return value
    }
    
}
