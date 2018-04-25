//
//  GIRImplements.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 23.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRImplements : GIRBase {
    public private(set) var name: String? = nil
    
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            switch key {
            case "text",
                "type":
                continue
            case "name":
                self.name = (value as! String)
            default:
                self.logUnknownElement(key)
            }
        }
    }
    
}
