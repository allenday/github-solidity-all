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

import "./lib/oraclizeAPI.sol"

contract DaoInterface {

    // Token Creation
    uint public closingTime;

    // Token
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _amount) returns (bool success);

    // Dao
    modifier onlyTokenholders {}
    function halveMinQuorum() returns (bool _success);
    function changeAllowedRecipients(address _recipient, bool _allowed) external returns (bool _success);
    function getNewDAOAddress(uint _proposalID) constant returns (address _newDAO);
    function newProposal(address _recipient, uint _amount, string _description, bytes _transactionData, uint _debatingPeriod, bool _newCurator) onlyTokenholders returns (uint _proposalID);
    function vote(uint _proposalID, bool _supportsProposal) onlyTokenholders returns (uint _voteID);
    function splitDAO(uint _proposalID, address _newCurator) returns (bool _success);
    function executeProposal(uint _proposalID, bytes _transactionData) returns (bool _success);
}


// TODO: also make proposal to get funds from extraBalance

contract AutoSplitCurator is usingOraclize {
//    uint constant minProposalDebatePeriod = 2 weeks;
    uint constant minProposalDebatePeriod = 5 minutes;
//    uint constant minSplitDebatePeriod = 1 weeks;
    uint constant minSplitDebatePeriod = 5 minutes;
    uint proposalDeposit = 2000000000000000000;
    address public parentDaoAddress;
    address public childDaoAddress;
    DaoInterface parentDao;
    DaoInterface childDao;
    address public splitInitiator;
    uint latestAutoCuratorSplitProposalId;
    uint latestAutoCuratorWithdrawProposalId;

    bytes32 oraclizeSplitProposalId;
    bytes32 oraclizeSplitExecutionId;
    bytes32 oraclizeRefundProposalId;

    bool public success = false;

    modifier onlySplitter {
        if (msg.sender != splitInitiator)
            throw;
        _
    }

    function AutoSplitCurator(address _parentDaoAddress) {
        parentDaoAddress = _parentDaoAddress;
        parentDao = DaoInterface(parentDaoAddress);
        splitInitiator = address(msg.sender);
    }

    function startSplit() onlySplitter {
        latestAutoCuratorSplitProposalId = parentDao.newProposal(address(this),
                             0,
                             "AutoCurator split proposal",
                             "",
                             minSplitDebatePeriod,
                             true);
        parentDao.vote(latestAutoCuratorSplitProposalId, true);
        oraclizeSplitProposalId = oraclize_query(now + minSplitDebatePeriod + 1, "URL","", 3500000);
    }

    function executeParentDaoSplit() internal {
        parentDao.splitDAO(latestAutoCuratorSplitProposalId, address(this));
        childDaoAddress = parentDao.getNewDAOAddress(latestAutoCuratorSplitProposalId);
        if (childDaoAddress != address(0)) {
            childDao = DaoInterface(childDaoAddress);
            oraclizeSplitExecutionId = oraclize_query(childDao.closingTime() + 1, "URL","", 500000);
        }
    }

    function prepareWithdrawProposalGivenSplitProposalId() internal {
        childDao.halveMinQuorum();
        childDao.changeAllowedRecipients(splitInitiator, true);
        latestAutoCuratorWithdrawProposalId = childDao.newProposal.value(proposalDeposit)(address(this),
                             childDao.balance,
                             "",
                             "",
                             minProposalDebatePeriod,
                             false);
        childDao.vote(latestAutoCuratorWithdrawProposalId, true);
        oraclizeRefundProposalId = oraclize_query(now + minProposalDebatePeriod + 1, "URL","", 3500000);
    }

    function executeChildDaoProposal() internal {
        childDao.executeProposal(latestAutoCuratorWithdrawProposalId, "");
//        if (!splitInitiator.send(this.balance)) throw;
        success = true;
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;

        if (myid == oraclizeSplitProposalId) {
            executeParentDaoSplit();
        } else if (myid == oraclizeSplitExecutionId) {
            prepareWithdrawProposalGivenSplitProposalId();
        } else if (myid == oraclizeRefundProposalId) {
            executeChildDaoProposal();
        }
    }

    function () returns (bool _success) { return true; }

    function withdrawDao() onlySplitter { if (!parentDao.transfer(msg.sender, parentDao.balanceOf(address(this)))) throw; }
    function withdrawChildDao() onlySplitter { if (!childDao.transfer(msg.sender, childDao.balanceOf(address(this)))) throw; }
    function withdrawEth() onlySplitter { if (!msg.sender.send(this.balance)) throw; }
    function setProposalDeposit(uint _proposalDeposit) onlySplitter { proposalDeposit = _proposalDeposit; }


}