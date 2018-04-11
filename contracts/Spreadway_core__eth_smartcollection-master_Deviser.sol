/*
This file is part of the Deviser Contract.

The Deviser Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The Deviser Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the Deviser Contract. If not, see <http://www.gnu.org/licenses/>.
*/

pragma solidity ^0.4.0;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }
}

contract Deviser is owned {
    uint    public lastAction;
    uint    public timeout;
    address public heir;

    event Income  (address indexed from, uint amount);
    event Outcome (address indexed to,   uint amount);
    event Withdraw(address indexed to,   uint amount);

    modifier onlyHeir {
        require(heir == msg.sender);
        _;
    }
    
    function Deviser() owned {
        heartbeat();
    }
    
    function heartbeat() public onlyOwner {
        lastAction = now;
    }
    
    function () payable public {
        heartbeat();
        Income(msg.sender, msg.value);
    }
    
    function setHeir(address _heir, uint _timeout) public onlyOwner {
        heir    = _heir;
        timeout = _timeout;
    }
    
    function pay(address _to, uint _amount) public onlyOwner {
        require(_amount <= this.balance);
        heartbeat();
        require(_to.call.gas(3000000).value(_amount)());
        Outcome(_to, _amount);
    }
    
    function withdraw() public onlyHeir {
        require(heir != 0);
        require(lastAction + timeout <= now);
        Withdraw(heir, this.balance);
        selfdestruct(heir);
    }
}