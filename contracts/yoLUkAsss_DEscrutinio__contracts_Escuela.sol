pragma solidity ^0.4.11;

import "./Mesa.sol";

contract Escuela {
  uint lastId;
  uint[] mesaIds;
  bytes32 delegadoDeEscuelaAsignado;
  bool mesasCreadas;
  mapping (uint => MesaStruct) mesaMapping;

  struct MesaStruct {
    uint id;
    address mesaAddress;
    uint index;
    bool isMesa;
  }

  function createMesaVerify(bytes32[] inputCandidates) public returns (bool, bytes32) {
    if (mesasCreadas) {
      return (true, "Ya existen mesas creadas");
    } else {
      return (false, "");
    }
  }
  function createMesa(uint mesaId, address mesaAddress) public{
    require(! mesasCreadas);
    mesaMapping[mesaId] = MesaStruct(mesaId, mesaAddress, mesaIds.length, true);
    mesaIds.push(mesaId);
  }

  function mesasCreatedVerify() public returns (bool, bytes32) {
    if (mesasCreadas) {
      return (true, "Mesas creadas ya validadas");
    } else {
      return (false, "");
    }
  }
  function mesasCreated() public {
    require (! mesasCreadas);
    mesasCreadas = true;
  }

  function existsMesa(uint id) public constant returns(bool){
    return mesaIds.length != 0 && mesaMapping[id].isMesa;
  }
  function getMesa(uint id) public constant returns(address){
    require(existsMesa(id));
    return mesaMapping[id].mesaAddress;
  }
  function getMesas() public constant returns(uint[]){
    return mesaIds;
  }

  function setFiscalVerify(uint mesaId, bytes32 fiscalEmail) public returns (bool, bytes32) {
    if (! existsMesa(mesaId)) {
      return (true, "ID de mesa inexistente");
    } else {
      return Mesa(mesaMapping[mesaId].mesaAddress).setFiscalVerify(fiscalEmail);
    }
  }
  function setFiscal(uint mesaId, bytes32 fiscalEmail) public {
    require(existsMesa(mesaId));
    Mesa(mesaMapping[mesaId].mesaAddress).setFiscal(fiscalEmail);
  }

  function setPresidenteDeMesaVerify(bytes32 delegadoEscuela, uint mesaId, bytes32 presidenteDeMesaEmail) public returns (bool, bytes32) {
    if (! existsMesa(mesaId)) {
      return (true, "ID de mesa inexistente");
    }
    if (delegadoDeEscuelaAsignado != delegadoEscuela) {
      return (true, "Debe ser delegado de escuela");
    } else {
      return Mesa(mesaMapping[mesaId].mesaAddress).setPresidenteDeMesaVerify(presidenteDeMesaEmail);
    }
  }
  function setPresidenteDeMesa(bytes32 delegadoEscuela, uint mesaId, bytes32 presidenteDeMesaEmail) public {
    require(existsMesa(mesaId));
    require(delegadoDeEscuelaAsignado == delegadoEscuela);
    Mesa(mesaMapping[mesaId].mesaAddress).setPresidenteDeMesa(presidenteDeMesaEmail);
  }

  function setVicepresidenteDeMesa(bytes32 delegadoEscuela, uint mesaId, bytes32 presidenteDeMesaEmail) public {
    require(existsMesa(mesaId));
    require(delegadoDeEscuelaAsignado == delegadoEscuela);
    Mesa(mesaMapping[mesaId].mesaAddress).setVicepresidenteDeMesa(presidenteDeMesaEmail);
  }

  function setDelegadoDeEscuelaVerify(bytes32 newDelegadoDeEscuela) public returns (bool, bytes32) {
    if (delegadoDeEscuelaAsignado != "") {
      return (true, "Ya hay delegado asignado");
    } else {
      return (false, "");
    }
  }
  function setDelegadoDeEscuela(bytes32 newDelegadoDeEscuela) public {
    require(delegadoDeEscuelaAsignado == "");
    delegadoDeEscuelaAsignado = newDelegadoDeEscuela;
  }
}
