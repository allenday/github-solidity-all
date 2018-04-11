pragma solidity ^0.4.17;


import "./common/StandardToken.sol";
import "./common/Ownable.sol";


/// @title Papyrus Prototype Token (PRP) smart contract.
contract PapyrusPrototypeTokenTest is StandardToken, Ownable {

  // EVENTS

  event Mint(address indexed to, uint256 amount, uint256 priceUsd);
  event MintFinished();
  event Burn(address indexed burner, uint256 amount);
  event TransferableChanged(bool transferable);

  // PUBLIC FUNCTIONS

  // If ether is sent to this address, send it back
  function() public { revert(); }

  // Check transfer ability and sender address before transfer
  function transfer(address _to, uint256 _value) canTransfer public returns (bool) {
    return super.transfer(_to, _value);
  }

  // Check transfer ability and sender address before transfer
  function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  /// @dev Function to mint tokens.
  /// @param _to The address that will receive the minted tokens.
  /// @param _amount The amount of tokens to mint.
  /// @param _priceUsd The price of minted token at moment of purchase in USD with 18 decimals.
  /// @return A boolean that indicates if the operation was successful.
  function mint(address _to, uint256 _amount, uint256 _priceUsd) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    if (_priceUsd != 0) {
      uint256 amountUsd = _amount.mul(_priceUsd).div(10**18);
      totalCollected = totalCollected.add(amountUsd);
    }
    Mint(_to, _amount, _priceUsd);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /// @dev Function to stop minting new tokens.
  /// @return A boolean that indicates if the operation was successful.
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

  /// @dev Burns a specific amount of tokens.
  /// @param _value The amount of token to be burned.
  function burn(uint256 _value) public {
    require(_value > 0);
    require(_value <= balances[msg.sender]);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    totalBurned = totalBurned.add(_value);
    Burn(burner, _value);
  }

  /// @dev Change ability to transfer tokens by users.
  /// @return A boolean that indicates if the operation was successful.
  function setTransferable(bool _transferable) onlyOwner public returns (bool) {
    require(transferable != _transferable);
    transferable = _transferable;
    TransferableChanged(transferable);
    return true;
  }

  // MODIFIERS

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier canTransfer() {
    require(transferable || msg.sender == owner);
    _;
  }

  // FIELDS

  // Standard fields used to describe the token
  string public name = "Test Token";
  string public symbol = "WWW";
  string public version = "H0.1";
  uint8 public decimals = 18;

  // At the start of the token existence token is not transferable
  bool public transferable = false;

  // Will be set to true when minting tokens will be finished
  bool public mintingFinished = false;

  // Amount of burned tokens
  uint256 public totalBurned;

  // Amount of USD (with 18 decimals) collected during sale phase
  uint256 public totalCollected;
}
