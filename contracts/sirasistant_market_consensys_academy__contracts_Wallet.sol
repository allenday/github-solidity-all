pragma solidity 0.4.15;

import "./ERC20.sol";

contract Wallet{
    event LogMoneyAdded(address indexed account, uint amount);
    event LogTokenAdded(address indexed account,address indexed tokenAddress, uint amount);
    event LogWithdraw(address indexed account, uint amount);
    event LogWithdrawToken(address indexed account,address indexed tokenAddress, uint amount);
    event LogTransfer(address indexed from,address indexed to, uint amount);
    event LogTokenTransfer(address indexed from,address indexed to,address indexed tokenAddress, uint amount);

    
    mapping(address=>uint) public balances;
    
    mapping(address=>mapping(address=>uint)) public tokenBalances;
    
    function withdraw()
    public
    returns(bool success){
        require(balances[msg.sender]>0);
        uint amount = balances[msg.sender];
        balances[msg.sender]=0;
        msg.sender.transfer(amount);
        LogWithdraw(msg.sender, amount);
        return true;
    }
    
    function withdrawTokens(address tokenAddress)
    public
    returns(bool success){
        require(tokenBalances[tokenAddress][msg.sender]>0);
        uint amount = tokenBalances[tokenAddress][msg.sender];
        tokenBalances[tokenAddress][msg.sender]=0;
        ERC20 token = ERC20(tokenAddress);
        token.transfer(msg.sender,amount);
        LogWithdrawToken(msg.sender,tokenAddress, amount);
        return true;
    }
    
    function transfer(address from,address to,uint amount)
    internal{
        require(balances[from]>=amount);
        balances[from]-= amount;
        balances[to] += amount;
        LogTransfer( from, to, amount);
    }
    
    function tokenTransfer(address from,address to,address tokenAddress,uint amount)
    internal{
        require(tokenBalances[tokenAddress][from]>=amount);
        tokenBalances[tokenAddress][from]-= amount;
        tokenBalances[tokenAddress][to] += amount;
        LogTokenTransfer( from, to, tokenAddress, amount);
    }
    
    
    function addMoneyInternal(address account, uint amount)
    internal{
        balances[account] += amount;
        LogMoneyAdded(account,amount);
    }
    
    function addTokenInternal(address account,address tokenAddress, uint amount)
    internal{
        tokenBalances[tokenAddress][account] += amount;
        LogTokenAdded(account,tokenAddress,amount);
    }
}