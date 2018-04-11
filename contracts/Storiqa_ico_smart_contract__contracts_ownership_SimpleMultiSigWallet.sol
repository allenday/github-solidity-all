pragma solidity 0.4.15;

import './multiowned.sol';


/**
 * @title Basic demonstration of multi-owned entity.
 */
contract SimpleMultiSigWallet is multiowned {

    event Deposit(address indexed sender, uint value);
    event EtherSent(address indexed to, uint value);

    function SimpleMultiSigWallet(address[] _owners, uint _signaturesRequired)
        multiowned(_owners, _signaturesRequired)
    {
    }

    /// @dev Fallback function allows to deposit ether.
    function()
        payable
    {
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
    }

    /// @notice Send `value` of ether to address `to`
    /// @param to where to send ether
    /// @param value amount of wei to send
    function sendEther(address to, uint value)
        external
        onlymanyowners(sha3(msg.data))
    {
        require(0 != to);
        require(value > 0 && this.balance >= value);
        to.transfer(value);
        EtherSent(to, value);
    }
}
