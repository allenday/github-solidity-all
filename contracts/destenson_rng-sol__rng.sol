/* This contract is deployed at 0xaED5a41450B38FC0EA0F6F203a985653fE187d9c with the ABI:
[
    {
        "constant": true,
        "inputs": [],
        "name": "last",
        "outputs": [
            {
                "name": "",
                "type": "uint256"
            }
        ],
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "_guess",
                "type": "uint256"
            }
        ],
        "name": "Guess",
        "outputs": [
            {
                "name": "",
                "type": "bool"
            }
        ],
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [
            {
                "name": "seed",
                "type": "uint256"
            }
        ],
        "name": "RandomNumberFromSeed",
        "outputs": [
            {
                "name": "",
                "type": "uint256"
            }
        ],
        "type": "function"
    },
    {
        "constant": false,
        "inputs": [],
        "name": "RandomNumber",
        "outputs": [
            {
                "name": "",
                "type": "uint256"
            }
        ],
        "type": "function"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "random_number",
                "type": "uint256"
            }
        ],
        "name": "GeneratedNumber",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "name": "random_number",
                "type": "uint256"
            },
            {
                "indexed": false,
                "name": "guesser",
                "type": "address"
            }
        ],
        "name": "RandomNumberGuessed",
        "type": "event"
    }
]
*/

contract RNG {
    mapping (address => uint) nonces;
    uint public last;
    function RNG() { }
    function RandomNumber() returns(uint) {
        return RandomNumberFromSeed(uint(sha3(block.number))^uint(sha3(now))^uint(msg.sender)^uint(tx.origin));
    }
    function RandomNumberFromSeed(uint seed) returns(uint) {
        nonces[msg.sender]++;
        last = seed^(uint(sha3(block.blockhash(block.number),nonces[msg.sender]))*0x000b0007000500030001);
        GeneratedNumber(last);
        return last;
    }
    event GeneratedNumber(uint random_number);
    event RandomNumberGuessed(uint random_number, address guesser);
    function Guess(uint _guess) returns (bool) {
        if (RandomNumber() == _guess) {
            RandomNumberGuessed(_guess, msg.sender);
            if (!msg.sender.send(this.balance)) throw;
            return true;
        }
        return false;
    }
}
