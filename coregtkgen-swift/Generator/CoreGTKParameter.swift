//
//  CoreGTKParameter.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 25.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public struct CoreGTKParameter : Equatable {
    public static func ==(lhs: CoreGTKParameter, rhs: CoreGTKParameter) -> Bool {
        return lhs.cName == rhs.cName && lhs.cType == lhs.cType
    }
    
    
    public var cName: String
    public var cType: String
    
    public var name: String {
        get {
            return CoreGTKUtil.convertUSSToCamelCase(cName)
        }
    }
    
    public var type: String {
        get {
            return CoreGTKUtil.swapTypes(cType)
        }
    }
}
