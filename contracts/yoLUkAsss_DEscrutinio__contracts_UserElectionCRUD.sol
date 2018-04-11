pragma solidity ^0.4.11;

import "./UserCRUD.sol";
import "./User.sol";

contract UserElectionCRUD is UserCRUD{

  /*functions defined to be used for election contract*/
    mapping (bytes32 => uint) public emailMap;

    function signupVerify(bytes32 email, bytes32 pass) public returns (bool,bytes32){
        return createUserByEmailVerify(email, pass, 7);
    }
    function signup(bytes32 email, bytes32 pass) public {
        createUserByEmail(email, pass, 7);
    }

    function createUserByEmailVerify(bytes32 email, bytes32 password, uint category) internal returns (bool,bytes32) {
        if(existsUser(emailMap[email])) {
          return (true, "Usuario se encuentra en uso");
        } else {
          return (false, "");
        }
    }
    function createUserByEmail(bytes32 email, bytes32 password, uint category) internal {
        if(existsUser(emailMap[email])) revert();
        createUser(email, password, category);
        emailMap[email] = lastId;
    }

    function deleteUserByEmail(bytes32 email) public {
        if(!existsUser(emailMap[email])) revert();
        deleteUser(emailMap[email]);
        delete emailMap[email];
    }

    function existsUserByEmail(bytes32 email) public constant returns(bool){
        return emailMap[email] != 0;
    }

    function createAutoridadElectoral(bytes32 email, bytes32 password) public {
        createUserByEmail(email, password, 0);
    }

    function getUserByEmailVerify(bytes32 email) public constant returns(bool,bytes32){
      if(!existsUserByEmail(email)) {
        return (true, "Usuario inexistente");
      } else {
        return (false, "");
      }
    }

    function getUserByEmail(bytes32 email) public constant returns(address){
      if(!existsUserByEmail(email)) revert();
      return getUser(emailMap[email]);
    }
    /*
    FUNCIONALIDAD: setear roles,
    quizas para mantener la transaccionabilidad y seguridad sobre los unicos usuarios q puedan realizar
    esta operacion, sea mejor dejar el conjunto de funciones q esta conlleva en election
    */
    function setAutoridadElectoral(bytes32 email) public {
      User(getUserByEmail(email)).setCategory(0);
    }

    function setDelegadoDeDistritoVerify(bytes32 email, uint idDistrito) public returns (bool, bytes32) {
      if(! existsUser(emailMap[email])) {
        return (true, "Usuario inexistente");
      } else {
        return User(getUserByEmail(email)).setCategoryVerify(1);
      }
    }
    function setDelegadoDeDistrito(bytes32 email, uint idDistrito) public {
      User(getUserByEmail(email)).setCategory(1);
      User(getUserByEmail(email)).setDistrito(idDistrito);
    }

    function setDelegadoDeEscuelaVerify(bytes32 email, uint idDistrito, uint idEscuela) public returns (bool, bytes32) {
      if(! existsUser(emailMap[email])) {
        return (true, "Usuario inexistente");
      } else {
        return User(getUserByEmail(email)).setCategoryVerify(2);
      }
    }
    function setDelegadoDeEscuela(bytes32 email, uint idDistrito, uint idEscuela) public {
      User(getUserByEmail(email)).setCategory(2);
      User(getUserByEmail(email)).setDistrito(idDistrito);
      User(getUserByEmail(email)).setEscuela(idEscuela);
    }

    function setApoderadoVerify(bytes32 email) public returns (bool, bytes32) {
      if(! existsUser(emailMap[email])) {
        return (true, "Usuario inexistente");
      } else {
        return User(getUserByEmail(email)).setCategoryVerify(3);
      }
    }
    function setApoderado(bytes32 email) public {
      User(getUserByEmail(email)).setCategory(3);
    }

    function setPresidenteDeMesaVerify(bytes32 email, uint idDistrito, uint idEscuela, uint idMesa) public returns (bool, bytes32) {
      if(! existsUser(emailMap[email])) {
        return (true, "Usuario inexistente");
      } else {
        return User(getUserByEmail(email)).setCategoryVerify(3);
      }
    }

    function setPresidenteDeMesa(bytes32 email, uint idDistrito, uint idEscuela, uint idMesa) public {
      User(getUserByEmail(email)).setCategory(4);
      User(getUserByEmail(email)).setDistrito(idDistrito);
      User(getUserByEmail(email)).setEscuela(idEscuela);
      User(getUserByEmail(email)).setMesa(idMesa);
    }

    function setVicepresidenteDeMesa(bytes32 email, uint idDistrito, uint idEscuela, uint idMesa) public {
      User(getUserByEmail(email)).setCategory(5);
      User(getUserByEmail(email)).setDistrito(idDistrito);
      User(getUserByEmail(email)).setEscuela(idEscuela);
      User(getUserByEmail(email)).setMesa(idMesa);
    }

    function setFiscalVerify(bytes32 email, uint idDistrito, uint idEscuela, uint idMesa) public returns (bool, bytes32) {
      if(! existsUser(emailMap[email])) {
        return (true, "Usuario inexistente");
      } else {
        return User(getUserByEmail(email)).setCategoryVerify(6);
      }
    }
    function setFiscal(bytes32 email, uint idDistrito, uint idEscuela, uint idMesa) public {
      User(getUserByEmail(email)).setCategory(6);
      User(getUserByEmail(email)).setDistrito(idDistrito);
      User(getUserByEmail(email)).setEscuela(idEscuela);
      User(getUserByEmail(email)).setMesa(idMesa);
    }
}
