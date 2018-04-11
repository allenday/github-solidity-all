pragma solidity ^0.4.14;
//
// http://remix.ethereum.org/

// Corda
// IOUContract https://github.com/corda/corda/blob/master/docs/source/hello-world-contract.rst

contract User{}

contract IOU {
    User public lender;
    User public borrower;
    uint public amount;
    function IOU(User _lender, User _borrower, uint _amount){
        lender = _lender;
        borrower = _borrower;
        amount = _amount;
    }
}

contract IOUContract {
    function  verify(IOU _addrIOU) returns (bool) {
        IOU iou = IOU(_addrIOU);
        // "The IOU's value must be non-negative." using (out.value > 0)
        require(iou.amount()>0);
    }
}


// 
// References
// corda/corda: Corda is a distributed ledger platform  https://github.com/corda/corda
// What Slack Can Teach Us About Privacy In Enterprise Blockchains | Richard Gendal Brown 
// https://gendal.me/2017/07/20/what-slack-can-teach-us-about-privacy-in-enterprise-blockchains/