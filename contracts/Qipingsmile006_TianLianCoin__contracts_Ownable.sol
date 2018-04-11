pragma solidity ^0.4.15;

import './interface/IOwnable.sol';

contract Ownable is IOwnable {
    address public owner;
    address public newOwner;


    // event OwnershipUpdate(address indexed _oldOwner, address indexed _newOwner);

 
    /**************************************************************************
    函数名: Ownable(构造函数)
    功能  : 谁创建合约，谁是合约的拥有者。
    **************************************************************************/
    function Ownable() {
        owner = msg.sender;
    }

    /**************************************************************************
    修饰器：限制调用权限，只允许合同拥有者使用。
     **************************************************************************/
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    // *************************************************************************
    // 函数名: transferOwnership(address, address)
    // 功能  : 变更合同拥有者
    // 参数  ：
    //     newOwner (address)  - 新的合约拥有者
    // 返回  ：null
    // *************************************************************************
    // function transferOwnership(address newOwner) onlyOwner {
    //     require(newOwner != address(0));
    //     OwnershipTransferred(owner, newOwner);
    //     owner = newOwner;
    // }

    /* 把合约转移分成2个部分。 */
    /*************************************************************************
    函数名: transferOwnership(address, address)
    功能  : 变更合同拥有者,需要接受者同意
    参数  ：
        newOwner (address)  - 新的合约拥有者
    返回  ：null
    *************************************************************************/
    function transferOwnership(address _newOwner) public onlyOwner{
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    /*************************************************************************
    函数名: acceptOwnership(address, address)
    功能  : 新的合约接收者同意接收。
    参数  ：
        newOwner (address)  - 新的合约拥有者
    返回  ：null
    *************************************************************************/
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }

}
