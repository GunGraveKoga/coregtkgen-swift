//
//  GIRClass.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 23.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRClass : GIRBase {
    public private(set) var name: String? = nil
    public private(set) var cType: String? = nil
    public private(set) var glibGetType: String? = nil
    public private(set) var cSymbolPrefix: String? = nil
    public private(set) var parent: String? = nil
    public private(set) var version: String? = nil
    public private(set) var abstract: Bool = false
    public private(set) var doc: GIRDoc? = nil
    public private(set) var constructors: [GIRConstructor] = [GIRConstructor]()
    public private(set) var fields: [GIRField] = [GIRField]()
    public private(set) var methods: [GIRMethod] = [GIRMethod]()
    public private(set) var virtualMethods: [GIRVirtualMethod] = [GIRVirtualMethod]()
    public private(set) var properties: [GIRProperty] = [GIRProperty]()
    public private(set) var implements: [GIRImplements] = [GIRImplements]()
    public private(set) var functions: [GIRFunction] = [GIRFunction]()
    
    
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            switch key {
                case "text",
                     "glib:type-name",
                     "glib:type-struct",
                     "glib:signal":
                continue
            case "name":
                self.name = (value as! String)
            case "c:type":
                self.cType = (value as! String)
            case "c:symbol-prefix":
                self.cSymbolPrefix = (value as! String)
            case "parent":
                self.parent = (value as! String)
            case "version":
                self.version = (value as! String)
            case "abstract":
                self.abstract = (value as! String == "1") ? true : false
            case "doc":
                self.doc = GIRDoc(value as! Dictionary)
            case "constructor":
               self.processArrayOrDictionary(value, clazz: GIRConstructor.self, andArray: &self.constructors)
            case "field":
                self.processArrayOrDictionary(value, clazz: GIRField.self, andArray: &self.fields)
            case "method":
                self.processArrayOrDictionary(value, clazz: GIRMethod.self, andArray: &self.methods)
            case "virtual-method":
                self.processArrayOrDictionary(value, clazz: GIRVirtualMethod.self, andArray: &self.virtualMethods)
            case "property":
                self.processArrayOrDictionary(value, clazz: GIRProperty.self, andArray: &self.properties)
            case "implements":
                self.processArrayOrDictionary(value, clazz: GIRImplements.self, andArray: &self.implements)
            case "function":
                self.processArrayOrDictionary(value, clazz: GIRFunction.self, andArray: &self.functions)
            case "glib:get-type":
                self.glibGetType = (value as! String)
            default:
                self.logUnknownElement(key)
            }
            
        }
    }
}
