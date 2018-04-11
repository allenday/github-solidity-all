pragma solidity ^0.4.18;

import "../supporting/SafeMath.sol";
import "../TruReputationToken.sol";
import "../TruSale.sol";


contract MockSale is TruSale {

    using SafeMath for uint256;

    uint256 public constant PRESALE_CAP = 12000 * 10**18;

    function MockSale(
        uint256 _startTime, 
        uint256 _endTime, 
        address _token,
        address _saleWallet) public TruSale(_startTime, _endTime, _token, _saleWallet) 
    {
        isPreSale = true;
        isCrowdSale = false;
        cap = PRESALE_CAP;
    }


    function mockBuy() public {
        super.validatePurchase(0x0);
    }

    function mockWhiteList() public {
        
        super.updateWhitelist(0x0, 0);
        super.updateWhitelist(0x0, 1);
        super.updateWhitelist(0x0, 3);
        super.updateWhitelist(0, 0);
        super.updateWhitelist(0, 1);
        super.updateWhitelist(0, 3);
        super.updateWhitelist(0x0000000000000000000000000000000000000000, 0);
        super.updateWhitelist(0x0000000000000000000000000000000000000000, 1);
        super.updateWhitelist(0x0000000000000000000000000000000000000000, 3);
        super.updateWhitelist(msg.sender, 3);
        super.updateWhitelist(msg.sender, 4);
        super.updateWhitelist(msg.sender, 5);
    }
}