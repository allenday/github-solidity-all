pragma solidity ^0.4.11;

import "./User.sol";

contract UserCRUD {
  enum UserCategory {AutoridadElectoral, DelegadoDistrito, DelegadoEscolar, PresidenteMesa, VicepresidenteMesa, ApoderadoPartido, Fiscal}
  //AutoridadElectoral 0
  //DelegadoDistrito 1
  //DelegadoEscolar 2
  //ApoderadoPartido 3
  //PresidenteMesa 4
  //VicepresidenteMesa 5
  //Fiscal 6
  struct UserStruct{
    uint id;
    address userAddress;
    uint index;
    bool isUser;
  }

  address owner;
  uint[] userIds;
  uint lastId;
  mapping (uint => UserStruct) userMapping;

  function UserCRUD () public{
      owner = msg.sender;
  }
  function createUser(bytes32 email, bytes32 password, uint category) public{
    lastId += 1;
    address userCreatedAddress = new User(email, password, category);
    userMapping[lastId] = UserStruct(lastId, userCreatedAddress, userIds.length, true);
    userIds.push(lastId);
    LogCreateUser(msg.sender, lastId, userCreatedAddress);
  }
  function existsUser(uint id) public constant returns(bool){
    return userIds.length != uint256(0) && userMapping[id].isUser;
  }
  /*Devuelve la lista con los id de todos los usuarios*/
  function getUsers() public constant returns(uint[]){
    return userIds;
  }

  function getUser(uint id) public constant returns(address){
    if(!existsUser(id)) revert();
    return userMapping[id].userAddress;
  }

  function deleteUser(uint id) public{
    if(!existsUser(id)) revert();
    uint toDelete = userMapping[id].index;
    uint idToMove = userIds[userIds.length - 1];
    userIds[toDelete] = idToMove;
    userMapping[idToMove].index = toDelete;
    userIds.length--;
    User(userMapping[id].userAddress).destroy(owner);
    delete userMapping[id];
    LogDeleteUser(msg.sender, id);
  }

  /*Geerate a event function for each function that modify the blockchain
  * ex: createUser
  */

  event LogCreateUser(address indexed senderAddress, uint userId, address userAddress);
  event LogDeleteUser(address indexed senderAddress, uint userId);

}
