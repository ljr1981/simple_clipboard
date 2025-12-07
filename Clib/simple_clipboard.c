/*
 * simple_clipboard.c - Clipboard access for Eiffel
 * Copyright (c) 2025 Larry Rix - MIT License
 */

#include "simple_clipboard.h"
#include <stdlib.h>
#include <string.h>

char* scb_get_text(void) {
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
            break;  /* Success (even if no text found) */
        }
        retries--;
        if (retries > 0) Sleep(10);
    }

    return result;
}

int scb_set_text(const char* text) {
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

int scb_clear(void) {
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
        if (retries > 0) Sleep(10);  /* Small delay before retry */
    }

    return success;
}

int scb_has_text(void) {
    return IsClipboardFormatAvailable(CF_TEXT) ? 1 : 0;
}

int scb_is_empty(void) {
    int count;

    if (!OpenClipboard(NULL)) {
        return 1;  /* Assume empty if can't open */
    }

    count = CountClipboardFormats();
    CloseClipboard();

    return (count == 0) ? 1 : 0;
}

int scb_format_count(void) {
    int count;

    if (!OpenClipboard(NULL)) {
        return 0;
    }

    count = CountClipboardFormats();
    CloseClipboard();

    return count;
}
