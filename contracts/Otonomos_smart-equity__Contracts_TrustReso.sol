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

import "Trust.sol";
import "Portfolio.sol";
import "Asset.sol";
import "ResoDetails.sol";
import "Identity.sol";

contract TrustReso {

  uint constant public version = 1;
  address trustContract;
  uint[3] scParams;

  address[100] resoDetailsAddr;
  address fromAddress;
  address toAddress;
  address persona;

	uint resoType;
	uint resoMethod;
  uint period;

	uint quorumPercent;
	uint requiredSigs;
	uint requiredNegSigs;
	uint obtainedSigs;
	uint obtainedNegSigs;
	uint state;
	uint createdDate;

	mapping(address => uint) signerMap;
	address[100] signerAddresses;
	uint[100] signerTable;
	uint signerIndex;

	mapping(address => uint) signedMap;
	address[100] signedAddresses;
	int[100] signedTable;
	uint signedIndex;

  address constant treasuryAddress = 0x1111111111111111111111111111111111111111;

  Identity idFromAddress;
  Identity idToAddress;

	event onResult(uint resultType, string resultMsg);


	function TrustReso(uint[3] _scParams, address trustAddress, address persona, address[] _resoDetails) {
    scParams = _scParams;
    resoType = scParams[0];
    resoMethod = scParams[1];
    period = scParams[2];

    trustContract = trustAddress;

    uint i;
    for (i=0;i<_resoDetails.length;i++){
      resoDetailsAddr[i] = _resoDetails[i];
    }

    obtainedSigs = 0;
    obtainedNegSigs = 0;
    state = 1;
    createdDate = now;

    signerIndex = 0;
    signedIndex = 0;

    Trust trust = Trust(trustAddress);

    if (resoType == 2 || resoType == 3){
        Portfolio port = Portfolio(trust.getPortfolioTable()[1]);

        address[100] memory bfTable = port.getBfTable();
        address[100] memory assetTable = port.getAssetTable();

        uint temp = 0;
        uint temp2 = 0;

        for (i=2;i<=port.getBfMapIndex();i++){
            temp = 0;
            uint[100] memory bfHoldings = port.getBfHoldings(i);
            for (uint j=1;j<=port.getAssetMapIndex();j++){
                Asset asset = Asset(assetTable[j]);
                temp = temp + bfHoldings[j] * asset.getVotingPercentage()/100;
            }

            signerIndex++;
            signerMap[bfTable[i]] = signerIndex;
            signerTable[signerIndex] = temp;
            signerAddresses[signerIndex] = bfTable[i];
            temp2 = temp2 + temp;
        }
        if (resoType == 2) {
            requiredSigs = temp2 / 2 + 1;
        }else if (resoType == 3) {
            requiredSigs = temp2 / 4 * 3 + 1;
        }
        requiredNegSigs = temp2 - requiredSigs;
        quorumPercent = trust.getQuorum();
    }
	}

	function sign(int vote){
	    sign(msg.sender, vote);
	}

	function sign(address persona, int vote) internal {
	    if (now>createdDate+period*1 days) {
	        state = 3;
	        onResult(1, "[Reso][sign] Reso Expired");
	    }else{
	        if (state==1 && signerMap[persona]>0 && signedMap[persona]==0 && (vote==1 || vote==-1)){
    	        signedIndex++;
    	        signedMap[persona] = signedIndex;
    	        signedTable[signedIndex] = (int)(signerTable[signerMap[persona]])*vote;
    	        signedAddresses[signedIndex] = persona;
    	        if (vote>0) {
        	        obtainedSigs = obtainedSigs + (uint)(signedTable[signedIndex]);
        	        if (obtainedSigs>=requiredSigs) {
        	            state = 2;
        	            onResult(1, "[Reso][sign] Success: Reso Passed");
        	        }
    	        }else{ //negative vote limit logic
    	            obtainedNegSigs = obtainedNegSigs + (uint)(signedTable[signedIndex]);
    	            if (obtainedNegSigs>requiredSigs) {
        	            state = 3;
        	            onResult(1, "[Reso][sign] Success: Reso Failed");
        	        }
    	        }
    	        onResult(1, "[Reso][sign] Success: Reso Signed");
    	    }else{
    	        onResult(0, "[Reso][sign] Error: Not authorized to sign or already signed");
    	    }
	    }
	}

	function timeCheck(){
	    if (state==1 && now>createdDate+period*1 days) {
	        if (obtainedSigs>=quorumPercent*requiredSigs/100) {
	            state = 2;
	            onResult(1, "[Reso][sign] Success: Reso Passed");
	        }else{
	            state = 3;
	            onResult(1, "[Reso][sign] Success: Reso Failed");
	        }
	    }else{
            state = 3;
            onResult(1, "[Reso][sign] Success: Reso Failed");
        }
	}

	function getTrustContract() constant returns (address) {
		return trustContract;
	}
	function getResoType() constant returns (uint) {
		return resoType;
	}
	function getResoMethod() constant returns (uint) {
		return resoMethod;
	}
  function getState() constant returns (uint) {
		return state;
	}
	function getRequiredSigs() constant returns (uint) {
		return requiredSigs;
	}
	function getQuorum() constant returns (uint) {
		return quorumPercent;
	}
	function getSignerTable() constant returns (uint[100]){
	    return signerTable;
	}
	function getSignedTable() constant returns (int[100]){
	    return signedTable;
	}
	function getSignerAddresses() constant returns (address[100]){
	    return signerAddresses;
	}
	function getSignedAddresses() constant returns (address[100]){
	    return signedAddresses;
	}
	function getSignerIndex() constant returns (uint){
	    return signerIndex;
	}
	function getSignedIndex() constant returns (uint){
	    return signedIndex;
	}
  function getResoSCParams() constant returns (uint[3]){
    return scParams;
  }
  function getResoDetails() constant returns (address[100]){
    return resoDetailsAddr;
  }
  function getResoPeriod() constant returns (uint){
    return period;
  }
  function getCreatedDate() constant returns (uint){
    return createdDate;
  }

}
