pragma solidity ^0.4.11;

import "./UserElectionCRUD.sol";
import "./DistritoCRUD.sol";
import "./Counts.sol";

contract Election {


    address owner;
    address distritoCRUDaddress;
    address userCRUDaddress;

    address countsAddress;
    uint distritos;
    uint escuelas;
    uint mesas;

    mapping (bytes32 => bytes32) apoderados;
    mapping (bytes32 => bytes32) partidos;

    bool public created;
    bytes32 autoridadElectoralAsignada;
    bytes32[] candidates;

    function Election (address newUserCRUDaddress, address newDistritoCRUDaddress, address newCountsAddress) public {
      owner = msg.sender;
      userCRUDaddress = newUserCRUDaddress;
      distritoCRUDaddress = newDistritoCRUDaddress;
      countsAddress = newCountsAddress;
    }
    function createElectionVerify(bytes32 email, bytes32[] newCandidates) external returns (bool, bytes32) {
      if (created) {
        return (true, "La elección se encuentra creada");
      }
      if (autoridadElectoralAsignada != "") {
        return (true, "Ya existe autoridad electoral");
      }
      if (newCandidates.length < 2) {
        return (true, "Los candidatos deben ser 2+");
      } else {
        return (false, "");
      }
    }
    function createElection(bytes32 email, bytes32[] newCandidates) external {
      require(!created && autoridadElectoralAsignada == "");
      candidates = newCandidates;
      for (uint8 index = 0; index<candidates.length; index++ ) {
          apoderados[candidates[index]] = "";
      }
      UserElectionCRUD(userCRUDaddress).setAutoridadElectoral(email);
      autoridadElectoralAsignada = email;
      Counts(countsAddress).init(candidates);
    }

    function setElectionInfo(uint cantidadDistritos, uint cantidadEscuelas, uint cantidadMesas) public {
      require(!created);
      created = true;
      distritos = cantidadDistritos;
      escuelas = cantidadEscuelas;
      mesas = cantidadMesas;
    }

    function getElectionInfo() constant public returns(bool,uint,uint,uint, bytes32[]){
      return (created, distritos, escuelas, mesas, candidates);
    }

    function verifyAutoridadElectoral(bytes32 email) public returns(bool){
      return autoridadElectoralAsignada == email;
    }

    function getCandidates() public constant returns(bytes32[]) {
      return candidates;
    }

    function getCandidateForApoderado (bytes32 apoderado) public constant returns (bytes32) {
      return partidos[apoderado];
    }

    function isValidCandidate(bytes32 candidate) public constant returns(bool){
      for(uint8 index = 0; index < candidates.length; index++){
        if(candidates[index] == candidate){
          return true;
        }
      }
      return false;
    }

    function setApoderadoVerify(bytes32 autoridadElectoral, bytes32 apoderado, bytes32 candidato) public returns (bool, bytes32) {
      if (autoridadElectoralAsignada != autoridadElectoral) {
        return (true, "Debe ser autoridad electoral");
      }
      if (apoderados[candidato] != "") {
        return (true, "Ya existe apoderado asignado");
      }
      if (!isValidCandidate(candidato)) {
        return (true, "Candidato no existe");
      } else {
        return UserElectionCRUD(userCRUDaddress).setApoderadoVerify(apoderado);
      }
    }
    function setApoderado(bytes32 autoridadElectoral, bytes32 apoderado, bytes32 candidato) public {
        require(autoridadElectoralAsignada == autoridadElectoral && apoderados[candidato] == "" && isValidCandidate(candidato));
        apoderados[candidato] = apoderado;
        partidos[apoderado] = candidato;
        UserElectionCRUD(userCRUDaddress).setApoderado(apoderado);
    }

    function setDelegadoDeDistritoVerify(bytes32 autoridadElectoral, bytes32 delegadoDistrito, uint8 idDistrito) public returns (bool, bytes32) {
      if (autoridadElectoralAsignada != autoridadElectoral) {
        return (true, "Debe ser autoridad electoral");
      } else {
        bool huboError;
        bytes32 mensaje;
        (huboError, mensaje) = UserElectionCRUD(userCRUDaddress).setDelegadoDeDistritoVerify(delegadoDistrito, idDistrito);
        if (huboError) {
          return (huboError, mensaje);
        } else {
          return DistritoCRUD(distritoCRUDaddress).setDelegadoDeDistritoVerify(delegadoDistrito, idDistrito);
        }
      }
    }
    function setDelegadoDeDistrito(bytes32 autoridadElectoral, bytes32 delegadoDistrito, uint8 idDistrito) public {
        require(autoridadElectoralAsignada == autoridadElectoral);
        UserElectionCRUD(userCRUDaddress).setDelegadoDeDistrito(delegadoDistrito, idDistrito);
        DistritoCRUD(distritoCRUDaddress).setDelegadoDeDistrito(delegadoDistrito, idDistrito);
    }

    function setDelegadoDeEscuelaVerify(bytes32 delegadoDistrito, bytes32 delegadoEscuela, uint8 idDistrito, uint8 idEscuela) public returns (bool, bytes32) {
      bool huboError;
      bytes32 mensaje;
      (huboError, mensaje) = UserElectionCRUD(userCRUDaddress).setDelegadoDeEscuelaVerify(delegadoEscuela, idDistrito, idEscuela);
      if (huboError) {
        return (huboError, mensaje);
      } else {
        return DistritoCRUD(distritoCRUDaddress).setDelegadoDeEscuelaVerify(delegadoDistrito, delegadoEscuela, idDistrito, idEscuela);
      }
    }
    function setDelegadoDeEscuela(bytes32 delegadoDistrito, bytes32 delegadoEscuela, uint8 idDistrito, uint8 idEscuela) public {
        UserElectionCRUD(userCRUDaddress).setDelegadoDeEscuela(delegadoEscuela, idDistrito, idEscuela);
        DistritoCRUD(distritoCRUDaddress).setDelegadoDeEscuela(delegadoDistrito, delegadoEscuela, idDistrito, idEscuela);
    }

    function setPresidenteDeMesaVerify(bytes32 delegadoEscuela, uint distritoId, uint escuelaId, uint mesaId, bytes32 presidenteDeMesaEmail) public returns (bool, bytes32) {
      bool huboError;
      bytes32 mensaje;
      (huboError, mensaje) = UserElectionCRUD(userCRUDaddress).setPresidenteDeMesaVerify(presidenteDeMesaEmail, distritoId, escuelaId, mesaId);
      if (huboError) {
        return (huboError, mensaje);
      } else {
        return DistritoCRUD(distritoCRUDaddress).setPresidenteDeMesaVerify(delegadoEscuela, distritoId, escuelaId, mesaId, presidenteDeMesaEmail);
      }
    }
    function setPresidenteDeMesa(bytes32 delegadoEscuela, uint distritoId, uint escuelaId, uint mesaId, bytes32 presidenteDeMesaEmail) public {
      UserElectionCRUD(userCRUDaddress).setPresidenteDeMesa(presidenteDeMesaEmail, distritoId, escuelaId, mesaId);
      DistritoCRUD(distritoCRUDaddress).setPresidenteDeMesa(delegadoEscuela, distritoId, escuelaId, mesaId, presidenteDeMesaEmail);
    }
    function setVicepresidenteDeMesa(bytes32 delegadoEscuela, uint distritoId, uint escuelaId, uint mesaId, bytes32 presidenteDeMesaEmail) public {
      UserElectionCRUD(userCRUDaddress).setVicepresidenteDeMesa(presidenteDeMesaEmail, distritoId, escuelaId, mesaId);
      DistritoCRUD(distritoCRUDaddress).setVicepresidenteDeMesa(delegadoEscuela, distritoId, escuelaId, mesaId, presidenteDeMesaEmail);
    }

    function setFiscalVerify(bytes32 apoderadoDePartido, bytes32 candidato, bytes32 fiscalEmail, uint distritoId, uint escuelaId, uint mesaId) public returns (bool, bytes32) {
      if (apoderados[candidato] != apoderadoDePartido) {
        return (true, "Debe ser apoderado del partido");
      } else {
        bool huboError;
        bytes32 mensaje;
        (huboError, mensaje) = UserElectionCRUD(userCRUDaddress).setFiscalVerify(fiscalEmail, distritoId, escuelaId, mesaId);
        if (huboError) {
          return (huboError, mensaje);
        } else {
          return DistritoCRUD(distritoCRUDaddress).setFiscalVerify(distritoId, escuelaId, mesaId, fiscalEmail);
        }
      }
    }
    function setFiscal(bytes32 apoderadoDePartido, bytes32 candidato, bytes32 fiscalEmail, uint distritoId, uint escuelaId, uint mesaId) public {
      require(apoderados[candidato] == apoderadoDePartido);
      UserElectionCRUD(userCRUDaddress).setFiscal(fiscalEmail, distritoId, escuelaId, mesaId);
      DistritoCRUD(distritoCRUDaddress).setFiscal(distritoId, escuelaId, mesaId, fiscalEmail);
    }

    function getDistrito(uint id) constant public returns(address){
      return DistritoCRUD(distritoCRUDaddress).getDistrito(id);
    }
    function getEscuela(uint distritoId, uint escuelaId) constant public returns(address){
      return DistritoCRUD(distritoCRUDaddress).getEscuela(distritoId, escuelaId);
    }
    function getMesa(uint distritoId, uint escuelaId, uint mesaId) constant public returns(address){
      return DistritoCRUD(distritoCRUDaddress).getMesa(distritoId, escuelaId, mesaId);
    }
}
