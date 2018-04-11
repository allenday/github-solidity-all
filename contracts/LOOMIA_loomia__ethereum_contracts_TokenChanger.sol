pragma solidity ^0.4.15;

import './ERC20.sol';
import './SafeMath.sol';
import './BancorFormula.sol';

contract TokenChanger is BancorFormula {

    address public owner; 
    ERC20 TILE;
    ERC20 STORJ;

    uint public RESERVE_RATIO = 10; 
    uint public DECIMAL_PLACES = 7;

    function TokenChanger (address tileContract, address storjContract) {
        owner = msg.sender;
        TILE = ERC20(tileContract);
        STORJ = ERC20(storjContract);
    }

    function tileBalance () constant returns (uint) {
        return TILE.balanceOf(address(this));
    }

    function storjBalance () constant returns (uint) {
        return STORJ.balanceOf(address(this));
    }

    // price of STORJ in TILE
    function storjPrice () constant returns (uint) {
        return tileBalance() * 10**DECIMAL_PLACES / 
               (storjBalance() * RESERVE_RATIO);
    }

    // price of TILE in STORJ 
    function tilePrice () constant returns (uint) {
        return storjBalance() * 10**DECIMAL_PLACES * RESERVE_RATIO / 
               tileBalance();
    }

    // User has to approve TILE contract to transfer funds before
    // running this function or it will throw an error. 
    // Later on, if the token changer is part the TILE contract, 
    // no approval would be required
    // WARNING: CRR IS HARDCODED
    function sellTile(uint quantity) {
        success = TILE.transferFrom(msg.sender, address(this), quantity);
        require(success);
        uint bid = BancorFormula.calculateSaleReturn(tileBalance(), storjBalance(), 1e5, quantity);
        bool success = STORJ.transfer(msg.sender, bid);
        require(success);
    }

    // user has to approve STORJ contract to transfer funds before
    // running this function or it will throw an error
    // WARNING: CRR IS HARDCODED
    function sellStorj (uint quantity) {
        bool success = STORJ.transferFrom(msg.sender, address(this), quantity);
        require(success);
        uint bid = BancorFormula.calculatePurchaseReturn(tileBalance(), storjBalance(), 1e5, quantity);
        success = TILE.transfer(msg.sender, bid);
        require(success);
    }

}
