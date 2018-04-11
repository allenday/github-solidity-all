pragma solidity ^0.4.13;

import "./FixedGameToken.sol";

contract FixGameRegistry is DSStop {
    // TODO: is public here useful?
    mapping (bytes32 => address) public tokens;


    function registerFixedToken(bytes32 _symbol, uint _ratio, address _pls) public auth stoppable returns (address) {
        // TODO:

        address token = new FixedGameToken(_symbol, _ratio, _pls);

        tokens[_symbol] = token;

        return token;
    }
}