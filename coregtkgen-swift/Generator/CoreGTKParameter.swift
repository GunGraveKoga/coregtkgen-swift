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
    public var nullable: Bool
    public var optional: Bool
    
    public var name: String {
        get {
            let _name = CoreGTKUtil.convertUSSToCamelCase(cName)
            
            switch _name {
            case "func":
                return "function"
            case "protocol":
                return "gtkProtocol"
            case "class":
                return "gtkClass"
            default:
                break
            }
            
            return _name
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
                var result = "UnsafeMutablePointer<UnsafeMutablePointer<\(type[..<range!.lowerBound])>?>"
                
                if nullable {
                    result += "?"
                    
                    if optional {
                        result += " = nil"
                    }
                } else {
                    result += "!"
                }
                
                return result
            }
            
            range = type.range(of: "*", options: .caseInsensitive)
            
            if range != nil {
                var result = "UnsafeMutablePointer<\(type[..<range!.lowerBound])>"
                
                if nullable {
                    result += "?"
                    
                    if optional {
                        result += " = nil"
                    }
                } else {
                    result += "!"
                }
                
                return result
            }
            
            if nullable && optional {
                return type + "? = nil"
            }
            
            return type
        }
    }
}
