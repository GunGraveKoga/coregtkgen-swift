//
//  GIRReturnValue.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 23.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRReturnValue : GIRBase {
    public private(set) var transferOwnership: String? = nil
    public private(set) var nullable: Bool = false
    public private(set) var doc: GIRDoc? = nil
    public private(set) var type: GIRType? = nil
    public private(set) var array: GIRArray? = nil
    
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            switch key {
            case "text":
                continue
            case "transfer-ownership":
                self.transferOwnership = (value as! String)
            case "doc":
                self.doc = GIRDoc(value as! Dictionary<String, Any>)
            case "type":
                self.type = GIRType(value as! Dictionary<String, Any>)
            case "array":
                self.array = GIRArray(value as! Dictionary<String, Any>)
            case "nullable":
                self.nullable = (value as! String == "1") ? true : false
            default:
                self.logUnknownElement(key)
            }
        }
    }
    
}
