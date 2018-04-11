pragma solidity ^0.4.11;

import "./Escuela.sol";

contract Distrito {


  uint lastEscuelaId;
  uint[] escuelaIds;
  mapping (uint => EscuelaStruct) escuelaMapping;
  bytes32 delegadoDeDistritoAsignado;


  struct EscuelaStruct {
    uint id;
    address escuelaAddress;
    uint index;
    bool isEscuela;
  }

  function createEscuela(uint escuelaId, address escuelaAddress) public {
    escuelaMapping[escuelaId] = EscuelaStruct(escuelaId, escuelaAddress, escuelaIds.length, true);
    escuelaIds.push(escuelaId);
  }
  function getEscuela(uint id) public constant returns(address){
    require(existsEscuela(id));
    return escuelaMapping[id].escuelaAddress;
  }
  function existsEscuela(uint id) public constant returns(bool){
    return escuelaIds.length != 0 && escuelaMapping[id].isEscuela;
  }
  function getEscuelas() public constant returns(uint[]){
    return escuelaIds;
  }
  function getMesa(uint escuelaId, uint mesaId) constant public returns(address){
    require(existsEscuela(escuelaId));
    return Escuela(escuelaMapping[escuelaId].escuelaAddress).getMesa(mesaId);
  }

  function setFiscalVerify(uint escuelaId, uint mesaId, bytes32 fiscalEmail) public returns (bool, bytes32) {
    if (! existsEscuela(escuelaId)) {
      return (true, "ID de escuela inexistente");
    } else {
      return Escuela(escuelaMapping[escuelaId].escuelaAddress).setFiscalVerify(mesaId, fiscalEmail);
    }
  }
  function setFiscal(uint escuelaId, uint mesaId, bytes32 fiscalEmail) public {
    require(existsEscuela(escuelaId));
    Escuela(escuelaMapping[escuelaId].escuelaAddress).setFiscal(mesaId, fiscalEmail);
  }
  function setPresidenteDeMesaVerify(bytes32 delegadoEscuela, uint escuelaId, uint mesaId, bytes32 presidenteDeMesaEmail) public returns (bool, bytes32) {
    if (! existsEscuela(escuelaId)) {
      return (true, "ID de escuela inexistente");
    } else {
      return Escuela(escuelaMapping[escuelaId].escuelaAddress).setPresidenteDeMesaVerify(delegadoEscuela, mesaId, presidenteDeMesaEmail);
    }
  }
  function setPresidenteDeMesa(bytes32 delegadoEscuela, uint escuelaId, uint mesaId, bytes32 presidenteDeMesaEmail) public {
    require(existsEscuela(escuelaId));
    Escuela(escuelaMapping[escuelaId].escuelaAddress).setPresidenteDeMesa(delegadoEscuela, mesaId, presidenteDeMesaEmail);
  }
  function setVicepresidenteDeMesa(bytes32 delegadoEscuela, uint escuelaId, uint mesaId, bytes32 presidenteDeMesaEmail) public {
    require(existsEscuela(escuelaId));
    Escuela(escuelaMapping[escuelaId].escuelaAddress).setVicepresidenteDeMesa(delegadoEscuela, mesaId, presidenteDeMesaEmail);
  }
  function setDelegadoDeDistritoVerify(bytes32 newDelegado) public returns (bool, bytes32) {
    if (delegadoDeDistritoAsignado != "") {
      return (true, "Ya existe delegado asignado");
    } else {
      return (false, "");
    }
  }
  function setDelegadoDeDistrito(bytes32 newDelegado) public {
    require(delegadoDeDistritoAsignado == "");
    delegadoDeDistritoAsignado = newDelegado;
  }
  function setDelegadoDeEscuelaVerify(bytes32 delegadoDistrito, bytes32 delegadoEscuela, uint escuelaId) public returns (bool, bytes32) {
    if (delegadoDeDistritoAsignado != delegadoDistrito) {
      return (true, "Debe ser delegado de distrito");
    } else {
      return Escuela(escuelaMapping[escuelaId].escuelaAddress).setDelegadoDeEscuelaVerify(delegadoEscuela);
    }
  }
  function setDelegadoDeEscuela(bytes32 delegadoDistrito, bytes32 delegadoEscuela, uint escuelaId) public {
    require(delegadoDeDistritoAsignado == delegadoDistrito);
    Escuela(escuelaMapping[escuelaId].escuelaAddress).setDelegadoDeEscuela(delegadoEscuela);
  }
}
