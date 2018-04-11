/*
This file is part of the EasyCrowdsale Contract.

The EasyCrowdsale Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The EasyCrowdsale Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the EasyCrowdsale Contract. If not, see <http://www.gnu.org/licenses/>.

@author Ilya Svirin <i.svirin@prover.io>
*/

pragma solidity ^0.4.0;

contract owned {

    address public owner;

    function owned() payable {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    function changeOwner(address _owner) onlyOwner public {
        owner = _owner;
    }
}

contract Crowdsale is owned {
    
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function Crowdsale() payable owned() {
        totalSupply = 21000000;
        balanceOf[this] = 20000000;
        balanceOf[owner] = totalSupply - balanceOf[this];
        Transfer(this, owner, balanceOf[owner]);
    }

    function () payable {
        require(balanceOf[this] > 0);
        uint256 tokensPerOneEther = 5000;
        uint256 tokens = tokensPerOneEther * msg.value / 1000000000000000000;
        if (tokens > balanceOf[this]) {
            tokens = balanceOf[this];
            uint valueWei = tokens * 1000000000000000000 / tokensPerOneEther;
            msg.sender.transfer(msg.value - valueWei);
        }
        require(tokens > 0);
        balanceOf[msg.sender] += tokens;
        balanceOf[this] -= tokens;
        Transfer(this, msg.sender, tokens);
    }
}

contract EasyToken is Crowdsale {
    
    string  public standard    = 'Token 0.1';
    string  public name        = 'EasyTokens';
    string  public symbol      = "ETN";
    uint8   public decimals    = 0;

    function EasyToken() payable Crowdsale() {}

    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }
}

contract EasyCrowdsale is EasyToken {

    function EasyCrowdsale() payable EasyToken() {}
    
    function withdraw() public onlyOwner {
        owner.transfer(this.balance);
    }
    
    function killMe() public onlyOwner {
        selfdestruct(owner);
    }
}