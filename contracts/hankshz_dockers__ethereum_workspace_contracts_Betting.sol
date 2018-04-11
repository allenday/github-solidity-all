pragma solidity ^0.4.2;

contract Betting {
    uint public betId;
    uint public amount;
    address[10] public participants;
    uint public number;

    function Betting(uint _betId, uint _amount)
    {
        betId = _betId;
        amount = _amount;
    }

    function getId() public returns (uint){
		return betId;
	}

    function getAmount() public returns (uint){
		return amount;
	}

    function makeBet() public returns (uint){
        require( number >= 0 && number <= 9 );
        participants[number] = msg.sender;
        number++;
        return number-1;
    }

    function getNumber() public returns (uint){
        return number;
    }

    function getParticipant(uint index) returns (address){
        require( index >= 0 && index <= number );
        return participants[index];
    }

    function resetBet() public {
        for(uint i = 0; i < participants.length; i++){
            delete participants[i];
        }
        number = 0;
    }

    function settle() public returns (address){
        require( number >= 1 && number <= 9 );
        uint result = block.timestamp % number;
        return participants[result];
    }
}
