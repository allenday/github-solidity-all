pragma solidity ^0.4.2;

contract Vulnerable{

    /* Public variables of the token */
    // string public standard = 'Token 0.1';
    string public name = 'VulnerableTokens'; // Set the name for display purposes
    string public symbol = 'VT';  // Set the symbol for display purposes
    uint8 public decimals = 0;    // Amount of decimals for display purposes
    uint public totalSupply = 10;

    /* This creates an array with all Token balances */
    mapping (address => uint) public balanceOf; // ! in tokens
    /* Ledger of holders or all tokens */
    mapping (uint => address) public tokenHolders;
    address public manager;

         /* -- */
    bool initialised = false;

    /* ---- Creates contract */
    function CreditUnits () {
        manager = msg.sender;
    }

     /* ---- Contract initialization: */
    function initialization(){

        if (msg.sender != manager){
            throw;
        }

        if (initialised){
            throw;
        }

        for (uint i=0; i < totalSupply; i++){
            tokenHolders[i] = manager;
        }

        balanceOf[manager]=totalSupply;
        initialised = true;
    } // end of initialization()

    function changeTokenHolder(address _oldHolder, address _newHolder) private {
        for (uint i=0; i < totalSupply; i++){
            if (tokenHolders[i] == _oldHolder){
                tokenHolders[i] = _newHolder;
                return;
            }
        }
    }

    function transferTokens(address _from, address _to, uint _value) {
        if (_value <= 0) throw;
        if (balanceOf[_from] < _value) throw;
        // change tokens holder in the Ledger:
        for (uint i=0; i < _value; i++){
            changeTokenHolder(_from, _to);
        }
        balanceOf[_from] -= _value;
        balanceOf[_to] -= _value;
    }

    function transfer(address _to, uint _value) {
        if (_value <= 0) throw;
        if (balanceOf[msg.sender] < _value) throw;  // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows

        transferTokens(msg.sender, _to, _value);

        // change tokens holder in the Ledger:
        for (uint i=0; i < _value; i++){
            changeTokenHolder(msg.sender, _to);
        }

    }


}
