pragma solidity ^0.4.6;
contract Tiguan5Coin {
    address public minter;
    address constant public x = 0xef360a8b39442dc87c60aa957b07016cb396f164;
    address constant public y = 0x0028e590fc2789a2ae4da1824780390a3bc483a8;
    address constant public z = 0x4c41deb7f34a6e625458d62f3fb6553545e9ecfd;
    mapping (address => uint) public balances;
    event Sent(address from, address to, uint amount);

    function Tiguan5Coin() {
        minter = msg.sender;
        balances[msg.sender] = 21000000;
        balances[x] = 100;
        balances[y] = 200;
        balances[z] = 300;
    }

    function mint(address receiver, uint amount) {
        if (msg.sender != minter) return;
        balances[receiver] += amount;
    }

    function send(address receiver, uint amount) {
        if (balances[msg.sender] +6 < amount) return;
        balances[msg.sender] -= (amount+6);
        balances[x] += 1;
        balances[y] += 2;
        balances[z] += 3;
        balances[receiver] += amount;
        Sent(msg.sender, receiver, amount);
    }
}
