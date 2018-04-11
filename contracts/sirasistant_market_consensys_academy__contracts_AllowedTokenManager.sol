pragma solidity 0.4.15;

contract AllowedTokenManager{
    event LogAddAllowedToken(address indexed account);
    event LogRemoveAllowedToken(address indexed account);
    
    struct AllowedTokenStruct{
        bool isIndeed;
        uint index;
    }
    
    mapping(address=>AllowedTokenStruct) private allowedTokenStructs;
    
    address[] private allowedTokens;
    
    modifier onlyAllowedToken(address account){
        require(isAllowedToken(account));
        _;
    }
    
    function isAllowedToken(address account)
    public
    constant
    returns (bool isIndeed){
        return allowedTokenStructs[account].isIndeed;
    }
    
    function insertAllowedTokenInternal(address account)
    internal
    returns(bool success){
        require(!isAllowedToken(account));
        uint index = allowedTokens.push(account)-1;
        AllowedTokenStruct memory allowedTokenStruct;
        allowedTokenStruct.isIndeed = true;
        allowedTokenStruct.index = index;
        allowedTokenStructs[account] = allowedTokenStruct;
        
        LogAddAllowedToken(account);
        return true;
    }
    
    function removeAllowedTokenInternal(address account)
    internal
    returns(bool success){
        require(isAllowedToken(account));
        allowedTokenStructs[account].isIndeed = false;
        uint index = allowedTokenStructs[account].index;
        delete allowedTokens[index];
        if(index!=allowedTokens.length-1){
            //Move the item
            address toMove = allowedTokens[allowedTokens.length-1];
            allowedTokenStructs[toMove].index = index;
            allowedTokens[index]= toMove;
        }
        allowedTokens.length--;
        
        LogRemoveAllowedToken(account);
        return true;
    }
    
    function getAllowedTokensCount()
    public
    constant
    returns (uint amount){
        return allowedTokens.length;
    }
    
    function getAllowedTokenAt(uint index)
    public
    constant
    returns (address allowedToken){
        require(allowedTokens.length>index);
        return allowedTokens[index];
    }
    
}