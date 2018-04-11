pragma solidity ^0.4.11;


contract BacCara {
    address owner;
    // who won (ww): 0 - dealer, 1 - player, 2 - tie
    // payout: how much the player won
    // total player value (tpv): total value of player
    // total dealer value (tdv): total value of dealer
    // [ww, payout, tpv, tdv]
    mapping(address => uint[4]) public results;


    function BacCara() {
        owner = msg.sender;
    }

    function getGameResults() constant returns(uint[4]) {
        return results[msg.sender];
    }

    function setResults(uint[4] values) external {
        // values = [tpv, tdv, ww, payout]
        results[msg.sender] = values;
    }

    // This function returns array: [first card p [0], type_first_card_p [1],
    //                              first card d [2], type_first_card_d [3],
    //                              second card p [4], type_second_card_p [5],
    //                              second_card_d [6], type_second_card_d [7],
    //                              third_card_p [8], type_third_card_p [9],
    //                              third_card_d [10], type_third_card_d [11],
    //                              total_v_player [12], total_v_dealer [13],
    //                              who_won [14], playout [15]]
    function play(uint[3] bets) constant returns(uint[16]) {
        // bets: dealer, player, tie
        // Value of each cards
        uint[13] memory value;
        value[0] = 1; // Ace
        value[1] = 0; // King
        value[2] = 0; // Queen
        value[3] = 0; // Jack
        value[4] = 0; // 10
        value[5] = 9;
        value[6] = 8;
        value[7] = 7;
        value[8] = 6;
        value[9] = 5;
        value[10] = 4;
        value[11] = 3;
        value[12] = 2;

        // name = ['Ace', 'King', 'Queen', 'Jack', '10', '9', '8', '7', '6', '5', '4', '3', '2'];
        // name = [14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2];
        uint[13] memory name;
        name[0] = 14; // Ace
        name[1] = 13; // King
        name[2] = 12; // Queen
        name[3] = 11; // Jack
        name[4] = 10; // 10
        name[5] = 9;
        name[6] = 8;
        name[7] = 7;
        name[8] = 6;
        name[9] = 5;
        name[10] = 4;
        name[11] = 3;
        name[12] = 2;

        // Type = ['Spades', 'Clubs', 'Hearts', 'Diamonds'];
        uint[4] memory Type;
        Type[0] = 4; // Spades
        Type[1] = 3; // Clubs
        Type[2] = 2; // Hearts
        Type[3] = 1; // Diamonds

        uint[16] memory r;

        uint i = 0;
        uint s = block.number;
        while (i < 12) {
            uint a = 1093;
            uint c = 18257;
            uint m = 86436;

            // uint s = (a * block.number + c) % m;
            s = (a * s + c) % m;
            r[i] = s % 416;
            r[i + 1] = (s % 416) % 52 % 4;
            i = i + 2;
        }

        uint total_p = (value[r[0] % 52 % 13] + value[r[4] % 52 % 13]) % 10;
        uint total_d = (value[r[2] % 52 % 13] + value[r[6] % 52 % 13]) % 10;

        if(total_p == 9 && total_d == 9) {
            r[12] = total_p;
            r[13] = total_d;
            r[14] = 2; // 0 - dealer, 1 - player, 2 - tie
            //TODO: Returns bets on player and dealer
            r[15] = bets[2] * 8;
            return r;
        } else if (total_p == 8 && total_p > total_d) {
            r[12] = total_p;
            r[13] = total_d;
            r[14] = 1; // 0 - dealer, 1 - player, 2 - tie
            r[15] = bets[1] * 2;
            return r;
        } else if (total_d == 8 && total_d > total_p) {
            r[12] = total_p;
            r[13] = total_d;
            r[14] = 0; // 0 - dealer, 1 - player, 2 - tie
            r[15] = bets[1] * 2;
            return r;
        } else if (total_p <= 5) {
            total_p = (total_p + value[r[8] % 52 % 13]) % 10;
        } else if (total_d <= 4) {
            total_d = (total_d + value[r[10] % 52 % 13]) % 10;
        }

        if (total_p > total_d) {
            r[12] = total_p;
            r[13] = total_d;
            r[14] = 1; // 0 - dealer, 1 - player, 2 - tie
            r[15] = bets[1] * 2;
            return r;
        } else if (total_d > total_p) {
            r[12] = total_p;
            r[13] = total_d;
            r[14] = 0; // 0 - dealer, 1 - player, 2 - tie
            r[15] = bets[0] * 2;
            return r;
        } else if (total_d == total_p) {
            r[12] = total_p;
            r[13] = total_d;
            r[14] = 2; // 0 - dealer, 1 - player, 2 - tie
            r[15] = bets[0] * 8;
            return r;
        }
    }

    function close() {
        if(msg.sender == owner) {
            selfdestruct(owner);
        }
    }

}
