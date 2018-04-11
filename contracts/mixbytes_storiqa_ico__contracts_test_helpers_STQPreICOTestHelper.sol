pragma solidity 0.4.15;

import '../STQPreICO.sol';


/// @title Test helper for STQPreICO, DONT use it in production!
contract STQPreICOTestHelper is STQPreICO {

    function STQPreICOTestHelper(address token, address funds)
        STQPreICO(token, funds)
    {
    }


    function getCurrentTime() internal constant returns (uint) {
        return m_time;
    }

    function setTime(uint time) external onlyOwner {
        m_time = time;
    }


    function getMaximumFunds() internal constant returns (uint) {
        return 400 finney;
    }


    uint m_time;
}
