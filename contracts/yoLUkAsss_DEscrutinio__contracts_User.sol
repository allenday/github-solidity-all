pragma solidity ^0.4.11;

contract User{
    // enum UserCategory {AutoridadElectoral, DelegadoDistrito, DelegadoEscolar, PresidenteMesa, VicepresidenteMesa, ApoderadoPartido, Fiscal}
  //AutoridadElectoral 0
  //DelegadoDistrito 1
  //DelegadoEscolar 2
  //ApoderadoPartido 3
  //PresidenteMesa 4
  //VicepresidenteMesa 5
  //Fiscal 6
  // Usuario General 7

    uint idDistrito;
    uint idEscuela;
    uint idMesa;

    bytes32 public email;
    bytes32 public password;
    bool public isLogged;
    uint category;

    function User(bytes32 e, bytes32 pass, uint cat) public {
        email = e;
        password = pass;
        category = cat;
    }
    function getUser() public constant returns(address, bytes32, uint, uint, uint, uint){
      return (this, email, category, idDistrito, idEscuela, idMesa);
    }



/////////////////////////////////////////////////////////////////////////////////////////////////
    function loginVerify(bytes32 pass) public returns (bool,bytes32){
        if(password != pass) {
            return (true, "Contraseña incorrecta");
        } else {
            return (false, "");
        }
    }
    function login(bytes32 pass) public{
        if(password != pass) revert();
        isLogged = true;
    }
/////////////////////////////////////////////////////////////////////////////////////////////////




    function logout() public {
        isLogged = false;
    }
    function isAutoridadElectoral() public constant returns(bool){
        return category == 0;
    }
    function isPresidenteDeMesa() public constant returns(bool){
        return category == 4;
    }
    function isFiscal() public constant returns(bool){
        return category == 6;
    }
    function destroy(address parent) public {
        selfdestruct(parent);
    }



/////////////////////////////////////////////////////////////////////////////////////////////////
    function setCategoryVerify(uint cat) public returns (bool, bytes32) {
        if (category != 7) {
            return (true, "Usuario posee otra categoria");
        } else {
            return (false, "");
        }
    }
    function setCategory(uint cat) public {
      category = cat;
    }
/////////////////////////////////////////////////////////////////////////////////////////////////

    
    
    function setDistrito(uint id) public {
      idDistrito = id;
    }
    function setEscuela(uint id) public {
      idEscuela = id;
    }
    function setMesa(uint id) public {
      idMesa = id;
    }
}
