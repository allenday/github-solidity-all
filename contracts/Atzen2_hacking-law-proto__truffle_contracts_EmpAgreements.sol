pragma solidity ^0.4.8;

import "./EmployeeWallet.sol";
import "./AgencyWallet.sol";


contract EmpAgreements {
	EA[]  eAs;
	uint32 idCnt;
	bool plAAdressSet;
    
	address public agency;
	address public agencyWallet;
	address public plAAdress;

	struct EA {
		uint32 id;	// id des Arbeitsvertrages
		string eAName; // employee agreements name
		
		string agencyName;
		bool agencySigned;
		
		string emplyeName;
		address emplyeAdress;
		uint32 emplyeHWage;
		bool emplyeSigned;
		string attachment; // etwas was man noch dazu packen kann (z.B. Hash des Vertrages)
		address emplyeWalletAdress;
	}


	function () payable {

	}


	function EmpAgreements(address _agencyWallet) {
		idCnt = 0;
		agency = msg.sender;
		agencyWallet = _agencyWallet;
		plAAdressSet = false;
	}


	/* must be called after PLAgreements contract is deployed */
	function setPlAAdress(address _plAAddress) {
			plAAdress = _plAAddress;
			plAAdressSet = true;
	}


	function addEA(string _eAName, string _agencyName, string _emplyeName, uint32 _emplyeHWage, address _emplyeAdress, address _emplyeWalletAdress, string _attachment) returns (bool success, uint32 id) {
		if(msg.sender != agency) return (false, 0);


		EA memory newEA;
		
		idCnt++;

		newEA.id = idCnt;

		newEA.eAName = _eAName;

		newEA.agencySigned = false;
		newEA.agencyName = _agencyName;

		newEA.emplyeSigned = false;
		newEA.emplyeName = _emplyeName;
		newEA.emplyeAdress = _emplyeAdress;
		newEA.emplyeHWage = _emplyeHWage;
		newEA.attachment = _attachment;
		newEA.emplyeWalletAdress = _emplyeWalletAdress;

		eAs.push(newEA);

		return (true, idCnt);
	}


	function signEA(uint32 _id){
		for(uint i = 0; i < eAs.length; i++){
			if(eAs[i].id == _id) {
			    
				if(msg.sender == agency && !eAs[i].agencySigned) {
					eAs[i].agencySigned = true;
				}
				
				if(msg.sender == eAs[i].emplyeAdress && !eAs[i].emplyeSigned) {
					eAs[i].emplyeSigned = true;
				}

				if(eAs[i].agencySigned && eAs[i].emplyeSigned){
					
					EmployeeWallet ew = EmployeeWallet(eAs[i].emplyeWalletAdress);
					ew.validContract( agency, eAs[i].emplyeHWage);

					AgencyWallet aw = AgencyWallet(agencyWallet);
					aw.validEAContract(eAs[i].emplyeHWage, eAs[i].emplyeWalletAdress);
				}
			}
		}
	}


	// function removeEA(uint32 _id) returns (bool success){
	// 	for(uint i = 0; i < eAs.length; i++){
	// 		if(eAs[i].id == _id && msg.sender == agency) {
	// 			delete eAs[i];
	// 			return (true);
	// 		} 
	// 	}
	// 	return (false);
	// }


	// function getEAAttributes(uint32 _id) constant returns (string eAName, string agencyNames, string emplyeNames, uint emplyeHWage, string attachment){
	// 	for(uint i = 0; i < eAs.length; i++){
	// 		if(eAs[i].id == _id) {
	// 	        if(msg.sender == agency || msg.sender == eAs[i].emplyeAdress){
	// 			    return (eAs[i].eAName, eAs[i].agencyName, eAs[i].emplyeName, eAs[i].emplyeHWage, eAs[i].attachment);
	// 	        }
	// 		} 
	// 	}
	// }

	/* called from PLAgreements */
	function isEASigned(uint32 _id) constant returns (bool signed) {
		for(uint i = 0; i < eAs.length; i++){
			if(eAs[i].id == _id && eAs[i].emplyeSigned && eAs[i].agencySigned) {
				return (true);
			}
		}
		return (false);
	}
}