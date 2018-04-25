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
        return true
    }
}
