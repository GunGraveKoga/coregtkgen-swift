//
//  CoreGTKSwiftHelper.h
//  CoreGTKSwiftHelper
//
//  Created by Yury Vovk on 28.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

#ifndef CoreGTKSwiftHelper_h
#define CoreGTKSwiftHelper_h

#include <gtk/gtk.h>

extern glong swift_g_signal_connect(gpointer instance, const gchar *detailed_signal, void(^callback)(gpointer, void*));

extern glong swift_g_signal_connect_f(gpointer instance, const gchar *detailed_signal, void (*callback)(gpointer, void*), void *ctx, void (*destroy_callback)(void*));

extern GtkWidget *swift_gtk_file_chooser_dialog_new(const gchar *title, GtkWindow *parent, GtkFileChooserAction action);

extern GtkWidget *swift_gtk_message_dialog_new_with_markup(GtkWindow *parent, GtkDialogFlags flags, GtkMessageType type, GtkButtonsType buttons, const gchar *markup);

extern GtkWidget *swift_gtk_message_dialog_new(GtkWindow *parent, GtkDialogFlags flags, GtkMessageType type, GtkButtonsType buttons, const gchar *message);

extern void swift_gtk_message_dialog_format_secondary_markup(GtkMessageDialog *message_dialog, const gchar *message);

extern void swift_gtk_message_dialog_format_secondary_text(GtkMessageDialog *message_dialog, const gchar *text);

extern GtkWidget *swift_gtk_dialog_new_with_buttons(const gchar *title, GtkWindow *parent, GtkDialogFlags flags);

extern GtkWidget *swift_gtk_recent_chooser_dialog_new(const gchar *title, GtkWindow *parent);

extern GtkWidget *swift_gtk_recent_chooser_dialog_new_for_manager(const gchar *title, GtkWindow *parent, GtkRecentManager *manager);

#endif /* CoreGTKSwiftHelper_h */
