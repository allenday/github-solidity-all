pragma solidity ^0.4.14;
//
// zeppelin-solidity/contracts/token https://github.com/OpenZeppelin/zeppelin-solidity/tree/master/contracts/token
//
import "github.com/OpenZeppelin/zeppelin-solidity/contracts/token/StandardToken.sol";

/**
 * @title FooToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator. 
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract FooToken is StandardToken {

  string public constant name = "FooToken";
  string public constant symbol = "FOT";
  uint256 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 2100 ether;

  /**
   * @dev Contructor that gives msg.sender all of existing tokens. 
   */
  function FooToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}

contract User {
    function transferFrom(FooToken ft, address _from, address _to, uint256 _value){
        ft.transferFrom(_from, _to, _value);
    }
}

contract FooTokenTest {

    // from zeppelin 
    using SafeMath for uint256;
    
    function testTransfer() returns (uint){
        User alice = new User();
        User bob = new User();
        FooToken ft = new FooToken();
        ft.transfer(alice,10 ether);
        require(ft.balanceOf(alice)== 10 ether);
        ft.transfer(bob, 20 ether);
        require(ft.balanceOf(bob)== 20 ether);
        return ft.balanceOf(bob).add(ft.balanceOf(alice));
    }
    
    function testTransferFrom() {
        User alice = new User();
        User bob = new User();
        FooToken ft = new FooToken();
        require(ft.balanceOf(this)== 2100 ether);
        
        // approve by FooTokenTest
        require(ft.approve(alice, 5 ether));
        
        require(ft.allowance(this, alice) == 5 ether);
        alice.transferFrom(ft,  this, bob, 2 ether);
        require(ft.allowance(this, alice) == 3 ether);
        require(ft.balanceOf(alice)== 0 ether);
        require(ft.balanceOf(bob)== 2 ether);
        
    }
}

