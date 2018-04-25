//
//  GIRApi.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 24.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRApi : GIRBase {
    public private(set) var version: String? = nil
    public private(set) var cIncludes: [GIRInclude] = [GIRInclude]()
    public private(set) var namespaces: [GIRNamespace] = [GIRNamespace]()
    
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            switch key {
            case "text",
                 "include",
                 "xmlns:glib",
                 "xmlns:c",
                 "xmlns",
                 "package":
                continue
            case "version":
                self.version = (value as! String)
            case "c:include":
                self.processArrayOrDictionary(value, clazz: GIRInclude.self, andArray: &self.cIncludes)
            case "namespace":
                self.processArrayOrDictionary(value, clazz: GIRNamespace.self, andArray: &self.namespaces)
            default:
                self.logUnknownElement(key)
            }
        }
    }
}
