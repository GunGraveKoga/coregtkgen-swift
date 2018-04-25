//
//  CoreGTKMethod.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 25.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public struct CoreGTKMethod {
    public var cName: String
    public var cReturnType: String
    public private(set) var parameters = [CoreGTKParameter]()
    public var deprecated = false
    public var cDeprecatedMessage: String? = nil
    
    public var name: String {
        get {
            let trimmedMethodName = CoreGTKUtil.trimMethodName(cName)
            return CoreGTKUtil.convertUSSToCamelCase(trimmedMethodName)
        }
    }
    
    public var returnType: String {
        get {
            return CoreGTKUtil.swapTypes(cReturnType)
        }
    }
    
    public var returnsVoid: Bool {
        get {
            return cReturnType == "void"
        }
    }
    
    public mutating func setParameters(_ parameters_: [CoreGTKParameter]) {
        self.parameters.append(contentsOf: parameters_)
        // Hacky fix to get around issue with missing GError parameter from GIR file
        switch cName {
        case "gtk_window_set_icon_from_file",
             "gtk_window_set_default_icon_from_file",
             "gtk_builder_add_from_file",
             "gtk_builder_add_from_resource",
             "gtk_builder_add_from_string",
             "gtk_builder_add_objects_from_file",
             "gtk_builder_add_objects_from_resource",
             "gtk_builder_add_objects_from_string",
             "gtk_builder_extend_with_template",
             "gtk_builder_value_from_string",
             "gtk_builder_value_from_string_type":
            do {
                let param = CoreGTKParameter(cName: "err", cType: "GError**")
                self.parameters.append(param)
            }
        default:
            break
        }
    }
    
    public var sig: String {
        get {
            // C method with no parameters
            if parameters.count <= 0 {
                return "\(self.name)()"
            }
            // C method with only one parameter
            else if parameters.count == 1 {
                let param = parameters.first!
                
                return "\(self.name)(_ \(param.name): \(param.type))"
            }
            // C method with multiple parameters
            else {
                var output = "\(self.name)With("
                
                let last = self.parameters.last
                
                for param in self.parameters {
                    output += "\(param.name): \(param.type)"
                    
                    if param != last! {
                        output += ", "
                    }
                }
                
                output += ")"
                
                return output
            }
        }
    }
}
