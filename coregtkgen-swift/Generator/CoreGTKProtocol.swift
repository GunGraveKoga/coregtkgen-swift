//
//  CoreGTKProtocol.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 04.05.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public struct CoreGTKProtocol {
    public var cName: String
    public var cType: String
    public var cSymbolPrefix: String
    public var glibGetType: String? = nil
    public var doc: String? = nil
    public var methods = [CoreGTKMethod]()
    
    public var name: String {
        get {
            return "CGTK\(cName)"
        }
    }
    
    public var type: String {
        get {
            let gtkType = CoreGTKUtil.swapTypes(cType)
            
            guard gtkType != "OpaquePointer" else {
                return cType
            }
            
            return gtkType
        }
    }
    
    init(cName: String, cType: String, cSymbolPrefix: String) {
        self.cName = cName
        self.cType = cType
        self.cSymbolPrefix = cSymbolPrefix
    }
    
    @inline(__always) public func hasMethods() -> Bool {
        return methods.count != 0
    }
    
    public mutating func addMethod(_ method: CoreGTKMethod) {
        self.methods.append(method)
    }
}
