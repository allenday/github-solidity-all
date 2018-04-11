/*  HotCold - Ethereum contract with temperature.
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

contract HotCold {

    event Swapped(bytes4 hot, bytes4 cold);

    bytes4 public hot;
    bytes4 public cold;

    function HotCold() {
        cold = "cold";
        hot = "hot";
    }

    function swap() {
        bytes4 temp = hot;
        hot = cold;
        cold = temp;
        Swapped(hot, cold);
    }

}
