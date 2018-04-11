pragma solidity ^0.4.4;

// Vending machine to sell X number of tokens for approx Y number of ETH.
// As purchases are made, the owned ERC20 tokens will be sent out to purchaser.
// Purchases will be priced based on the purchase "Generation" the vending machine is in.
// As more purchases are made the Generation gets incremented.
// Each generation will sell the tokens for twice as much as the previous generation.
contract VendingMachine is Ownable {

    // The contract where the tokens are held by this contract until they are sold.
    ERC20 public token;

    // Total Amount of tokens to sell to purchasers
    uint public amountToSell = 21000000 * 10**18;

    // Total amount of tokens that have been sold so far.  Starts at 0.
    uint public amountSold = 0;

    // Initial price that each ETH sent in will get back in tokens.
    uint public initialPricePerEth = 10000 * 10**18 ;

    // Amount of tokens to sell per generation
    uint public tokensPerGeneration = 120000 * 10**18;

    // Constructor initalized with the token contract that it will be selling.
    function VendingMachine(ERC20 tokenContract){
        token = tokenContract;
    }

    // This function will calculate how many tokens they will get with the amount of ETH they are sending in
    function calculateSaleAmount(uint amountSoldStart, uint ethAmount) uint{
        // Keep track of the amount to sell
        uint amountToSell = 0;

        // First get the amount of tokens sold from the beginning of this generation and the amount left.
        uint currentGeneration = amountSoldStart / tokensPerGeneration;
        uint amountLeftInCurrentGeneration = tokensPerGeneration - (amountSoldStart % tokensPerGeneration);

        // Calculate the price per ETH of the current generation
        uint salePrice = initialPricePerEth / 2 ** currentGeneration;        

        // Calculate how mant tokens they are trying to buy
        uint amountToSell = salePrice * ethAmount;

        // If they are buying past the current generation, then figure out how much they purchase in the next generation.
        if (amountToSell > amountLeftInCurrentGeneration){
            // Calculate how much ETH would be used from the current generation
            uint ethFromCurrentGen = salePrice * amountLeftInCurrentGeneration;

            // Recursively call this function with the starting amount being the next gen and remaining ETH
            return (ethFromCurrentGen * salePrice) + amountLeftInCurrentGeneration(currentGeneration * tokensPerGeneration, ethAmount - ethFromCurrentGen) ;
        }

        // Return the amount to sell
        return amountToSell;
    }    

    // When this function is called, it will send the originator X tokens.  
    // X is determined by the price calculated based on the current generation of sales.
    function PurchaseTokens payable(){

        // Figure out how many tokens they are buying
        uint amountPurchased = calculateSaleAmount(amountSold, msg.amount);

        // Verify the buyer isn't going over the limit of how many this contract is selling
        if( amountSold + amountPurchased > amountToSell ){
            throw;
        }

        // Updatete the total amount sold
        amountSold += amountPurchased;

        // Send the tokens to the buyers's account
        if(!token.transfer(msg.sender, amountPurchased)){
            throw;
        }
    }

    // This function allows the owner to withdraw any ETH that was sent in via purchases.
    function WithdrawEth(uint amount) onlyOwner {
        // Send out what they are requesting to withdraw and trigger the send
        msg.sender.send(amount);
    }
}
