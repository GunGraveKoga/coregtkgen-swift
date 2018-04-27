//
//  main.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 23.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation
import CGtk

let path = CommandLine.arguments[1]

do {
    let aip = try Gir2Swift.firsApiFrom(girFile: path)
    print(aip!.elementTypeName!)
    
    print("parsed")
    
    if let api = aip {
        _ = Gir2Swift.generateClassFileFromApi(api)
    } else {
        print("nil")
    }
} catch let error {
    print("\(error)")
}
