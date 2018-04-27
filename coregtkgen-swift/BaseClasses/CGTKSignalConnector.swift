//
//  CGTKSignalConnector.swift
//  test
//
//  Created by Yury Vovk on 27.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation
@_exported import CGtk

public enum CGTKSignalConnector {
    public static func connect(gpointer: UnsafeMutableRawPointer, signal: String, data: UnsafeMutableRawPointer!, body: @escaping @convention(c) () -> Swift.Void)  {
        
        g_signal_connect_data(gpointer, signal, body, data, nil, GConnectFlags(rawValue: 0))
    }
}
