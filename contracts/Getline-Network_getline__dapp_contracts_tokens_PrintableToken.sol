pragma solidity ^0.4.11;

import "./BasicToken.sol";


contract PrintableToken is BasicToken {
    event Print(address indexed _who);

    uint256 public printValue;

    function PrintableToken(
        string tokenName,
        uint256 decimalUnits,
        string tokenSymbol,
        uint256 howMuchToPrint
    ) public BasicToken(0, tokenName, decimalUnits, tokenSymbol)
    {
        printValue = howMuchToPrint;
    }

    function print(address _who) public {
        require(_who != 0x0);
        require(totalSupplyField + printValue >= totalSupplyField);
        require(balanceOfField[_who] + printValue >= balanceOfField[_who]);

        totalSupplyField += printValue;
        balanceOfField[_who] += printValue;
        Print(_who);
    }
}
