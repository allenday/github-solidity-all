pragma solidity ^0.4.15;

import "./Roles.sol";


contract ContributionRegistration is SecuredWithRoles {
    mapping(bytes32 => string) contributionLists;
    // TODO add campaigns too in order for the providers to be able reconstruct the contribution pool

    function ContributionRegistration(address roles) SecuredWithRoles("ContributionRegistration", roles) {

    }

    function hasHash(bytes10 date, uint8 idx) constant returns (bool) {
        return keccak256(contributionLists[keccak256(date, idx)]) != keccak256("");
    }

    function getHash(bytes10 date, uint8 idx) constant returns (string) {
        return contributionLists[keccak256(date, idx)];
    }

    function getLastHash(bytes10 date) constant returns (string hash) {
        uint8 index = 0;
        while(keccak256(contributionLists[keccak256(date, index)]) != keccak256("")) {
            hash = contributionLists[keccak256(date, index++)];
        }
    }

    /* the date is in the format dd-mm-yyyy and we add 1 to it until no more entries are found */
    function addContributionList(bytes10 date, string ipfsHash) roleOrOwner("oracle") public returns (bytes32 index) {
        uint8 i = 0;
        index = keccak256(date, i);
        while(keccak256(contributionLists[index]) != keccak256("")) {
            index = keccak256(date, ++i);
        }
        contributionLists[index] = ipfsHash;
    }


}
