import './UpgradeableToken.sol';


/**
 * Centrally issued Ethereum token.
 *
 * We mix in upgradeable traits.
 *
 * Token supply is created in the token contract creation and allocated to owner.
 * The owner can then transfer from its supply to crowdsale participants.
 *
 */
contract CentrallyIssuedToken is UpgradeableToken {

  string public name;
  string public symbol;
  uint public decimals;

  /** Name and symbol were updated. */
  event UpdatedTokenInformation(string newName, string newSymbol);

  function CentrallyIssuedToken(address _owner, string _name, string _symbol, uint _totalSupply, uint _decimals)  UpgradeableToken(_owner) {
    name = _name;
    symbol = _symbol;
    totalSupply = _totalSupply;
    decimals = _decimals;

    // Allocate initial balance to the owner
    balances[_owner] = _totalSupply;
  }

  /**
   * Owner can update token information here.
   *
   * It is often useful to conceal the actual token association, until
   * the token operations, like central issuance or reissuance have been completed.
   * In this case the initial token can be supplied with empty name and symbol information.
   *
   * This function allows the token owner to rename the token after the operations
   * have been completed and then point the audience to use the token contract.
   */
  function setTokenInformation(string _name, string _symbol) {

    if(msg.sender != upgradeMaster) {
      throw;
    }

    if(bytes(name).length > 0 || bytes(symbol).length > 0) {
      // Information already set
      // Allow owner to set this information only once
      throw;
    }

    name = _name;
    symbol = _symbol;
    UpdatedTokenInformation(name, symbol);
  }

}
