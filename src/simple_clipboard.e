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

feature {NONE} -- C externals (using simple_clipboard.h)

	c_scb_get_text: POINTER
			-- Get text from clipboard. Caller must free result.
		external
			"C inline use %"simple_clipboard.h%""
		alias
			"return scb_get_text();"
		end

	c_scb_set_text (a_text: POINTER): INTEGER
			-- Set clipboard text. Returns 1 on success.
		external
			"C inline use %"simple_clipboard.h%""
		alias
			"return scb_set_text((const char*)$a_text);"
		end

	c_scb_clear: INTEGER
			-- Clear clipboard. Returns 1 on success.
		external
			"C inline use %"simple_clipboard.h%""
		alias
			"return scb_clear();"
		end

	c_scb_has_text: INTEGER
			-- Check if clipboard has text. Returns 1 if true.
		external
			"C inline use %"simple_clipboard.h%""
		alias
			"return scb_has_text();"
		end

	c_scb_is_empty: INTEGER
			-- Check if clipboard is empty. Returns 1 if true.
		external
			"C inline use %"simple_clipboard.h%""
		alias
			"return scb_is_empty();"
		end

	c_scb_format_count: INTEGER
			-- Get number of clipboard formats available.
		external
			"C inline use %"simple_clipboard.h%""
		alias
			"return scb_format_count();"
		end

	c_free (a_ptr: POINTER)
			-- Free allocated memory.
		external
			"C inline use <stdlib.h>"
		alias
			"free($a_ptr);"
		end

end
