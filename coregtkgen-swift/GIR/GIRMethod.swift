//
//  GIRMethod.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 23.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRMethod : GIRFunctionBase {
    public private(set) var invoker: String? = nil
    public private(set) var shadowedBy: Bool = false
    public private(set) var shadows: Bool = false
    
    override public func tryParse(key: String, value: Any) -> Bool {
        switch key {
        case "shadowed-by":
            self.shadowedBy = (value as! String == "1") ? true : false
        case "shadows":
            self.shadows = (value as! String == "1") ? true : false
        case "invoker":
            self.invoker = (value as! String)
        default:
            return super.tryParse(key: key, value: value)
        }
        
        return true
    }
    
}
