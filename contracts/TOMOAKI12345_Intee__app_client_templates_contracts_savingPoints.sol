// version 1
contract savingPoints {
    mapping (address => uint) savingPointBalance;
    // initial funds are 1000 ether 10^21 saving points
    function savingPoints() {
        savingPointBalance[this] = 1000000000000000000000;
    }
    function saveEther() returns(bool sufficient) {
        if(savingPointBalance[this] - msg.value >= 0){
        savingPointBalance[this] -= msg.value;
        savingPointBalance[msg.sender] += msg.value;
        return true;
        }else{
            return false;
        }
    }
    function borrowEther(uint borrowAmount) returns(bool sufficient) {
        if (savingPointBalance[msg.sender] < borrowAmount || this.balance - borrowAmount <= 0) return false;
       msg.sender.send(borrowAmount);
      savingPointBalance[msg.sender] -= borrowAmount;
        return true;
    }
    function getFundBalance() returns(uint balance){
        return this.balance;
    }
     function getEtherBalance(address account) returns(uint balance){
        return account.balance;
    }
    function getFundSPBalance() returns(uint balance){
        return savingPointBalance[this];
    }
    function getSPBalance(address account) returns(uint balance){
        return savingPointBalance[account];
    }
}
