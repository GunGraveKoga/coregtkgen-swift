//
//  GIRPrerequisite.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 24.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRPrerequisite : GIRBase {
    public private(set) var name: String? = nil
    
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            switch key {
            case "text":
                continue
            case "name":
                self.name = (value as! String)
            default:
                self.logUnknownElement(key)
            }
        }
    }
}
