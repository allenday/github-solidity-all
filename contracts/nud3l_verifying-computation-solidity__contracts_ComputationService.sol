pragma solidity ^0.4.8;
import "./usingOraclize.sol";
import "./AbstractArbiter.sol";

contract ComputationService is usingOraclize {
  struct Query {
    string URL;
    string JSON;
  }
  mapping(uint => Query) public computation;

  struct Request {
    string input1;
    string input2;
    uint operation;
    uint256 computationId;
    string result;
    address arbiter;
  }

  mapping(uint256 => bytes32) public requestId;
  mapping(bytes32 => Request) public requestOraclize;

  address public arbiter;

  event newOraclizeQuery(string description);
  event newResult(string comp_result);
  event newOraclizeID(bytes32 ID);

  function ComputationService() {
    OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
  }

  function __callback(bytes32 _oraclizeID, string _result) {
    if (msg.sender != oraclize_cbAddress()) throw;
    newResult(_result);

    requestOraclize[_oraclizeID].result = _result;

    // send result to arbiter contract
    AbstractArbiter myArbiter = AbstractArbiter(requestOraclize[_oraclizeID].arbiter);
    myArbiter.receiveResults.gas(80000)(_result, requestOraclize[_oraclizeID].computationId);
  }

  function compute(string _val1, string _val2, uint _operation, uint256 _computationId) payable {
    bytes32 oraclizeID;

    computation[_operation].JSON = strConcat('\n{"val1": ', _val1, ', "val2": ', _val2, '}');

    newOraclizeQuery("Oraclize query was sent, standing by for the answer.");

    oraclizeID = oraclize_query(60, "URL", computation[_operation].URL, computation[_operation].JSON, 350000);

    // store address for specific request
    requestOraclize[oraclizeID].input1 = _val1;
    requestOraclize[oraclizeID].input2 = _val2;
    requestOraclize[oraclizeID].operation = _operation;
    requestOraclize[oraclizeID].computationId = _computationId;
    requestOraclize[oraclizeID].arbiter = msg.sender;

    requestId[_computationId] = oraclizeID;

    newOraclizeID(oraclizeID);
  }

  function provideIndex(string _resultSolver, uint _computationId) {
    // this is for two intergers: always returns 0 and 1 for two two intergers
    Request memory _request = requestOraclize[requestId[_computationId]];

    AbstractArbiter myArbiter = AbstractArbiter(msg.sender);
    myArbiter.receiveIndex(0, 1, _request.operation, _request.computationId, true);
  }

  function registerOperation(uint _operation, string _query) {
    // operation 0: add two integers
    if (_operation == 0) {
      Query memory twoInt = Query(_query, "");
      computation[0] = twoInt;
    }
  }

  function enableArbiter(address _arbiterAddress) {
    arbiter = _arbiterAddress;
    AbstractArbiter myArbiter = AbstractArbiter(_arbiterAddress);
    myArbiter.enableService();
  }

  function disableArbiter(address _arbiterAddress) {
    delete arbiter;
    AbstractArbiter myArbiter = AbstractArbiter(_arbiterAddress);
    myArbiter.disableService();
  }

  function getResult(uint _computationId) constant returns (string) {
    return requestOraclize[requestId[_computationId]].result;
  }
}
