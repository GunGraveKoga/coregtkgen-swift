//
//  GIRFunction.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 23.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRFunctionBase : GIRBase {
    public private(set) var name: String? = nil
    public private(set) var cIdentifier: String? = nil
    public private(set) var version: String? = nil
    public private(set) var deprecatedVersion: String? = nil
    public private(set) var doc: GIRDoc? = nil
    public private(set) var docDeprecated: GIRDoc?  = nil
    public private(set) var deprecated: Bool = false
    public private(set) var introspectable: Bool = false
    public private(set) var `throws`: Bool = false
    public private(set) var returnValue: GIRReturnValue? = nil
    public private(set) var parameters: [GIRParameter] = [GIRParameter]()
    public private(set) var instanceParameters: [GIRParameter] = [GIRParameter]()
    
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            if !self.tryParse(key: key, value: value) {
                self.logUnknownElement(key)
            }
        }
    }
    
    public func tryParse(key: String, value: Any) -> Bool {
        switch key {
        case "text":
            break
        case "name":
            self.name = (value as! String)
        case "c:identifier":
            self.cIdentifier = (value as! String)
        case "version":
            self.version = (value as! String)
        case "deprecated-version":
            self.deprecatedVersion = (value as! String)
        case "introspectable":
            self.introspectable = (value as! String == "1") ? true : false
        case "deprecated":
            self.deprecated = (value as! String == "1") ? true : false
        case "throws":
            self.throws = (value as! String == "1") ? true : false
        case "doc":
            self.doc = GIRDoc(value as! Dictionary<String, Any>)
        case "doc-deprecated":
            self.docDeprecated = GIRDoc(value as! Dictionary<String, Any>)
        case "return-value":
            self.returnValue = GIRReturnValue(value as! Dictionary<String, Any>)
        case "parameters":
            let parametersValue = value as! Dictionary<String, Any>
            for (paramKey, paramValue) in parametersValue {
                if paramKey == "parameter" {
                    self.processArrayOrDictionary(paramValue, clazz: GIRParameter.self, andArray: &self.parameters)
                } else if paramKey == "instance-parameter" {
                    self.processArrayOrDictionary(paramValue, clazz: GIRParameter.self, andArray: &self.instanceParameters)
                }
            }
        default:
            return false
        }
        
        return true
    }
    
}

public class GIRFunction : GIRFunctionBase {
    public private(set) var movedTo: String? = nil
    
    override public func tryParse(key: String, value: Any) -> Bool {
        if key == "moved-to" {
            self.movedTo = (value as! String)
            
            return true
        }
        
        return super.tryParse(key: key, value: value)
    }
}
