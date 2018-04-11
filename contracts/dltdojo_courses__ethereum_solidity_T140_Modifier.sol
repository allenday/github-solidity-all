pragma solidity ^0.4.14;
// https://ethereum.github.io/browser-solidity/
// modifier http://solidity.readthedocs.io/en/develop/common-patterns.html#state-machine

contract Base {
    event InfoEvent(address contractAddress,  uint balance);
    function info(){
       InfoEvent(this, this.balance);
    }
}

contract Foo is Base {
   address public owner;
 
   function Foo() {
     owner = msg.sender;
   }

   modifier onlyOwner() {
      require(msg.sender == owner);
      _;
   }

    modifier validLegacyRequirement(uint limit) {
        require(this.balance >= limit);
        _;
    }
    
    // switch to account1
    function funForOwner() onlyOwner {
        info();
    }
    
    // switch to account1
    function changeOwner(address newOwner) onlyOwner {
      require(newOwner != address(0));      
      owner = newOwner;
    }
    
    function endContract(address legacyAddress) onlyOwner validLegacyRequirement(99 ether) {
       selfdestruct(legacyAddress);
    }
    
    // fallback function
    function () payable {}
}

// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/ownership/Ownable.sol";

contract Foo2 is Base, Ownable{
    modifier validLegacyRequirement(uint limit) {
        require(this.balance >= limit);
        _;
    }
    
    // switch to account1
    function funForOwner() onlyOwner {
        info();
    }
    
    function endContract(address legacyAddress) onlyOwner validLegacyRequirement(99 ether) {
       selfdestruct(legacyAddress);
    }
    
    // fallback function
    function () payable {}
}