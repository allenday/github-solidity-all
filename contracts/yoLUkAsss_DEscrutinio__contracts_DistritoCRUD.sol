pragma solidity ^0.4.11;

import "./Distrito.sol";

contract DistritoCRUD {

  uint[] distritoIds;
  mapping (uint => DistritoStruct) distritoMapping;

  struct DistritoStruct {
    uint id;
    address distritoAddress;
    uint index;
    bool isDistrito;
  }

  mapping (bytes32 => uint) counting;

  function createDistritoVerify(uint distritoId) public returns (bool, bytes32) {
    if (existsDistrito(distritoId)) {
      return (true, "Distrito ya creado");
    } else {
      return (false, "");
    }
  }
  function createDistrito(uint distritoId, address distritoAddress) public {
    require(! existsDistrito(distritoId));
    distritoMapping[distritoId] = DistritoStruct(distritoId, distritoAddress, distritoIds.length, true);
    distritoIds.push(distritoId);
  }

  function getDistrito(uint id) public constant returns(address){
    require(existsDistrito(id));
    return distritoMapping[id].distritoAddress;
  }
  function existsDistrito(uint id) public constant returns(bool){
    return distritoIds.length != 0 && distritoMapping[id].isDistrito;
  }
  function getDistritos() public constant returns(uint[]){
    return distritoIds;
  }

  function getEscuela(uint distritoId, uint escuelaId) public constant returns(address){
    require(existsDistrito(distritoId));
    return Distrito(distritoMapping[distritoId].distritoAddress).getEscuela(escuelaId);
  }
  function getMesa(uint distritoId, uint escuelaId, uint mesaId) constant public returns(address){
    require(existsDistrito(distritoId));
    return Distrito(distritoMapping[distritoId].distritoAddress).getMesa(escuelaId, mesaId);
  }

  function setFiscalVerify(uint distritoId, uint escuelaId, uint mesaId, bytes32 fiscalEmail) public returns (bool, bytes32) {
    if (! existsDistrito(distritoId)) {
      return (true, "ID de distrito inexistente");
    } else {
      return Distrito(distritoMapping[distritoId].distritoAddress).setFiscalVerify(escuelaId, mesaId, fiscalEmail);
    }
  }
  function setFiscal(uint distritoId, uint escuelaId, uint mesaId, bytes32 fiscalEmail) public {
    require(existsDistrito(distritoId));
    Distrito(distritoMapping[distritoId].distritoAddress).setFiscal(escuelaId, mesaId, fiscalEmail);
  }
  function setDelegadoDeDistritoVerify(bytes32 delegadoDeDistrito, uint distritoId) public returns (bool, bytes32) {
    if (! existsDistrito(distritoId)) {
      return (true, "ID de distrito inexistente");
    } else {
      return Distrito(distritoMapping[distritoId].distritoAddress).setDelegadoDeDistritoVerify(delegadoDeDistrito);
    }
  }
  function setDelegadoDeDistrito(bytes32 delegadoDeDistrito, uint distritoId) public {
    require(existsDistrito(distritoId));
    Distrito(distritoMapping[distritoId].distritoAddress).setDelegadoDeDistrito(delegadoDeDistrito);
  }

  function setDelegadoDeEscuelaVerify(bytes32 delegadoDistrito, bytes32 delegadoEscuela, uint distritoId, uint idEscuela) public returns (bool, bytes32) {
    if (! existsDistrito(distritoId)) {
      return (true, "ID de distrito inexistente");
    } else {
      return Distrito(distritoMapping[distritoId].distritoAddress).setDelegadoDeEscuelaVerify(delegadoDistrito, delegadoEscuela, idEscuela);
    }
  }
  function setDelegadoDeEscuela(bytes32 delegadoDistrito, bytes32 delegadoEscuela, uint distritoId, uint idEscuela) public {
    require(existsDistrito(distritoId));
    Distrito(distritoMapping[distritoId].distritoAddress).setDelegadoDeEscuela(delegadoDistrito, delegadoEscuela, idEscuela);
  }

  function setPresidenteDeMesaVerify(bytes32 delegadoEscuela, uint distritoId, uint escuelaId, uint mesaId, bytes32 presidenteDeMesaEmail) public returns (bool, bytes32) {
    if (! existsDistrito(distritoId)) {
      return (true, "ID de distrito inexistente");
    } else {
      return Distrito(distritoMapping[distritoId].distritoAddress).setPresidenteDeMesaVerify(delegadoEscuela, escuelaId, mesaId, presidenteDeMesaEmail);
    }
  }
  function setPresidenteDeMesa(bytes32 delegadoEscuela, uint distritoId, uint escuelaId, uint mesaId, bytes32 presidenteDeMesaEmail) public {
    require(existsDistrito(distritoId));
    Distrito(distritoMapping[distritoId].distritoAddress).setPresidenteDeMesa(delegadoEscuela, escuelaId, mesaId, presidenteDeMesaEmail);
  }

  function setVicepresidenteDeMesa(bytes32 delegadoEscuela, uint distritoId, uint escuelaId, uint mesaId, bytes32 presidenteDeMesaEmail) public {
    require(existsDistrito(distritoId));
    Distrito(distritoMapping[distritoId].distritoAddress).setVicepresidenteDeMesa(delegadoEscuela, escuelaId, mesaId, presidenteDeMesaEmail);
  }
}
