//一个简单代币合约例子 2016-3-1
//注：此例子不符合标准代币API要求，标准代币例子参见token.sol  https://github.com/ethereum/wiki/wiki/Standardized_Contract_APIs#token
contract Coin {
//关键字“public”使变量能从合约外部访问。
    address public minter;
    mapping (address => uint) public balances;

//事件让轻客户端能高效的对变化做出反应。
    event Sent(address from, address to, uint amount);

//这个构造函数的代码仅仅只在合约创建的时候被运行。
    function Coin() {
        minter = msg.sender;
    }
    function mint(address receiver, uint amount) {
        if (msg.sender != minter) return;
        balances[receiver] += amount;
    }
    function send(address receiver, uint amount) {
        if (balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        Sent(msg.sender, receiver, amount);
    }
    
    /**********
     Standard kill() function to recover funds 
     **********/
    function kill()
    { 
        if (msg.sender == minter)
            suicide(minter);  // kills this contract and sends remaining funds back to creator
    }
}
