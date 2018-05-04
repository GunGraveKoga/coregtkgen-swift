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
    public var doc: String? = nil
    public var isOverrided = false
    
    public var name: String {
        get {
            let trimmedMethodName = CoreGTKUtil.trimMethodName(cName)
            return CoreGTKUtil.convertUSSToCamelCase(trimmedMethodName)
        }
    }
    
    public var returnsGeneric: Bool {
        get {
            return self.returnType.hasPrefix("CGTK")
        }
    }
    
    public var returnType: String {
        get {
            switch cName {
            case "gtk_about_dialog_get_artists",
                 "gtk_about_dialog_get_authors",
                 "gtk_about_dialog_get_documenters":
                return "UnsafePointer<UnsafePointer<gchar>?>!"
            default:
                break
            }
            var type = CoreGTKUtil.swapTypes(cReturnType)
            var isConst = false
            var range = type.range(of: "const")
            
            if range != nil {
                type = String(type[range!.upperBound...]).trimmingCharacters(in: CharacterSet.whitespaces)
                
                if type.hasSuffix("*") {
                    type = CoreGTKUtil.swapTypes(type)
                }
                
                isConst = true
            }
            
            range = type.range(of: "**", options: .caseInsensitive)
            
            if range != nil {
                var result = "Unsafe"
                
                let isGtkType = cReturnType.hasPrefix("Gtk") || cReturnType.hasPrefix("Gdk") || cReturnType.hasPrefix("Atk") || cReturnType.hasPrefix("G")
                
                if isGtkType && !isConst {
                    result += "Mutable"
                }
                
                result += "Pointer<Unsafe"
                
                if isGtkType {
                    result += "Mutable"
                }
                
                result += "Pointer<\(type[..<range!.lowerBound])>?>"
                
                if isReturnNullable {
                    result += "?"
                } else {
                    result += "!"
                }
                
                return result
            }
            
            range = type.range(of: "*", options: .caseInsensitive)
            
            if range != nil {
                let isGtkType = cReturnType.hasPrefix("Gtk") || cReturnType.hasPrefix("Gdk") || cReturnType.hasPrefix("Atk") || cReturnType.hasPrefix("G")
                
                var result = "Unsafe"
                
                if isGtkType && !isConst {
                    result += "Mutable"
                }
                
                result += "Pointer<\(type[..<range!.lowerBound])>"
                
                if isReturnNullable {
                    result += "?"
                } else {
                    result += "!"
                }
                
                return result
            }
            
            if isReturnNullable || type == "String" {
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
        
        if cName == "gtk_image_get_stock" {
            let stockIdParam = parameters[0]
            parameters[0] = CoreGTKParameter(cName: stockIdParam.cName, cType: "UnsafeMutablePointer<UnsafeMutablePointer<gchar>?>!", nullable: false, optional: false)
            
        } else if cName == "gtk_widget_class_path" ||
            cName == "gtk_widget_path" {
            let pathParam = parameters[1]
            let pathReversedParam = parameters[2]
            
            parameters[1] = CoreGTKParameter(cName: pathParam.cName, cType: "UnsafeMutablePointer<UnsafeMutablePointer<gchar>?>!", nullable: false, optional: false)
            parameters[2] = CoreGTKParameter(cName: pathReversedParam.cName, cType: "UnsafeMutablePointer<UnsafeMutablePointer<gchar>?>!", nullable: false, optional: false)
        } else if cName == "gtk_builder_add_objects_from_file" ||
            cName == "gtk_builder_add_objects_from_resource" ||
            cName == "gtk_builder_add_objects_from_string" {
            
            var index = 1
            
            if cName == "gtk_builder_add_objects_from_string" {
                index += 1
            }
            
            let objectIdsParam = parameters[index]
            
            parameters[index] = CoreGTKParameter.init(cName: objectIdsParam.cName, cType: "UnsafeMutablePointer<UnsafeMutablePointer<gchar>?>!", nullable: false, optional: false)
        }
    }
    
    public var sig: String {
        get {
            var result: String
            
            let isGeneric = self.returnsGeneric
            
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
                
                
                if isGeneric {
                    result = "\(self.name)<T>("
                } else {
                    result = "\(self.name)("
                }
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
            
            if !self.returnsVoid && !isConstructor {
                if isGeneric {
                    result += " -> T"
                    var retType = self.returnType
                    
                    if retType.hasSuffix("?") || retType.hasSuffix("!") {
                        let index = retType.index(before: retType.endIndex)
                        result += String(retType[index...])
                        retType = String(retType[..<index])
                    }
                    result += " where T: "
                    result += retType
                } else {
                    result += " -> \(self.returnType)"
                }
            }
            
            return result
        }
    }
}
