pragma solidity ^0.4.11;


contract CardManager {
    address owner;

    function CardManger() {
        owner = msg.sender;
    }

    function getValueByNumber(uint number) constant external returns(uint) {
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

        return value[number % 52 % 13];
    }

    function getNameByNumber(uint number) constant external returns(uint) {
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

        return name[number % 52 % 13];
    }

    function getTypeByNumber(uint number) constant external returns(uint) {
        // Type = ['Spades', 'Clubs', 'Hearts', 'Diamonds'];
        uint[4] memory Type;
        Type[0] = 4;
        Type[1] = 3;
        Type[2] = 2;
        Type[3] = 1;
        return Type[number % 52 % 4];
    }

    function close() {
        if(msg.sender == owner) {
            selfdestruct(owner);
        }
    }
}
