pragma solidity ^0.4.11;

contract DiceGame {
    address public owner;
    uint public minimumBet;
    mapping (address => uint) public players;
    uint private daNumber;

    modifier onlyOwner() {
        require(msg.sender == owner);
        // Do not forget the "_;"! It will
        // be replaced by the actual function
        // body when the modifier is used.
        _;
    }

    event GuessedNumber(address _from, uint _number);
    event Lose(address _from, uint _number);
    event Win(address _from, uint _number);

    function DiceGame()
    {
        owner = msg.sender;

    /*  Denominations:
        Wei = 10^0 Wei
        Ada = 10^3 Wei
        Babbage = 10^6 Wei
        Shannon = 10^9 Wei
        Szabo = 10^12 Wei
        Finney = 10^15 Wei
        Ether = 10^18 Wei
        Einstein = 10^21 Wei
        Douglas = 10^42 Wei
    */
        minimumBet = 1 ether;
        reset();
    }

    /**
     * Fallback function: If the contract gets called without extra data, keep the money.
     */
    function() payable { }

    function guessNumber(uint guess) public payable returns (bool success)
    {
        if (msg.value != minimumBet) {
            return false;
        }

        players[msg.sender] = guess;

        if (guess == daNumber) {
            if (this.balance >= minimumBet*2) {
                msg.sender.transfer(minimumBet*2);
            }

            // Raise event
            Win(msg.sender, guess);

            reset();
            return true;
        }

        if (guess < daNumber) {
            if (this.balance > 1 wei) {
                msg.sender.transfer(1 wei);
            }

            Lose(msg.sender, guess);
            return true;
        }

        if (guess > daNumber) {
            if (this.balance > 2 wei) {
                msg.sender.transfer(2 wei);
            }

            Lose(msg.sender, guess);
            return true;
        }

        return false;
    }

    function reset()
    {
        daNumber = 42; // later we want to make this a random number
    }

    function setMinimumBet(uint newMinimumBet) public onlyOwner
    {
        minimumBet = newMinimumBet;
    }

    // Close contract and send the funds to the owner
    function destroy() onlyOwner {
        suicide(owner);
    }
}