//
//  XMLReader.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 25.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

fileprivate let kXMLReaderTextNodeKey: String = "text"

public class XMLReader : NSObject, XMLParserDelegate {
    public private(set) var dictionaryStack: [Dictionary<String, Any>]? = nil
    public private(set) var textInProgress: String?  = nil
    public private(set) var error: Error? = nil
    
    public class func dictionaryFromXML(data: Data, parserError error: inout Error?) -> Dictionary<String, Any>? {
        let reader = XMLReader()
        
        let rootDictionary = reader.objectWithData(data)
        
        error = reader.error
        
        return rootDictionary
    }
    
    public class func dictionaryFromXML(string: String, parserError error: inout Error?) -> Dictionary<String, Any>? {
        let data = string.data(using: .utf8)
        
        return self.dictionaryFromXML(data: data!, parserError: &error)
    }
    
    fileprivate func objectWithData(_ data: Data) -> Dictionary<String, Any>? {
        self.dictionaryStack = [Dictionary<String, Any>]()
        self.textInProgress = ""
        
        self.dictionaryStack!.append([String: Any]())
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        guard parser.parse() else {
            return nil
        }
        
        return self.dictionaryStack![0]
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        var dictInProgress = [String: Any]()
        
        dictInProgress.merge(attributeDict, uniquingKeysWith: {(_, last) in last})
        
        self.dictionaryStack!.append(dictInProgress)
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        var dictInProgress = self.dictionaryStack!.last!
        self.dictionaryStack!.removeLast()
        let index = self.dictionaryStack!.count - 1
        
        if self.textInProgress!.count > 0 {
            dictInProgress[kXMLReaderTextNodeKey] = self.textInProgress!
            self.textInProgress = ""
        }
        
        if let lastValue = self.dictionaryStack![index][elementName] {
            var array: [Dictionary<String, Any>]
            if lastValue is [Dictionary<String, Any>] {
                array = lastValue as! [Dictionary<String, Any>]
            } else {
                array = [Dictionary<String, Any>]()
                array.append(lastValue as! Dictionary<String, Any>)
            }
            
            array.append(dictInProgress)
            
            self.dictionaryStack![index][elementName] = array
            
        } else {
            self.dictionaryStack![index][elementName] = dictInProgress
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.textInProgress! += string
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.error = parseError
    }
}
