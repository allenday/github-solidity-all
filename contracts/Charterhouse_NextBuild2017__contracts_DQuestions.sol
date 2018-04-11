pragma solidity ^0.4.18;

contract DQuestions {
    string[] questions;
    bytes32[] answers;
    address[] winners;

    function numberOfQuestions() public view returns (uint) {
        return questions.length;
    }

    function add(string question, bytes32 answer) public {
        questions.push(question);
        answers.push(answer);
        winners.length++;
    }

    function getQuestion(uint index) public view returns (string) {
        return questions[index];
    }

    function getAnswer(uint index) public view returns (bytes32) {
        return answers[index];
    }

    function guess(uint index, string answer) public {
        if (winners[index] == 0 && keccak256(answer) == answers[index]) {
            winners[index] = msg.sender;
        }
    }

    function getWinner(uint index) public view returns (address) {
        return winners[index];
    }
}
