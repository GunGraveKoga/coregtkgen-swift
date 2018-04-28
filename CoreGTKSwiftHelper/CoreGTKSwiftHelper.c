//
//  CoreGTKSwiftHelper.c
//  CoreGTKSwiftHelper
//
//  Created by Yury Vovk on 28.04.2018.
//  Copyright © 2018 gungravekoga. All rights reserved.
//

#include "CoreGTKSwiftHelper.h"
#include <Block.h>

#ifndef _BLOCK_PRIVATE_H_
struct Block_layout {
    void *isa;
    volatile int32_t flags;
    int32_t reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 *descriptor;
};
#endif

static void __call_block(gpointer gtk, struct Block_layout *block_ptr) {
    block_ptr->invoke(block_ptr, gtk);
}

static void __destroy_block(void *block_ptr, GClosure *closure) {
    Block_release(block_ptr);
}

glong swift_g_signal_connect(gpointer instance, const gchar *detailed_signal, void(^callback)(gpointer, void*)) {
    
    struct Block_layout *block_ptr = (__typeof__(block_ptr))(void *)Block_copy(callback);
    
    return g_signal_connect_data(instance, detailed_signal, &__call_block, block_ptr, &__destroy_block, 0);
}

struct __swift_callback_ctx {
    void (*execute)(gpointer, void*);
    void (*destroy)(void*);
    void *ctx;
};

static void __call_swift_callback(gpointer gtk, struct __swift_callback_ctx *ctx) {
    ctx->execute(gtk, ctx->ctx);
}

static void __destroy_swift_callback_ctx(struct __swift_callback_ctx *ctx, GClosure *closure) {
    
    void *swift_ctx = ctx->ctx;
    ctx->ctx = NULL;
    ctx->execute = NULL;
    ctx->destroy(swift_ctx);
    ctx->destroy = NULL;
    swift_ctx = NULL;
    
    free(ctx);
}

glong swift_g_signal_connect_f(gpointer instance, const gchar *detailed_signal, void (*callback)(gpointer, void*), void *ctx, void (*destroy_callback)(void*)) {
    
    struct __swift_callback_ctx *_ctx = (__typeof__(_ctx))calloc(1, sizeof(struct __swift_callback_ctx));
    
    memset(ctx, 0, sizeof(struct __swift_callback_ctx));
    
    _ctx->ctx = ctx;
    _ctx->execute = callback;
    _ctx->destroy = destroy_callback;
    
    return g_signal_connect_data(instance, detailed_signal, &__call_swift_callback, _ctx, &__destroy_swift_callback_ctx, 0);
}

GtkWidget *swift_gtk_file_chooser_dialog_new(const gchar *title, GtkWindow *parent, GtkFileChooserAction action) {
    
    return gtk_file_chooser_dialog_new(title, parent, action, NULL, NULL);
}

GtkWidget *swift_gtk_message_dialog_new_with_markup(GtkWindow *parent, GtkDialogFlags flags, GtkMessageType type, GtkButtonsType buttons, const gchar *markup) {
    return gtk_message_dialog_new_with_markup(parent, flags, type, buttons, markup, NULL);
}

GtkWidget *swift_gtk_message_dialog_new(GtkWindow *parent, GtkDialogFlags flags, GtkMessageType type, GtkButtonsType buttons, const gchar *message) {
    return gtk_message_dialog_new(parent, flags, type, buttons, message, NULL);
}

void swift_gtk_message_dialog_format_secondary_markup(GtkMessageDialog *message_dialog, const gchar *message) {
    gtk_message_dialog_format_secondary_markup(message_dialog, message, NULL);
}

void swift_gtk_message_dialog_format_secondary_text(GtkMessageDialog *message_dialog, const gchar *text) {
    gtk_message_dialog_format_secondary_text(message_dialog, text);
}

GtkWidget *swift_gtk_dialog_new_with_buttons(const gchar *title, GtkWindow *parent, GtkDialogFlags flags) {
    return gtk_dialog_new_with_buttons(title, parent, flags, NULL, NULL);
}

GtkWidget *swift_gtk_recent_chooser_dialog_new(const gchar *title, GtkWindow *parent) {
    return gtk_recent_chooser_dialog_new(title, parent, NULL, NULL);
}

GtkWidget *swift_gtk_recent_chooser_dialog_new_for_manager(const gchar *title, GtkWindow *parent, GtkRecentManager *manager) {
    return gtk_recent_chooser_dialog_new_for_manager(title, parent, manager, NULL, NULL);
}
