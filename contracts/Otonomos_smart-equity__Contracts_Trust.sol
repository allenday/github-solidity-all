/*
This is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with this software.  If not, see <http://www.gnu.org/licenses/>.

Authors:
Mano Thanabalan
Joël Hubert
*/

import "Identity.sol";
import "Persona.sol";
import "Portfolio.sol";
import "TrustReso.sol";
import "ResoDetails.sol";

contract Trust {

  uint constant public version = 1;
  uint trustState;
  uint portfolioMapIndex;
  uint quorumPercent;

  address constant treasuryAddress = 0x1111111111111111111111111111111111111111;
	address idAddress;

	mapping(address => uint) portfolioMap;
	address[10] portfolioTable;

	mapping(address => uint) trusteeMap;
	address[100] trusteeTable;
	uint trusteeIndex;

	mapping(address => uint) resoMap;

  event onResult(uint resultType, string resultMsg);

	function Trust(address[] _trusteeTable, uint _quorumPercent, address _defaultVEContract, bytes idData) {
		idAddress = new Identity("trust",_defaultVEContract, idData);
    trusteeIndex = trusteeTable.length;
    for (uint i = 1; i<=trusteeIndex; i++) {
    	trusteeTable[i] = trusteeTable[i-1];
      trusteeMap[trusteeTable[i]] = i;
    }
    quorumPercent = _quorumPercent;

		trustState = 1;
	}

  // Add portfolio to trust
	function setInitialState(address portfolioAddress){
		if (trustState == 1) {
			++portfolioMapIndex;
    	portfolioTable[portfolioMapIndex] = portfolioAddress;
    	portfolioMap[portfolioAddress] = portfolioMapIndex;
   	}
	}

  // Trust smart contract must be accepted by DTHs via resolution
  // Resolutions are smart contracts as well
	function acceptTrustSC(address reso) {
	 	if (resoMap[reso]==0 && trustState == 1) {
      resoMap[reso] = 1;
	    TrustReso tr = TrustReso(reso);
	    address temp = this;
  		if (tr.getTrustContract()==temp && tr.getResoType() == 2 && tr.getResoMethod() == 3 && tr.getState() == 2) {
  			trustState = 2;
        onResult(1, "[Trust][acceptTrustSC] Result: new trust accepted");
  		}
    }
	}

  // Add or remove trustees
	function editTrustee(address reso) {
	    if (resoMap[reso]==0 && trustState == 2) {
	        resoMap[reso] = 1;
    	    TrustReso tr = TrustReso(reso);
    	    ResoDetails rd = ResoDetails(tr.getResoDetails()[0]);
    	    address temp = this;
      		if (tr.getTrustContract()==temp && tr.getState() == 2) {
      		    if (tr.getResoType() == 2 && tr.getResoMethod() == 2 && trusteeMap[rd.getResoAddressArr()[0]]==0) {
          		    ++trusteeIndex;
            			trusteeMap[rd.getResoAddressArr()[0]] = trusteeIndex;
            			trusteeTable[trusteeIndex] = rd.getResoAddressArr()[0];
            			onResult(1,"[Trust][addTrustee] Result: Trustee added");
      		    }else if (tr.getResoType() == 2 && tr.getResoMethod() == 3 && trusteeMap[rd.getResoAddressArr()[0]]>0) {
      		        --trusteeIndex;
            			delete trusteeTable[trusteeMap[rd.getResoAddressArr()[0]]];
            			delete trusteeMap[rd.getResoAddressArr()[0]];
            			onResult(1,"[Trust][removeTrustee] Result: Trustee removed");
      		    }
      		}
	    }
	}

  // Allow trustees to resign
	function resignTrustee() {
	    if (trusteeMap[msg.sender]>0 && trusteeIndex>1) {
    			--trusteeIndex;
    			delete trusteeTable[trusteeMap[msg.sender]];
    			delete trusteeMap[msg.sender];
    			onResult(1, "[Trust][resignTrustee] Result: Trustee resigned");
	    }
	}

// Transfer Trust Tokens between DTHs according to their DAO token holdings
function assetManagement(address reso) {
    TrustReso tr;
    ResoDetails rd;
    if (resoMap[reso]==0 && trustState == 2) {
          tr = TrustReso(reso);
          rd = ResoDetails(tr.getResoDetails()[0]);
          address[100] memory resoAddressParams = rd.getResoAddressArr();
          address temp = this;
          Portfolio port = Portfolio(resoAddressParams[0]);
          if (port.getTrust() == temp) {
              // Genesis Issuance of Trust Tokens or Cap Increase if trust holdings increase
              if (resoAddressParams[1]==treasuryAddress && resoAddressParams[2]==treasuryAddress) {
                  if (tr.getResoType()==3 && tr.getResoMethod()==4 && tr.getState()==2) {
                      port.transferAssets(treasuryAddress, treasuryAddress, resoAddressParams[3], rd.getResoUIntArr()[0]);
                  }
              // P2P or P2Treasury Transfer
              }else if (tr.getResoType()==4 && tr.getResoMethod()==9 && tr.getState()==2 && resoAddressParams[1] != treasuryAddress){
                      port.transferAssets(resoAddressParams[1], resoAddressParams[2], resoAddressParams[3],  rd.getResoUIntArr()[0]);
              // T2P Transfer
              }else if (tr.getResoType()==4 && tr.getResoMethod()==9 && tr.getState()==2 && resoAddressParams[1] == treasuryAddress){
                      port.transferAssets(treasuryAddress, resoAddressParams[2], resoAddressParams[3], rd.getResoUIntArr()[0]);
              }else{
              }
          }
	    }
	}

	function getPortfolioTable() constant returns (address[10]) {
    	return portfolioTable;
	}
	function getQuorum() constant returns (uint) {
    	return quorumPercent;
	}
	function getTrusteeTable() constant returns (address[100]) {
    	return trusteeTable;
	}
	function getTrusteeIndex() constant returns (uint) {
    	return trusteeIndex;
	}
	function getTrustState() constant returns (uint) {
    	return trustState;
	}

}
