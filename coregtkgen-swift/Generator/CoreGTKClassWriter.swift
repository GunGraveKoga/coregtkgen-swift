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
        let gtkClassName = gtkClass.cName.uppercased()
        
        output += self.generateLicense(forFile: "\(gtkClass.name).swift") ?? ""
        output += "\n@_exported import CGtk\n\n"
        
        if gtkClassName != "WIDGET" {
            let type = CoreGTKUtil.selfTypeMacrosName(gtkClass.cType)
            output += "public let GTK_TYPE_\(type): GType = gtk_\(type.lowercased())_get_type()\n\n"
            output += "@inline(__always) public func GTK_\(type)(_ ptr: UnsafeMutableRawPointer!) -> UnsafeMutablePointer<\(gtkClass.cType)> {\n"
            output += "\treturn G_TYPE_CHECK_INSTANCE_CAST(ptr, GTK_TYPE_\(type))\n}\n\n"
        }
        
        output += "open class \(gtkClass.name) : \(CoreGTKUtil.swapTypes(gtkClass.cParentType!)) {\n"
        
        for function in gtkClass.functions {
            output += "\topen class "
            output += self.sourceString(forFunction: function)
        }
        
        let _extraMethods = CoreGTKUtil.extraMethods(of: gtkClass.name)
        
        if let extraMethods = _extraMethods {
            for (key, value) in extraMethods {
                output += "\(key)\n\(value as! String)\n\n"
            }
        }
        
        for constructor in gtkClass.constructors {
            output += self.sourceString(forConstructor: constructor, of: gtkClass)
        }
        
        if gtkClassName != "WIDGET" {
            output += "\topen var \(gtkClassName): UnsafeMutablePointer<\(gtkClass.cType)>! {\n\t\tget {\n\t\t\treturn \(CoreGTKUtil.selfTypeMethodCall(gtkClass.cType))\n\t\t}\n\t}\n\n"
        }
        
        for method in gtkClass.methods {
            output += "\topen "
            
            output += self.sourceString(forFunction: method, passSelf: gtkClass.type)
        }
        
        output += "}\n"
        
        return output
    }
    
    public static func sourceString(forFunction gtkFunction: CoreGTKMethod, passSelf: String? = nil) -> String {
        var output = "func \(gtkFunction.sig)"
        
        if !gtkFunction.returnsVoid {
            output += " -> \(gtkFunction.returnType)"
        }
        
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
        
        output += "\tpublic \(constructor.sig) {\n\t\t"
        let constructorString = "\(constructor.cName)(\(self.generateCParameterListString(constructor.parameters)))"
        
        output += CoreGTKUtil.getFunctionCallForConstructor(of: gtkClass.cType, with: constructorString)
        
        output += "\t}\n\n"
        
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
        var doc = "/// func \(method.sig) -> \(method.returnType)\n"
        
        if method.parameters.count > 0 {
            doc += "/// Parameters:\n"
            
            for parameter in method.parameters {
                doc += "///\t- \(parameter.name): \(parameter.type)\n"
            }
        }
        
        if !method.returnsVoid {
            doc += "/// - Returns: \(method.returnType)"
        }
        
        return doc
    }
}
