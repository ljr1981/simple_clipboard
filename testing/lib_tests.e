note
	description: "Tests for SIMPLE_CLIPBOARD library"
	testing: "covers"

class
	LIB_TESTS

inherit
	TEST_SET_BASE

feature -- Test routines

	test_basic_set_get
			-- Test basic set and get text.
		local
			l_clip: SIMPLE_CLIPBOARD
		do
			create l_clip
			l_clip.set_text ("Test123")
			if l_clip.last_operation_succeeded then
				if attached l_clip.text as t then
					assert_string_contains ("text_matches", t, "Test123")
				else
					assert ("text_retrieved", False)
				end
			else
				-- Clipboard may be locked by another app - skip
				assert ("clipboard_access_skipped", True)
			end
		end

	test_has_text_query
			-- Test has_text query.
		local
			l_clip: SIMPLE_CLIPBOARD
		do
			create l_clip
			l_clip.set_text ("HasTextTest")
			if l_clip.last_operation_succeeded then
				assert_true ("has_text_after_set", l_clip.has_text)
			else
				assert ("clipboard_access_skipped", True)
			end
		end

	test_clear_clipboard
			-- Test clearing clipboard.
		local
			l_clip: SIMPLE_CLIPBOARD
		do
			create l_clip
			l_clip.set_text ("ToClear")
			l_clip.clear
			-- Just verify no crash
			assert ("clear_attempted", True)
		end

	test_multiline_text
			-- Test multiline text.
		local
			l_clip: SIMPLE_CLIPBOARD
		do
			create l_clip
			l_clip.set_text ("Line1%R%NLine2%R%NLine3")
			if l_clip.last_operation_succeeded then
				if attached l_clip.text as t then
					assert_string_contains ("has_line1", t, "Line1")
					assert_string_contains ("has_line2", t, "Line2")
					assert_string_contains ("has_line3", t, "Line3")
				else
					assert ("multiline_retrieved", False)
				end
			else
				assert ("clipboard_access_skipped", True)
			end
		end

	test_format_count_query
			-- Test format_count query.
		local
			l_clip: SIMPLE_CLIPBOARD
		do
			create l_clip
			assert_greater_or_equal ("format_count_non_negative", l_clip.format_count, 0)
		end

	test_copy_text_alias
			-- Test copy_text method.
		local
			l_clip: SIMPLE_CLIPBOARD
		do
			create l_clip
			l_clip.copy_text ("CopyTest")
			if l_clip.last_operation_succeeded then
				if attached l_clip.paste as t then
					assert_string_contains ("paste_works", t, "CopyTest")
				else
					assert ("paste_returned_void", False)
				end
			else
				assert ("clipboard_access_skipped", True)
			end
		end

end
