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
            if !self.generateProtocolsFilesFromNamespace(ns) {
                return false
            }
            
            if !self.generateClassesFilesFromNamespace(ns) {
                return false
            }
        }
        
        return true
    }
    
    public static func generateProtocolsFilesFromNamespace(_ namespace: GIRNamespace) -> Bool {
        
        return true
    }
    
    public static func generateClassesFilesFromNamespace(_ namespace: GIRNamespace) -> Bool {
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
        
        var classesDictionary = [String: CoreGTKClass]()
        
        for clazz in namespace.classes {
            if !classesToGen!.contains(clazz.name!) {
                continue
            }
            // Create class
            var gtkClass = CoreGTKClass(cName: clazz.name!, cType: clazz.cType!, cParentType: clazz.parent)
            // Set constructors
            for constructor in clazz.constructors {
                let ctor = self.generateMethodFromFunction(constructor)
                
                if var ctor = ctor {
                    ctor.isConstructor = true
                    gtkClass.addConstructor(ctor)
                }
            }
            
            // Set functions
            for function in clazz.functions {
                let classFunction = self.generateMethodFromFunction(function)
                
                if let classFunction = classFunction {
                    gtkClass.addFunction(classFunction)
                }
            }
            
            // Set methods
            for method in clazz.methods {
                let instanceMethod = self.generateMethodFromFunction(method)
                
                if let instanceMethod = instanceMethod {
                    gtkClass.addMethod(instanceMethod)
                }
            }
            
            gtkClass.doc = clazz.doc?.docText
            gtkClass.glibGetType = clazz.glibGetType
            
            for implemets in clazz.implements {
                gtkClass.implements.append(implemets.name!)
            }
            
            classesDictionary[gtkClass.name] = gtkClass
        }
        
        do {
            let classesArray = classesDictionary.map {$0.value}
            let rootClasses = classesArray.filter {
                if CoreGTKUtil.swapTypes($0.cParentType!) == "CGTKBase" {
                    return true
                }
                
                return false
            }
            
            for clazz in rootClasses {
                
                let rootFunctions = clazz.hasFunctions() ? Set(clazz.functions.map {$0.sig}) : nil
                let rootConstructors = clazz.hasConstructors() ? Set(clazz.constructors.map {$0.sig}) : nil
                let rootMethods = clazz.hasMethods() ? Set(clazz.methods.map {$0.sig}) : nil
                
                if let overrides = self.resolveOverrides(parent: clazz.name, functionsSigs: rootFunctions, constructorsSigs: rootConstructors, methodsSigs: rootMethods, classes: classesArray) {
                    for (key, value) in overrides {
                        do {
                            if let functions = value["functions"] {
                                for index in functions {
                                    classesDictionary[key]!.functions[index].isOverrided = true
                                }
                            }
                            
                            if let constructors = value["constructors"] {
                                for index in constructors {
                                    classesDictionary[key]!.constructors[index].isOverrided = true
                                }
                            }
                            
                            if let methods = value["methods"] {
                                for index in methods {
                                    classesDictionary[key]!.methods[index].isOverrided = true
                                }
                            }
                        }
                    }
                }
            }
        }
        
        for (_, gtkClass) in classesDictionary {
            do {
                try CoreGTKClassWriter.generateFile(forClass: gtkClass, inDirectory: CommandLine.arguments[3])
            } catch let error {
                print("Cannot generate source file for \(gtkClass.name): \(error)")
                
                return false
            }
        }
        
        return true
    }
    
    fileprivate static func resolveOverrides(parent: String, functionsSigs: Set<String>?, constructorsSigs: Set<String>?, methodsSigs: Set<String>?, classes: [CoreGTKClass]) -> [String: [String: [Int]]]? {
        let children = classes.filter {
            if CoreGTKUtil.swapTypes($0.cParentType!) == parent {
                return true
            }
            
            return false
        }
        
        guard children.count > 0 else {
            return nil
        }
        
        var overrides = [String: [String: [Int]]]()
        
        for child in children {
            var childOverrides = [String: [Int]]()
            
            var rootFunctions: Set<String>? = nil
            
            if child.hasFunctions() {
                if functionsSigs != nil {
                    rootFunctions = functionsSigs
                } else {
                    rootFunctions = Set<String>()
                }
                
                do {
                    var indexes = [Int]()
                    
                    for (index, method) in child.functions.enumerated() {
                        let sig = method.sig
                        
                        if functionsSigs?.contains(sig) ?? false {
                            indexes.append(index)
                        }
                        
                        rootFunctions!.insert(sig)
                    }
                    
                    if indexes.count > 0 {
                        childOverrides["functions"] = indexes
                    }
                }
            }
 
            var rootConstructors: Set<String>? = nil
            /*
            if child.hasConstructors() {
                if constructorsSigs != nil {
                    rootConstructors = constructorsSigs
                } else {
                    rootConstructors = Set<String>()
                }
                
                do {
                    var indexes = [Int]()
                    
                    for (index, method) in child.constructors.enumerated() {
                        let sig = method.sig
                        
                        if constructorsSigs?.contains(sig) ?? false {
                            indexes.append(index)
                        }
                        
                        rootConstructors!.insert(sig)
                    }
                    
                    if indexes.count > 0 {
                        childOverrides["constructors"] = indexes
                    }
                }
            }
            */
            var rootMethods: Set<String>? = nil
            
            if child.hasMethods() {
                if methodsSigs != nil {
                    rootMethods = methodsSigs
                } else {
                    rootMethods = Set<String>()
                }
                
                do {
                    var indexes = [Int]()
                    
                    for (index, method) in child.methods.enumerated() {
                        let sig = method.sig
                        
                        if methodsSigs?.contains(sig) ?? false {
                            indexes.append(index)
                        }
                        
                        rootMethods!.insert(sig)
                    }
                    
                    if indexes.count > 0 {
                        childOverrides["methods"] = indexes
                    }
                }
            }
            
            if childOverrides.count > 0 {
                overrides[child.name] = childOverrides
            }
            
            if let nexOverrides = self.resolveOverrides(parent: child.name, functionsSigs: rootFunctions, constructorsSigs: rootConstructors, methodsSigs: rootMethods, classes: classes) {
                overrides.merge(nexOverrides, uniquingKeysWith: {(_, last) in last})
            }
        }
        
        guard overrides.count > 0 else {
            return nil
        }
        
        return overrides
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
            method.doc = function.doc?.docText
            
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
