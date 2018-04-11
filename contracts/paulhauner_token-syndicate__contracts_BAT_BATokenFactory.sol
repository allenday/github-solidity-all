pragma solidity ^0.4.10;
import './BAToken.sol';


contract BATokenFactory {

    event LogCreateBATokenContract(address newContractAddress);

    function BATokenFactory(){

    }

    function createBATokenContract(
    address _ethFundDeposit,
    address _batFundDeposit,
    uint256 _fundingStartBlock,
    uint256 _fundingEndBlock) returns (address newSyndicateAddress) {
        BAToken newContract = (new BAToken(
            _ethFundDeposit,
            _batFundDeposit,
            _fundingStartBlock,
            _fundingEndBlock
        ));
        LogCreateBATokenContract(address(newContract));
        return newContract;
    }
}
