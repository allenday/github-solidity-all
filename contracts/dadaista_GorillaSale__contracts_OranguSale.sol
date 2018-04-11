pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "./GorillaToken.sol";


/**
 * @title OranguSale
 * @dev This is an example of a fully fledged crowdsale.
 * The way to add new features to a base crowdsale is by multiple inheritance.
 * In this example we are providing following extensions:
 * CappedCrowdsale - sets a max boundary for raised funds
 *
 * After adding multiple features it's good practice to run integration tests
 * to ensure that subcontracts works together as intended.
 */
contract OranguSale is CappedCrowdsale,Ownable, Pausable {

  uint256  public MAXRATE;
  uint256  public MINRATE;
  function OranguSale(     uint256 _time_start,
                           uint256 _time_end,
                           uint256 _rate,
                           uint256 _maxrate,
                           uint256 _minrate,   
                           address _wallet,
                           address _preminedOwner,
                           uint256 _cap,
			                     uint256 _premined) public
  
  CappedCrowdsale(_cap)
  Crowdsale(_time_start, _time_end, _rate, _wallet)
  {
      MAXRATE = _maxrate;
      MINRATE = _minrate;
      require( _rate >= MINRATE);
      require( _rate <= MAXRATE);
      token.mint(_preminedOwner,_premined);
  }

  function createTokenContract() internal returns (MintableToken) {
    return new GorillaToken();
  }

  function setRate(uint256 _rate) onlyOwner public{
    require( _rate >= MINRATE);
    require( _rate <= MAXRATE);
    rate = _rate;
  }

  //adding pause to super.buyTokens
  function buyTokens(address beneficiary) public payable whenNotPaused{
    super.buyTokens(beneficiary);
  }

  function   () payable external whenNotPaused  {
    buyTokens(msg.sender);
  }

  //this function transfers the token contract ownership to sale owner
  //this is dangerous, use only if a disaster happens with this sale
  // and you want to take the contract safe out of it
  function takeTokenContractOwnership() onlyOwner public{
    token.transferOwnership(owner);
  }
  

}
