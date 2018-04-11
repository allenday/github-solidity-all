// An aesthetic of opposites.
// Good and bad, bless and blast, foreground and background,
// positive and negative, etc.

contract BivalentAesthetic {

    // Two colours
    // Each is CIELAB, components are l, a, b

    int8 color[2][3];

    // Two words, strings, or emoji(s)

    string word[2];

    // Two 16x16 monochrome bitmaps, e.g. foreground and background

    int256 bitmaps[2];

    // Two shapes encoded as SVG paths
    // BUT with values encoded as bytes (for maximum 0..256 or -127..+128)
    // AND with no whitespace separators

    string shapes[2];
}
