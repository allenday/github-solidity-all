pragma solidity ^0.4.15;

import './CentrallyIssuedToken.sol';
import './SafeMath.sol';
import './BancorFormula.sol';

contract TokenChangerBNT is BancorFormula {
    
    address public owner; 
    ERC20 public TILE;
    ERC20 public BNT;

    uint public RESERVE_RATIO = 10; 
    uint public DECIMAL_PLACES = 7;

    function TokenChangerBNT (address tileContract, address BNTContract) {
        owner = msg.sender;
        TILE = ERC20(tileContract);
        BNT = ERC20(BNTContract);
    }

    function tileBalance () constant returns (uint) {
        return TILE.balanceOf(address(this));
    }

    function BNTBalance () constant returns (uint) {
        return BNT.balanceOf(address(this));
    }

    // price of BNT in TILE
    function BNTPrice () constant returns (uint) {
        return tileBalance() * 10**DECIMAL_PLACES / 
               (BNTBalance() * RESERVE_RATIO);
    }

    // price of TILE in BNT 
    function tilePrice () constant returns (uint) {
        return BNTBalance() * 10**DECIMAL_PLACES * RESERVE_RATIO / 
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
        uint bid = BancorFormula.calculateSaleReturn(tileBalance(), BNTBalance(), 1e5, quantity);
        bool success = BNT.transfer(msg.sender, bid);
        require(success);
    }

    // user has to approve BNT contract to transfer funds before
    // running this function or it will throw an error
    // WARNING: CRR IS HARDCODED
    function sellBNT (uint quantity) {
        bool success = BNT.transferFrom(msg.sender, address(this), quantity);
        require(success);
        uint bid = BancorFormula.calculatePurchaseReturn(tileBalance(), BNTBalance(), 1e5, quantity);
        success = TILE.transfer(msg.sender, bid);
        require(success);
    }

}
