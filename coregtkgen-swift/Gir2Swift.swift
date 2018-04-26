//
//  Gir2Swift.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 25.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public enum Gir2Swift {
    public static func parseGirFromFile(_ file: String, into dictionary: inout Dictionary<String, Any>) throws {
        
        let girContent = try String(contentsOfFile: file)
        var error: Error? = nil
        let girDict = XMLReader.dictionaryFromXML(string: girContent, parserError: &error)
        
        guard girDict != nil else {
            throw error!
        }
        
        dictionary = girDict!
    }
    
    public static func firstApiFrom(dictionary: Dictionary<String, Any>) -> GIRApi? {
        guard dictionary.count > 0 else {
            return nil
        }
        
        for (key, value) in dictionary {
            let dict = (value as! Dictionary<String, Any>)
            switch key {
            case "api",
                 "repository":
                return GIRApi(dict)
            default:
                return self.firstApiFrom(dictionary: dict)
            }
        }
        
        return nil
    }
    
    public static func firsApiFrom(girFile file: String) throws -> GIRApi? {
        var dict = Dictionary<String, Any>()
        
        try self.parseGirFromFile(file, into: &dict)
        
        return self.firstApiFrom(dictionary: dict)
    }
    
    public static func generateClassFileFromApi(_ api: GIRApi) -> Bool {
        let namspaces = api.namespaces
        
        if namspaces.count <= 0 {
            return false
        }
        
        for ns in namspaces {
            if !self.generateClassFileFromNamespace(ns) {
                return false
            }
        }
        
        return true
    }
    
    public static func generateClassFileFromNamespace(_ namespace: GIRNamespace) -> Bool {
        let classesToGen: [String]? = CoreGTKUtil.globalConfigValue(forKey: "classesToGen")
        
        guard classesToGen != nil else {
            print("Cannot get classes list!")
            return false
        }
        
        let set = CharacterSet.uppercaseLetters
        // Pre-load trimMethodNames (in GTKUtil) from info in classesToGen
        // In order to do this we must convert from something like
        // ScaleButton to gtk_scale_button
        for clazz in classesToGen! {
            var i = 0
            var result = ""
            
            clazz.unicodeScalars.forEach {
                if i != 0 && set.contains($0) {
                    result += "_"
                }
                
                result += String($0).lowercased()
                
                i += 1
            }
            
            CoreGTKUtil.addToTrimMethodName("gtk_\(result)")
        }
        
        for clazz in namespace.classes {
            if !classesToGen!.contains(clazz.name!) {
                continue
            }
            // Create class
            var gtkClass = CoreGTKClass(cName: clazz.name!, cType: clazz.cType!, cParentType: clazz.parent)
            print("Generated class \(gtkClass.name)")
            
            // Set constructors
            for constructor in clazz.constructors {
                let ctor = self.generateMethodFromFunction(constructor)
                
                if var ctor = ctor {
                    ctor.isConstructor = true
                    gtkClass.addConstructor(ctor)
                    print("Generated constructor \(ctor.sig)")
                }
            }
            
            // Set functions
            for function in clazz.functions {
                let classFunction = self.generateMethodFromFunction(function)
                
                if let classFunction = classFunction {
                    gtkClass.addFunction(classFunction)
                    print("Generated class method \(classFunction.sig)")
                }
            }
            
            // Set methods
            for method in clazz.methods {
                let instanceMethod = self.generateMethodFromFunction(method)
                
                if let instanceMethod = instanceMethod {
                    gtkClass.addMethod(instanceMethod)
                    print("Generated instance method \(instanceMethod.sig)")
                }
            }
            
            do {
                try CoreGTKClassWriter.generateFile(forClass: gtkClass, inDirectory: CommandLine.arguments[3])
            } catch let error {
                print("Cannot generate source file for \(gtkClass.name): \(error)")
                
                return false
            }
        }
        
        return true
    }
    
    fileprivate static func generateMethodFromFunction<T>(_ function: T) -> CoreGTKMethod? where T: GIRFunctionBase {
        // Don't handle VarArgs function
        if !self.hasVarArgs(function) {
            var type: String
            
            if function.returnValue?.type == nil && function.returnValue?.array != nil {
                type = function.returnValue!.array!.cType!
            } else {
                type = function.returnValue!.type!.cType!
            }
            
            var method = CoreGTKMethod(cName: function.cIdentifier!, cReturnType: type, isReturnNullable: function.returnValue!.nullable)
            
            var params = [CoreGTKParameter]()
            
            for parameter in function.parameters {
                let param = self.generateParameter(parameter)
                
                params.append(param)
            }
            
            method.setParameters(params)
            
            method.deprecated = function.deprecated
            method.cDeprecatedMessage = function.docDeprecated?.docText
            
            return method
        }
        
        return nil
    }
    
    fileprivate static func generateParameter(_ parameter: GIRParameter) -> CoreGTKParameter {
        var type: String
        
        if parameter.type == nil && parameter.array != nil {
            type = parameter.array!.cType!
        } else {
            type = parameter.type!.cType!
        }
        
        return CoreGTKParameter(cName: parameter.name!, cType: type, nullable: parameter.nullable, optional: parameter.optional)
    }
    
    fileprivate static func hasVarArgs<T>(_ function: T) -> Bool where T: GIRFunctionBase {
        for parameter in function.parameters {
            if parameter.varArgs != nil {
                return true
            }
        }
        
        return false
    }
}
