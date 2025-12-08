note
	description: "[
		SCOOP-compatible clipboard access.
		Provides text clipboard operations via inline Win32 API.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_CLIPBOARD

feature -- Access

	text: detachable STRING_32
			-- Get text from clipboard.
			-- Returns Void if no text available.
		local
			l_result: POINTER
		do
			l_result := c_scb_get_text
			if l_result /= default_pointer then
				Result := pointer_to_string (l_result)
				c_free (l_result)
			end
		end

feature -- Status Report

	has_text: BOOLEAN
			-- Does clipboard contain text?
		do
			Result := c_scb_has_text /= 0
		end

	is_empty: BOOLEAN
			-- Is clipboard empty (no data in any format)?
		do
			Result := c_scb_is_empty /= 0
		end

	format_count: INTEGER
			-- Number of different formats available on clipboard.
		do
			Result := c_scb_format_count
		end

feature -- Modification

	set_text (a_text: READABLE_STRING_GENERAL)
			-- Put `a_text' on clipboard.
		require
			text_not_void: a_text /= Void
		local
			l_text: C_STRING
		do
			create l_text.make (a_text.to_string_8)
			last_operation_succeeded := c_scb_set_text (l_text.item) /= 0
		ensure
			text_set: last_operation_succeeded implies has_text
		end

	clear
			-- Clear all clipboard contents.
		do
			last_operation_succeeded := c_scb_clear /= 0
		ensure
			cleared: last_operation_succeeded implies is_empty
		end

	copy_text (a_text: READABLE_STRING_GENERAL)
			-- Copy `a_text' to clipboard (alias for set_text).
		require
			text_not_void: a_text /= Void
		do
			set_text (a_text)
		end

	paste: detachable STRING_32
			-- Paste text from clipboard (alias for text).
		do
			Result := text
		end

feature -- Status

	last_operation_succeeded: BOOLEAN
			-- Did the last operation succeed?

feature {NONE} -- Implementation

	pointer_to_string (a_ptr: POINTER): STRING_32
			-- Convert C string pointer to STRING_32.
		local
			l_c_string: C_STRING
		do
			create l_c_string.make_by_pointer (a_ptr)
			Result := l_c_string.string.to_string_32
		end

feature {NONE} -- C externals (inline)

	c_scb_get_text: POINTER
			-- Get text from clipboard. Caller must free result.
		external
			"C inline use <windows.h>, <stdlib.h>, <string.h>"
		alias
			"[
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
			]"
		end

	c_scb_set_text (a_text: POINTER): INTEGER
			-- Set clipboard text. Returns 1 on success.
		external
			"C inline use <windows.h>, <stdlib.h>, <string.h>"
		alias
			"[
				HGLOBAL hMem;
				char* pMem;
				size_t len;
				int success = 0;
				int retries = 3;
				
				if (!$a_text) return 0;
				
				len = strlen((const char*)$a_text) + 1;
				
				while (retries > 0 && !success) {
					hMem = GlobalAlloc(GMEM_MOVEABLE, len);
					if (!hMem) return 0;
					
					pMem = (char*)GlobalLock(hMem);
					if (!pMem) {
						GlobalFree(hMem);
						return 0;
					}
					
					memcpy(pMem, (const char*)$a_text, len);
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
			]"
		end

	c_scb_clear: INTEGER
			-- Clear clipboard. Returns 1 on success.
		external
			"C inline use <windows.h>"
		alias
			"[
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
			]"
		end

	c_scb_has_text: INTEGER
			-- Check if clipboard has text. Returns 1 if true.
		external
			"C inline use <windows.h>"
		alias
			"return IsClipboardFormatAvailable(CF_TEXT) ? 1 : 0;"
		end

	c_scb_is_empty: INTEGER
			-- Check if clipboard is empty. Returns 1 if true.
		external
			"C inline use <windows.h>"
		alias
			"[
				int count;
				if (!OpenClipboard(NULL)) return 1;
				count = CountClipboardFormats();
				CloseClipboard();
				return (count == 0) ? 1 : 0;
			]"
		end

	c_scb_format_count: INTEGER
			-- Get number of clipboard formats available.
		external
			"C inline use <windows.h>"
		alias
			"[
				int count;
				if (!OpenClipboard(NULL)) return 0;
				count = CountClipboardFormats();
				CloseClipboard();
				return count;
			]"
		end

	c_free (a_ptr: POINTER)
			-- Free allocated memory.
		external
			"C inline use <stdlib.h>"
		alias
			"free($a_ptr);"
		end

end
