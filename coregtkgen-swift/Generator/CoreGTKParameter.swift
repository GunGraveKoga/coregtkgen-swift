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
                
                if type.hasSuffix("*") {
                    type = CoreGTKUtil.swapTypes(type)
                }
            }
            
            range = type.range(of: "**", options: .caseInsensitive)
            
            if range != nil {
                var result = "Unsafe"
                
                let isGtkType = cType.hasPrefix("Gtk") || cType.hasPrefix("Gdk") || cType.hasPrefix("Atk") || cType.hasPrefix("G")
                
                if isGtkType {
                    result += "Mutable"
                }
                
                result += "Pointer<Unsafe"
                
                if isGtkType {
                    result += "Mutable"
                }
                
                result += "Pointer<\(type[..<range!.lowerBound])>?>"
                
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
                let isGtkType = cType.hasPrefix("Gtk") || cType.hasPrefix("Gdk") || cType.hasPrefix("Atk") || cType.hasPrefix("G")
                
                var result = "Unsafe"
                
                if isGtkType {
                    result += "Mutable"
                }
                
                result += "Pointer<\(type[..<range!.lowerBound])>"
                
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
            } else if type == "OpaquePointer" {
                if nullable {
                    return type + "?"
                }
                
                return type + "!"
            }
            
            let _name = self.name
            let isFunction = _name.range(of: "func", options: .caseInsensitive) != nil
            let isNotify = _name.range(of: "notify", options: .caseInsensitive) != nil
            let isCallback = _name.range(of: "callback", options: .caseInsensitive) != nil
            let isDestroyCallback = _name.range(of: "destroy", options: .caseInsensitive) != nil
            
            if isFunction || isNotify || isCallback || isDestroyCallback ||
                _name == "detacher" || _name == "updateHeader" {
                return "@escaping " + type
            }
            
            return type
        }
    }
}
