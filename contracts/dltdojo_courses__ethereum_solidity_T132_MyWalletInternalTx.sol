pragma solidity ^0.4.14;

//
// Confused by internal transactions - Ethereum Stack Exchange 
// https://ethereum.stackexchange.com/questions/8315/confused-by-internal-transactions

// https://rinkeby.etherscan.io/address/0x6f5f98d26917da4ac831f4e566deeec2aadd2fd2
contract MyWallet {
    
    // 
    // https://rinkeby.etherscan.io/tx/0x69589377eb320ab85a14f811a478c29e17e883dd128814d62141c5e93bb6a416
    // block height 820594
    // MethodID: 0x1a695230
    // [0]:000000000000000000000000d7c3c049a0d010ccec02078cabde42818b5880c2
    // 
    // Ethereum Account 0xd7c3c049a0d010ccec02078cabde42818b5880c2 Info 
    //  https://rinkeby.etherscan.io/address/0xd7c3c049a0d010ccec02078cabde42818b5880c2
    // 
    function transfer(address to) payable {
        to.transfer(msg.value);
    }
}

// kovan testnet
// https://kovan.etherscan.io/address/0xb270120d3a1a4acf8ca5fb9d8ad5bbbd9f419213
// https://kovan.etherscan.io/tx/0x3a4414119600db4e70885fba5d8a54e5bc382827435aeaad570023b36fb91129

// TODO
// rinkeby testnet