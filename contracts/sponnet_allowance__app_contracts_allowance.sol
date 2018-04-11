contract allowance {
    
    address public parent;
    address public mychild;
    uint public amount;
    uint public payoutperiod;
    uint public lastpayout;
    
    function allowance(address _mychild, uint _amount, uint _payoutperiod){
        parent = msg.sender;
        mychild = _mychild;
        amount = _amount * 1 ether;
        payoutperiod = _payoutperiod * 60 * 60 * 24;
        lastpayout = now - payoutperiod;
    }

    function requestPayout(){
        if (msg.sender != mychild) throw;
        
        uint timecheck = now - payoutperiod;
        if (lastpayout > timecheck) throw;
        
        lastpayout = now;    

        mychild.send(amount);
        
    }

}