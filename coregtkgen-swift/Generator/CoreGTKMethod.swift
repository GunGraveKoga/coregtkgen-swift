//
//  CoreGTKMethod.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 25.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public struct CoreGTKMethod {
    public var cName: String
    public var cReturnType: String
    public var isReturnNullable: Bool
    public private(set) var parameters = [CoreGTKParameter]()
    public var deprecated = false
    public var cDeprecatedMessage: String? = nil
    public var isConstructor = false
    
    public var name: String {
        get {
            let trimmedMethodName = CoreGTKUtil.trimMethodName(cName)
            return CoreGTKUtil.convertUSSToCamelCase(trimmedMethodName)
        }
    }
    
    public var returnType: String {
        get {
            var type = CoreGTKUtil.swapTypes(cReturnType)
            
            var range = type.range(of: "const")
            
            if range != nil {
                type = String(type[range!.upperBound...]).trimmingCharacters(in: CharacterSet.whitespaces)
            }
            
            range = type.range(of: "**", options: .caseInsensitive)
            
            if range != nil {
                var result = "UnsafeMutablePointer<UnsafeMutablePointer<\(type[..<range!.lowerBound])>?>"
                
                if isReturnNullable {
                    result += "?"
                } else {
                    result += "!"
                }
                
                return result
            }
            
            range = type.range(of: "*", options: .caseInsensitive)
            
            if range != nil {
                var result = "UnsafeMutablePointer<\(type[..<range!.lowerBound])>"
                
                if isReturnNullable {
                    result += "?"
                } else {
                    result += "!"
                }
                
                return result
            }
            
            if isReturnNullable {
                return type + "?"
            }
            
            return type
        }
    }
    
    public var returnsVoid: Bool {
        get {
            return cReturnType == "void"
        }
    }
    
    init(cName: String, cReturnType: String, isReturnNullable: Bool) {
        self.cName = cName
        self.cReturnType = cReturnType
        self.isReturnNullable = isReturnNullable
    }
    
    public mutating func setParameters(_ parameters_: [CoreGTKParameter]) {
        self.parameters.append(contentsOf: parameters_)
        // Hacky fix to get around issue with missing GError parameter from GIR file
        switch cName {
        case "gtk_window_set_icon_from_file",
             "gtk_window_set_default_icon_from_file",
             "gtk_builder_add_from_file",
             "gtk_builder_add_from_resource",
             "gtk_builder_add_from_string",
             "gtk_builder_add_objects_from_file",
             "gtk_builder_add_objects_from_resource",
             "gtk_builder_add_objects_from_string",
             "gtk_builder_extend_with_template",
             "gtk_builder_value_from_string",
             "gtk_builder_value_from_string_type":
            do {
                let param = CoreGTKParameter(cName: "err", cType: "GError**", nullable: true, optional: true)
                self.parameters.append(param)
            }
        default:
            break
        }
    }
    
    public var sig: String {
        get {
            var result: String
            
            if isConstructor {
                result = "init("
                let _name = self.name
                let range = _name.range(of: "new", options: .caseInsensitive)
                
                if range != nil {
                    let initMethodName = String(_name[range!.upperBound...])
                    
                    if initMethodName.count > 0 {
                        let index = initMethodName.index(after: initMethodName.startIndex)
                        result += initMethodName[..<index].lowercased() + initMethodName[index...] + " "
                    }
                }
                
            } else {
                result = "\(self.name)("
            }
            
            if parameters.count > 0 {
                let param = parameters.first!
                let suffix = CoreGTKUtil.convertUSSToCapCase(param.cName)
                
                if !isConstructor && self.name.hasSuffix(suffix) {
                    result += "_ "
                }
                
                result += "\(param.name): \(param.type)"
                
                if parameters.count > 1 {
                    let limit = self.parameters.count - 1
                    result += ", "
                    
                    for i in 1..<parameters.count {
                        let param = self.parameters[i]
                        
                        result += "\(param.name): \(param.type)"
                        
                        if i < limit {
                            result += ", "
                        }
                    }
                }
            }
            
            result += ")"
            
            return result
        }
    }
}
