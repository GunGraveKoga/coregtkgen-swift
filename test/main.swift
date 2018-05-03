//
//  main.swift
//  test
//
//  Created by Yury Vovk on 26.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation
import CGtk

func standartExample() {
    let window = CGTKWindow.init(type: GTK_WINDOW_TOPLEVEL)
    
    CGTKSignalConnector.connect(gpointer: window.WIDGET, signal: "destroy") { widget in
        print("Goodbye!")
        CGTK.mainQuit()
    }
    
    window.setBorderWidth(10)
    window.setTitle("Now supporting GTK+ 3.22!")
    window.setDefaultSize(width: 400, height: 300)
    
    let button = CGTKButton(withLabel: "Hello world!")
    
    CGTKSignalConnector.connect(gpointer: button.WIDGET, signal: "clicked") { widget in
        print("Hello world")
    }
    
    window.add(widget: button)
    
    button.show()
    window.show()
    
    CGTK.main()
}

func gladeExample() {
    let builder = CGTKBuilder()
    var dict: [String: CGTKSignalHandler] = ["endGtkLoop": {widget in CGTK.mainQuit()},
                                             "on_button1_clicked": {widget in print("Hello world")},
                                             "on_button2_clicked": {widget in print("Goodbye!")}]
    
    if builder.addFromFile(filename: "gladeExample.glade", err: nil) == 0 {
        print("Error loading GUI file")
        
        return
    }
    
    CGTKBaseBuilder.connectSignals(&dict, withBuilder: builder)
    
    let window: CGTKWindow? = CGTKBaseBuilder.getWidget(withName: "window1", fromBuilder: builder)
    
    if let window = window {
        window.showAll()
        
        CGTK.main()
    } else {
        print("Failed to get window widget from glade file!")
    }
}

CGTK.initialize()

standartExample()

gladeExample()

