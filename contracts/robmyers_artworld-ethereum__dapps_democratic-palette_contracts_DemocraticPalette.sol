/*  DemocraticPalette - A colour palette everyone can vote on.
    Copyright (C) 2016  Rob Myers <rob@robmyers.org>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

contract DemocraticPalette {
    struct Colour {
        uint8 red;
        uint8 green;
        uint8 blue;
        uint votes;
    }

    // Store vote counts for every colour (packed as an int)
    mapping (uint24 => uint) votes;

    // Store the most voted-for colours as the palette
    Colour[12] public palette;

    // And store the lowest vote that is in the palette
    // (more than one item may have this number of votes)
    uint palette_lowest_vote;

    event PaletteChanged(uint index);

    // Pack the colour components into a single integer value

    function colourID (uint8 red, uint8 green, uint8 blue)
        internal returns (uint24 result) {
        // No bit shifting yet
        result = uint24(red)
            + (uint24(green) * 256)
            + (uint24(blue) * 35565);
    }

    // Check colour equality by comparing its components and ignoring votes

    function colourEq (Colour colour, uint8 red, uint8 green, uint8 blue)
        internal returns (bool equal) {
        equal = colour.red == red
            && colour.green == green
            && colour.blue == blue;
    }

    // If the colour has enough votes to get into the palette, insert it
    // (or update it if already in the palette)
    // Naive implementation but with some subtleties:
    // - the palette is not sorted in vote count order (this turns out to be
    //   useful for keeping visual palette order stable)
    // - one or all of the colours may have palette_lowest_vote votes

    function updatePalette (uint8 red, uint8 green, uint8 blue, uint votes)
        internal {
        if (votes > palette_lowest_vote) {
            // Check to see if the colour is already present, update vote if so
            bool already_present;
            for (uint i = 0; i < palette.length; i++) {
                if (colourEq(palette[i], red, green, blue)) {
                    // If the colour is already in the list, update its votes
                    palette[i].votes = votes;
                    already_present = true;
                    break;
                }
            }
            // If not already present, overwrite (one of) the lowest colours
            if (! already_present) {
                for (uint j = 0; j < palette.length; j++) {
                    if (palette[j].votes == palette_lowest_vote) {
                        palette[j] = Colour(red, green, blue, votes);
                        break;
                    }
                }
            }
            // Update the lowest vote count
            uint new_lowest = palette[0].votes;
            for (uint k = 1; k < palette.length; k++) {
                if (palette[k].votes == palette_lowest_vote) {
                    new_lowest = palette[k].votes;
                }
            }
            palette_lowest_vote = new_lowest;
            if (already_present) {
                PaletteChanged(i);
            } else {
                PaletteChanged(j);
            }
        }
    }

    // Start with all the colours in the palette black with zero votes,
    // and the minimum vote at zero so that a single vote gets a colour into
    // the palette.

    function DemocraticPalette () {
    }

    // The function users use to vote for a colour
    // This may not get the colour into the palette, but every vote is counted
    // so if enough people vote for it then eventually it will get in.

    function voteFor (uint8 red, uint8 green, uint8 blue) public {
        uint24 colour_id = colourID(red, green, blue);
        votes[colour_id] = votes[colour_id] + 1;
        updatePalette(red, green, blue, votes[colour_id]);
    }

    // Make it easier for clients to check votes regardless of whether the
    // colour is in the palette or not

    function voteCount (uint8 red, uint8 green, uint8 blue)
        public returns (uint count) {
        count = votes[colourID(red, green, blue)];
    }
}
