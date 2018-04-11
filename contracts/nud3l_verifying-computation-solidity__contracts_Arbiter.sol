pragma solidity ^0.4.8;
import "./AbstractComputationService.sol";
import "./Judge.sol";

contract Arbiter {
  // Requests can have different status with a default of 0
  // status 100: request is created, no solutions are provided
  // status 200: request for computations send; awaiting results
  // status 300 + n: 0 + n results are in (i.e 301 := 1 result is in)
  // status 400: all results are in
  // status 500: solver and validators match
  // status 600 + n: solver and validators mismatch with n binary encoding of mismatches
  // e.g. status 629: 600 + 16 + 8 + 4 + 1 => verfier 0, 2, 3, 4 indicated a mismatch
  // status 700: dispute resolution started
  // status 701: dispute resolution state 1
  // status 801: dispute resolved; solver correct
  // status 802: dispute resolved; solver incorrect
  // status 900: result send to requester

  address public judge;

  struct Request {
    string input1;
    string input2;
    uint operation;
    address solver;
    address[] verifier;
    string resultSolver;
    string[6] resultVerifier;
    uint status;
    bool finished;
  }

  mapping(uint256 => Request) public requests;
  mapping(address => uint256) public currentRequest;

  address[] public service;
  mapping(address => uint) internal serviceIndex;

  event newRequest(uint newRequest);
  event solverFound(address solverFound);
  event verifierFound(address verifierFound);
  event StatusChange(uint status_code);
  event newExecution(uint newExecution);
  event solverExecution(address solverExecution);
  event verifierExecution(address verifierExecution);
  event receivedResult(string receivedResult);
  event loopTest(uint helper, uint thisValue);

  // event thisIndex(uint thisIndex);
  // event step(uint thisStep);
  // event setLength(uint setLength);

  function enableService() {
    uint index;
    service.push(msg.sender);
    index = (service.length - 1);
    serviceIndex[msg.sender] = index;
  }

  function disableService() {
    uint index;
    index = serviceIndex[msg.sender];
    delete service[index];
    serviceIndex[msg.sender] = 0;

    // update service array and index mapping
    if (index < (service.length - 1)) {
      uint next_index;
      uint this_index;
      this_index = index;
      next_index = this_index + 1;

      while (this_index < (service.length - 1)) {
        service[this_index] = service[next_index];
        delete service[next_index];
        this_index++;
        next_index++;
      }
    }
  }

  function requestComputation(string _input1, string _input2, uint _operation, uint _numVerifiers) {
    // testEvent("Request computation started");
    address solver;
    address verifier;
    uint256 computationId;
    uint count = 0;
    uint check;
    uint index;
    uint length = service.length;
    address[] memory remainingService = new address[](length);

    // number of services for potential verifiers minus solver; maximum 6 verifiers
    if (_numVerifiers > service.length) throw;
    if (_numVerifiers > 6) throw;

    remainingService = service;

    computationId = rand(0, 2**64);

    currentRequest[msg.sender] = computationId;

    requests[computationId].input1 = _input1;
    requests[computationId].input2 = _input2;
    requests[computationId].operation = _operation;

    newRequest(computationId);

    // select a random solver from the list of computation services
    index = rand(0, length - 1);
    solver = remainingService[index];
    requests[computationId].solver = solver;
    solverFound(solver);

    for (uint i = index; i < length - 1; i++) {
      remainingService[i] = remainingService[i + 1];
    }
    // length-- is a workaround since memory arrays can NOT be resized
    length--;

    // select random verifiers from the list of computation services
    for (uint j = 0; j < _numVerifiers; j++) {
      index = rand(0, length - 1);
      verifier = remainingService[index];
      requests[computationId].verifier.push(verifier);
      verifierFound(verifier);

      for (uint k = index; k < length - 1; k++) {
        remainingService[k] = remainingService[k + 1];
      }
      length--;
    }

    // status 100: request is created, no solutions are provided
    updateStatus(100, computationId);
    StatusChange(requests[computationId].status);
  }

  function executeComputation() payable {
    uint256 computationId = currentRequest[msg.sender];
    // status 200: request for computations send; awaiting results
    // updateStatus(200, computationId);

    newExecution(computationId);
    // send computation request to the solver
    AbstractComputationService mySolver = AbstractComputationService(requests[computationId].solver);
    mySolver.compute.value(10000000000000000).gas(500000)(requests[computationId].input1, requests[computationId].input2, requests[computationId].operation, computationId);
    solverExecution(requests[computationId].solver);

    // send computation request to all verifiers
    for (uint i = 0; i < requests[computationId].verifier.length; i++) {
      AbstractComputationService myVerifier = AbstractComputationService(requests[computationId].verifier[i]);
      myVerifier.compute.value(10000000000000000).gas(500000)(requests[computationId].input1, requests[computationId].input2, requests[computationId].operation, computationId);
      verifierExecution(requests[computationId].verifier[i]);
    }

    StatusChange(requests[computationId].status);
  }

  function receiveResults(string _result, uint256 _computationId) {
    // ONLY FOR LOCAL TESTING
    if (requests[_computationId].status == 100) {
      updateStatus(200, _computationId);
    }

    receivedResult(_result);

    uint count = 0;
    // receive results from solvers and verifiers
    if (msg.sender == requests[_computationId].solver) {
      requests[_computationId].resultSolver = _result;
      count = 1;
    } else {
      for (uint i = 0; i < requests[_computationId].verifier.length; i++) {
        if (msg.sender == requests[_computationId].verifier[i]) {
          requests[_computationId].resultVerifier[i] = _result;
          count = 1;
          break;
        }
      }
    }

    // status 300 + n: 0 + n results are in (i.e 301 := 1 result is in)
    if (requests[_computationId].status == 200) {
      updateStatus((300 + count), _computationId);
    } else {
      updateStatus((requests[_computationId].status + count), _computationId);
    }

    if ((requests[_computationId].status - 300) == (1 + requests[_computationId].verifier.length)) {
      // status 400: all results are in
      updateStatus(400, _computationId);
    }

    StatusChange(requests[_computationId].status);
  }

  function compareResults() {
    uint256 computationId = currentRequest[msg.sender];

    if (requests[computationId].status != 400) throw;

    uint count = 0;

    for (uint i = 0; i < requests[computationId].verifier.length; i++) {
      if (!(stringsEqual(requests[computationId].resultSolver,requests[computationId].resultVerifier[i]))) {
        count += 2**i;
      }
    }

    if (count == 0) {
      // status 500: solver and validators match
      requests[computationId].status = 500;
    } else {
      // status 700: solver and validators mismatch
      requests[computationId].status = 700 + count;
    }

    StatusChange(requests[computationId].status);
  }

  function requestIndex() {
    uint256 computationId = currentRequest[msg.sender];

    // get all verifiers that disagreed with the solver
    uint length = requests[computationId].verifier.length;
    uint[] memory verifierIndex = new uint[](length);
    uint count = requests[computationId].status - 700;
    uint helper = length - 1;

    for (uint i = 0; i < length; i++) {
      if (count >= (2**helper)) {
        verifierIndex[helper] = 1;
        count -= (2**helper);
      }
      helper--;
    }

    // status 800: dispute resolution started
    requests[computationId].status = 800;
    StatusChange(requests[computationId].status);

    // request an index in the result, which is different
    for (uint j = 0; j < length; j++) {
      if (verifierIndex[j] == 1) {
        AbstractComputationService myVerifier = AbstractComputationService(requests[computationId].verifier[j]);
        myVerifier.provideIndex.gas(100000)(requests[computationId].resultSolver, computationId);
      }
    }
  }

  function receiveIndex(uint _index1, uint _index2, uint _operation, uint256 _computationId, bool _end) {
    // receives two coordinates
    uint result;
    bool solverCorrect;
    uint input1;
    uint input2;

    input1 = stringToUint(requests[_computationId].input1);
    input2 = stringToUint(requests[_computationId].input2);

    // check if solver and verifier value differ for given coordinates
    // this is just an integer check
    if (requests[_computationId].status < 900) {
      if (_end) {
        result = stringToUint(requests[_computationId].resultSolver);
        Judge myJudge = Judge(judge);
        solverCorrect = myJudge.resolveDispute(input1, input2, result, _operation);
        if (solverCorrect) {
          // status 901: dispute resolved; solver correct
          requests[_computationId].status = 901;
        } else {
          // status 902: dispute resolved; solver incorrect
          requests[_computationId].status = 902;
        }
      }
    }

    StatusChange(requests[_computationId].status);
    // TODO: matrix check
  }

  function setJudge(address _judge) {
    judge = _judge;
  }

  function updateStatus(uint newStatus, uint computationId) {
    requests[computationId].status = newStatus;
  }

  function getStatus(address _requester) constant returns (uint status) {
    status = requests[currentRequest[_requester]].status;
  }

  function getCurrentSolver(address _requester) constant returns (address solver) {
    solver = requests[currentRequest[_requester]].solver;
  }

  function stringToUint(string s) internal constant returns (uint result) {
    bytes memory b = bytes(s);
    uint i;
    result = 0;
    for (i = 0; i < b.length; i++) {
      uint c = uint(b[i]);
      if (c >= 48 && c <= 57) {
          result = result * 10 + (c - 48);
      }
    }
  }

  function stringsEqual(string _a, string _b) internal constant returns (bool) {
    bytes memory a = bytes(_a);
    bytes memory b = bytes(_b);
    if (a.length != b.length) return false;

    for (uint i = 0; i < a.length; i ++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  function rand(uint min, uint max) internal constant returns (uint256 random) {
    uint256 blockValue = uint256(block.blockhash(block.number-1));
    random = uint256(uint256(blockValue)%(min+max));
    return random;
  }
}
