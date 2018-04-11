pragma solidity ^0.4.9;
import "./erc20Token.sol";

contract LykkeTokenBase is ERC20Token {

  address internal _issuer;
  string public standard;
  string public name;
  string public symbol;
  uint8 public decimals;

  function LykkeTokenBase(
      address issuer,
      string tokenName,
      uint8 divisibility,
      string tokenSymbol, 
      string version) ERC20Token(){
    symbol = tokenSymbol;
    standard = version;
    name = tokenName;
    decimals = divisibility;
    _issuer = issuer;
  }
}
