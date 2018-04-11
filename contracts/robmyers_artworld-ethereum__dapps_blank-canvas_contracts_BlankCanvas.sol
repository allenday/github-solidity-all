/*  BlankCanvas - A blank canvas anyone can set the colour of.
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

contract BlankCanvas {
    uint8 public red;
    uint8 public green;
    uint8 public blue;

    event ColourChanged(uint8 red, uint8 green, uint8 blue);

    function BlankCanvas () {
        red = 8;
        green = 32;
        blue = 255;
    }

    function setColour (uint8 new_red, uint8 new_green, uint8 new_blue) public {
        // Should check that the new colour is different before setting
        red = new_red;
        green = new_green;
        blue = new_blue;
        ColourChanged(red, green, blue);
    }

    function getColour () external
        returns (uint8 r, uint8 g, uint8 b) {
        return (red, green, blue);
    }
}
