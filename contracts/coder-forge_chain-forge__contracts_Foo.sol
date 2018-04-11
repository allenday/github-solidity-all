pragma solidity ^0.4.2;

import './Bar.sol';

contract Foo{

    function createBar(){

      Bar bar = new Bar();
    }
}
