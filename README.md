<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/claude_eiffel_op_docs/main/artwork/LOGO.png" alt="simple_ library logo" width="400">
</p>

# SIMPLE_CLIPBOARD

**[Documentation](https://simple-eiffel.github.io/simple_clipboard/)**

### Windows Clipboard Access Library for Eiffel

[![Language](https://img.shields.io/badge/language-Eiffel-blue.svg)](https://www.eiffel.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows-blue.svg)]()
[![SCOOP](https://img.shields.io/badge/SCOOP-compatible-orange.svg)]()
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()

---

## Overview

SIMPLE_CLIPBOARD provides SCOOP-compatible clipboard access for Eiffel applications. It wraps the Win32 Clipboard API through a clean C interface, enabling copy/paste operations without threading complications.

The library supports reading and writing text to the clipboard, checking clipboard status, and clearing clipboard contents.

**Developed using AI-assisted methodology:** Built interactively with Claude Opus 4.5 following rigorous Design by Contract principles.

---

## Features

### Clipboard Operations

- **Get Text** - Read text content from clipboard
- **Set Text** - Write text content to clipboard
- **Clear** - Remove all clipboard contents
- **Status Queries** - Check if clipboard has text, is empty, or get format count

---

## Quick Start

### Installation

1. Clone the repository:
```bash
git clone https://github.com/simple-eiffel/simple_clipboard.git
```

2. Compile the C library:
```bash
cd simple_clipboard/Clib
compile.bat
```

3. Set the environment variable:
```bash
set SIMPLE_CLIPBOARD=D:\path\to\simple_clipboard
```

4. Add to your ECF file:
```xml
<library name="simple_clipboard" location="$SIMPLE_CLIPBOARD\simple_clipboard.ecf"/>
```

### Basic Usage

```eiffel
class
    MY_APPLICATION

feature

    clipboard_example
        local
            cb: SIMPLE_CLIPBOARD
        do
            create cb

            -- Copy text to clipboard
            cb.set_text ("Hello, World!")

            if cb.last_operation_succeeded then
                print ("Text copied to clipboard%N")
            end

            -- Paste text from clipboard
            if attached cb.text as t then
                print ("Clipboard contains: " + t + "%N")
            end

            -- Check clipboard status
            if cb.has_text then
                print ("Clipboard has text%N")
            end

            -- Clear clipboard
            cb.clear
        end

end
```

---

## API Reference

### SIMPLE_CLIPBOARD Class

#### Access

```eiffel
text: detachable STRING_32
    -- Get text from clipboard.
    -- Returns Void if no text available.

paste: detachable STRING_32
    -- Alias for `text'.
```

#### Status Report

```eiffel
has_text: BOOLEAN
    -- Does clipboard contain text?

is_empty: BOOLEAN
    -- Is clipboard empty (no data in any format)?

format_count: INTEGER
    -- Number of different formats available on clipboard.

last_operation_succeeded: BOOLEAN
    -- Did the last operation succeed?
```

#### Modification

```eiffel
set_text (a_text: READABLE_STRING_GENERAL)
    -- Put `a_text' on clipboard.

copy_text (a_text: READABLE_STRING_GENERAL)
    -- Alias for `set_text'.

clear
    -- Clear all clipboard contents.
```

---

## Building & Testing

### Build Library

```bash
cd simple_clipboard
ec -config simple_clipboard.ecf -target simple_clipboard -c_compile
```

### Run Tests

```bash
ec -config simple_clipboard.ecf -target simple_clipboard_tests -c_compile
./EIFGENs/simple_clipboard_tests/W_code/simple_clipboard.exe
```

---

## Project Structure

```
simple_clipboard/
├── Clib/                       # C wrapper library
│   ├── simple_clipboard.h      # C header file
│   ├── simple_clipboard.c      # C implementation
│   └── compile.bat             # Build script
├── src/                        # Eiffel source
│   └── simple_clipboard.e      # Main wrapper class
├── testing/                    # Test suite
│   ├── application.e           # Test runner
│   └── test_simple_clipboard.e # Test cases
├── simple_clipboard.ecf        # Library configuration
├── README.md                   # This file
└── LICENSE                     # MIT License
```

---

## Dependencies

- **Windows OS** - Clipboard API is Windows-specific
- **EiffelStudio 23.09+** - Development environment
- **Visual Studio C++ Build Tools** - For compiling C wrapper

---

## SCOOP Compatibility

SIMPLE_CLIPBOARD is fully SCOOP-compatible. The C wrapper handles all Win32 API calls synchronously without threading dependencies, making it safe for use in concurrent Eiffel applications.

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

## Contact

- **Author:** Larry Rix
- **Repository:** https://github.com/simple-eiffel/simple_clipboard
- **Issues:** https://github.com/simple-eiffel/simple_clipboard/issues

---

## Acknowledgments

- Built with Claude Opus 4.5 (Anthropic)
- Uses Win32 Clipboard API (Microsoft)
- Part of the simple_ library collection for Eiffel
