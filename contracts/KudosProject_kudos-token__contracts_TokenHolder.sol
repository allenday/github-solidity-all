pragma solidity ^0.4.15;

import './Ownable.sol';
import './ERC20Token.sol';

/**
 * @title Token holder contract
 *
 * @dev Allow the owner to transfer any ERC20 tokens accidentally sent to the contract address
 */
contract TokenHolder is Ownable {

    /**
     * @dev transfer tokens to the specified address
     * @param _tokenAddress The address to transfer to
     * @param _amount The amount to be transferred
     * @return bool A successful transfer returns true
     */
    function transferAnyERC20Token(address _tokenAddress, uint256 _amount) onlyOwner returns (bool success) {
        return ERC20Token(_tokenAddress).transfer(owner, _amount);
    }
}
