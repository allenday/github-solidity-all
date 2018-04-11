pragma solidity ^0.4.0;

import "./Concept.sol";
import "./ConceptRegistry.sol";

// Contract that can add a specified number of members to the mew-concept
// of the given conceptRegistry
contract Distributor{
    uint public nInitialMembers;
    address public conceptRegistry;
    address[] public memberAddresses;
    uint[] public memberWeights;

    function Distributor(uint _nInitialMembers, address _conceptRegistry) public {
        nInitialMembers = _nInitialMembers;
        conceptRegistry = _conceptRegistry;
    }

    function addInitialMember(address _memberAddress, uint _memberWeight) public {
        require(memberAddresses.length < nInitialMembers);
        Concept(ConceptRegistry(conceptRegistry).mewAddress()).addInitialMember(_memberAddress, _memberWeight);
        memberAddresses.push(_memberAddress);
        memberWeights.push(_memberWeight);
    }

}

