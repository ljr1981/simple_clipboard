/*
 * simple_clipboard.h - Windows Clipboard helper functions for Eiffel
 * 
 * This header provides a C interface to Windows Clipboard operations,
 * designed to be called from Eiffel via inline C externals.
 * 
 * Following Eric Bezault's recommended pattern: implementations in .h file,
 * called from Eiffel inline C with use directive.
 */

#ifndef SIMPLE_CLIPBOARD_H
#define SIMPLE_CLIPBOARD_H

#include <windows.h>
#include <stdlib.h>
#include <string.h>

/* Get text from clipboard. Caller must free result with free(). */
static char* scb_get_text(void) {
    HANDLE hData;
    char* pData;
    char* result = NULL;
    size_t len;
    int retries = 3;
    
    while (retries > 0) {
        if (OpenClipboard(NULL)) {
            hData = GetClipboardData(CF_TEXT);
            if (hData != NULL) {
                pData = (char*)GlobalLock(hData);
                if (pData != NULL) {
                    len = strlen(pData);
                    result = (char*)malloc(len + 1);
                    if (result) {
                        strcpy(result, pData);
                    }
                    GlobalUnlock(hData);
                }
            }
            CloseClipboard();
            break;
        }
        retries--;
        if (retries > 0) Sleep(10);
    }
    return result;
}

/* Set clipboard text. Returns 1 on success, 0 on failure. */
static int scb_set_text(const char* text) {
    HGLOBAL hMem;
    char* pMem;
    size_t len;
    int success = 0;
    int retries = 3;
    
    if (!text) return 0;
    
    len = strlen(text) + 1;
    
    while (retries > 0 && !success) {
        hMem = GlobalAlloc(GMEM_MOVEABLE, len);
        if (!hMem) return 0;
        
        pMem = (char*)GlobalLock(hMem);
        if (!pMem) {
            GlobalFree(hMem);
            return 0;
        }
        
        memcpy(pMem, text, len);
        GlobalUnlock(hMem);
        
        if (OpenClipboard(NULL)) {
            EmptyClipboard();
            if (SetClipboardData(CF_TEXT, hMem) != NULL) {
                success = 1;
            } else {
                GlobalFree(hMem);
            }
            CloseClipboard();
            if (success) break;
        } else {
            GlobalFree(hMem);
        }
        
        retries--;
        if (retries > 0) Sleep(10);
    }
    return success;
}

/* Clear clipboard. Returns 1 on success, 0 on failure. */
static int scb_clear(void) {
    int retries = 3;
    int success = 0;
    
    while (retries > 0 && !success) {
        if (OpenClipboard(NULL)) {
            if (EmptyClipboard()) {
                success = 1;
            }
            CloseClipboard();
            if (success) break;
        }
        retries--;
        if (retries > 0) Sleep(10);
    }
    return success;
}

/* Check if clipboard has text. Returns 1 if true, 0 if false. */
static int scb_has_text(void) {
    return IsClipboardFormatAvailable(CF_TEXT) ? 1 : 0;
}

/* Check if clipboard is empty. Returns 1 if empty, 0 if not. */
static int scb_is_empty(void) {
    int count;
    if (!OpenClipboard(NULL)) return 1;
    count = CountClipboardFormats();
    CloseClipboard();
    return (count == 0) ? 1 : 0;
}

/* Get number of clipboard formats available. */
static int scb_format_count(void) {
    int count;
    if (!OpenClipboard(NULL)) return 0;
    count = CountClipboardFormats();
    CloseClipboard();
    return count;
}

#endif /* SIMPLE_CLIPBOARD_H */
