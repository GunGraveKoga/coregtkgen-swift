//
//  main.swift
//  coregtkgen-swift
//
//  Created by Yury Vovk on 23.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation

let path = CommandLine.arguments[1]

do {
    let aip = try Gir2Swift.firsApiFrom(girFile: path)
    
    if let api = aip {
        _ = Gir2Swift.generateClassFileFromApi(api)
    } else {
        print("Failed to parse gir file \(path)")
    }
} catch let error {
    print("\(error)")
}
