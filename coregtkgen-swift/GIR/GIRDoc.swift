//
//  GIRDoc.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 23.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public class GIRDoc : GIRBase {
    public private(set) var xmlSpace: String? = nil
    public private(set) var xmlWhitespace: String? = nil
    public private(set) var docText: String? = nil
    
    public override func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        for (key, value) in dictionary {
            switch key {
            case "text":
                self.docText = (value as! String)
            case "xml:space":
                self.xmlSpace = (value as! String)
            case "xml:whitespace":
                self.xmlWhitespace = (value as! String)
            default:
                self.logUnknownElement(key)
            }
        }
    }
}
