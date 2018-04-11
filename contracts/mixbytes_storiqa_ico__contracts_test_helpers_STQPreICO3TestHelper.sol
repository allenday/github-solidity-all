pragma solidity 0.4.15;

import '../STQPreICO3.sol';


/// @title Test helper for STQPreICO3, DONT use it in production!
contract STQPreICO3TestHelper is STQPreICO3 {

    function STQPreICO3TestHelper(address token, address wallet)
        STQPreICO3(token, wallet)
    {
    }


    function getCurrentTime() internal constant returns (uint) {
        return m_time;
    }

    function setTime(uint time) external onlyOwner {
        m_time = time;
    }


    function getMinimumFunds() internal constant returns (uint) {
        return 100 finney;
    }

    function getMaximumFunds() internal constant returns (uint) {
        return 400 finney;
    }


    uint m_time;
}
