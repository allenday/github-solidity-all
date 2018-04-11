pragma solidity ^0.4.2;

contract Transfer {


    // The keyword "public" makes those variables
    // readable from outside.
    address public recipient;
    // mapping (address => uint) public balances;

    // Events allow light clients to react on
    // changes efficiently.
    event Sent(address from, address to, uint amount );


    // function send(address receiver, uint amount)  {
    //     if (balances[msg.sender] < amount) return;
    //     balances[msg.sender] -= amount;
    //     balances[receiver] += amount;
    //     return Sent(msg.sender, receiver, amount);
    // }
    
    function send_to_darshil() payable {
        address x = 0xA29d85F5fa740DF89a6Aa07187d3c7AF080595fa;
        address myAddress = msg.sender;
        if (myAddress.balance >= 10){
            x.transfer(this.balance);
            return Sent(this, x, 10);
        } 
    }

}
