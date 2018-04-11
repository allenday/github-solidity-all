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
*/

contract SSE {

    uint stateOfPlan;
    uint startDateOfPlan;
    uint noOfFounders;
    address[100] APAddresses;
    uint APAddressSize;
    
    uint[100][100] APSchedule;
    
    uint[100] periodicalBudget;
    
    uint totalPeriods;
    uint totalBudget;
    uint lastAPPeriod;
    
    uint[100] revForecast;
    uint forecastVarPercent;
    uint lastARvsRevForecastPeriod;
    int[100] ARvsRevForecast;
    uint MaxNoOfConsecPeriodsInRed;
    uint CurrNoOfConsecPeriodsInRed;
    
    uint investorIndex;
    mapping(address=>uint) investorMap;
    address[100] investorArray;
    uint[100] investmentArray;
    uint totalInvestment;
    
    uint[100][100] ARSchedule;
    uint[100][100] ARInvTable;
    uint[100] ARInvIndexTable;
    uint[100] periodicalAR;
    int[100] periodicalPnL;
    
    uint invId;
    mapping(uint=>uint) invMap;
    uint[100] invArray;

    uint DIVDPayoutPercent;
    uint lastDIVDPeriod;
    uint[100][100] paidDIVDSchedule;

    
    event onEvent(uint, string);
    
    function SSE(){
        stateOfPlan = 0;
    }
    
    function setInitialState(address[] _founders, uint[] _founderSSE, address[] _APAddresses, uint[100][] _APSchedule, uint[] _revForecast, uint _forecastVarPercent, uint _MaxNoOfConsecPeriodsInRed, uint _DIVDPayoutPercent, uint _DIVDStartDate){
        if (stateOfPlan == 0) {
            noOfFounders = _founders.length;
            for (uint i=0;i<noOfFounders;++i){
                ++investorIndex;
                investorMap[_founders[i]] = investorIndex;
                investorArray[investorIndex] = _founders[i];
                investmentArray[investorIndex] = _founderSSE[i];
            }
            totalPeriods = _APSchedule.length;
            APAddressSize = _APAddresses.length;
            for ( i=0;i<totalPeriods;++i){
                for (uint j=0;j<APAddressSize;++j){
                    APSchedule[i+1][j+1] = _APSchedule[i][j];
                    periodicalBudget[i+1] += _APSchedule[i][j];
                    if (i==0) {
                        APAddresses[j+1] = _APAddresses[j];
                    }
                }
                totalBudget += periodicalBudget[i];
                revForecast[i] = _revForecast[i];
            }
            forecastVarPercent = _forecastVarPercent;
            DIVDPayoutPercent = _DIVDPayoutPercent;
            lastDIVDPeriod = _DIVDStartDate;
    
            stateOfPlan = 1;
        }
    }
    
    function invest(){
        if (stateOfPlan == 1) {
            if (investorMap[msg.sender]>0) {
                investmentArray[investorMap[msg.sender]]+=msg.value;
            }else{
                ++investorIndex;
                investorMap[msg.sender] = investorIndex;
                investorArray[investorIndex] = msg.sender;
                investmentArray[investorIndex] = msg.value;
                
            }
            totalInvestment+=msg.value;
            if (totalInvestment>=totalBudget){
                 stateOfPlan = 2;
                 startDateOfPlan = now;
                 msg.sender.send(totalInvestment - totalBudget);
            }
        }else{
            onEvent(0, "Investment Denied, plan fully subscribed");
        }
    }
    
    function transferOwnership(address bene, uint amount){
        if (stateOfPlan == 2) {
            if (investorMap[msg.sender]>0 && investmentArray[investorMap[msg.sender]]>=amount ) {
                this.send(amount);
                investmentArray[investorMap[msg.sender]]-=amount;
                if (investorMap[bene]>0) {
                    investmentArray[investorMap[bene]]+=msg.value;
                }else{
                    ++investorIndex;
                    investorMap[bene] = investorIndex;
                    investmentArray[investorIndex] = msg.value;
                }
            }
        }
    }
    
    function processAP(){
        if (stateOfPlan == 2) {
            uint currentPeriod = (now - startDateOfPlan) /  86400;
            for (uint i=lastAPPeriod+1;i<=currentPeriod;++i){
                for (uint j=1;j<APAddressSize;++j){
                    if (APSchedule[i][j]>0){
                        APAddresses[j].send(APSchedule[i][j]);
                        periodicalPnL[i]-=(int)(APSchedule[i][j]);
                    }
                }
            }
            lastAPPeriod = currentPeriod;
        }
    }
    
    function createInvoice(uint amount){
        //Allow only project owners to create invoices
        if (stateOfPlan == 2 && investorMap[msg.sender]>0 && investorMap[msg.sender]<=noOfFounders) {
            ++invId;
            invArray[invId] = amount;
            invMap[invId] = 1;
        }
    }
    
    function processAR(uint invId){
        if (stateOfPlan == 2) {
            uint currentPeriod = (now - startDateOfPlan) /  86400;
            if (invMap[invId]==1 && invArray[invId]==msg.value) {
                ++ARInvIndexTable[currentPeriod];
                ARInvTable[currentPeriod][ARInvIndexTable[currentPeriod]] = invId;
                ARSchedule[currentPeriod][ARInvIndexTable[currentPeriod]] = msg.value;
                periodicalAR[currentPeriod] += msg.value;
                periodicalPnL[currentPeriod]+=(int)(msg.value);
                invMap[invId] = 2;
            }else{
                onEvent(0, "AR Denied");
                throw;
            }
        }
    }
    
    function processARvRevForecast(){
        if (stateOfPlan == 2) {
            uint currentPeriod = (now - startDateOfPlan) /  86400;
            for (uint i=lastARvsRevForecastPeriod+1;i<=currentPeriod;++i){
                ARvsRevForecast[i] = (int)(periodicalAR[i]/revForecast[i]*100 - 100);
                if (ARvsRevForecast[i]<(int)(forecastVarPercent)*-1){
                    ++CurrNoOfConsecPeriodsInRed;
                    if (CurrNoOfConsecPeriodsInRed>=MaxNoOfConsecPeriodsInRed){
                        stateOfPlan = 3;
                    }
                }else{
                    MaxNoOfConsecPeriodsInRed = 0;
                }
            }
            lastARvsRevForecastPeriod = currentPeriod;
        }
    }
    
    
    function processDIVD(){
        if (stateOfPlan == 2) {
            uint currentPeriod = (now - startDateOfPlan) /  86400;
            for (uint i=lastDIVDPeriod+1;i<=currentPeriod;++i){
                for (uint j=1;j<investorIndex;++j){
                    if (investmentArray[j]>0 && periodicalPnL[i]>0){
                        uint DIVDAmt = investmentArray[j]/totalInvestment*(uint)(periodicalPnL[i])*DIVDPayoutPercent/100;
                        investorArray[j].send(DIVDAmt);
                        paidDIVDSchedule[currentPeriod][j] = DIVDAmt;
                    }
                }
                lastDIVDPeriod = currentPeriod;
            }
        }
        
    }
    
    function initVote(uint daysToExpire){
        //to be implemented or imported from Reso.sol
    }
    
    function vote(){
        //to be implemented or imported from Reso.sol
    }
    
    function(){
        onEvent(0, "Invalid Investment or AR, ether returned.");
        throw;
    } 
    
    function getStateOfPlan() constant returns (uint) {
    	return stateOfPlan;
	}
    function getStartDateOfPlan() constant returns (uint) {
    	return startDateOfPlan;
	}
	function getAPAddresses() constant returns (uint) {
    	return startDateOfPlan;
	}
	function getAPAddressSize() constant returns (uint) {
    	return APAddressSize;
	}
    function getAPSchedule() constant returns (uint[100][100]) {
    	return APSchedule;
	}
	function getPeriodicalBudget() constant returns (uint[100]) {
    	return periodicalBudget;
	}
	function getTotalPeriods() constant returns (uint) {
    	return totalPeriods;
	}
    function getTotalBudget() constant returns (uint) {
    	return totalBudget;
	}
	function getLastAPPeriod() constant returns (uint) {
    	return lastAPPeriod;
	}
	function getRevForecast() constant returns (uint[100]) {
    	return revForecast;
	}
	function getInvestorIndex() constant returns (uint) {
    	return investorIndex;
	}
	function getInvestorArray() constant returns (address[100]) {
    	return investorArray;
	}
	function getInvestmentArray() constant returns (uint[100]) {
    	return investmentArray;
	}
	function getTotalInvestment() constant returns (uint) {
    	return totalInvestment;
	}
	function getARSchedule() constant returns (uint[100][100]) {
    	return ARSchedule;
	}
	function getARInvTable() constant returns (uint[100][100]) {
    	return ARInvTable;
	}
	function getARInvIndexTable() constant returns (uint[100]) {
    	return ARInvIndexTable;
	}
	function getPeriodicalAR() constant returns (uint[100]) {
    	return periodicalAR;
	}
	function getPeriodicalPnL() constant returns (int[100]) {
    	return periodicalPnL;
	}
	function getInvId() constant returns (uint) {
    	return invId;
	}
	function getInvArray() constant returns (uint[100]) {
    	return invArray;
	}
	function getDIVDPayoutPercent() constant returns (uint) {
    	return DIVDPayoutPercent;
	}
	function getLastDIVDPeriod() constant returns (uint) {
    	return lastDIVDPeriod;
	}
	function getPaidDIVDSchedule() constant returns (uint[100][100]) {
    	return paidDIVDSchedule;
	}
}


