pragma solidity ^0.4.11;
import "../Tokens/StandardToken.sol";


/// @title Token contract - Token exchanging Element 1:1
/// @author Stefan George - <stefan@gnosis.pm>
contract ElementToken is StandardToken {
    using Math for *;

    /*
     *  Events
     */
    event Deposit(address indexed sender, uint value);
    event Withdrawal(address indexed receiver, uint value);

    /*
     *  Constants
     */
    string public constant name = "Element Token";
    string public constant symbol = "ELE";
    uint8 public constant decimals = 18;

    /*
     *  Public functions
     */
    /// @dev Buys tokens with Element, exchanging them 1:1
    function deposit()
        public
        payable
    {
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        totalTokens = totalTokens.add(msg.value);
        Deposit(msg.sender, msg.value);
    }

    /// @dev Sells tokens in exchange for Element, exchanging them 1:1
    /// @param value Number of tokens to sell
    function withdraw(uint value)
        public
    {
        // Balance covers value
        balances[msg.sender] = balances[msg.sender].sub(value);
        totalTokens = totalTokens.sub(value);
        msg.sender.transfer(value);
        Withdrawal(msg.sender, value);
    }
}
