pragma solidity ^0.4.14;
//
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
// 
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/MintableToken.sol";
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/ownership/Ownable.sol";

contract FooStdToken is StandardToken, Ownable {
    function FooStdToken(){
        totalSupply = 2100 ether;
        balances[msg.sender] = totalSupply;
    }
}

contract FooMintToken is MintableToken {
    function FooMintToken(){
        totalSupply = 2200 ether;
        balances[msg.sender] = totalSupply;
    }
}

contract Foo is Ownable {
    function Foo() payable {}
    function () payable {}
    
    function setStdOwner(address _tokenOwner, address _tokenAddress) onlyOwner {
        balancesStd[_tokenOwner] = FooStdToken(_tokenAddress);
    }
    
    function setMintTokenOwner(address _tokenOwner, address _tokenAddress) onlyOwner {
        balancesMint[_tokenOwner] = FooMintToken(_tokenAddress);
    }
    
    mapping (address => FooStdToken) balancesStd;
    mapping (address => FooMintToken) balancesMint;
    
}

// Permission Topics
//
// 1. Bitcoin: Multisignature - Bitcoin Wiki  https://en.bitcoin.it/wiki/Multisignature
//
// 2. Ethereum; Ownable Contract
//
// 3. Hyperledger Burrow/Sawtooth: Permissioned Ethereum Virtual Machine
// Permissioning is enforced through secure native functions and underlies all smart contract code.
// https://github.com/hyperledger/burrow/blob/master/permission/types/permissions.go#L58
//
// 4. Hyperledger Composer Access Control Language
// Access Control Language | Hyperledger Composer https://hyperledger.github.io/composer/reference/acl_language.html
// 