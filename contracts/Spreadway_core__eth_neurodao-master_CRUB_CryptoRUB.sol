/*
This file is part of the CRUB Contract.

The CRUB Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The CRUB Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the CRUB Contract. If not, see <http://www.gnu.org/licenses/>.

@author Ilya Svirin <i.svirin@nordavind.ru>
IF YOU ARE ENJOYED IT DONATE TO 0x3Ad38D1060d1c350aF29685B2b8Ec3eDE527452B ! :)
*/


pragma solidity ^0.4.0;

contract owned {

    address public owner;
    address public newOwner;

    function owned() payable public {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    function changeOwner(address _owner) onlyOwner public {
        require(_owner != 0);
        newOwner = _owner;
    }
    
    function confirmOwner() public {
        require(newOwner == msg.sender);
        owner = newOwner;
        delete newOwner;
    }
}

contract Token {
    
    string  public standard    = "Token 0.1";
    string  public name        = "CRUB";
    string  public symbol      = "CRUB";
    uint8   public decimals    = 2;

    uint    public totalSupply;
    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowed;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    event Burn(address indexed who, uint value);

    // Fix for the ERC20 short address attack
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }

    function Token() payable public {}

    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }
    
    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]); // overflow
        require(allowed[_from][msg.sender] >= _value);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint _value) public {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }
    
    function burn(uint _value) public {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
    }
}

contract CryptoRUB is owned, Token {

    mapping (address => bool) public officers;

    event Emit(address indexed from, uint value);
   
    function CryptoRUB() payable public {}

    function addOfficer(address _officer) onlyOwner public {
        require(officers[_officer] == false);
        officers[_officer] = true;
    }
    
    function removeOfficer(address _officer) onlyOwner public {
        require(officers[_officer] == true);
        officers[_officer] = false;
    }
    
    function emit(uint _value) public {
        require(officers[msg.sender] == true);
        require(totalSupply + _value > totalSupply);
        balanceOf[this] += _value;
        totalSupply += _value;
        Emit(msg.sender, _value);
    }
    
    function transferFund(address _to, uint _value) public {
        require(officers[msg.sender] == true);
        require(balanceOf[this] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[this] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }
}