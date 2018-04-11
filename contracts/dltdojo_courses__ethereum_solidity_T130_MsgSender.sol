pragma solidity ^0.4.14;
// https://ethereum.github.io/browser-solidity/
// this, selfdestruct http://solidity.readthedocs.io/en/develop/units-and-global-variables.html?#contract-related
// fallback http://solidity.readthedocs.io/en/develop/contracts.html#fallback-function
// event http://solidity.readthedocs.io/en/develop/contracts.html#events

contract TestMsgSender {
    // send 100 ether
    function() payable {}

    function test0Alice() returns (uint){
        Foo foo = new Foo();
        Alice alice = new Alice(foo);
        require(alice.foo()==foo);
        alice.transfer(2 ether);
        alice.testFooSend();
        require(foo.balance == 1 ether);
        require(alice.balance == 1 ether);
        // who pay gas ? 
        alice.testFooKill();
        require(alice.balance == 2 ether);
        // who pay gas ? 
        return alice.balance;
    }

    function test1Bob() returns (uint){
        Foo foo = new Foo();
        Alice alice = new Alice(foo);
        Bob bob = new Bob(foo);
        require(bob.foo()==foo);
        require(bob.alice()!=alice);
        bob.transfer(10 ether);
        
        Alice balice = Alice(bob.alice());
        balice.transfer(1 ether);
        bob.testAliceFooSend();
        require(foo.balance == 1 ether);
        bob.testAliceFooKill();
        require(bob.balance == 10 ether);
        return bob.balance;
    }
    
    function testTodo() returns (uint){
        // Carol carol = new Carol();
        // Carol carol = Carol(addr);
        // require(carol.balance == ?);
        return 0;
    }

}

contract Base {
    event InfoEvent(address contractAddress,  uint balance);
    function info(){
       InfoEvent(this, this.balance);
    }
}

contract Foo is Base {
  
    function Foo() payable {}

    function() payable {}
  
    function kill(){
        selfdestruct(msg.sender);
    }
}

// https://ethereum.stackexchange.com/questions/1891/whats-the-difference-between-msg-sender-and-tx-origin
contract Alice is Base {
    
    Foo public foo;
    
    function Alice(address _fooAddress) payable {
        foo = Foo(_fooAddress);
    }
    
    function() payable {}

    function testFooSend(){
        // Warning: Failure condition of 'send' ignored. Consider using 'transfer' instead.
        foo.send(1 ether);
        // foo.transfer(1 ether);
    }
    
    function testFooKill(){
        foo.kill();
    }
    
    //function kill(){
    //  selfdestruct(msg.sender);
    //}
}

contract Bob is Base {
    
    Foo public foo;
    Alice public alice;
    
    function Bob(address _fooAddress) payable {
        foo = Foo(_fooAddress);
        alice = new Alice(foo);
    }
    
    function() payable {}

    function testFooSend(){
        foo.transfer(2 ether);
    }
    
    function testFooKill(){
        foo.kill();
    }
    
    function testAliceFooSend(){
        alice.testFooSend();
    }
    
    function testAliceFooKill(){
        alice.testFooKill();
    }
}

contract Carol is Base {}

// TODO
// Foo - Create - Alice - Create - testFooSend - testFooKill
// Foo - Create - Bob - Create - testAliceFooSend
// TestMsgSender
//