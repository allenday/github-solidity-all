/// @title TruMintableToken
/// @notice A mintable token - forked from Open-Zeppelin Mintable Token to include 
/// TokenMarket Ltd's ReleaseableToken's functionality
/// @dev - Based off of zeppelin-solidity's Mintable Token 
/// (https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/MintableToken.sol)
/// - Based off of TokenMarket's ReleasableToken 
/// (https://github.com/TokenMarketNet/ico/blob/master/contracts/ReleasableToken.sol).
/// Updated by Tru Ltd October 2017 to comply with Solidity 0.4.18 syntax and Best Practices
/// and to meet requirements of the Tru Reputation Token
/// @author Ian Bray
pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./ReleasableToken.sol";


contract TruMintableToken is ReleasableToken {
    
    using SafeMath for uint256;
    using SafeMath for uint;

    bool public mintingFinished = false;

    bool public preSaleComplete = false;

    bool public saleComplete = false;

    event Minted(address indexed _to, uint256 _amount);

    event MintFinished(address indexed _executor);
    
    event PreSaleComplete(address indexed _executor);

    event SaleComplete(address indexed _executor);

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /// @dev Function to mint tokens
    /// @param _to The address that will receive the minted tokens.
    /// @param _amount The amount of tokens to mint.
    /// @return A boolean that indicates if the operation was successful.
    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
        require(_amount > 0);
        require(_to != address(0));
    
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Minted(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    /// @dev Function to stop minting new tokens.
    /// @return True if the operation was successful.
    function finishMinting(bool _presale, bool _sale) public onlyOwner returns (bool) {
        // Require at least one argument to be true
        require(_sale != _presale);

        /// @dev If _presale is true, require _sale to be false and mark the Pre Sale as Complete
        if (_presale == true) {
            preSaleComplete = true;
            PreSaleComplete(msg.sender);
            return true;
        }

        /// @dev Else, require preSaleComplete to be true and mark the CrowdSale as Complete
        require(preSaleComplete == true);
        saleComplete = true;
        SaleComplete(msg.sender);
        mintingFinished = true;
        MintFinished(msg.sender);
        return true;
    }
}