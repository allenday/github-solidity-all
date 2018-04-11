pragma solidity 0.4.15;

import "./Shop.sol";
import "./Wallet.sol";
import "./Owned.sol";
import "./ERC20.sol";
import "./AllowedTokenManager.sol";

contract MarketHub is Owned,Wallet,AllowedTokenManager {
    
    mapping(address=>bool) trustedShops;
    
    address[] public trustedShopAddresses;
    
    uint fee;
    
    modifier onlyShop(address account){
        require(trustedShops[account]);
        _;
    }
    
    function MarketHub(uint _fee){
        fee = _fee;
    }
    
    function deployShop(address seller)
    onlyOwner
    returns (bool success){
        Shop trustedShop = new Shop(fee,seller);
        trustedShopAddresses.push(trustedShop);
        trustedShops[trustedShop] = true;
        return true;
    }
    
    function setShopRunning(address shopAddress,bool status)
    onlyOwner
    returns (bool success){
        require(trustedShops[shopAddress]);
        Shop trustedShop = Shop(shopAddress);
        trustedShop.setRunning(status);
        return true;
    }
    
    function registerBuy()
    public
    payable
    onlyShop(msg.sender){
        Shop shop = Shop(msg.sender);
        require(msg.value>fee);
        addMoneyInternal(shop.getSeller(),msg.value - fee);
        addMoneyInternal(owner,fee);
    }
    
    
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData)
    public
    onlyAllowedToken(msg.sender)
    onlyShop(_from){
        require(_token == msg.sender);
        require(_extraData.length==0);
        require(_value>fee);
        Shop shop = Shop(_from);
        ERC20 token = ERC20(_token);
        token.transferFrom( _from, this, _value);
        addTokenInternal(shop.getSeller(),msg.sender,_value-fee);
        addTokenInternal(owner,msg.sender,fee);
    }

    function tokenFallback(address _from, uint _value, bytes _data)
    public
    onlyAllowedToken(msg.sender)
    onlyShop(_from){
        require(_data.length==0);
        require(_value>fee);
        Shop shop = Shop(_from);
        addTokenInternal(shop.getSeller(),msg.sender,_value-fee);
        addTokenInternal(owner,msg.sender,fee);
    }
    
    function isTrustedShop(address shop)
    public
    constant
    returns (bool isIndeed){
        return trustedShops[shop];
    }
    
    function addAllowedToken(address account)
    public
    onlyOwner()
    returns(bool success){
        return insertAllowedTokenInternal(account);
    }
    
    function getTrustedShopCount()
    public
    constant
    returns (uint count){
        return trustedShopAddresses.length; 
    }
    
}




