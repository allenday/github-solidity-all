pragma solidity ^0.4.8;

import "./EmpAgreements.sol";
import "./ManufactorWallet.sol";


contract PLAgreements {
	PA[]  pAs;
	uint32 idCnt;
	address public eAAdress;
    
	address public agency;
	address public agencyWallet;

	struct PA {
		uint32 id;
		uint32 eAid;
		string plArgName;
		
		string emplyrName;
		bool emplyrSigned;
		
		uint32 emplyeHWage;
		uint32 emplyeHours;
		address emplyeAdress;
		address emplyeWalletAdress;
		
		string manuName;
		address manuAdress;
		address manuWalletAdress;
		bool manuSigned;
		string attachment;
	}



	function () payable {

	}


	function PLAgreements(address _eAAdress, address _agencyWallet) {
		idCnt = 0;
		agency = msg.sender;
		eAAdress = _eAAdress;
		agencyWallet = _agencyWallet;

		// EmpAgreements eAs = EmpAgreements(eAAdress);
		// eAs.setPlAAdress(this); funktioniert vielleicht
	}


	function addPA(string _plArgName, string _emplyrName, string _manuName, address _manuWalletAdress, address _manuAdress, uint32 _emplyeHWage, uint32 _emplyeHours, address _emplyeAdress, address _emplyeWalletAdress, uint32 _eAid, string _attachment) returns (bool success, uint32 id) {
		if(msg.sender != agency) return (false, 0);


		
		PA memory newPA;
		
		idCnt++;

		newPA.id = idCnt;
		newPA.eAid = _eAid;

		newPA.plArgName = _plArgName;

		newPA.emplyrSigned = false;
		newPA.emplyrName = _emplyrName;

		newPA.manuSigned = false;
		newPA.manuName = _manuName;
		newPA.manuAdress = _manuAdress;
		newPA.manuWalletAdress = _manuWalletAdress;

		newPA.emplyeHWage = _emplyeHWage;
		newPA.emplyeHours = _emplyeHours;
		newPA.emplyeAdress = _emplyeAdress;
		newPA.emplyeWalletAdress = _emplyeWalletAdress;
		newPA.attachment = _attachment;

		pAs.push(newPA);

		return (true, idCnt);
	}


	function signPA(uint32 _id) {
		for(uint i = 0; i < pAs.length; i++){
			if(pAs[i].id == _id) {
			    
				if(msg.sender == agency && !pAs[i].emplyrSigned) {
					pAs[i].emplyrSigned = true;
				}
				
				if(msg.sender == pAs[i].manuAdress && !pAs[i].manuSigned) {
					pAs[i].manuSigned = true;
				}

				if(pAs[i].emplyrSigned && pAs[i].manuSigned){
					
					EmpAgreements eAs = EmpAgreements(eAAdress);
					eAs.isEASigned(pAs[i].eAid);
					
					EmployeeWallet ew = EmployeeWallet(pAs[i].emplyeWalletAdress);
					ew.allowWorking(pAs[i].emplyeHours);

					AgencyWallet aw = AgencyWallet(agencyWallet);
					aw.validPLAContract(pAs[i].emplyeHWage, pAs[i].emplyeHours);

					ManufactorWallet mw = ManufactorWallet(pAs[i].manuWalletAdress);
					mw.validContract(pAs[i].emplyeHWage, pAs[i].emplyeHours, agencyWallet);
				}
			}
		}
	}


	// function removePA(uint32 _id) returns (bool success){
	// 	for(uint i = 0; i < pAs.length; i++){
	// 		if(pAs[i].id == _id && msg.sender == agency) {
	// 			delete pAs[i];
	// 			return (true);
	// 		} 
	// 	}
	// 	return (false);
	// }


	// function getPAAttributes(uint32 _id) constant returns (string plArgName, string emplyrNames, string manuNames, uint emplyeHWage, uint emplyeHours, string attachment){
	// 	for(uint i = 0; i < pAs.length; i++){
	// 		if(pAs[i].id == _id) {
	// 	        if(msg.sender == agency || msg.sender == pAs[i].manuAdress){
	// 			    return (pAs[i].plArgName, pAs[i].emplyrName, pAs[i].manuName, pAs[i].emplyeHWage, pAs[i].emplyeHours, pAs[i].attachment);
	// 	        }
	// 		} 
	// 	}
	// }


	// function isPASigned(uint32 _id) constant returns (bool signed) {
	// 	for(uint i = 0; i < pAs.length; i++){
	// 		if(pAs[i].id == _id && pAs[i].manuSigned && pAs[i].emplyrSigned) {
	// 			return (true);
	// 		}
	// 	}
	// 	return (false);
	// }
}
