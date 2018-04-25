//
//  GIRParameter.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 23.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRParameter : GIRBase {
    public private(set) var name: String? = nil
    public private(set) var transferOwnership: String? = nil
    public private(set) var direction: String?  = nil
    public private(set) var scope: String? = nil
    public private(set) var allowNone: Bool = false
    public private(set) var callerAllocates: Bool = false
    public private(set) var closure: Int = 0
    public private(set) var destroy: Int = 0
    public private(set) var doc: GIRDoc? = nil
    public private(set) var type: GIRType? = nil
    public private(set) var array: GIRArray? = nil
    public private(set) var varArgs: GIRVarArgs? = nil
    
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            switch key {
            case "text":
                continue
            case "name":
                self.name = (value as! String)
            case "transfer-ownership":
                self.transferOwnership = (value as! String)
            case "direction":
                self.direction = (value as! String)
            case "scope":
                self.scope = (value as! String)
            case "allow-none":
                self.allowNone = (value as! String == "1") ? true : false
            case "caller-allocates":
                self.callerAllocates = (value as! String == "1") ? true : false
            case "closure":
                self.closure = Int(value as! String)!
            case "destroy":
                self.destroy = Int(value as! String)!
            case "doc":
                self.doc = GIRDoc(value as! Dictionary<String, Any>)
            case "type":
                self.type = GIRType(value as! Dictionary<String, Any>)
            case "array":
                self.array = GIRArray(value as! Dictionary<String, Any>)
            case "varargs":
                self.varArgs = GIRVarArgs(value as! Dictionary<String, Any>)
            default:
                self.logUnknownElement(key)
            }
        }
    }
    
}
