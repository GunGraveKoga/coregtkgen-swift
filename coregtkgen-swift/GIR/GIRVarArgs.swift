//
//  GIRVarArgs.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 24.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRVarArgs : GIRBase {
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, _) in dictionary {
            switch key {
            case "text",
                 "type":
                continue
            default:
                self.logUnknownElement(key)
            }
        }
    }
    
}
