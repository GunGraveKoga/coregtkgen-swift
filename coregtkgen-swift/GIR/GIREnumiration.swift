//
//  GIREnumiration.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 24.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIREnumiration : GIRBase {
    public private(set) var name: String? = nil
    public private(set) var cType: String? = nil
    public private(set) var version: String? = nil
    public private(set) var doc: GIRDoc? = nil
    public private(set) var deprecated: Bool = false
    public private(set) var depricatedVersion: String? = nil
    public private(set) var docDeprecated: GIRDoc? = nil
    public private(set) var members: [GIRMember] = [GIRMember]()
    public private(set) var functions: [GIRFunction] = [GIRFunction]()
    
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            switch key {
            case "text",
                 "glib:type-name",
                 "glib:get-type",
                 "glib:error-domain":
                continue
            case "name":
                self.name = (value as! String)
            case "c:type":
                self.cType = (value as! String)
            case "versio":
                self.version = (value as! String)
            case "deprecated-version":
                self.depricatedVersion = (value as! String)
            case "deprecated":
                self.deprecated = (value as! String == "1") ? true : false
            case "doc":
                self.doc = GIRDoc(value as! Dictionary<String, Any>)
            case "doc-deprecated":
                self.docDeprecated = GIRDoc(value as! Dictionary<String, Any>)
            case "member":
                self.processArrayOrDictionary(value, clazz: GIRMember.self, andArray: &self.members)
            case "function":
                self.processArrayOrDictionary(value, clazz: GIRFunction.self, andArray: &self.functions)
            default:
                self.logUnknownElement(key)
            }
        }
    }
}
