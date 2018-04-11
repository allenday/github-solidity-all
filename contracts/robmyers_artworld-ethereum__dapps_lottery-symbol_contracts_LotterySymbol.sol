/*
 * Lottery Symbol - A symbol you can change via a lottery.
 * Copyright (C) 2017 Rob Myers <rob@robmyers.org>
 *
 * This file is part of Lottery Symbol.
 *
 * Lottery Symbol is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Lottery Symbol is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Lottery Symbol.  If not, see <http://www.gnu.org/licenses/>.
 */


pragma solidity ^0.4.11;


contract LotterySymbol {

    struct Entry {
        address entrant;
        uint32 symbol;
    }

    // One day
    uint public constant ROUND_LENGTH = 86400;

    event SymbolChanged(uint32 symbol, address winner);
    event NewEntry(address entrant, uint32 symbol, uint roundEnds);

    // Biohazard symbol
    uint32 public symbol = 9763;

    uint public currentRoundEnds;
    uint public numEntries = 0;
    Entry[] public entries;

    function LotterySymbol () {
        currentRoundEnds = block.timestamp + ROUND_LENGTH;
    }

    // Solidity cannot return arrays of structs
    // But we need to access the entries atomically from the UI

    function getEntries () public returns (
        address[] entrants,
        uint32[] symbols
        ) {
        if (numEntries > 0) {
            address[] memory ent = new address[](numEntries);
            uint32[] memory sym = new uint32[](numEntries);
            for (uint i = 0; i < numEntries; i++) {
                ent[i] = entries[i].entrant;
                sym[i] = entries[i].symbol;
            }
            entrants = ent;
            symbols = sym;
        }
    }

    // Not "has winner been chosen", has the time run out

    function hasRoundEnded () public returns (bool stale) {
        stale = (block.timestamp > currentRoundEnds);
    }

    // You can enter the lottery multiple times in a given round

    function enterLottery (uint32 entrySymbol) public {
        // Since we aren't running this on a cron job, call it where we can
        maybeNewRound();
        // https://ethereum.stackexchange.com/questions/3373/how-to-clear-large-arrays-without-blowing-the-gas-limit
        if (numEntries == entries.length) {
            entries.length += 1;
        }
        entries[numEntries] = Entry(msg.sender, entrySymbol);
        numEntries += 1;
        NewEntry(msg.sender, entrySymbol, currentRoundEnds);
    }

    // Called by entrants to choose the winner.
    // Note that this doesn't start a new round.

    function finalizeRound () public {
        if (hasRoundEnded()) {
            chooseWinner();
        }
    }

    // This may end a round and start a new one.
    // It's called when adding an entry to ensure that it is placed in a live
    // lottery.
    // This may have the unexpected (by the user) effect of updating the symbol
    // on-screen in the DApp to the winner of the previous round.

    function maybeNewRound () private {
        if (hasRoundEnded()) {
            chooseWinner();
            newRound();
        }
    }

    // Choose the current symbol from the list of entries.
    // This doesn't start a new round, that's a separate operation so we don't
    // put the cost of starting an empty round onto a previous entrant.

    function chooseWinner ()
        private
        returns (uint32 winningSymbol, address winningEntrant)
    {
        // This allows gaming if the caller gets to choose the block
        // (which at low entry volumes is easy). So this is demo quality only.
        if (numEntries > 0) {
            // This will fail in the first block on a blockchain,
            // which might affect some tests
            uint previousBlock = block.number - 1;
            uint blockHash = uint256(block.blockhash(previousBlock));
            uint index = blockHash % numEntries;
            Entry memory winner = entries[index];
            symbol = winner.symbol;
            winningSymbol = winner.symbol;
            winningEntrant = winner.entrant;
            // These seem to be more efficient in modern Solidity
            //delete entrants;
            //delete symbols;
            // NO, in real usage we blow the gas limit. So back to counting.
            // https://ethereum.stackexchange.com/questions/3373/how-to-clear-large-arrays-without-blowing-the-gas-limit
            numEntries = 0;
            SymbolChanged(winningSymbol, winningEntrant);
        }
    }

    // Start a new round.
    // This isn't available as a separate public option, you can only call it
    // via enterLottery() .

    function newRound () private {
        currentRoundEnds = block.timestamp + ROUND_LENGTH;
    }
}
