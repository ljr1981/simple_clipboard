# SIMPLE_CLIPBOARD

SCOOP-compatible clipboard access for Windows applications using inline Win32 API.

## Features

- Get and set text from Windows clipboard
- Check if clipboard contains text
- Clear clipboard contents
- Check clipboard format availability
- Thread-safe (SCOOP-compatible)

## Installation

Add to your ECF file:

```xml
<library name="simple_clipboard" location="$SIMPLE_CLIPBOARD/simple_clipboard.ecf"/>
```

Set the environment variable:
```
SIMPLE_CLIPBOARD=/path/to/simple_clipboard
```

## Quick Start

```eiffel
local
    cb: SIMPLE_CLIPBOARD
do
    create cb

    -- Copy text to clipboard
    cb.set_text ("Hello, World!")

    -- Paste text from clipboard
    if attached cb.text as t then
        print (t)
    end

    -- Check if clipboard has text
    if cb.has_text then
        print ("Clipboard contains text%N")
    end

    -- Clear clipboard
    cb.clear
end
```

## API Overview

### SIMPLE_CLIPBOARD

| Feature | Description |
|---------|-------------|
| `text` | Get text from clipboard (Void if empty) |
| `set_text (str)` | Set clipboard text |
| `has_text` | Check if clipboard has text |
| `is_empty` | Check if clipboard is empty |
| `clear` | Clear clipboard contents |
| `copy_text (str)` | Alias for set_text |
| `paste` | Alias for text |
| `format_count` | Number of formats on clipboard |

## Documentation

- [API Documentation](https://simple-eiffel.github.io/simple_clipboard/)

## Platform Support

- Windows only (uses Win32 API)

## License

MIT License - see LICENSE file for details.

## Author

Larry Rix
