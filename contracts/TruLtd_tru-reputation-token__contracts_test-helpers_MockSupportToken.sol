pragma solidity ^0.4.18;

import "../supporting/SafeMath.sol";
import "../supporting/BasicToken.sol";
import "../supporting/StandardToken.sol";


contract MockSupportToken is StandardToken {

    using SafeMath for uint256;

    // @notice number of decimals for the Token - 18
    uint8 public constant decimals = 18;

    string public constant name = "Mock Support Harness";

    string public constant symbol = "MSH";

    event TransferHappened();

    event MathDone();

    function testMath() public returns(uint256 result) {
        uint256 number = 1;
        uint256 anotherNumber = 2;
        number = number.add(anotherNumber);
        number = number.mul(anotherNumber);
        number = number.div(anotherNumber);
        number = number.sub(anotherNumber);
        // Purely for coverage
        number.mul(0);
        uint256 a = 0;
        a.mul(number);
        MathDone();
        return number;
    }

    function testTransfer(address _from) public {
        totalSupply = totalSupply.add(100);
        balances[_from] = balances[_from].add(100);
        super.transferFrom(_from, msg.sender, 100);
        TransferHappened();
    }
}