pragma solidity >=0.4.15;
import "zeppelin/token/StandardToken.sol";

//includes common functions needed by multiple kiwi contracts

contract KiwiUtils is StandardToken {

  event Mint(address indexed to, uint256 amount);
  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    //Mint(_to, _amount); //@todo - this causes issue with event checking in the tests.
    //Transfer(0x0, _to, _amount); //@todo - this causes issue with event checking in the tests.
    return true;
  }

  /**
   * @dev Burns a specific amount of tokens.
   * @param _from The address that will lose tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(address _from, uint256 _value) public {
      require(_value > 0);

      address burner = _from;
      balances[burner] = balances[burner].sub(_value);
      totalSupply = totalSupply.sub(_value);
      //Burn(burner, _value); //@todo - this causes issue with event checking in the tests.
  }

  // converts Kiwi to tuis
  function toTuis(uint256 _amount) public constant returns(uint256) {
    return _amount * 1e18; //@todo - need to use variables to calculate this.
  }

  // calculates value of tokens in Eth
  function toEth(uint256 _amount) public constant returns(uint256) {
    return (_amount * 1e18) / 1000; //@todo - need to use variables to calculate this
  }

  // converts eth to tokens
  function toKiwi(uint256 _amount) public constant returns(uint256) {
    return (_amount * 1000);
  }

}
