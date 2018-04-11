pragma solidity ^0.4.10;

import "zeppelin-solidity/contracts/token/SimpleToken.sol";
import "zeppelin-solidity/contracts/token/ERC20Basic.sol";
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


contract PensionFundRelease {
    address[] public validators;
    address public worker;
    address public master;
    uint8 public firstPaymentPercent;
    uint8 public recurrentPaymentPercent;
    uint public paymentTime;
    uint public recurrentPaymentInterval;
    bool public firtPaymentReleased = false;
    ERC20Basic public roots;
    uint public initialFunds;

    struct Vote {
        bool approve;
        address validator;
        string justification;
    }

    mapping (address => uint) public voteIndex;
    Vote[] public votes;

    event Voted(bool approve, address validator, string justification);
    event Released(uint amount, address worker);
    event Refunded(uint amount, address master);

    function PensionFundRelease(
        address[] _validators,
        address _worker,
        address _master,
        uint8 _firstPaymentPercent,
        uint _firstPaymentTime,
        uint _recurrentPaymentInterval,
        uint8 _recurrentPaymentPercent,
        address _rootsAddress
    ) {
        require(_validators.length > 0);
        require(_worker != 0x0);
        require(_master != 0x0);
        require(_firstPaymentPercent <= 100);
        require(_recurrentPaymentPercent <= 100);

        validators = _validators;
        worker = _worker;
        master = _master;
        firstPaymentPercent = _firstPaymentPercent;
        paymentTime = _firstPaymentTime;
        recurrentPaymentInterval = _recurrentPaymentInterval;
        roots = ERC20Basic(_rootsAddress);
        recurrentPaymentPercent = _recurrentPaymentPercent;

        votes.push(Vote(false, 0x0, "")); //first dummy vote
    }

    //ensure that only validator can perform the action
    modifier onlyValidator() {
        bool isValidator = false;
        for (uint i = 0; i < validators.length; i++) {
            isValidator = isValidator || (msg.sender == validators[i]);
        }
        require(isValidator);
        _;
    }

    //vote for the fund release or burn
    function vote(bool approve, string justification) onlyValidator returns (uint index) {
        index = voteIndex[msg.sender];
        Vote memory vote = Vote(approve, msg.sender, justification);
        if (index == 0) {
            index = votes.length;
            voteIndex[msg.sender] = index;
            votes.push(vote);
        } else {
            votes[index] = vote;
        }

        Voted(approve, msg.sender, justification);
    }

    // check wether validators have approved the release
    function isReleaseApproved() constant returns (bool approved) {
        uint num = 0;
        for (uint i = 1; i < votes.length; i++) { //skip dummy vote
            if (votes[i].approve)
                num++;
        }

        return num == validators.length;
    }

    // Check whether the time period on fund dispersal has been reached
    function isFundFreezePeriodEnded() constant returns (bool ended) {
        return (block.timestamp > paymentTime);
    }

    // check wether validators have decided to burn the fund
    function isBurnApproved() constant returns (bool approved) {
        uint num = 0;
        for (uint i = 1; i < votes.length; i++) { //skip dummy vote
            if (!votes[i].approve)
                num++;
        }

        return num == validators.length;
    }

    // calculate the amount of payment
    function getPaymentAmount() constant returns (uint amount) {
        if (!firtPaymentReleased) {
            return initialFunds * firstPaymentPercent / 100;
        } else {
            return initialFunds * recurrentPaymentPercent / 100;
        }
    }

    // get current fund balance in ROOTs
    function balance() constant returns (uint amount) {
        return roots.balanceOf(this);
    }

    // release the fund
    function releaseRoots() returns (uint releasedAmount) {
        // Confirm validators have released funds
        require(isReleaseApproved());
        // Confirm the next payment is due to be released
        require(isFundFreezePeriodEnded());
        if (!firtPaymentReleased) {
            initialFunds = balance();
            releasedAmount = getPaymentAmount();
            firtPaymentReleased = true;
        } else {
            releasedAmount = getPaymentAmount();
        }
        if (releasedAmount > balance())
            releasedAmount = balance();
        // Assumes intended interval is meant to recur regardless of claiming funds
        paymentTime = paymentTime + recurrentPaymentInterval;
        roots.transfer(worker, releasedAmount);
        Released(releasedAmount, worker);
    }

    function refundRoots() returns (uint refundedAmount) {
        // Confirm validators have refunded funds
        require(isBurnApproved());
        // Assumes intended interval is meant to recur regardless of claiming funds
        refundedAmount = balance();
        roots.transfer(master, refundedAmount);
        Refunded(refundedAmount, master);
    }
}
