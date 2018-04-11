/// @title Blocktu.be contract.


contract blockTube {

	address owner;
	string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
	mapping(address => uint256) public balanceOf;

	/* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    function blockTube(uint256 _initialSupply, string _tokenName, uint8 _decimalUnits, string _tokenSymbol){
    	balanceOf[msg.sender] = _initialSupply;              // Give the creator all initial tokens
        totalSupply = _initialSupply;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
    }

    /* Receive a like and do something with it */
    function like(address _clipaddr, uint256 _value){
    	var clipcontract = blocktubeClip(_clipaddr);
    	clipcontract.blocktubeTransfer(msg.sender, _value);
    }

	/* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }
}

/// @title [TESTNET] Blocktu.be user contract.

/* 

    Blocktube has two tokens:
    a/ The BTToken
    b/ The ClipToken

    A blocktube clip has a limited supply of tokens (cliptoken).
    The ClipTokens are created by depositing BTToken ('like').
    
    After a certain treshold is met (end of the minting / crowdsale), 
    the next BTTokens (likes) will be distributed amongst 
    the token holders, in relation to the amount 
    of ClipTokens they hold.

*/

// we add the token contract so later, it knows what to do.
contract token { 
    function transfer(address receiver, uint amount){} 
}

contract blocktubeClip {
    
    // First, we need to declare some variables used in this contract.
    // The address of the original poster
    address public owner;

    // The percentage of shares the original poster is willing to trade
    uint public treshold;

    // The contract of the Blocktube token contract
    token public Token;
    
    // The address of the Blocktube token contract
    address public tokenaddr;

    // The total supply of clipshares
    uint public clipshares;

    // How much shares the owner has
    uint public percentageforowner;

    // The remaining supply of clipshares
    uint public remainingCliptokens;

    // Every clip has a json object, that's stored on IPFS.
    string public ipfsclipobject;
    
    // We have an array of 'funders', the early likes.
    Shareholder[] public shareholders;
    
    // The shareholder object
    struct Shareholder {
        address addr;
        uint shares;
    }

    // We have a boolean, crowdsaleClosed
    bool tresholdReached = false;

    // And of course, the array with likes / shares
    mapping(address => uint256) public balanceOf;

    // Then we define some events, where our contraclistener can listen to.
    //event tresholdReached(likesBalance);

    // And now, the function that runs when deploying this contract.
    function blocktubeClip(string _ipfsclipobject, uint _treshold, uint _clipshares, uint _percentageforowner){
        owner = msg.sender;
        treshold = _treshold;
        clipshares = _clipshares;
        remainingCliptokens = _clipshares;
        ipfsclipobject = _ipfsclipobject;
        tresholdReached = false;
        percentageforowner = _percentageforowner;
        uint shares = (_clipshares / _percentageforowner) * 100;
        shareholders[0] = Shareholder({addr: msg.sender, shares: shares});
        tokenaddr = 0x79FCA913Bb8c6Be97145aFd5A9B70300663AF1d7;
    }

    // When someone sends a like token to this contract's balance in the token contract,
    // the tokencontract will call this function
    function blocktubeTransfer(address _liker, uint _likeamount){
        // When the current amount of shareholders is lower than the treshold,
        // add the msg.sender to shareholders, and give him the amount of
        // shares left / number of shareholders.
        if(shareholders.length < treshold){
            uint shares = remainingCliptokens / shareholders.length;
            shareholders[shareholders.length++] = Shareholder({addr: msg.sender, shares: shares});
            remainingCliptokens = remainingCliptokens - shares;
        } else {
            // When we have reached the treshold, the likeamount is spread over the shareholders.
            // We invoke the token contract's function 'transfer'
            for (var i = shareholders.length - 1; i >= 0; i--) {
                Token.transfer(_liker, (_likeamount / shareholders[i].shares)); 
            }
        }
    }



}