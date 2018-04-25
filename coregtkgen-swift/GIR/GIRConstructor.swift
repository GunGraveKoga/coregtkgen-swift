//
//  GIRConstructor.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 23.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRConstructor : GIRFunctionBase {
    public private(set) var shadowedBy: String? = nil
    public private(set) var shadows: String?  = nil
    
    override public func tryParse(key: String, value: Any) -> Bool {
        switch key {
        case "shadowed-by":
            self.shadowedBy = (value as! String)
        case "shadows":
            self.shadows = (value as! String)
        default:
            return super.tryParse(key: key, value: value)
        }
        
        return true
    }
    
}
