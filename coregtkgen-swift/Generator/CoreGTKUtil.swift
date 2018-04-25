//
//  CoreGTKUtil.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 25.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

fileprivate var trimMethodNames = [String]()

public enum CoreGTKUtil {
    
    public static func convertUSSToCamelCase(_ string: String) -> String {
        let output = self.convertUSSToCapCase(string)
        
        var result: String
        
        if output.count > 0 {
            let index = output.index(after: output.startIndex)
            result = output[..<index].uppercased() + output[index...]
        } else {
            result = output.lowercased()
        }
        
        return result
    }
    
    public static func convertUSSToCapCase(_ string: String) -> String {
        
    }
    
    public static func isTypeSwappable(_ type: String) -> Bool {
        
    }
    
    public static func swapTypes(_ type: String) -> String {
        
    }
    
    public static func convertFunctionToInit(_ function: String) -> String {
        
    }
    
    public static func getFunctionCallForConstructor(of type: String, with constructor: String) -> String {
        
    }
    
    public static func convertType(from fromType: String, to toType: String, withName name: String) -> String {
        
    }
    
    public static func selfTypeMethodCall(_ type: String) -> String {
        
    }
    
    public static func addToTrimMethodName(_ value: String) {
        if !trimMethodNames.contains(value) {
            trimMethodNames.append(value)
        }
    }
    
    public static func trimMethodName(_ method: String) -> String {
        
    }
    
    public static func extraImports(of clazz: String) -> [String] {
        
    }
    
    public static func extraMethods(of clazz: String) -> [String: Any] {
        
    }
    
    public static func globalConfigValue(forKey key: String) -> Any {
        
    }
}
