<license>
/*
 * This file is part of the DAO. The DAO is free software: you can redistribute it and/or modify it under the terms of
 * the GNU lesser General Public License as published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version. The DAO is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * lesser General Public License for more details. You should have received a copy of the GNU lesser General Public
 * License along with the DAO.  If not, see `link:http://www.gnu.org/licenses/|http://www.gnu.org/licenses/`.
 */
</license>

<purpose>/*
 *
 */</purpose>
<interface></interface>
<contract>contract DAO_Creator {
  function createDAO(address _curator, uint _proposalDeposit, uint _minTokensToCreate, uint _closingTime) returns (DAO _newDAO) {
        return new DAO(_curator, DAO_Creator(this), _proposalDeposit, _minTokensToCreate, _closingTime, msg.sender);
  }
}</contract>
