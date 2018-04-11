// An aesthetic of single values.
// Everything else is irrelevant

contract UnivalentAesthetic {

    // CIELAB, components are l, a, b
    int8 color[3];

    // Word, string, or emoji(s). utf-8
    string word;

    // 16x16 monochrome bitmap
    int256 bitmap;

    // Shape encoded as SVG paths
    // BUT with values encoded as bytes (for maximum 0..256 or -127..+128)
    // AND with no whitespace separators
    int8 shape[256];

}
