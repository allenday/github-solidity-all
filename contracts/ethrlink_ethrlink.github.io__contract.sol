pragma solidity ^0.4.11;

contract ETHRLINK {

     struct Url {
        string url;
        uint endDate;
        bool exists;
    }

    uint public constant weiPrice = 1000000000000000;
    uint public constant timeUnit = 30 days;

    address contractOwner;
    address withdrawWallet;
    mapping(string => Url) urls;

    function ETHRLINK(address _contractOwner, address _withdrawWallet) public {
        require(_contractOwner != address(0));
        require(_withdrawWallet != address(0));

        contractOwner = _contractOwner;
        withdrawWallet = _withdrawWallet;
    }

    function get(string key) public constant returns(string url) {
        if(urls[key].exists && now <= urls[key].endDate){
            return urls[key].url;
        }
        return "";
    }


    function set(string key, string value, uint period) public payable returns(bool success) {
        require(bytes(get(key)).length == 0);

        uint len = bytes(key).length;
        if(len > 5){
            len = 5;
        }

        uint cost = weiPrice * (2 ** (5 - len)) * period;

        require(cost > 0);
        require(msg.value >= cost);

        urls[key] = Url(value, now + (period * timeUnit), true);
        return true;
    }

    //allow deletion of keys that point to malicious sites
    function deactivateKey(string key) public {
        require(msg.sender == contractOwner);
        urls[key].exists = false;
    }

    function withdraw() public {
        require(msg.sender == contractOwner);
        withdrawWallet.transfer(this.balance);
    }

}
