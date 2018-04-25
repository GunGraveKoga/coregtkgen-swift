//
//  GIRBase.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 23.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

public protocol GIRParseDictionary : class {
    init()
    init(_ dictionary: Dictionary<String, Any>)
    func parseDictionary(_ dictionary: Dictionary<String, Any>) -> Void
}



public class GIRBase : GIRParseDictionary {
    
    public enum LogLevel : Int {
        case Debug = 0
        case Info = 1
        case Warning = 2
        case Error = 3
    }
    
    fileprivate static var _logLevel: LogLevel = .Info
    fileprivate static var unknownElements: Dictionary<String, Any>? = nil
    
    public class var logLevel: LogLevel {
        get {
            return _logLevel
        }
        set {
            _logLevel = newValue
        }
    }
    public internal(set) var elementTypeName: String? = nil
    
    required public init() {
        self.elementTypeName = String(describing: type(of: self))
    }
    
    required public convenience init(_ dictionary: Dictionary<String, Any>) {
        self.init()
        
        self.parseDictionary(dictionary)
    }
    
    public func parseDictionary(_ dictionary: Dictionary<String, Any>) {
        fatalError("Not implemented")
    }
    
    public class func log(_ message: String, logLevel level: LogLevel) {
        if level.rawValue >= GIRBase.logLevel.rawValue {
             print("[\(String(reflecting:level).split(separator: ".").last!)] \(message)")
        }
    }
    
    public func logUnknownElement(_ element: String) {
        if GIRBase.unknownElements == nil {
            GIRBase.unknownElements = Dictionary()
        }
        
        let hopefullyUniqueKey = "\(self.elementTypeName!)--\(element)"
        
        if GIRBase.unknownElements![hopefullyUniqueKey] != nil {
            GIRBase.unknownElements![hopefullyUniqueKey] = hopefullyUniqueKey
        } else {
            GIRBase.log("[\(self.elementTypeName!)]: Found unknown element: [\(element)]", logLevel: .Warning)
            GIRBase.unknownElements![hopefullyUniqueKey] = hopefullyUniqueKey
        }
    }
    
    public func processArrayOrDictionary<T>(_ value: Any, clazz: T.Type, andArray array: inout Array<T>) where T: GIRParseDictionary {
        
        if let arrayValue = value as? Array<Dictionary<String, Any>> {
            self.processArrayOrDictionary(arrayValue, clazz: clazz, andArray: &array)
        } else {
            self.processArrayOrDictionary((value as! Dictionary<String, Any>), clazz: clazz, andArray: &array)
        }
    }
    
    public func processArrayOrDictionary<T>(_ value: Dictionary<String, Any>, clazz: T.Type, andArray array: inout Array<T>) where T: GIRParseDictionary {
        
        let obj = clazz.init()
        
        obj.parseDictionary(value)
        
        array.append(obj)
    }
    
    public func processArrayOrDictionary<T>(_ value: Array<Dictionary<String, Any>>, clazz: T.Type, andArray array: inout Array<T>) where T: GIRParseDictionary {
        
        for obj in value {
            self.processArrayOrDictionary(obj, clazz: clazz, andArray: &array)
        }
    }
}
