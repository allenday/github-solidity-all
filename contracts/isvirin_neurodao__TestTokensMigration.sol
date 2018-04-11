/*
This file is part of the NeuroDAO Contract.

The NeuroDAO Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The NeuroDAO Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the NeuroDAO Contract. If not, see <http://www.gnu.org/licenses/>.

@author Ilya Svirin <i.svirin@nordavind.ru>
*/

pragma solidity ^0.4.0;

contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value);
}

contract TestTokensMigration is MigrationAgent {

    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    address public migrationHost;
 
    function TestTokensMigration(address _migrationHost) {
        migrationHost = _migrationHost;
    }

    function migrateFrom(address _from, uint256 _value) public {
        require(migrationHost == msg.sender);
        require(balanceOf[_from] + _value > balanceOf[_from]); // overflow?
        balanceOf[_from] += _value;
        totalSupply += _value;
    }
}