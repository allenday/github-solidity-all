pragma solidity ^0.4.18;

import "./SafeMathLib.sol";

contract TestLib {
    using SafeMathLib for uint256;
    
    uint256 readme = 1;

    function TestLib() public {
        readme = readme.add(3);
    }

    function getReadme() public view returns (uint256) {
        return readme;
    }
}