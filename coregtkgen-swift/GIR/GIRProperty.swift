//
//  GIRProperty.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 23.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRProperty : GIRBase {
    public private(set) var name: String? = nil
    public private(set) var transferOwnership: String? = nil
    public private(set) var version: String? = nil
    public private(set) var deprecatedVersion: String? = nil
    public private(set) var doc: GIRDoc? = nil
    public private(set) var docDeprecated: GIRDoc? = nil
    public private(set) var type: GIRType? = nil
    public private(set) var allowNone: Bool = false
    public private(set) var constructOnly: Bool = false
    public private(set) var readable: Bool = false
    public private(set) var deprecated: Bool = false
    public private(set) var construct: String? = nil
    public private(set) var writable: String? = nil
    public private(set) var array: GIRArray? = nil
    
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            switch key {
            case "text":
                continue
            case "name":
                self.name = (value as! String)
            case "transfer-ownership":
                self.transferOwnership = (value as! String)
            case "version":
                self.version = (value as! String)
            case "deprecated-version":
                self.deprecatedVersion = (value as! String)
            case "doc":
                self.doc = GIRDoc(value as! Dictionary<String, Any>)
            case "doc-deprecated":
                self.docDeprecated = GIRDoc(value as! Dictionary<String, Any>)
            case "type":
                self.type = GIRType(value as! Dictionary<String, Any>)
            case "allow-none":
                self.allowNone = (value as! String == "1") ? true : false
            case "construct-only":
                self.constructOnly = (value as! String == "1") ? true : false
            case "readable":
                self.readable = (value as! String == "1") ? true : false
            case "deprecated":
                self.deprecated = (value as! String == "1") ? true : false
            case "construct":
                self.construct = (value as! String)
            case "writable":
                self.writable = (value as! String)
            case "array":
                self.array = GIRArray(value as! Dictionary<String, Any>)
            default:
                self.logUnknownElement(key)
            }
        }
    }
    
}
