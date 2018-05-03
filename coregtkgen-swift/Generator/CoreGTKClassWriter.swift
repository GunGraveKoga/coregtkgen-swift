//
//  CoreGTKClassWriter.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 25.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

fileprivate let configURL = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)

public enum CoreGTKClassWriter {
    public static func generateFile(forClass gtkClass: CoreGTKClass, inDirectory directory: String) throws {
        var isDir: ObjCBool = false
        
        if FileManager.default.fileExists(atPath: directory, isDirectory: &isDir) && isDir.boolValue {
            let directoryURL = URL(fileURLWithPath: directory, isDirectory: true)
            
            let fileURL = directoryURL.appendingPathComponent(gtkClass.name, isDirectory: false).appendingPathExtension("swift")
            
            try self.sourceString(forClass: gtkClass).write(to: fileURL, atomically: false, encoding: .utf8)
            
        } else {
            var message = "Invalid output directory path \(directory)"
            
            if !isDir.boolValue {
                message += " (not directory!)"
            }
            
            print(message)
            fatalError(message)
        }
    }
    
    public static func sourceString(forClass gtkClass: CoreGTKClass) -> String {
        var output = ""
        
        output += self.generateLicense(forFile: "\(gtkClass.name).swift") ?? ""
        output += "\n@_exported import CGtk\n\n"
        output += self.macrosesSourceString(forClass: gtkClass)
        
        if gtkClass.doc != nil {
            let set = CharacterSet.whitespaces
            for line in gtkClass.doc!.split(separator: "\n") {
                output += "/// " + line.trimmingCharacters(in: set) + "\n"
            }
            
            output += "\n\n"
        }
        
        output += "open class \(gtkClass.name) : \(CoreGTKUtil.swapTypes(gtkClass.cParentType!)) {\n"
        
        for function in gtkClass.functions {
            output += self.generateDocumentation(forMethod: function)
            output += "\t"
            if function.isOverrided {
                output += "override "
            }
            output += "open class "
            output += self.sourceString(forFunction: function)
        }
        
        let _extraMethods = CoreGTKUtil.extraMethods(of: gtkClass.type)
        
        if let extraMethods = _extraMethods {
            for (key, value) in extraMethods {
                output += "\(key)\n\(value as! String)\n\n"
            }
        }
        
        for constructor in gtkClass.constructors {
            output += self.generateDocumentation(forMethod: constructor)
            output += self.sourceString(forConstructor: constructor, of: gtkClass)
        }
        
        output += self.selfTypeMethodSourceString(forClass: gtkClass)
        
        for method in gtkClass.methods {
            output += self.generateDocumentation(forMethod: method)
            output += "\t"
            if method.isOverrided {
                output += "override "
            }
            output += "open "
            output += self.sourceString(forFunction: method, passSelf: gtkClass.type)
        }
        
        output += "}\n"
        
        return output
    }
    
    public static func sourceString(forFunction gtkFunction: CoreGTKMethod, passSelf: String? = nil) -> String {
        var output = ""
        
        output += "func \(gtkFunction.sig)"
        
        output += " {\n"
        
        if gtkFunction.returnsVoid {
            output += "\t\t\(gtkFunction.cName)("
            
            if passSelf != nil {
                output += self.generateCParameterListWith(instance: passSelf!, params: gtkFunction.parameters)
            } else {
                output += self.generateCParameterListString(gtkFunction.parameters)
            }
            
            output += ")\n"
        } else {
            output += "\t\treturn "
            
            let name: String
            
            if passSelf != nil {
                name = "\(gtkFunction.cName)(\(self.generateCParameterListWith(instance: passSelf!, params: gtkFunction.parameters)))"
            } else {
                name = "\(gtkFunction.cName)(\(self.generateCParameterListString(gtkFunction.parameters)))"
            }
            
            if CoreGTKUtil.isTypeSwappable(gtkFunction.cReturnType) {
                output += CoreGTKUtil.convertType(from: gtkFunction.cReturnType, to: gtkFunction.returnType, withName: name)
                
                
            } else {
                output += name
            }
            
            output += "\n"
        }
        
        output += "\t}\n\n"
        
        return output
    }
    
    public static func sourceString(forConstructor constructor: CoreGTKMethod, of gtkClass: CoreGTKClass) -> String {
        var output = ""
        
        output += "\t"
        
        if constructor.isOverrided {
            output += "override "
        }
        
        output += "public convenience \(constructor.sig) {\n\t\t"
        
        let constructorString = "\(constructor.cName)(\(self.generateCParameterListString(constructor.parameters)))"
        
        output += CoreGTKUtil.getFunctionCallForConstructor(of: gtkClass.cType, with: constructorString)
        
        output += "\t}\n\n"
        
        return output
    }
    
    public static func macrosesSourceString(forClass gtkClass: CoreGTKClass) -> String {
        let gtkClassName = gtkClass.cName.uppercased()
        var output = ""
        
        switch gtkClassName {
        case "WIDGET",
             "HPANED",
             "VPANED":
            break
        default:
            do {
                let type: String
                let macrosName = CoreGTKUtil.selfTypeMacrosName(gtkClass.cType)
                
                switch gtkClassName {
                case "POPOVERMENU",
                     "SHORTCUTSSHORTCUT",
                     "MODELBUTTON",
                     "PLACESSIDEBAR":
                    type = "OpaquePointer!"
                default:
                    type = "UnsafeMutablePointer<\(gtkClass.cType)>!"
                }
                
                if let glibGetType = gtkClass.glibGetType {
                    output += "public let GTK_TYPE_\(macrosName): GType = \(glibGetType)()\n\n"
                } else {
                    output += "public let GTK_TYPE_\(macrosName): GType = gtk_\(macrosName.lowercased())_get_type()\n\n"
                }
                output += "@inline(__always) public func GTK_\(macrosName)(_ ptr: UnsafeMutableRawPointer!) -> \(type) {\n"
                output += "\treturn G_TYPE_CHECK_INSTANCE_CAST(ptr, GTK_TYPE_\(macrosName))\n}\n\n"
            }
        }
        
        return output
    }
    
    public static func selfTypeMethodSourceString(forClass gtkClass: CoreGTKClass) -> String {
        let gtkClassName = gtkClass.cName.uppercased()
        var output = ""
        
        switch gtkClassName {
        case "WIDGET",
             "HPANED",
             "VPANED":
            break
        default:
            do {
                let type: String
                
                switch gtkClassName {
                case "POPOVERMENU",
                     "SHORTCUTSSHORTCUT",
                     "MODELBUTTON",
                     "PLACESSIDEBAR":
                    type = "OpaquePointer!"
                default:
                    type = "UnsafeMutablePointer<\(gtkClass.cType)>!"
                }
                
                output += "\topen var \(gtkClassName): \(type) {\n\t\tget {\n\t\t\treturn \(CoreGTKUtil.selfTypeMethodCall(gtkClass.cType))\n\t\t}\n\t}\n\n"
            }
        }
        
        return output
    }
    
    public static func generateCParameterListString(_ params: [CoreGTKParameter]) -> String {
        var paramsOutput = ""
        let limit = params.count - 1
        
        for i in 0..<params.count {
            let param = params[i]
            
            paramsOutput += CoreGTKUtil.convertType(from: param.type, to: param.cType, withName: param.name)
            
            if i < limit {
                paramsOutput += ", "
            }
        }
        
        return paramsOutput
    }
    
    public static func generateCParameterListWith(instance instanceType: String, params: [CoreGTKParameter]) -> String {
        var paramsOutput = ""
        
        paramsOutput += CoreGTKUtil.selfTypeMethodCall(instanceType)
        
        if params.count > 0 {
            paramsOutput += ", "
            
            let limit = params.count - 1
            for i in 0..<params.count {
                let param = params[i]
                
                paramsOutput += CoreGTKUtil.convertType(from: param.type, to: param.cType, withName: param.name)
                
                if i < limit {
                    paramsOutput += ", "
                }
            }
        }
        
        return paramsOutput
    }
    
    public static func generateLicense(forFile fileName: String) -> String? {
        do {
            let licText = try String(contentsOf: configURL.appendingPathComponent("license.txt"))
            
            return licText.replacingOccurrences(of: "@@@FILENAME@@@", with: fileName)
            
        } catch let error {
            print("Error reading license file: \(error)")
            
            return nil
        }
    }
    
    public static func generateDocumentation(forMethod method: CoreGTKMethod) -> String {
        var doc = ""
        
        if method.doc != nil {
            let set = CharacterSet.whitespaces
            for line in method.doc!.split(separator: "\n") {
                doc += "\t/// " + line.trimmingCharacters(in: set) + "\n"
            }
        } else {
            doc += "\t/// func \(method.sig) -> \(method.returnType)\n"
        }
        
        if method.parameters.count > 0 {
            doc += "\t/// Parameters:\n"
            
            for parameter in method.parameters {
                doc += "\t///\t- \(parameter.name): \(parameter.type)\n"
            }
        }
        
        if !method.returnsVoid {
            doc += "\t/// - Returns: \(method.returnType)\n"
        }
        
        return doc
    }
}
