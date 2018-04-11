pragma solidity ^0.4.10;

import "zeppelin-solidity/contracts/token/SimpleToken.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";


contract ProjectValidation {

    /**
    * projectValidation contract have number of stages:
    *   1) CollectingSignatures: accepting signatures from starter and manager of project
    *   2) TryToCompleteProjectStage: on this stage validators call tryToCompleteProject() function.
    *   3) CheckerWork: this stage is connected with checker work
    *   4) ProjectCompleted: this stage is called when project is complete
    *   5) ProjectNonCompleted: this stage is called when project is non-complete
    *   6) SuccessfullyClosed: this stage is called automatically after ProjectCompleted stage
    *   7) UnsuccessfullyClosed: this stage is called automatically after ProjectNonCompleted stage
    */
    enum Stages {
        CollectingSignatures,
        TryToCompleteProjectStage,
        CheckerWork,
        ProjectCompleted,
        ProjectNonCompleted,
        SuccessfullyClosed,
        UnsuccessfullyClosed
    }

    /**
    * Checker is the struct which contains next variables:
    *   addr: the ethereum address of checker
    *   signature: checker signature(true or false)
    *   signed: the fact about checker signing(signed = true, if checker already signed the project)
    *   presence: this variable help us to detect presence of checker on this project
    */
    struct Checker {
        address addr;
        bool signature;
        bool signed;
        bool presence;
    }

    /** address of project starter */
    address public starter;

    /** address of project manager */
    address public manager;

    /** read description about checker struct below */
    Checker public checker;

    /** the address of exchanger contract which convert fundTokens to Roots */
    address public exchangerContract;

    /** balance of project in fundTokens */
    uint public projectBalance;

    /** this variable show part of fundTokens which worker will receive */
    uint public workerRatio = 2;

    /** amount of fundTokens to send to exchanger contract if project successfully complete */
    uint public amountForRoots = 0;

    SimpleToken public fundTokens;

    /** addresses of workers */
    address[] public workers;

    mapping (address => uint) public workersBalances;

    /** signatures of validators */
    mapping (address => bool) public signatures;

    event Signed(address who);
    event Closed();
    event StateChanged(Stages previous, Stages current);

    /** show the current stage of contract */
    Stages public stage = Stages.CollectingSignatures;

    function ProjectValidation(
        address _manager,
        address _checker,
        address _exchangerContract,
        address[] _workers,
        address fundTokenAddress
    ) {
        starter = msg.sender;
        manager = _manager;
        checker = Checker(
            _checker,
            false,
            false,
            false
        );
        exchangerContract = _exchangerContract;
        fundTokens = SimpleToken(fundTokenAddress);
        workers = _workers;
        signatures[starter] = false;
        signatures[manager] = false;
    }

    modifier onlyValidator() {
        require(msg.sender == manager || msg.sender == starter || msg.sender == checker.addr);
        _;
    }

    modifier onlyChecker(){
        require(msg.sender == checker.addr && checker.presence);
        _;
    }

    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }

    function changeStateTo (Stages _stage) internal {
        StateChanged(stage, _stage);
        stage = _stage;
    }

    modifier afterExecutingGoToState(Stages _stage){
        _;
        changeStateTo(_stage);
    }

    /** allow validators to sign the project only at CollectingSignatures stage */
    function sign() external onlyValidator atStage(Stages.CollectingSignatures) returns (bool signed) {
        signatures[msg.sender] = true;
        Signed(msg.sender);
        return true;
    }

    /** allow checker to make a desicion about project */
    function checkerSign(bool signature) external onlyChecker atStage(Stages.CheckerWork) afterExecutingGoToState(Stages.TryToCompleteProjectStage) {
        checker.signed = true;
        checker.signature = signature;
    }

    /** interrupt the CollectingSignatures stage */
    function stopCollectSignatures() external onlyValidator atStage(Stages.CollectingSignatures) {
        changeStateTo(Stages.TryToCompleteProjectStage);
    }

    /** allow to get worker balance in fundTokens */
    function getWorkerBalance(address worker) external constant returns (uint balance) {
        uint fundWorkerBalance = workersBalances[worker];
        balance = fundWorkerBalance * 2 / 3;
    }

    /**
    * from tryToCompleteProject() function contract execution can go on 1 of 3 branches:
    *   1) call the checker and change stage to CheckerWork: if no necessary signatures from starter or manager and checker.precense == false
    *   2) successfully complete project: if there are necessary signatures from starter or manager or checker.signature = true
    *   3) Unsuccessfully complete project: if no necessary signatures from starter or manager and checker.presence = true and checker.signature = false
    */
    function tryToCompleteProject() external onlyValidator atStage(Stages.TryToCompleteProjectStage) {
        if (! ( (signatures[starter] && signatures[manager] ) || checker.presence)) {
            changeStateTo(Stages.CheckerWork);
            checker.presence = true;
        } else if ( (checker.signed && checker.signature) || (signatures[starter] && signatures[manager]) ) {
            changeStateTo(Stages.ProjectCompleted);
            projectBalance = fundTokens.balanceOf(this);
        } else {
            changeStateTo(Stages.ProjectNonCompleted);
            projectBalance = fundTokens.balanceOf(this);
        }
    }

    /**
    *   tryToCloseProject() function check the current stage and change it to SuccessfullyClosed stage if ProjectCompleted
    *   or to UnsuccessfullyClosed stage if ProjectNonCompleted
    */
    function tryToCloseProject() external onlyValidator {
        require(stage == Stages.ProjectCompleted || stage == Stages.ProjectNonCompleted);
        if (stage == Stages.ProjectCompleted) {
            changeStateTo(Stages.SuccessfullyClosed);
        } else {
            changeStateTo(Stages.UnsuccessfullyClosed);
        }
        Closed();
    }

    /** allow to send to workers their fundTokens and remaining fundTokens send to exchanger contract */
    function sendTokensToWorkers(uint8 _start, uint8 _end) external atStage(Stages.SuccessfullyClosed) returns (uint amount) {
        require(_start >= 0 && _end <= workers.length);
        for (uint8 i = _start; i < _end; i++) {
            uint workerBalance = workersBalances[workers[i]];
            projectBalance -= workerBalance;
            assert(fundTokens.transfer(workers[i], workerBalance));
        }
        assert(fundTokens.transfer(exchangerContract, amountForRoots));
    }

    /** allow to send fundTokens back to project starter only if project is closed unsuccessfully */
    function sendTokensBack() external onlyValidator atStage(Stages.UnsuccessfullyClosed) returns (uint amount) {
        assert(fundTokens.transfer(starter, fundTokens.balanceOf(this)));
    }

    /** allow validators change worker balance */
    function changeWorkerBalance(address worker, uint amount) external onlyValidator returns (bool success) {
        require(amount >= 0);
        uint pureBalance = amount * workerRatio / 3;
        amountForRoots += (amount - pureBalance);
        workersBalances[worker] = pureBalance;
    }

}
