pragma solidity ^0.4.11;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

//contract Owned {
//  address public owner;
//
//  modifier onlyOwner() {
//    require(msg.sender == owner);
//    _;
//  }
//
//  function Owned(){
//    owner = msg.sender;
//  }
//
//  function changeOwnship(address _to) onlyOwner {
//    require(_to != 0x0);
//    owner = _to;
//  }
//
//  function kill() onlyOwner {
//    selfdestruct(owner);
//  }
//}


contract CypressOrganization is Ownable {

    uint public creationTime; // The contract organization creation time.
    uint public totalTokens; // Total supply of Tokens

    struct Member {
      bytes name;
      uint   token;
      address account;
    }

    /// Keep record of registered account
    mapping(address => bool) registered;

    Member[] members;   // Organization members

    /// Guard the transition after a specific time
    modifier onlyAfter(uint _time) {
        require(now >= _time);
        _;
    }


    function CypressOrganization(bytes _name, uint _amount) onlyOwner payable {
        require(_amount > 100);
        totalTokens = _amount;  // initialize the total amount of tokens (shares)
        owner = msg.sender;
        members.push(Member({
            name: _name,
            token: _amount,
            account: owner
            }
        ));
        registered[owner] = true;
        creationTime = now;
    }

    /// check if the account is registered.
    function isRegistered(address _account) constant returns (bool yes) {
//        if (registered[_account].length == 0) return false;
        return registered[_account];
    }

    /// Register a member, assign tokens to him.
    function registerMember(address _member, bytes _name, uint _token)
      onlyOwner
      returns (bool success) {
        // validate the input parameter
        require(_member != 0x0 && _token > 0);
        // check if the member is already registered
        require(!isRegistered(_member));

        // check if there is enough tokens to assign to the member.
        require(members[0].token > _token);

        members.push(Member({name: _name, token: _token, account: _member}));
        members[0].token -= _token;

        registered[_member] = true;
        return true;
    }

    /// Distribute Ether balance to all the members in the Organization.
    function distributeEther() onlyOwner payable returns (bool success){
      // check the Ether balance. If the balance >= 100 finney (0.1 ether), then distribute
        if (this.balance < 100 finney) { // balance is too small for distribution.
            return false;
        } else {
            uint sharePerToken = this.balance / totalTokens;
            for (var i = 0; i < members.length; i++) {
                members[i].account.transfer(sharePerToken * members[i].token);      // send the Ether share to the member
            }
        }
        return true;
    }
}

