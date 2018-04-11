/*  ArtIs - Ethereum contract to define art.
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

contract ArtIs {

    event DefinitionChanged(uint8 index, uint8 extent, uint8 connection,
                            uint8 relation, uint8 subject, address setter);

    uint8 constant NUM_TERMS = 16;
    uint constant BASE_PRICE = 1000;

    struct Definition {
        uint8 extent;
        uint8 connection;
        uint8 relation;
        uint8 subject;
        address setter;
    }

    Definition[8] public definitions;

    function ArtIs () {
        definitions[0] = Definition({extent:0, connection:0, relation:0,
                                     subject:0, setter:tx.sender});
        definitions[1] = Definition({extent:0, connection:0, relation:0,
                                     subject:0, setter:tx.sender});
        definitions[2] = Definition({extent:0, connection:0, relation:0,
                                     subject:0, setter:tx.sender});
        definitions[3] = Definition({extent:0, connection:0, relation:0,
                                     subject:0, setter:tx.sender});
        definitions[4] = Definition({extent:0, connection:0, relation:0,
                                     subject:0, setter:tx.sender});
        definitions[5] = Definition({extent:0, connection:0, relation:0,
                                     subject:0, setter:tx.sender});
        definitions[6] = Definition({extent:0, connection:0, relation:0,
                                     subject:0, setter:tx.sender});
        definitions[7] = Definition({extent:0, connection:0, relation:0,
                                     subject:0, setter:tx.sender});
    }

    function indexPrice (uint8 index) returns (uint price) {
        return BASE_PRICE * (index ** 2);
    }

    function setDefinition (uint8 index, uint8 extent, uint8 connection,
                            uint8 relation, uint8 subject) returns (bool set) {
        set = (index < definitions.length) &&
            (tx.value >= indexPrice(index)) &&
            (extent < NUM_TERMS) &&
            (connection < NUM_TERMS) &&
            (relation < NUM_TERMS) &&
            (subject < NUM_TERMS);
        if (set) {
            definitions[index].extent = extent;
            definitions[index].connection = connection;
            definitions[index].relation = relation;
            definitions[index].subject = subject;
            DefinitionChanged(index, extent, connection, relation, subject,
                              tx.sender);
            send(definitions[index].setter, );
        }
    }
}
