pragma solidity ^0.4.9;
import "./erc20Token.sol";
import "./lykkeTokenBase.sol";

contract NonEmissiveToken is LykkeTokenBase {

  uint256 internal _initialSupply;

  function NonEmissiveToken(address issuer,
                    string tokenName,
                    uint8 divisibility,
                    string tokenSymbol, 
                    string version, 
                    uint256 initialSupply) LykkeTokenBase(issuer, tokenName, divisibility, tokenSymbol, version){
    _initialSupply = initialSupply;
    accounts [_issuer] = initialSupply;
  }

  function totalSupply () constant returns (uint256 supply) {
    return _initialSupply;
  }

  function balanceOf (address _owner) constant returns (uint256 balance) {
    return ERC20Token.balanceOf (_owner);
  }
}
