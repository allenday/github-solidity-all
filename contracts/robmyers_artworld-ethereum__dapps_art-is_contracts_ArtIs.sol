/*  ArtIs - Ethereum contract to define art.
    Copyright (C) 2015, 2016, 2017  Rob Myers <rob@robmyers.org>

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

pragma solidity ^0.4.8;


contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

    function transferOwnership(address newOwner)
        onlyOwner
    {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


contract ArtIs is owned {
    uint constant NUM_DEFS = 12;
    // Allow empty definition values, catch invalid definitions in code
    uint constant DEF_MIN = 0x00;
    uint constant DEF_MAX = 0x0F;

    // FIXME: Solidity 0.4.4 won't let this be NUM_DEFS
    uint[12] PRICES = [
        uint(1), // 1 Wei
        uint(10),
        uint(100),
        uint(500),
        uint(1000), // 1 Ada
        uint(500000),
        uint(1000000), // 1 Babbage
        uint(500000000),
        uint(1000000000), // 1 Shannon
        uint(1000000000000), // 1 Szabo
        uint(1000000000000000), // 1 Finney
        uint(1000000000000000000) // 1 Ether
    ];

    struct Definition {
        address theorist;
        uint8 extent;
        uint8 connection;
        uint8 relation;
        uint8 subject;
    }

    event DefinitionChanged(
        address theorist,
        uint8 index,
        uint8 extent,
        uint8 connection,
        uint8 relation,
        uint8 subject
    );

    // FIXME: Solidity 0.4.4 won't let this be NUM_DEFS
    Definition[12] public definitions;

    function ArtIs () {
        // Catch this at deploy time until we can use constants for array sizes
        if (! ((definitions.length == PRICES.length) &&
               (definitions.length == NUM_DEFS))) {
            throw;
        }
        // Incredibly meaningful initial values
        for (uint8 i = 0; i < definitions.length; i++) {
            definitions[i] = Definition(
                owner,
                i + 1,
                i + 3,
                (i / 2) + 4,
                (i / 3) + 5
            );
        }
    }

    function isDefValueInRange (uint8 defValue) public returns (bool result) {
        result = ((defValue >= DEF_MIN) &&
                  (defValue <= DEF_MAX));
    }

    function isDefIndexInRange (uint8 index) public returns (bool result) {
        result = index < definitions.length;
    }

    function isDefValid (
        uint8 index,
        uint8 extent,
        uint8 connection,
        uint8 relation,
        uint8 subject
    )
        public
        returns (bool result)
    {
        result =
            isDefIndexInRange(index) &&
            isDefValueInRange(extent) &&
            isDefValueInRange(connection) &&
            isDefValueInRange(relation) &&
            isDefValueInRange(subject);
    }

    function setDefinition(
        uint8 index,
        uint8 extent,
        uint8 connection,
        uint8 relation,
        uint8 subject
    )
        public
        payable
    {
        // Solidity 0.4.4 doesn't recognise require or revert
        if (! isDefValid(
            index,
            extent,
            connection,
            relation,
            subject
              )) {
            throw;
        }
        // isDefValid checks that index is in range, so we can use PRICES here
        if (! (msg.value == PRICES[index])) {
            throw;
        }
        address theorist = msg.sender;
        definitions[index].theorist = theorist;
        definitions[index].extent = extent;
        definitions[index].connection = connection;
        definitions[index].relation = relation;
        definitions[index].subject = subject;
        DefinitionChanged(
            theorist,
            index,
            extent,
            connection,
            relation,
            subject
        );
    }

    function drain()
        public
        onlyOwner
    {
        if (this.balance > 0) {
            // Transfer is 0.4.10
            if (! owner.send(this.balance)) {
                throw;
            }
        }
    }

}
