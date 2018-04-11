pragma solidity ^0.4.0;
import {Node} from "node.sol";

contract Reddit is Node{

  mapping(address => uint) payments;
  /* User enrollment */
  mapping(address => bool) enrollment;
  /* Enrolled users */
  address[] users;
  /* Public Key, private */
  bytes public publicKey;
  /* How many people can the service hold ? */
  uint public maxUsers;
  /* How much is the service ? */
  uint public price;

  event Enrollment(address indexed userAddress,bytes publicKey);
  event Payment(address sender,uint price);

  function Reddit(uint _maxUsers,uint _price,bytes _publicKey,bytes _ipfsHash){
    owner     = msg.sender;
    maxUsers  = _maxUsers;
    price     = _price;
    /* When the Reddit service sends data, it will encrypt it with the public key*/
    publicKey = _publicKey;
    /* Reddit have any child entities, nor does cmkt support that*/
    maxLinks  = 0;
    /* set the ipfs ipfsHash */
    ipfsHash    = _ipfsHash;
    /* vendorCount 0 */
    linkCount   = 0;
  }

  function payServiceProvider() payable returns (bool){
    if ( price != msg.value || enrollment[msg.sender] == false) { 
     /* if the sent value is not the price, then throw :) */
      throw;
    } else {
      /* else record the payment */
      payments[msg.sender] = payments[msg.sender] + 1;
      Payment(msg.sender,price);
      return true;
    }
  }

  function collectPayments() returns (bool){
    uint accum = 0;
    if ( msg.sender == owner){
      for (uint i = 0;i < users.length; i++){
	if (payments[users[i]] > 0) {
	  // collect if user has at least 1 paymetng
	  accum += price;
	  // decrement their payments
	  payments[users[i]] -= 1;
	}
      }
      if ( accum > 0 ) {
	if(!msg.sender.send(accum)){
	  // undo all of the junk from above
	  throw;
	} else {
	  // success getting paid
	  return true;
	}
      } else {
	// no funds accumulated
	return false;
      }
    } else {
      // boo not the owner
      return false;
    }
  }

  function sumPayments() constant returns (uint){
    uint accum = 0;
    for (uint i = 0;i < users.length; i++){
      if (payments[users[i]] > 0) {
	// collect if user has at least 1 payment
	accum += price;
      }
    }
    return accum;
  }

  function getPaymentsFor(address user) constant returns (uint){
    if ( enrollment[user] == true){
      return price * payments[user];
    } else {
      throw;
    }
  }

  /*function getUsers() constant returns (address[]){
    if ( msg.sender == owner ){
      return users;
    } else {
      throw;
    }
    }*/

  function getUsersLength() constant returns (uint){
    return users.length;
  }

  // this will get more features in the future
  function enrollUser(address user) returns (bool){
    if ( msg.sender == owner && enrollment[user] == false && maxUsers > users.length){
      // enroller must be owner, value must be equal to or greater than price, must not already be enrolled, not full
      // enroll the user
      enrollment[user] = true;
      // set payments to zero
      payments[user]   = 0;
      // add their name to the roster
      users.push(user);
      Enrollment(user,publicKey);
      return true;
    } else {
      throw;
    }
  }
  
}


  
