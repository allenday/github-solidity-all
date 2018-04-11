pragma solidity ^0.4.11;
contract PotOfEther {

    struct Pot {
        string name;
        uint buyIn;

        address[] players;
        
        uint lastPlayerBlockNumber;
        
        bool isOpen;
    }
    
    address public owner;
    
    mapping(string => Pot) nameToPot;
    mapping(address => uint) public refunds;
    uint public totalPendingRefunds;
    
    event LogPotCreated(string name, uint buyIn);
    event LogPotJoined(string name, address indexed newPlayer, uint buyIn);
    event LogPotFull(string name);
    event LogPotClosed(string name);
    event LogPotWinner(string name, address indexed winner, uint refundAmount);
    event LogPotLoser(string name, address indexed loser);
    event LogAccountRefund(address indexed account, uint refundAmount);

    function PotOfEther() {
        owner = msg.sender;
    }

    function availableOwnerWithdraw() constant returns (uint) {
        return this.balance - totalPendingRefunds;
    }

    function ownerWithdraw() {
        owner.transfer(availableOwnerWithdraw());
    }

    function createPot(string name) payable {
        require(msg.value > 0); // must bet something
        require(bytes(name).length > 0); // name can't be empty 
        require(nameToPot[name].buyIn == 0); // there isn't already a pot with this name 

        Pot storage pot = nameToPot[name];
        pot.name = name;
        pot.buyIn = msg.value;
        pot.players.push(msg.sender);
        pot.isOpen = true;

        totalPendingRefunds += pot.buyIn; // owner can't withdraw this funds while pot is open

        LogPotCreated(name, msg.value);
        LogPotJoined(name, msg.sender, msg.value);
    }

    function joinPot(string name) payable {
        Pot storage pot = nameToPot[name];
        require(pot.isOpen); // pot exists and isn't over
        require(pot.players.length < 3); // pot isn't full
        require(msg.value == pot.buyIn); // must pay buyIn amount
        for (uint i = 0; i < pot.players.length; i++) {
            require(pot.players[i] != msg.sender); //must be new to this pot
        }

        pot.players.push(msg.sender);
        LogPotJoined(name, msg.sender, msg.value);
        
        totalPendingRefunds += pot.buyIn; // owner can't withdraw this funds while pot is open

        if (pot.players.length == 3) {
            pot.lastPlayerBlockNumber = block.number;
            LogPotFull(name);
        }
    }

    function canClosePot(string name) constant returns (bool) {
        Pot storage pot = nameToPot[name];
        return pot.isOpen && pot.players.length == 3 && block.number > pot.lastPlayerBlockNumber;
    }

    function closePot(string name) {
        Pot storage pot = nameToPot[name];
        require(canClosePot(name));
        
        pot.isOpen = false;
        LogPotClosed(name);
        totalPendingRefunds -= (pot.buyIn * 3);
        
        bytes32 blockHash = block.blockhash(block.number);

        bytes32 potShaResult = sha3(name, blockHash);
        uint8 loserIndex = uint8(uint256(potShaResult) % 3);

        address loser = pot.players[loserIndex];
        address winner1 = pot.players[(loserIndex + 1) % 3];
        address winner2 = pot.players[(loserIndex + 2) % 3];

        uint fee = pot.buyIn / 100;
        uint playerWinAmount = (pot.buyIn - fee) / 2; // take 1% fee and split winnins
        uint winnerRefundAmount = pot.buyIn + playerWinAmount;

        refunds[winner1] += winnerRefundAmount;
        totalPendingRefunds += winnerRefundAmount;
        
        refunds[winner2] += winnerRefundAmount;
        totalPendingRefunds += winnerRefundAmount;

        LogPotWinner(name, winner1, winnerRefundAmount);
        LogPotWinner(name, winner2, winnerRefundAmount);
        LogPotLoser(name, loser);
    }

    function withdrawRefund() {
        uint refund = refunds[msg.sender];
        refunds[msg.sender] = 0;
        totalPendingRefunds -= refund;

        msg.sender.transfer(refund);
        LogAccountRefund(msg.sender, refund);
    }
}
