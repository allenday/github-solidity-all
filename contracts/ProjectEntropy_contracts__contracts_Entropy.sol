pragma solidity ^0.4.4;

import "tokens/EntropyToken.sol";

contract Entropy is EntropyToken {

  /**
   * A Citizen 🏃 is anyone who holds one or more Entropy Tokens 🍪
   * Any address with a balance > 0 is considered a Citizen
   */

  /**
   * Trusted Citizens 👬 hold equal voting rights to all
   * trusted individuals in the Entropy Community
   */
  mapping(address => bool) trusted;

  /**
   * Guardians 💂 are the elected protectors of the project
   * They are also able to mark Citizens as trusted, allowing for a human-based
   * proof of individuality system.
   */
  mapping(address => bool) guardians;
  



  /**
   * Constructor
   * ran once when the Entropy contract first comes into existence
   */
  function Entropy() {
    // Setup token attributes
    name      = "Entropy";
    decimals  = 0;
    symbol    = "ENT";        //identifier
    safety_limit = 300 ether;

    // Add the creator as a Citizen and Guardian
    totalSupply = 1;
    balances[msg.sender] = 1;

    trusted[msg.sender] = true;

    guardians[msg.sender] = true;
    NewGuardian(msg.sender, msg.sender);
  }

  /**
   * Fallback function
   * This runs whenever ether is sent to Entropy without any other information
   */
  function() {
    buyTokens();
  }


  /**
   * Creates Entropy tokens for whoever called this method
   */
  function buyTokens() payable returns (bool success) {
    var value = msg.value;
    var buyer = msg.sender;
    if (value == 0) throw;

    // safety cap
    if (totalValue + value > safety_limit) throw;

    // 1 Ether === 1 Entropy Token
    //   Solidity will floor this by default, so sending 1.9 eth will result in
    //   1 token
    uint tokens = value / 1 ether;

    totalSupply += tokens;
    balances[buyer] += tokens;
    totalValue += value;
    Transfer(this, buyer, value);
  }

  function changeSafetyLimit(uint _new_limit) onlyGuardians returns (bool success) {
    // Limit can only be increased
    if(_new_limit < safety_limit) throw;

    // Set new safety limit
    safety_limit = _new_limit;
    SafetyLimitChange(msg.sender, _new_limit);
  }

  /**
   * Guardians 💂
   */

  // Set someone as a Guardian
  function setGuardian(address _person, bool _is_guardian)
  onlyGuardians // Only other guardians can do this
  returns (bool success) {
    guardians[_person] = _is_guardian;

    NewGuardian(_person, msg.sender);
    return true;
  }

  // Guardianship of an address
  function isGuardian(address _citizen) public constant returns (bool guardian) {
    return guardians[_citizen];
  }

  modifier onlyGuardians {
    if (isGuardian(msg.sender) == false) throw;
    _;
  }

  // Citizenship of an address
  function isCitizen(address _citizen) public constant returns (bool citizen) {
    return balanceOf(_citizen) > 0;
  }

  modifier onlyCitizens {
    if (isCitizen(msg.sender) == false) throw;
    _;
  }


  /**
   * Events
   */

  // A new guardian has been elected
  event NewGuardian(address indexed _guardian, address indexed _creator);

  // Safety Limit has been increased
  event SafetyLimitChange(address indexed _guardian, uint indexed limit);
}
