pragma solidity ^0.4.9;
import "./erc20Token.sol";
import "./lykkeTokenBase.sol";

contract EmissiveToken is LykkeTokenBase {
  function EmissiveToken(
      address issuer,
      string tokenName,
      uint8 divisibility,
      string tokenSymbol, 
      string version) LykkeTokenBase(issuer, tokenName, divisibility, tokenSymbol, version){
    accounts [_issuer] = MAX_UINT256;
  }

  function totalSupply () constant returns (uint256 supply) {
    return safeSub (MAX_UINT256, accounts [_issuer]);
  }

  function balanceOf (address _owner) constant returns (uint256 balance) {
    return _owner == _issuer ? 0 : ERC20Token.balanceOf (_owner);
  }
}
