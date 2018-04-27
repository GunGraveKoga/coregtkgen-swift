//
//  CGTKApplication.swift
//  test
//
//  Created by Yury Vovk on 27.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation
@_exported import CGtk

public enum CGTK {
    public static func initialize() {
        var _argc = CommandLine.argc
        var _argv = CommandLine.unsafeArgv
        let argc = UnsafeMutablePointer(&_argc)
        let argv = UnsafeMutableRawPointer(&_argv)
        
        gtk_init(argc, argv.assumingMemoryBound(to:UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?.self))
    }
    
    public static func main() {
        gtk_main()
    }
    
    public static func mainQuit() {
        gtk_main_quit()
    }
}
