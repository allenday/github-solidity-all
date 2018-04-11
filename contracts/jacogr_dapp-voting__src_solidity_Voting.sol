//! MIT License, Copyright 2016, Jaco Greeff <jacogr@gmail.com>
//! A simple voting with account balances contract. Ask a question, keep track
//! of the yes/no answers and the strength (associated balances) of such votes

pragma solidity ^0.4.1;

// standard Owner interface
contract Owned {
  // emitted when a new owner is set
  event NewOwner(address indexed old, address indexed current);

  // only the owner is allowed to modify
  modifier only_owner {
    if (msg.sender != owner) throw;
    _;
  }

  // set the owner to the contract creator
  address public owner = msg.sender;

  // set a new owner
  function setOwner(address _newOwner) only_owner {
    NewOwner(owner, _newOwner);
    owner = _newOwner;
  }
}

// the voting contract
contract Voting is Owned {
  // emitted when a new question was asked
  event NewQuestion(address indexed owner, uint indexed index, string question);

  // emitted when a new answer is provided
  event NewAnswer(uint indexed index, uint indexed answer, uint value);

  // define a question with totals & voters
  struct Question {
    bool closed;
    address owner;
    string question;
    mapping (uint => uint) balances;
    mapping (uint => uint) votes;
    mapping (address => bool) voters;
  }

  // the list of questions
  Question[] questions;

  // total voting tallies
  uint public totalBalance = 0;
  uint public totalVotes = 0;

  // the applicable question & answer fees
  uint public answerFee = 0;
  uint public questionFee = 5 finney;

  // has the fee been paid to answer
  modifier is_answer_paid {
    if (msg.sender != owner && msg.value < answerFee) throw;
    _;
  }

  // has the fee been paid to ask a question
  modifier is_question_paid {
    if (msg.sender != owner && msg.value < questionFee) throw;
    _;
  }

  // is the sender either the question or contract owner
  modifier is_either_owner (uint _index) {
    if (questions[_index].owner != msg.sender && owner != msg.sender) throw;
    _;
  }

  // is the question in an open state
  modifier is_open (uint _index) {
    if (questions[_index].closed == true) throw;
    _;
  }

  // does the answer value conform to the tri-state
  modifier is_valid_answer (uint _answer) {
    if (_answer > 2) throw;
    _;
  }

  // is there an actual question at this index
  modifier is_valid_question (uint _index) {
    if (_index >= questions.length) throw;
    _;
  }

  // is the question of acceptable length
  modifier has_question_length (string _question) {
    if (bytes(_question).length < 4 || bytes(_question).length > 160) throw;
    _;
  }

  // has the sender not answered already
  modifier has_not_answered (uint _index) {
    if (questions[_index].voters[msg.sender] == true) throw;
    _;
  }

  // contract setup
  function Voting () {
    newQuestion('Hungry?');
  }

  // the number of questions asked
  function count () constant returns (uint) {
    return questions.length;
  }

  // details for a specific question
  function get (uint _index) constant returns (bool closed, address owner, string question, uint balanceNo, uint balanceYes, uint balanceMaybe, uint votesNo, uint votesYes, uint votesMaybe) {
    Question q = questions[_index];

    closed = q.closed;
    owner = q.owner;
    question = q.question;

    balanceNo = q.balances[0];
    balanceYes = q.balances[1];
    balanceMaybe = q.balances[2];

    votesNo = q.votes[0];
    votesYes = q.votes[1];
    votesMaybe = q.votes[2];
  }

  // tests if the sender has voted
  function hasSenderVoted (uint _index) constant returns (bool) {
    return questions[_index].voters[msg.sender];
  }

  // close the question for further answers
  function closeQuestion (uint _index) is_either_owner(_index) returns (bool) {
    questions[_index].closed = true;

    return true;
  }

  // ask a new question
  function newQuestion (string _question) payable is_question_paid has_question_length(_question) returns (bool) {
    uint index = questions.length;

    questions.length += 1;
    questions[index].owner = msg.sender;
    questions[index].question = _question;

    NewQuestion(msg.sender, index, _question);

    return true;
  }

  // answer a question
  function newAnswer (uint _index, uint _answer) payable is_answer_paid is_valid_question(_index) is_open(_index) has_not_answered(_index) is_valid_answer(_answer) returns (bool) {
    totalVotes += 1;
    totalBalance += msg.sender.balance;

    questions[_index].voters[msg.sender] = true;
    questions[_index].balances[_answer] += msg.sender.balance;
    questions[_index].votes[_answer] += 1;

    NewAnswer(_index, _answer, msg.sender.balance);

    return true;
  }

  // adjust the fee for providing answers
  function setAnswerFee (uint _fee) only_owner returns (bool) {
    answerFee = _fee;

    return true;
  }

  // adjust the fee for asking questions
  function setQuestionFee (uint _fee) only_owner returns (bool) {
    questionFee = _fee;

    return true;
  }

  // drain all accumulated funds
  function drain() only_owner returns (bool) {
    if (!msg.sender.send(this.balance)) {
      throw;
    }

    return true;
  }
}
