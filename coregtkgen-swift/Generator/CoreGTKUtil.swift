//
//  CoreGTKUtil.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 25.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

fileprivate let configURL = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
fileprivate var trimMethodNames = [String]()
fileprivate var dictConvertType = [String: Any]()
fileprivate var dictGlobalConf = [String: Any]()
fileprivate var dictSwapTypes = [String: Any]()
fileprivate var dictExtraImports = [String: Any]()
fileprivate var dictExtraMethods = [String: Any]()



public enum CoreGTKUtil {
    fileprivate static func _dictionaryFromFile(_ file: String) -> [String: Any] {
        let url = configURL.appendingPathComponent(file, isDirectory: false)
        let data = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        
        return (json as! Dictionary)
    }
    
    public static func convertUSSToCamelCase(_ string: String) -> String {
        let output = self.convertUSSToCapCase(string)
        
        var result: String
        
        if output.count > 1 {
            let index = output.index(after: output.startIndex)
            result = output[..<index].lowercased() + output[index...]
        } else {
            result = output.lowercased()
        }
        
        return result
    }
    
    public static func convertUSSToCapCase(_ string: String) -> String {
        var output = ""
        var previousItemWasSingleChar = false
        
        for component in string.split(separator: "_") {
            if component.count > 1 {
                if previousItemWasSingleChar {
                    output += component
                } else {
                    let index = component.index(after: component.startIndex)
                    output += component[..<index].uppercased()
                    output += component[index...]
                }
                
            } else {
                output += component.uppercased()
                previousItemWasSingleChar = true
            }
        }
        
        return output
    }
    
    public static func isTypeSwappable(_ type: String) -> Bool {
        return type == "Array" || self.swapTypes(type) != type
    }
    
    public static func swapTypes(_ type: String) -> String {
        if dictSwapTypes.count == 0 {
            dictSwapTypes.merge(self._dictionaryFromFile("swap_types.map"), uniquingKeysWith: {(_, last) in last})
        }
        
        let val = dictSwapTypes[type]
        
        return (val != nil) ? (val as! String) : type
    }
    
    public static func getFunctionCallForConstructor(of type: String, with constructor: String) -> String {
        return "self.init(withGObject: \(constructor))\n"
    }
    
    public static func convertType(from fromType: String, to toType: String, withName name: String) -> String {
        if dictConvertType.count == 0 {
            dictConvertType.merge(self._dictionaryFromFile("convert_type.map"), uniquingKeysWith: {(_, last) in last})
        }
        
        let outerDict = dictConvertType[fromType]
        
        if outerDict == nil {
            if fromType.hasPrefix("Gtk") && toType.hasPrefix("CGTK") {
                if toType.hasSuffix("?") || toType.hasSuffix("!") {
                    let index = toType.index(before: toType.endIndex)
                    return "\(toType[..<index])(withGObject: \(name))"
                }
                return "\(toType[..<toType.endIndex])(withGObject: \(name))"
            } else if fromType.hasPrefix("CGTK") && toType.hasPrefix("Gtk") {
                let start = toType.index(toType.startIndex, offsetBy: 3)
                let end = toType.index(toType.endIndex, offsetBy: -1)
                return "\(name).\(toType[start..<end].uppercased())"
            } else {
                return name
            }
        }
        
        let val: String?
        
        if toType.hasSuffix("?") || toType.hasSuffix("!") {
            let index = toType.index(before: toType.endIndex)
            val = (outerDict as! Dictionary<String, Any>)[String(toType[..<index])] as? String
        } else {
            val = (outerDict as! Dictionary<String, Any>)[toType] as? String
        }
        
        if val == nil {
            return name
        } else {
            return String(format: val!, name)
        }
    }
    
    public static func selfTypeMethodCall(_ type: String) -> String {
        if type.hasPrefix("CGTK") {
            let swappedType = self.swapTypes(type)
            let index = swappedType.index(swappedType.startIndex, offsetBy: 3)
            
            return "self.\(swappedType[index...])"
        } else if type.hasPrefix("Gtk") {
            return "GTK_" + self.selfTypeMacrosName(type) + "(self.GOBJECT)"
            
        } else {
            return type
        }
    }
    
    public static func selfTypeMacrosName(_ type_: String) -> String {
        guard type_.hasPrefix("Gtk") else {
            return type_
        }
        
        var result = ""
        
        switch type_ {
        case "GtkGLArea":
            result += "GL_AREA"
        case "GtkHSV":
            result += "HSV"
        case "GtkVSeparator":
            result += "VSEPARATOR"
        case "GtkHSeparator":
            result += "HSEPARATOR"
        case "GtkHBox":
            result += "HBOX"
        case "GtkVBox":
            result += "VBOX"
        case "GtkHScale":
            result += "HSCALE"
        case "GtkVScale":
            result += "VSCALE"
        case "GtkVScrollbar":
            result += "VSCROLLBAR"
        case "GtkHScrollbar":
            result += "HSCROLLBAR"
        case "GtkHButtonBox":
            result + "HBUTTON_BOX"
        case "GtkVButtonBox":
            result + "VBUTTON_BOX"
        default:
            do {
                let index = type_.index(type_.startIndex, offsetBy: 3)
                var type = type_[index...]
                
                var countBetweenUnderscores = 0
                var i = 0
                let set = CharacterSet.uppercaseLetters
                
                type.unicodeScalars.forEach {
                    
                    if i != 0 && set.contains($0) && countBetweenUnderscores > 0 {
                        result += "_\(String($0).uppercased())"
                        countBetweenUnderscores = 0
                    } else {
                        result += String($0).uppercased()
                        countBetweenUnderscores += 1
                    }
                    
                    i += 1
                }
            }
        }
        
        return result
    }
    
    public static func addToTrimMethodName(_ value: String) {
        if !trimMethodNames.contains(value) {
            trimMethodNames.append(value)
        }
    }
    
    public static func trimMethodName(_ method: String) -> String {
        var longestMatch: String? = nil
        
        for element in trimMethodNames {
            if method.hasPrefix(element) {
                if longestMatch == nil {
                    longestMatch = element
                } else if longestMatch!.count < element.count {
                    longestMatch = element
                }
            }
        }
        
        if let longestMatch = longestMatch {
            let range = method.range(of: longestMatch)
            
            return String(method[range!.upperBound...])
        }
        
        return method
    }
    
    public static func extraImports(of clazz: String) -> [String]? {
        if dictExtraImports.count == 0 {
            dictExtraImports.merge(self._dictionaryFromFile("extra_imports.map"), uniquingKeysWith: {(_, last) in last})
        }
        
        return dictExtraImports[clazz] as? Array<String>
    }
    
    public static func extraMethods(of clazz: String) -> [String: Any]? {
        if dictExtraMethods.count == 0 {
            dictExtraMethods.merge(self._dictionaryFromFile("extra_methods.map"), uniquingKeysWith: {(_, last) in last})
        }
        
        return dictExtraMethods[clazz] as? Dictionary<String, Any>
    }
    
    public static func globalConfigValue<T>(forKey key: String) -> T? {
        if dictGlobalConf.count == 0 {
            dictGlobalConf.merge(self._dictionaryFromFile("global_conf.map"), uniquingKeysWith: {(_, last) in last})
        }
        
        return dictGlobalConf[key] as? T
    }
}
