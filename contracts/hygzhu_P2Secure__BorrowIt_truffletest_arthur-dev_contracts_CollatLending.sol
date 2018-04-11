pragma solidity ^0.4.2;

contract CollatLending{

    address borrower;
    address lender;

    mapping (address => uint) balances;
    
    uint collat=0;
    uint loanPayment=0;

    function CollatLending(){
        borrower = msg.sender; 
        balances[borrower] = 1000;
    }

    function initLending(address _lenderAddr, uint _collat, uint _loanPayment){
        lender = _lenderAddr;
        collat = _collat;
        balances[borrower] -= loanPayment;
        balances[borrower] -= collat;
        loanPayment = _loanPayment;
    }
   
    function settle(){
        balances[lender] += loanPayment;
        balances[borrower] += collat;
 
        loanPayment = 0;
        collat = 0;
    }
 
    function forfietCollat(){
        balances[lender] += loanPayment;
        balances[lender] += collat; 
 
        loanPayment = 0;
        collat = 0;
    }


    function transfer(address _to, uint _value) returns (bool success){
         if (balances[msg.sender]< _value){
             return false;
         }
         balances[msg.sender] -= _value;
         balances[_to] += _value;
         return true;
    }
    function getBalance(address _user) constant returns (uint _balance){
        return balances[_user];
    }
    function setBalance(address _user, uint _balance){
        balances[_user] = _balance;

    }

}
