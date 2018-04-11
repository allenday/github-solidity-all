pragma solidity ^0.4.4;

contract StembiljetBeheerder {
    
    bytes32[] private voteTokens;
    mapping (bytes32 => bytes32) private receipts;

    function registerVoteToken(bytes32 receiptIn, bytes32 voteTokenIn) {
        // TODO: verify that voteTokenIn is correct
        voteTokens.push(voteTokenIn);
        receipts[voteTokenIn] = receiptIn;
    }

    function getReceipt(bytes32 voteToken) constant returns (bytes32) {
        return receipts[voteToken];
    }

    function getVoteTokens() constant returns (bytes32[]) {
        return voteTokens;
    }
}