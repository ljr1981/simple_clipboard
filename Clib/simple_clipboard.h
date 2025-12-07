/*
 * simple_clipboard.h - Clipboard access for Eiffel
 * Copyright (c) 2025 Larry Rix - MIT License
 */

#ifndef SIMPLE_CLIPBOARD_H
#define SIMPLE_CLIPBOARD_H

#include <windows.h>

/* Get text from clipboard. Caller must free result. Returns NULL if no text. */
char* scb_get_text(void);

/* Set text to clipboard. Returns 1 on success, 0 on failure. */
int scb_set_text(const char* text);

/* Clear clipboard. Returns 1 on success, 0 on failure. */
int scb_clear(void);

/* Check if clipboard has text. Returns 1 if yes, 0 if no. */
int scb_has_text(void);

/* Check if clipboard is empty. Returns 1 if empty, 0 if not. */
int scb_is_empty(void);

/* Get clipboard format count (number of available formats). */
int scb_format_count(void);

#endif /* SIMPLE_CLIPBOARD_H */
