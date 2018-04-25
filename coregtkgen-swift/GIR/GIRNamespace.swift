//
//  GIRNamespace.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 24.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRNamespace : GIRBase {
    public private(set) var name: String? = nil
    public private(set) var cSymbolPrefixes: String? = nil
    public private(set) var cIdentifierPrefixes: String? = nil
    public private(set) var classes: [GIRClass] = [GIRClass]()
    public private(set) var functions: [GIRFunction] = [GIRFunction]()
    public private(set) var enumirations: [GIREnumiration] = [GIREnumiration]()
    public private(set) var constants: [GIRConstant] = [GIRConstant]()
    public private(set) var interfaces: [GIRInterface] = [GIRInterface]()
    
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            switch key {
            case "text",
                 "shared-library",
                 "version",
                 "record",
                 "callback",
                 "bitfield",
                 "alias":
                continue
            case "name":
                self.name = (value as! String)
            case "c:symbol-prefixes":
                self.cSymbolPrefixes = (value as! String)
            case "c:identifier-prefixes":
                self.cIdentifierPrefixes = (value as! String)
            case "class":
                self.processArrayOrDictionary(value, clazz: GIRClass.self, andArray: &self.classes)
            case "function":
                self.processArrayOrDictionary(value, clazz: GIRFunction.self, andArray: &self.functions)
            case "enumeration":
                self.processArrayOrDictionary(value, clazz: GIREnumiration.self, andArray: &self.enumirations)
            case "constant":
                self.processArrayOrDictionary(value, clazz: GIRConstant.self, andArray: &self.constants)
            case "interface":
                self.processArrayOrDictionary(value, clazz: GIRInterface.self, andArray: &self.interfaces)
            default:
                self.logUnknownElement(key)
            }
        }
    }
    
}
