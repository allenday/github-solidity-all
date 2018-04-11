pragma solidity ^0.4.8;


// 'interface':
//  this is expected from another contract,
//  where tokens (ERC20) are managed
contract Erc20TokensContract {

    function transferFrom(
    address _from, //
    address _to, //
    uint256 _value) //
    returns (bool success); //
}


contract TokenExchange {

    /* list of allowed tokens contract addresses*/
    mapping (address => bool) public managers;

    /* list of allowed tokens contract addresses*/
    mapping (address => bool) public allowedTokens;

    /* To put tokens on exchange tokens owner first should call
    'approveAndCall' function in the smart contract that manages tokens.
    In the Dapp it can be 'put to exchange', to return from exchange user transfer to own address.
    Following variable 'tokensOwnerBalances' represents tokens transferred by token owner to this contract
    (tokenOwnerAddress => (contractAddress => tokenQuantityFromThisContract)
    - tokens will be added by 'receiveApproval' function of the contract that manages tokens
    */
    mapping (address => mapping (address => uint)) public tokensOwnerBalances;

    /* public variables  */
    address public owner;


    /* constructor */
    function TokenExchange(){
        owner = msg.sender;
    }

    /* ------- Utilities:  */
    function weiToEther(uint _wei) internal returns (uint){
        return _wei / 1000000000000000000;
    }

    function etherToWei(uint _ether) internal returns (uint){
        return _ether * 1000000000000000000;
    }
    // universal events
    event Result(address transactionInitiatedBy, string message);


    /* Manager functions */

    function allowTokenContract(address _tokenContractAddress) returns (bool){
        if (msg.sender != owner || !managers[msg.sender]) {throw;}
        allowedTokens[_tokenContractAddress] = true;
        return true;
    }

    /* Interaction with token contract address */

    /* this should be called from contract with tokens when 'approveAndCall' called*/
    function receiveApproval(address _from, // shareholder
    uint256 _value, // number of tokens
    address _tokenContractAddress, // - contract, than manages tokens
    bytes _extraData){
        // !!! only allowed tokens can be added to this Exchange :
        if (!allowedTokens[_tokenContractAddress]) {throw;}
        // message should be from contract that manages tokens
        // if (msg.sender != _tokenContractAddress) {throw;}
        // transaction should by initiated by tokens owner only
        // if (tx.origin != _from) {throw;}
        // tokens value have to be > 0
        if (_value <= 0) {throw;}
        // if everything is O.K., add to tokenOwner balances
        ReceiveApproval(
        _from,
        _value,
        _tokenContractAddress,
        _extraData // can be problem here ------------------------------------------------------------------------ ?
        );
        tokensOwnerBalances[_from][_tokenContractAddress] = _value;
    }

    /* User functions */
    function transferTokens(// we don't make this 'private' to allow owner to freely transfer tokens
    address _erc20TokensContractAddress,
    address _to, //
    uint256 _value) private returns (bool success) {
        // check args:
        if (_value <= 0) {throw;}
        if (_value < tokensOwnerBalances[msg.sender][_erc20TokensContractAddress]) {throw;}
        // call token contract
        Erc20TokensContract erc20TokensContract = Erc20TokensContract(_erc20TokensContractAddress);
        bool result = erc20TokensContract.transferFrom(msg.sender, _to, _value);
        if (result) {
            tokensOwnerBalances[msg.sender][_erc20TokensContractAddress]
            = tokensOwnerBalances[msg.sender][_erc20TokensContractAddress] - _value;
        }
        else {throw;}
        return result;
    }

    function createSellingProposition(address _tokenContractAddress, uint _quantity, uint _pricePerToken, uint _validForMinutes) {
        // check args
        if (tokensOwnerBalances[msg.sender][_tokenContractAddress] < _quantity) {throw;}
        //
        sellingPropositionsNumber = sellingPropositionsNumber + 1;

        sellingPropositions[sellingPropositionsNumber] = SellingProposition({
        seller : msg.sender,
        tokenContractAddress : _tokenContractAddress,
        quantity : _quantity,
        pricePerToken : _pricePerToken,
        created : now, // block.timestamp (absolute unix timestamps (seconds since 1970-01-01))
        validUntil : now + (_validForMinutes * 1 minutes)
        });
    }

}
