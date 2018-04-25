//
//  GIRMember.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 24.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRMember : GIRBase {
    public private(set) var name: String? = nil
    public private(set) var cIdentifier: String? = nil
    public private(set) var theValue: Int32 = 0
    public private(set) var doc: GIRDoc?  = nil
    
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            switch key {
            case "text",
                 "glib:nick":
                continue
            case "name":
                self.name = (value as! String)
            case "c:identifier":
                self.cIdentifier = (value as! String)
            case "value":
                self.theValue = Int32(value as! String)!
            case "doc":
                self.doc = GIRDoc(value as! Dictionary<String, Any>)
            default:
                self.logUnknownElement(key)
            }
        }
    }
}
