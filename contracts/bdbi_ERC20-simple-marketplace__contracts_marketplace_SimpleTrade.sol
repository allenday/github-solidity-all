pragma solidity ^0.4.15;

import '../ownership/Ownable.sol';

/**
@title SimpleTrade
@dev Trade contract allowing a vendor to sell ERC20 Tokens in exchange of ETH.
@dev TO SELLERS: Authorize this contract to manage your tokens with the function approve(<this_contract_address>,<amount>).
@dev TO BUYERS: Always check the token address and the content of the transferFrom() function to avoid scams.
 */
contract SimpleTrade is Ownable {

    address public seller;
    address public token;

    uint256 public amount;
    uint256 public price;

    bool public lock;
    bool public recovery;

    /**
    @dev Throws if caller is not the seller.
     */
    modifier onlySeller {
        require(msg.sender == seller);
        _;
    }

    /**
    @param _seller The seller address
    @param _token The token address
    @param _amount The amount of tokens to sell
    @param _price The price in wei for all the tokens
     */
    function SimpleTrade (
        address _seller,
        address _token,
        uint256 _amount,
        uint256 _price)
    {
        seller = _seller;
        token = _token;
        amount = _amount;
        price = _price;
        lock = true;
    }

    /**
    @dev Buyer pays the price requested, unlock the payment if the transferFrom() transaction does not throw.
    @dev TransferFrom() functions should throw if something goes wrong, always check the content on the original token contract to be sure.
     */
    function () payable {
        require(!recovery);
        require(lock);
        require(msg.value == price);
        require(token.call(bytes4(sha3("transferFrom(address,address,uint256)")),seller, msg.sender, amount));
        lock = false;
    }

    /**
    @dev Seller can close the trade and destroy this contract when desired.
    @dev Ether is sent to seller address if trade was successful, to owner otherwise (balance should be 0 in this case).
     */
    function close() onlySeller {
        require(!recovery);
        address to = lock ? owner : seller;
        selfdestruct(to);
    }

    /**
    @dev Seller can set the Trade in recovery mode if tokens are sent directly to the contract by mistake.
     */
    function setRecovery() onlySeller {
        require(!recovery);
        recovery = true;
    }

    /**
    @dev Marketplace can recover the stuck tokens. Works only in recovery mode.
    @param _token The token address
    @param _recipient The recipient address
    @param _amount The amount of tokens to send
    @return A bool set true if successful, false otherwise
     */
    function tokenRecovery(address _token, address _recipient, uint256 _amount) onlyOwner returns (bool) {
        require(recovery);
        require(_token.call(bytes4(sha3("transfer(address,uint256)")),_recipient, _amount));
        recovery = false;
        return true;
    }

}