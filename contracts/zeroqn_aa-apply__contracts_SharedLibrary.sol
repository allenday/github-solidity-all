pragma solidity ^0.4.17;

/**
 * @title SharedLibrary
 */

import "zeppelin-solidity/contracts/token/ERC20.sol";


library SharedLibrary {

    function withdrawFrom(address from, address to, address[] _tokens)
        internal
    {
        if (from.balance > 0) {
            to.transfer(from.balance);
        }

        for (uint i = 0; i < _tokens.length; i++) {
            ERC20 token = ERC20(_tokens[i]);
            uint256 amount = token.balanceOf(from);

            if (amount > 0) {
                token.transfer(to, amount);
            }
        }
    }

}
