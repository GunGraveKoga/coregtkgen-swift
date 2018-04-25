//
//  GIRInterface.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 24.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRInterface : GIRBase {
    public private(set) var name: String? = nil
    public private(set) var cType: String? = nil
    public private(set) var cSymbolPrefix: String?  = nil
    public private(set) var doc: GIRDoc? = nil
    public private(set) var fields: [GIRField] = [GIRField]()
    public private(set) var methods: [GIRMethod] = [GIRMethod]()
    public private(set) var virtualMethods: [GIRVirtualMethod] = [GIRVirtualMethod]()
    public private(set) var properties: [GIRProperty] = [GIRProperty]()
    public private(set) var prerequisite: GIRPrerequisite? = nil
    
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            switch key {
            case "text",
                 "glib:type-name",
                 "glib:type-struct",
                 "glib:signal",
                 "glib:get-type":
                continue
            case "name":
                self.name = (value as! String)
            case "c:type":
                self.cType = (value as! String)
            case "c:symbol-prefix":
                self.cSymbolPrefix = (value as! String)
            case "doc":
                self.doc = GIRDoc(value as! Dictionary<String, Any>)
            case "fields":
                self.processArrayOrDictionary(value, clazz: GIRField.self, andArray: &self.fields)
            case "method":
                self.processArrayOrDictionary(value, clazz: GIRMethod.self, andArray: &self.methods)
            case "virtual-method":
                self.processArrayOrDictionary(value, clazz: GIRVirtualMethod.self, andArray: &self.virtualMethods)
            case "property":
                self.processArrayOrDictionary(value, clazz: GIRProperty.self, andArray: &self.properties)
            case "prerequisite":
                self.prerequisite = GIRPrerequisite(value as! Dictionary<String, Any>)
            default:
                self.logUnknownElement(key)
            }
        }
    }
    
}
