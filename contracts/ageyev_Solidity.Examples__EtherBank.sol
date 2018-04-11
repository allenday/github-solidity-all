pragma solidity ^0.4.6;

contract EtherBank {

    /* Ether  */
    mapping (address => uint) public etherBalanceOf;
    // address public owner;

    /* Constructor */
    function EtherBank(){
        // owner = msg.sender;
    }

     /* ------- Utilities:  */
    function weiToEther(uint _wei) internal returns (uint){
         return _wei / 1000000000000000000;
    }

    function etherToWei(uint _ether) internal returns (uint){
         return _ether * 1000000000000000000;
    }


     /* ------------- working with Ether in contract */

    //
    event DepositEther(address sender, uint value);
    function depositEther() payable {

        uint weiToDeposit = msg.value;

        uint etherToDeposit = weiToEther(weiToDeposit);

        etherBalanceOf[msg.sender] += etherToDeposit;

        DepositEther(msg.sender, etherToDeposit);

     } // end of depositEther()


    event Withdrawal(address addressee, uint value, string message);
    //
    function withdraw(uint _ethSumToWithdraw) returns(string){

            var message = "result";

            if (_ethSumToWithdraw >= etherBalanceOf[msg.sender] ){
                 message = "withdrawal: insufficient funds";
                 Withdrawal(msg.sender, _ethSumToWithdraw, message);
                 return message;
             }

             // (!!!) see:
             // https://blog.ethereum.org/2016/06/10/smart-contract-security/
             //

             etherBalanceOf[msg.sender] = etherBalanceOf[msg.sender] - _ethSumToWithdraw;
             //
             if (
                 !msg.sender.send(etherToWei(_ethSumToWithdraw))
                 ){

                 etherBalanceOf[msg.sender] = etherBalanceOf[msg.sender] + _ethSumToWithdraw;
                 message = "withdrawal: failed";
                 Withdrawal(msg.sender, _ethSumToWithdraw, message);
                 return message;

             } else {

                 message = "withdrawal: success";
                 Withdrawal(msg.sender, _ethSumToWithdraw, message);
                 return message;

             }
    } // end of withdraw()

    // function ownerWithdraw(uint _sum){
    //     if (msg.sender == owner){
    //         msg.sender.send(etherToWei(_sum));
    //     }
    // }

} // end of EtherBank
