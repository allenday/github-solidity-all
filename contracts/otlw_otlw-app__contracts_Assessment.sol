pragma solidity ^0.4.11;

import "./Math.sol";
import "./Concept.sol";
import "./FathomToken.sol";

contract Assessment {
    address public assessee;
    address[] assessors;

    mapping (address => State) public assessorState;
    State public assessmentStage;
    enum State {
        None,
        Called,
        Confirmed,
        Committed,
        Done,
        Burned
    }

    Concept public concept;
    FathomToken fathomToken;

    uint public endTime;
    // will keep track of timelimits for 1) latest possible time to confirm and
    // 2) earliest time to reveal
    uint public checkpoint;
    uint public size;
    uint public cost;

    mapping(address => bytes32) commits;
    uint public done; //counter how many assessors have committed/revealed their score
    mapping(address => int128) scores;
    int public finalScore;
    bytes32 public salt; //used for token distribution

    modifier onlyConcept() {
        require(msg.sender == address(concept));
        _;
    }

    modifier onlyInStage(State _stage) {
        require(assessmentStage == _stage);
        _;
    }

    function Assessment(address _assessee,
                        uint _size,
                        uint _cost,
                        uint _confirmTime,
                        uint _timeLimit) public {
        assessee = _assessee;
        concept = Concept(msg.sender);
        fathomToken = concept.fathomToken();

        endTime = now + _timeLimit;
        // set checkpoint to latest possible time to confirm
        checkpoint = now + _confirmTime;
        assert(checkpoint < endTime);

        size = _size;
        cost = _cost;

        fathomToken.notification(assessee, 0); // assessee has started an assessment
        done = 0;
    }

    // ends the assessment, refunds the assessee and all assessors who have not been burned
    function cancelAssessment() private {
        uint assesseeRefund = assessmentStage == State.Called ? cost * size : cost * assessors.length; //in later stages size can be reduced by burned assessors
        fathomToken.transfer(assessee, assesseeRefund);
        fathomToken.notification(assessee, 3); //Assessment Cancelled and you have been refunded
        for (uint i = 0; i < assessors.length; i++) {
            if (assessorState[assessors[i]] != State.Burned) {
                fathomToken.transfer(assessors[i], cost);
                fathomToken.notification(assessors[i], 3); //Assessment Cancelled and you have been refunded
            }
        }
        selfdestruct(address(concept));
    }

    //adds a user to the pool eligible to accept an assessment
    function addAssessorToPool(address assessor) private returns(bool) {
        if (assessor != assessee && assessorState[assessor] == State.None) {
            fathomToken.notification(assessor, 1); //Called As A Potential Assessor
            assessorState[assessor] = State.Called;
            return true;
        }
    }

    /*
      To recursively set the pool to draw assessors from in the assessment
      stops when the pool of potential assessors is 20 times the size of the assessment2
      @param: uint seed = the seed number for random number generation
      @param: address _concept = the concept being called from
      @param: uint num = the total number of assessors to be called
    */
    function setAssessorPool(uint seed, address _concept, uint num) public onlyConcept() {
        uint numCalled = 0;
        uint membersOfConcept = Concept(_concept).getMemberLength();
        //we want to call at most half of the members of each concept
        uint maxFromThisPool = num > membersOfConcept/2 ? membersOfConcept/2 : num;
        for (uint k=0; k < maxFromThisPool; k++) {
            address randomUser = Concept(_concept).getWeightedRandomMember(seed + k);
            if (randomUser != address(0x0) && addAssessorToPool(randomUser)) {
                numCalled++;
            }
        }
        uint remaining = num - numCalled;
        if (remaining > 0) {
            for (uint i = 0; i < Concept(_concept).getParentsLength(); i++) {
                setAssessorPool(seed + numCalled + i, Concept(_concept).parents(i), remaining/Concept(_concept).getParentsLength() + 1); //Calls the remaining users from the parent concepts proportional to their size
            }
        }
        assessmentStage = State.Called;
    }

    /*
      Function to call all members of mew to be assessors. Will be removed after
      the alpha-testing phase.
    */
    function callAllFromMew(uint _nMew, address _mew) public onlyConcept() {
        Concept mew = Concept(_mew);
        for (uint i=0; i< _nMew; i++) {
            addAssessorToPool(mew.members(i));
        }
        assessmentStage = State.Called;
    }

    // called by an assessor to confirm and stake
    function confirmAssessor() public onlyInStage(State.Called) {
        // cancel if the assessment is past its startTime
        if (now > checkpoint){
            cancelAssessment();
            return;
        }
        if (assessorState[msg.sender] == State.Called &&
            assessors.length < size &&
            fathomToken.takeBalance(msg.sender, address(this), cost, concept)
            ) {
            assessors.push(msg.sender);
            assessorState[msg.sender] = State.Confirmed;
            fathomToken.notification(msg.sender, 2); //Confirmed for assessing, stake has been taken
        }
        if (assessors.length == size) {
            notifyAssessors(uint(State.Confirmed), 4);
            fathomToken.notification(assessee, 4);
            assessmentStage = State.Confirmed;
        }
    }
    //called by an assessor to commit a hash of their score //TODO explain in more detail what's happening
    function commit(bytes32 _hash) public onlyInStage(State.Confirmed) {
        if (now > endTime) {
            burnStakes(State.Confirmed);
        }
        if (assessorState[msg.sender] == State.Confirmed) {
                commits[msg.sender] = _hash;
                assessorState[msg.sender] = State.Committed;
                done++; //Increases done by 1 to help progress to the next assessment stage.
        }
        if (done == size) {
            //set checkpoint to end of 12 hour challenge period after which scores can be revealed
            checkpoint = now + 12 hours;
            notifyAssessors(uint(State.Committed), 5);
            done = 0; //Resets the done counter
            assessmentStage = State.Committed;
        }
    }


    function steal(int128 _score, string _salt, address assessor) public {
        if(assessorState[assessor] == State.Committed) {
            if(commits[assessor] == keccak256(_score, _salt)) {
                fathomToken.transfer(msg.sender, cost/2);
                assessorState[assessor] = State.Burned;
                size--;
            }
        }
    }

    //@purpose: called by assessors to reveal their own commits or others
    // must be called between 12 hours after the latest commit and 24 hours after the
    // end of the assessment. If the last commit happens during at the last possible
    // point in time (right before endtime), this period will be 12hours
    function reveal(int128 _score, string _salt) public onlyInStage(State.Committed) {
        // scores can only be revealed after the challenge period has passed
        require(now > checkpoint);
        // If the time to reveal has passed, burn all unrevealed assessors
        if (now > endTime + 24 hours) {
            burnStakes(State.Committed);
        }

        if(assessorState[msg.sender] == State.Committed &&
           commits[msg.sender] == keccak256(_score, _salt)) {
                    scores[msg.sender] = _score;
                    salt = salt ^ (keccak256(_salt));
                    assessorState[msg.sender] = State.Done;
                    done++;
        }

        if (done == size) {
            assessmentStage = State.Done;
            calculateResult();
        }
    }

    //burns stakes of all assessors who are in a certain state
    function burnStakes(State _state) private {
        for (uint i = 0; i < assessors.length; i++) {
            if (assessorState[assessors[i]] == _state) {
                burnAssessor(assessors[i]);
           }
        }
    }

    /** mark an assessor as burned, reduce size and cancel assessment
        if the size is below five.
        @param _assessor address of the assessor to be burned
    */
    function burnAssessor(address _assessor) private {
        assessorState[_assessor] = State.Burned;
        if (--size < 5) {
            cancelAssessment();
        }
    }

    function notifyAssessors(uint _state, uint _topic) private {
        for (uint i=0; i < assessors.length; i++) {
            if (uint(assessorState[assessors[i]]) == _state) {
                fathomToken.notification(assessors[i], _topic);
            }
        }
    }

    function calculateResult() onlyInStage(State.Done) private {
        int[] memory finalScores = new int[] (done);
        uint idx =0;
        for (uint j = 0; j < assessors.length; j++) {
            if (assessorState[assessors[j]] == State.Done) {
                finalScores[idx] = scores[assessors[j]];
                idx++;
            }
        }
        uint finalClusterLength;
        (finalScore, finalClusterLength) = Math.getFinalScore(finalScores);
        // check if a majority of assessors found a point of consensus
        if (finalClusterLength > done/2) {
            payout(finalClusterLength);
            if (finalScore > 0) {
                concept.addMember(assessee, uint(finalScore) * finalClusterLength);
            }
        } else {
            // set final Score to zero to signal no consensus
            finalScore = 0;
        }
        fathomToken.notification(assessee, 7);
    }

    function payout(uint finalClusterLength) onlyInStage(State.Done) public {
        uint q = 1; //INFLATION RATE
        uint dissentBonus = 0;
        bool[] memory inAssessor = new bool[] (assessors.length);
        uint[] memory inAssessorPayout = new uint[] (assessors.length);
        // pay out dissenting assessors their reduced stake and save how much stake to redistribute to whom
        for (uint i = 0; i < assessors.length; i++) {
            if (assessorState[assessors[i]] == State.Done) {
                uint payoutValue;
                bool dissenting;
                (payoutValue, dissenting) = Math.getPayout(Math.abs(scores[assessors[i]] - finalScore), cost, q);
                if (dissenting) {
                    dissentBonus += cost - payoutValue;
                    if (payoutValue > 0) {
                        fathomToken.transfer(assessors[i], payoutValue);
                    }
                    fathomToken.notification(assessors[i], 6); //Consensus reached; Tokens paid out
                } else {
                    inAssessor[i] = true;
                    inAssessorPayout[i] = payoutValue;
                }
            }
        }
        // pay out the majority-assessors their share of stake + the remainders of any dissenting assessors
        for (uint j = 0; j < inAssessorPayout.length; j++) {
            if (inAssessor[j]) {
                fathomToken.transfer(assessors[j],
                                                    inAssessorPayout[j] + dissentBonus/finalClusterLength);
                fathomToken.notification(assessors[j], 6); //Consensus reached; Tokens paid out
            }
        }
    }
}
