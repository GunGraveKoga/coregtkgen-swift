//
//  shim.h
//  SwiftGtk
//
//  Created by Yury Vovk on 30.03.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

#ifdef __linux__
#include <termios.h>
#include <sys/types.h>
#endif
#include <gtk/gtk.h>
#include "CoreGTKSwiftHelper.h"
