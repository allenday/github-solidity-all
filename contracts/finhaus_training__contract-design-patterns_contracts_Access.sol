/// @author hugooconnor
/// @title A shared account to demo some features of solidity, with standard tokens
/// see how to document solidity code; https://github.com/ethereum/wiki/wiki/Ethereum-Natural-Specification-Format

contract Access {

	/**
	 * Data structures
	 * members -- an array of addresses, useful for looping over
	 * member -- a mapping of addresses to Member objects
	 * Member -- a struct containing member details
   * tokenSupply -- how many tokens on issue
   * tokens -- mapping of addresses to tokens
	 */
  address[] public members;
  mapping(address => Member) public member;

  struct Member {
        uint joinDate;
        bool exists;
        bool isSpecial;
  }

  uint tokenSupply;
  mapping(address => uint) public tokens;

  	/**
	 * Events: a cheaper option than storing all data on chain - append Log to events for clarity
	 * NewMember -- will call when new member joins
	 * Spend -- will call when contract funds spent
   * Transfer -- will call when token is transfered
	 */
  event NewMemberLog(address admin, address newMember, uint joinDate, bool exists, bool isSpecial);
  event SpendLog(uint date, address recipient, uint amount);
  event TransferLog(uint date, address sender, address recipient, uint amount);

	/**
	 * Constructor -- adds msg.sender to membership, sets them as special
	 */
  function Access(){
        member[msg.sender] = Member(now, true, true);
        members.push(msg.sender);
        NewMemberLog(msg.sender, msg.sender, member[msg.sender].joinDate, member[msg.sender].exists, member[msg.sender].isSpecial);
        tokens[msg.sender] += 1000;
        tokenSupply += 1000;
  }

  	/**
	 * Function modifier -- only special members can execute _ block
	 */
  modifier onlySpecial {
      if (member[msg.sender].isSpecial) {
        _
      }
  }

	/// @notice Adds new members or sets existing members to special, onlySpecial can call
	/// @param _nominee the person we are adding as a member
	///	@param _isSpecial if they are special or not
	/// @return success if state changes
  function addMember(address _nominee, bool _setSpecial) onlySpecial returns (bool success){
  		if(!member[_nominee].exists){
            member[_nominee] = Member(now, true, _setSpecial);
            members.push(_nominee);
            tokens[_nominee] += 1000;
            tokenSupply += 1000;
            NewMemberLog(msg.sender, _nominee, member[_nominee].joinDate, member[_nominee].exists, member[_nominee].isSpecial);
            return true;
  		} else if (member[_nominee].exists && _setSpecial){
            member[_nominee].isSpecial = _setSpecial;
            return true;
  		}
      return false;
  }

	/// @notice Spends contract funds, onlySpecial can call
	/// @param _recipient who is recieving the funds
	/// @param _amount how much they are getting
	/// @return success if funds are sent
  function spend(address _recipient, uint _amount) onlySpecial returns (bool success){
  		if(this.balance >= _amount){
          if(_recipient.send(_amount)){
              SpendLog(now, _recipient, _amount);
              return true;
          }
          return false;
  		} else {
            return false;
  		}
  }

  /// @notice Gets total supply of issued tokens
  /// @return supply how many tokens are on issue
  function totalSupply() constant returns (uint256 supply){
    return tokenSupply;
  }

  /// @notice Gets the token balance of an address
  /// @param _owner whose address are we looking up
  /// @return balance how many tokens they have
  function balanceOf(address _owner) constant returns (uint256 balance){
    return tokens[_owner];
  }

  /// @notice transfers tokens between users
  /// @param _to who is the transfer to
  /// @param _value how many tokens are they transferring
  /// @return success if the transfer is successful or not
  function transfer(address _to, uint256 _value) returns (bool success){
    if(tokens[msg.sender] >= _value){
      tokens[msg.sender] -= _value;
      tokens[_to] += _value;
      TransferLog(now, msg.sender, _to, _value);
      return true;
    }
    return false;
  }
}