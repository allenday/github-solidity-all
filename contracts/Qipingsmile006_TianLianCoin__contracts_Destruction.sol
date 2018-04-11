 pragma solidity ^0.4.15;

 /**
  * This contract does this and that...
  */
 import './Ownable.sol';
 import './interface/IDestruction.sol';

 contract Destruction is Ownable, IDestruction{


  	/**************************************************************************
    函数名: distory(address)
    功能  : 摧毁合约，把合约中以太币发给合约拥有者。
    参数  ：null
    返回  ：null
    **************************************************************************/
 	function distory() onlyOwner public {
 		suicide(owner);
 	}

 	/**************************************************************************
    函数名: distoryAndSend(address)
    功能  : 摧毁合约，把合约中以太币发给指定接受者。
    参数  ：
        _recipient (address)  - 接受者
    返回  ：null
    **************************************************************************/
 	function distoryAndSend(address _recipient) onlyOwner public{
 		suicide(_recipient);
 	}
 }
