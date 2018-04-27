//
//  CoreGTKClass.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 25.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public struct CoreGTKClass {
    public var cName: String
    public var cType: String
    public var cParentType: String?
    public var doc: String? = nil
    public private(set) var constructors = [CoreGTKMethod]()
    public private(set) var functions = [CoreGTKMethod]()
    public private(set) var methods = [CoreGTKMethod]()
    
    public var type: String {
        get {
            let gtkType = CoreGTKUtil.swapTypes(cType)
            
            guard gtkType != "OpaquePointer" else {
                return cType
            }
            
            return gtkType
        }
    }
    
    public var name: String {
        get {
            return "CGTK\(cName)"
        }
    }
    
    init(cName: String, cType: String, cParentType: String? = nil) {
        self.cName = cName
        self.cType = cType
        self.cParentType = cParentType
    }
    
    @inline(__always) public func hasConstructors() -> Bool {
        return constructors.count != 0
    }
    
    public mutating func addConstructor(_ constructor: CoreGTKMethod) {
        switch constructor.cName {
        case "gtk_combo_box_text_new_with_entry",
             "gtk_combo_box_new_with_entry":
            do {
                var _constructor = constructor
                _constructor.isConstructor = false
                self.addFunction(_constructor)
                return
            }
        default:
            break
        }
        self.constructors.append(constructor)
    }
    
    @inline(__always) public func hasFunctions() -> Bool {
        return functions.count != 0
    }
    
    public mutating func addFunction(_ function: CoreGTKMethod) {
        self.functions.append(function)
    }
    
    @inline(__always) public func hasMethods() -> Bool {
        return methods.count != 0
    }
    
    public mutating func addMethod(_ method: CoreGTKMethod) {
        self.methods.append(method)
    }
}
