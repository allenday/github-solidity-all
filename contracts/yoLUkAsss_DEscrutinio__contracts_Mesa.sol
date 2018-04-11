pragma solidity ^0.4.11;

import "./Counts.sol";

contract Mesa {

    enum ParticipantCategory {Fiscal, PresidenteMesa, VicepresidenteMesa}
    ////////////////////////////////////////
    bool public checked;
    uint public cantidadDePersonas;
    address countsAddress;
    bytes32[] candidateList;
    bytes32[] participantList;
    bytes32 public presidenteDeMesaAsignado;
    bytes32 public vicepresidenteDeMesaAsignado;
    bool private existPresidenteMesa;
    bool private existVicepresidenteMesa;
    mapping (bytes32 => ParticipantData) participantMap;
    mapping (bytes32 => CandidateData) candidateMap;
    //Datos cargados y validados al sistema
    //Conteo de un partipante (fiscal/presidente/vice) para todos los candidatos
    struct ParticipantData {
      bool isValidParticipant;
      ParticipantCategory category;
      bool checked;
      mapping (bytes32 => uint8) votes;
    }
    struct CandidateData {
      bool isValidCandidate;
      uint8 votes;
    }
    function Mesa(bytes32[] inputCandidates, uint newCantidadDePersonas, address newCountsAddress) public{
      countsAddress = newCountsAddress;
      candidateList = inputCandidates;
      for(uint8 i=0;i<inputCandidates.length;i++){
        candidateMap[inputCandidates[i]] = CandidateData(true, 0);
      }
      cantidadDePersonas = newCantidadDePersonas;
    }

    function addParticipantVerify(bytes32 p, ParticipantData pd) internal returns (bool, bytes32) {
      if(participantMap[p].isValidParticipant) {
        return (true, "Participante ya asignado");
      } else {
        return (false, "");
      }
    }
    function addParticipant(bytes32 p, ParticipantData pd) internal {
      if(participantMap[p].isValidParticipant) revert();
      participantMap[p] = pd;
      participantList.push(p);
    }
    function getCandidatesList() public constant returns (bytes32[]){
        return candidateList;
    }
    function getParticipantList() public constant returns (bytes32[]){
        return participantList;
    }

    function getCounting ( bytes32 participant ) public constant returns (bytes32, bytes32[], uint8[], bool) {
      require(isValidParticipant(participant));
      bytes32[] memory resultCandidatos = new bytes32[](candidateList.length);
      uint8[] memory resultConteos = new uint8[](candidateList.length);
      for (uint8 i=0 ; i<candidateList.length ; i++) {
        resultCandidatos[i] = candidateList[i];
        resultConteos[i] = participantMap[participant].votes[candidateList[i]];
      }
      return (participant, resultCandidatos, resultConteos, participantMap[participant].checked);
    }

/////////////////////////////////////////////////////////////////////////////////////////////////
    function loadVotesForParticipantVerify(bytes32 participant, bytes32 candidate, uint8 votos) public returns (bool, bytes32) {
      if (! isValidCandidate(candidate)) {
        return (true, "Candidato no valido");
      }
      if (! isValidParticipant(participant)) {
        return (true, "Participante no valido");
      } else {
        return (false, "");
      }
    }
    function loadVotesForParticipant(bytes32 participant, bytes32 candidate, uint8 votos) private {
      require(isValidCandidate(candidate) && isValidParticipant(participant) && cantidadDePersonas > 0);
      participantMap[participant].votes[candidate] = votos;
    }
    function isValidCandidate(bytes32 candidate) public constant returns (bool){
        return candidateMap[candidate].isValidCandidate;
    }

    function isValidParticipant(bytes32 participant) public constant returns (bool){
      return participantMap[participant].isValidParticipant;
    }

    function isFiscal(bytes32 participant) public constant returns (bool) {
      return isCategory(participant, ParticipantCategory.Fiscal);
    }

    function isCategory(bytes32 participant, ParticipantCategory category) internal constant returns (bool) {
      return isValidParticipant(participant) && participantMap[participant].category == category;
    }

    function isPresidenteDeMesa(bytes32 participant) public constant returns(bool){
      return presidenteDeMesaAsignado == participant;
    }
    function setFiscalVerify(bytes32 fiscal) public returns (bool, bytes32) {
      return addParticipantVerify(fiscal, ParticipantData(true, ParticipantCategory.Fiscal, false));
    }
    function setFiscal(bytes32 fiscal) public {
      addParticipant(fiscal, ParticipantData(true, ParticipantCategory.Fiscal, false));
    }

    function setPresidenteDeMesaVerify(bytes32 presidente) public returns (bool, bytes32) {
      if (existPresidenteMesa) {
        return (true, "Ya existe presidente asignado");
      } else {
        return addParticipantVerify(presidente, ParticipantData(true, ParticipantCategory.PresidenteMesa, false));
      }
    }
    function setPresidenteDeMesa(bytes32 presidente) public{
      require(! existPresidenteMesa);
      addParticipant(presidente, ParticipantData(true, ParticipantCategory.PresidenteMesa, false));
      presidenteDeMesaAsignado = presidente;
      existPresidenteMesa = true;
    }

    function setVicepresidenteDeMesa(bytes32 vicepresidente) public{
      require(! existVicepresidenteMesa);
      vicepresidenteDeMesaAsignado = vicepresidente;
      existVicepresidenteMesa = true;
      addParticipant(vicepresidente, ParticipantData(true, ParticipantCategory.VicepresidenteMesa, false));
    }

/////////////////////////////////////////////////////////////////////////////////////////////////
    function checkVerify(bytes32 presi, uint distritoId, uint escuelaId, uint mesaId) public returns (bool, bytes32) {
      if (presidenteDeMesaAsignado != presi) {
        return (true, "Debe ser presidente de mesa");
      } else if(checked){
        return (true, "La mesa ya fue verificada");
      } else{
        return (false, "");
      }
    }
    function check(bytes32 presi, uint distritoId, uint escuelaId, uint mesaId) public {
      require(presidenteDeMesaAsignado == presi && !checked);
      checked = true;
      Counts countsCopy = Counts(countsAddress);
      uint8[] memory result = new uint8[](candidateList.length);
      for (uint8 index = 0 ; index < candidateList.length ; index++) {
        result[index] = participantMap[presidenteDeMesaAsignado].votes[candidateList[index]];
      }
      participantMap[presi].checked = true;
      countsCopy.setData(distritoId, escuelaId, mesaId, result);
    }

    function checkFiscalVerify(bytes32 participant) public returns (bool, bytes32) {
      if (! isValidParticipant(participant)) {
        return (true, "Debe ser fiscal en la mesa");
      }
      if (participantMap[participant].checked == true) {
        return (true, "Planilla ya validada");
      } else {
        return (false, "");
      }
    }
    function checkFiscal(bytes32 participant) public {
      require(isValidParticipant(participant) && !participantMap[participant].checked);
      participantMap[participant].checked = true;
    }

/////////////////////////////////////////////////////////////////////////////////////////////////
    function loadMesaVerify(bytes32 participante, bytes32[] candidatos, uint8[] conteos) public returns (bool, bytes32) {
      if (candidatos.length != conteos.length) {
        return (true, "Planilla incorrecta");
      }
      if (! isValidParticipant(participante)) {
        return (true, "Participante no valido");
      }
      if (participantMap[participante].checked) {
        return (true, "Planilla ya validada");
      }
      uint totalDeCarga = 0;
      for (uint8 i=0 ; i<candidatos.length ; i++) {
        bool huboError;
        bytes32 mensaje;
        (huboError, mensaje) = loadVotesForParticipantVerify(participante, candidatos[i], conteos[i]);
        totalDeCarga += conteos[i];
        if (huboError) {
          return (huboError, mensaje);
        }
      }
      if(totalDeCarga > cantidadDePersonas){
        return (true, "Excede la cantidad de personas");
      }
      return (false, "");
    }
    function loadMesa(bytes32 participante, bytes32[] candidatos, uint8[] conteos) public {
      require(candidatos.length == conteos.length && isValidParticipant(participante));
      for (uint8 i=0 ; i<candidatos.length ; i++) {
        loadVotesForParticipant(participante, candidatos[i], conteos[i]);
      }
    }
/////////////////////////////////////////////////////////////////////////////////////////////////

}
