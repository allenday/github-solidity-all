/*  IsArt - Ethereum contract that is or isn't art.
    Copyright (C) 2015  Rob Myers <rob@robmyers.org>

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

contract IsArt {

    event Status(bytes6 is_art);

    bytes6 public is_art;

    function IsArt () {
        is_art = "is not";
    }

    function toggle () {
        if (is_art == "is") {
            is_art = "is not";
        } else {
            is_art = "is";
        }
        Status(is_art);
    }

}
