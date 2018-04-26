//
//  CoreGTKParameter.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 25.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public struct CoreGTKParameter {
    public var cName: String
    public var cType: String
    
    public var name: String {
        get {
            return CoreGTKUtil.convertUSSToCamelCase(cName)
        }
    }
    
    public var type: String {
        get {
            var type = CoreGTKUtil.swapTypes(cType)
            
            var range = type.range(of: "const")
            
            if range != nil {
                type = String(type[range!.upperBound...]).trimmingCharacters(in: CharacterSet.whitespaces)
            }
            
            range = type.range(of: "**", options: .caseInsensitive)
            
            if range != nil {
                return "UnsafeMutablePointer<UnsafePointer<\(type[..<range!.lowerBound])>?>!"
            }
            
            range = type.range(of: "*", options: .caseInsensitive)
            
            if range != nil {
                return "UnsafePointer<\(type[..<range!.lowerBound])>!"
            }
            
            return type
        }
    }
}
