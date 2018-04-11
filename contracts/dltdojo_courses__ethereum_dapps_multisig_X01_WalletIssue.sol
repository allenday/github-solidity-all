pragma solidity ^0.4.10;
// 
// https://ethereum.github.io/browser-solidity/
// https://github.com/ethereum/dapp-bin/blob/master/wallet/wallet.sol
//
import "github.com/ethereum/dapp-bin/wallet/wallet.sol";


// 1-of-2
// copy account1
// swich back account0
// new Wallet() [account1],1,0
// ["0x14723a09acff6d2a60dcdf7aa4aff308fddc160c"],1,0
// fallback() 50 ether 
// execute() "0xdeed",100,"0x00" return ConfirmID
// confirm() confirmID

// 2-of-3
// copy account1,account2
// swich back account0
// new Wallet() [account1,account2],2,0
// ["0x14723a09acff6d2a60dcdf7aa4aff308fddc160c","0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db"],2,0
// fallback() 50 ether 
// execute() "0xdeed",100,"0x00" return ConfirmID
// invalid code ??
