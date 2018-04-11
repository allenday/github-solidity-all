pragma solidity ^0.4.0;

// Title AbstractSafecontractsTREXCrowdfunding.sol
// Customize @author Rocky Fikki - <rocky@fikki.net>
// Credit - https://github.com/ConsenSys/singulardtv-contracts

contract AbstractSafecontractsTREXCrowdfunding {
    function trexdevshopWaited1Years() returns (bool);
    function startDate() returns (uint);
    function CROWDFUNDING_PERIOD() returns (uint);
    function TOKEN_TARGET() returns (uint);
    function valuePerShare() returns (uint);
    function fundBalance() returns (uint);
    function campaignEndedSuccessfully() returns (bool);
}
