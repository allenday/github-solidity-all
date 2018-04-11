pragma solidity ^0.4.0;

contract Lottery {
    address public house;
    string lotteryName;
    uint public potValue;
    uint public potPayoutPercentage;
    uint public ticketsSold;
    uint public ticketPrice;
    mapping (address => uint) tickets;
    
    /* this function is executed at initialization and sets the owner of the contract */
    function mortal() { house = msg.sender; }

    
    /* Constructor */
    function Lottery(string _lotteryName, uint _potPayoutPercentage, uint _ticketPrice) is mortal {
        house = msg.sender;
        lotteryName = _lotteryName;
        potPayoutPercentage = _potPayoutPercentage;
        ticketPrice = _ticketPrice;
        ticketsSold = 0;
        potValue = 0;
    }
    
    /* Function to recover the funds on the contract */
    function kill() { if (msg.sender == owner) selfdestruct(owner); }
    
    function buy(address _to, uint _count) return (bool _success) {
        uint price = ticketPrice * _count;
        if (eth.sendTransaction({from: _to, to: house, value: web3.toWei(price, "ether")})) {
            tickets[_to] += _count;
            ticketsSold += _count;
            potValue += price;
        }
    }
    
    function transfer(address _to, uint _value) returns (bool _success) {
        if (tickets[msg.sender] < _value) {
            return false;
        }
        tickets[msg.sender] -= _value;
        tickets[_to] += _value;
        return true;
    }
    
    function getTicketCount(address _user) constant returns (uint _ticketCount) {
        return tickets[_user];
    }
    
    function setWinner(address _user) returns (bool _success){
        if (msg.sender == house) {
            eth.sendTransaction({from: _house, to: _user, value: web3.toWei(getWinnerPayout(), "ether")});
            selfdestruct(owner);
            return true;
        }
        return false;
    }
    
    function getWinnerPayout() {
        return (potPayoutPercentage / 100) * potValue;
    }
    
    function getHousePayout() {
        return potValue - getWinnerPayout();
    }
}
