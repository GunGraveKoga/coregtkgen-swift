//
//  main.swift
//  test
//
//  Created by Yury Vovk on 26.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

import Foundation
import CGtk

CGTK.initialize()
let window = CGTKWindow.init(type: GTK_WINDOW_TOPLEVEL)

CGTKSignalConnector.connect(gpointer: window.WIDGET, signal: "destroy", data: nil) {
    print("Goodbay!")
    CGTK.mainQuit()
}

window.setBorderWidth(10)
window.setTitle("Now supporting GTK+ 3.22!")
window.setDefaultSize(width: 400, height: 300)

let button = CGTKButton(withLabel: "Hello world!")

CGTKSignalConnector.connect(gpointer: button.WIDGET, signal: "clicked", data: nil) {
    print("Hello world #\(number)")
}

window.add(widget: button)

button.show()
window.show()

CGTK.main()
