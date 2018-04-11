pragma solidity ^0.4.17;

contract IssueElection {
    uint num_votes_required;
    uint num_votes_cast;
    string label;
    string description;

    function reset() private {
        num_votes_cast = 0;
        num_votes_required = 0;
        label = "";
        description = "";
    }

    function castVote() public {
        num_votes_cast += 1;
    }

    function setLabel(string newLabel) public {
        reset();
        label = newLabel;
    }

    function setDescription(string newDesccription) public {
        reset();
        description = newDesccription;
    }

    function setNumVotesRequired(uint newRequirement) public {
        num_votes_required = newRequirement;
    }
}
