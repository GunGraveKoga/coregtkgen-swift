//
//  GIRArray.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 23.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRArray : GIRBase {
    public private(set) var cType: String? = nil
    public private(set) var name: String? = nil
    public private(set) var length: Int = 0
    public private(set) var fixedSize: Int = 0
    public private(set) var zeroTerminated: Bool = false
    public private(set) var type: GIRType? = nil
    
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            switch key {
            case "text":
                continue
            case "name":
                self.name = (value as! String)
            case "c:type":
                self.cType = (value as! String)
            case "length":
                self.length = Int(value as! String)!
            case "fixed-size":
                self.fixedSize = Int(value as! String)!
            case "zero-terminated":
                self.zeroTerminated = (value as! String == "1") ? true : false
            case "type":
                self.type = GIRType(value as! Dictionary<String, Any>)
            default:
                self.logUnknownElement(key)
            }
        }
    }
    
}
