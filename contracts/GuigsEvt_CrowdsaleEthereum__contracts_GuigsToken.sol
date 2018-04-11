pragma solidity ^0.4.14;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./BasicToken.sol";

contract GuigsToken is ERC20, Ownable, BasicToken {

  /* Using SafeMath as library for safe operations for uint256 variables */
  using SafeMath for uint256;

  /* Public variables of the token */
  /* Those are the variables that must be changed with your token description */
  string public constant name = 'Guigs token development purpose';
  string public constant symbol = 'GUIGS';
  uint8 public constant decimals = 18;

  // States whether creating more tokens is allowed or not.
  // Used during token sale.
  bool public isMinting = true;

  // Event fired when minting is over. Though crowdsale is over.
  event MintingEnded();

  modifier onlyDuringMinting() {
    require(isMinting);
    _;
  }

  modifier onlyAfterMinting() {
    require(!isMinting);
    _;
  }

  /// @dev Mint GUIGS tokens.
  /// @param _to address Address to send minted GUIGS tokens to.
  /// @param _amount uint256 Amount of GUIGS tokens to mint.
  function mint(address _to, uint256 _amount) external onlyOwner onlyDuringMinting {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);

    Transfer(0x0, _to, _amount);
  }

  /// @dev End minting mode.
  function endMinting() external onlyOwner {
    if (isMinting == false) return;
    isMinting = false;

    MintingEnded();
  }

  /// @dev Same ERC20 behavior, but require the token to be unlocked
  /// @param _spender address The address which will spend the funds.
  /// @param _value uint256 The amount of tokens to be spent.
  function approve(address _spender, uint256 _value) public onlyAfterMinting returns (bool) {
      return super.approve(_spender, _value);
  }

  /// @dev Same ERC20 behavior, but require the token to be unlocked
  /// @param _to address The address to transfer to.
  /// @param _value uint256 The amount to be transferred.
  function transfer(address _to, uint256 _value) public onlyAfterMinting returns (bool) {
      return super.transfer(_to, _value);
  }

  /// @dev Same ERC20 behavior, but require the token to be unlocked
  /// @param _from address The address which you want to send tokens from.
  /// @param _to address The address which you want to transfer to.
  /// @param _value uint256 the amount of tokens to be transferred.
  function transferFrom(address _from, address _to, uint256 _value) public onlyAfterMinting returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  /// @notice Burn function that could be useful for further processes of the token contract. Can be called from the owner to reduce market cap.
  /// @dev Allows token holders to burn tokens
  /// @param _value uint256 the amount of tokens that must be burned
  function burn(uint256 _value) external onlyOwner onlyAfterMinting returns (bool success){
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Transfer(msg.sender, 0x0, _value);
    return true;
  }


}
