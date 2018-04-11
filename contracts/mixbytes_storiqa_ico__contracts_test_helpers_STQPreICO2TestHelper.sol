pragma solidity 0.4.15;

import '../STQPreICO2.sol';


/// @title Test helper for STQPreICO2, DONT use it in production!
contract STQPreICO2TestHelper is STQPreICO2 {

    function STQPreICO2TestHelper(address token, address[] fundOwners)
        STQPreICO2(token, fundOwners)
    {
    }


    function getCurrentTime() internal constant returns (uint) {
        return m_time;
    }

    function setTime(uint time) external onlyOwner {
        m_time = time;
    }


    function getWeiCollected() public constant returns (uint) {
        return getTotalInvestmentsStored().add(9 finney /* previous crowdsales */);
    }

    function getMinimumFunds() internal constant returns (uint) {
        return 100 finney;
    }

    function getMaximumFunds() internal constant returns (uint) {
        return 400 finney;
    }


    uint m_time;
}
