//
//  GIRConstant.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 24.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRConstant : GIRBase {
    public private(set) var name: String?  = nil
    public private(set) var cType: String? = nil
    public private(set) var theValue: String? = nil
    public private(set) var vaersion: String? = nil
    public private(set) var deprecatedVersion: String? = nil
    public private(set) var deprecated: Bool = false
    public private(set) var doc: GIRDoc? = nil
    public private(set) var docDeprecated: GIRDoc? = nil
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
            case "value":
                self.theValue = (value as! String)
            case "version":
                self.vaersion = (value as! String)
            case "deprecated-version":
                self.deprecatedVersion = (value as! String)
            case "deprecated":
                self.deprecated = (value as! String == "1") ? true : false
            case "doc":
                self.doc = GIRDoc(value as! Dictionary<String, Any>)
            case "doc-deprecated":
                self.docDeprecated = GIRDoc(value as! Dictionary<String, Any>)
            case "type":
                self.type = GIRType(value as! Dictionary<String, Any>)
            default:
                self.logUnknownElement(key)
            }
        }
    }
    
}
