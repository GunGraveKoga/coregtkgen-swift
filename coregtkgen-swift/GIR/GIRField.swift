//
//  GIRField.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 23.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRField : GIRBase {
    public private(set) var name: String? = nil
    public private(set) var isPrivate: Bool = false
    public private(set) var readable: Bool = false
    public private(set) var bits: Int = 0
    public private(set) var type: GIRType? = nil
    public private(set) var array: GIRArray? = nil
    
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            switch key {
            case "text":
                continue
            case "name":
                self.name = (value as! String)
            case "private":
                self.isPrivate = (value as! String == "1") ? true : false
            case "readable":
                self.readable = (value as! String == "1") ? true : false
            case "bits":
                self.bits = Int(value as! String)!
            case "type":
                self.type = GIRType(value as! Dictionary<String, Any>)
            case "array":
                self.array = GIRArray(value as! Dictionary<String, Any>)
            default:
                self.logUnknownElement(key)
            }
        }
    }
}
