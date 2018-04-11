pragma solidity ^0.4.13;

/**
    This contract represents a two-of-two multisig wallet with some usefull options
**/
contract Multisig {
    // Ethereum addresses of multisig owners
    address public owner1;
    address public owner2;

    // Ethereum addresses of witnesses
    address public witness1;
    address public witness2;

    // This structure represents who (from two owners) allowed some amount to spent the last time.
    // By default isFirstOwner = False so the owner2 is the person who last time allows to spend
    struct AllowancePosition {
        bool isFirstOwner;
        uint256 amount;
    }
    // Define allowance table
    mapping (address => AllowancePosition) public allowance;
    
    // Withdrawal limits approved by owners to each other
    uint256 public withdrawal1;
    uint256 public withdrawal2;

    // Active claims for the case when partners decide to end cooperation by this contract
    struct Claim {
        bool active;
        uint256 amount;
        address recipient;
        bool witnessApprove1;
        bool witnessApprove2;
    }
    Claim public ownerClaim1;
    Claim public ownerClaim2;

    // Modifiers
    modifier onlyOwners() {
        require(msg.sender == owner1 || msg.sender == owner2);
        _;
    }
    modifier onlyParticipants() {
        require(msg.sender == owner1 || msg.sender == owner2 || msg.sender == witness1 || msg.sender == witness2);
        _;
    }

    // Events
    event ChangeAllowance(address recipient, uint256 amount, address owner);
    event Transfer(address recipient, uint256 amount, address sender);
    event NewWithdrawals(uint256 firstOwnerAmount, uint256 secondOwnerAmount);
    event NewClaim(address claimCreator, uint256 amountRequested);

    // Constructor
    function Multisig(
        address _owner1,
        address _owner2,
        address _witness1,
        address _witness2) {
        // Set all addresses here
        owner1 = _owner1;
        owner2 = _owner2;
        witness1 = _witness1;
        witness2 = _witness2;
    }

    // Fallback function allows contract to recieve ether 
    function () payable {}

    // That function change allowance or
    // try to send ether to `recipient` dependding on who is the message sender
    function TransferTo(address recipient, uint256 amount) onlyOwners {
        // first check who is the message sender
        bool isFirstOwner = true;
        if (msg.sender == owner2) {
            isFirstOwner = false;
        }
        // check if we need increase allowance or transfer the ether
        if (allowance[recipient].isFirstOwner == isFirstOwner) {
            allowance[recipient].amount += amount;  // increase allowance and return
            return;
        } else {
            // transfer the allowed part of ether
            // and change allowance if amount covers its initial value 
            uint256 amountToSend = amount;
            if (amountToSend > allowance[recipient].amount) {
                amountToSend = allowance[recipient].amount;
            }
            if (amountToSend > this.balance) {
                amountToSend = this.balance;
            }
            // transfer ether
            if (amountToSend > 0) {
                allowance[recipient].amount -= amountToSend;
                recipient.transfer(amountToSend);
                Transfer(recipient, amountToSend, msg.sender);
            }
            // finilize function execution if we can't transfer the allowed value
            if (allowance[recipient].amount > 0 ) {
                return;
            }
            // increase allowance and change between the owners
            uint256 amountForAllowance = amount - amountToSend;
            if (amountForAllowance > 0) {
                allowance[recipient].amount = amountForAllowance;
                allowance[recipient].isFirstOwner = isFirstOwner;
                ChangeAllowance(recipient, amountForAllowance, msg.sender);
            }
        }     
    }

    // Try to decrease the allowance
    function DecreaseTheAllowance(address recipient, uint256 amount) onlyOwners {
        if (amount > allowance[recipient].amount) {
            allowance[recipient].amount = 0;
            ChangeAllowance(recipient, 0, msg.sender);
            return;
        }
        allowance[recipient].amount -= amount;
        ChangeAllowance(recipient, allowance[recipient].amount, msg.sender);
    }

    // Change the withdrawal amount
    function IncreaseWithdrawalAmount(uint256 amount) onlyOwners {
        if (msg.sender == owner1) {
            withdrawal2 += amount;
        } else {
            withdrawal1 += amount;
        }
        NewWithdrawals(withdrawal1, withdrawal2);
    }

    function DecreaseWithdrawalAmount(uint256 amount) onlyOwners {
        if (msg.sender == owner1) {
            if (amount > withdrawal2) {
                amount = withdrawal2;
            }
            withdrawal2 -= amount;
        } else {
            if (amount > withdrawal1) {
                amount = withdrawal1;
            }
            withdrawal1 -= amount;
        }
        NewWithdrawals(withdrawal1, withdrawal2);
    }

    // Transfer ether by withdrawal limit
    function Withdrawal(address to, uint256 amount) onlyOwners {
        require(this.balance >= amount);
        if (msg.sender == owner1) {
            require(withdrawal1 >= amount);
            withdrawal1 -= amount;
            to.transfer(amount);
        } else {
            require(withdrawal2 >= amount);
            withdrawal2 -= amount;
            to.transfer(amount);
        }
        Transfer(to, amount, msg.sender);    
    }

    // Claim proposition to end cooperation
    function createClaim(address to, uint256 amount) onlyOwners {
        if (msg.sender == owner1) {
            ownerClaim1.recipient = to;
            ownerClaim1.amount = amount;
            ownerClaim1.active = true;
            ownerClaim1.witnessApprove1 = false;
            ownerClaim1.witnessApprove2 = false;
        } else {
            ownerClaim2.recipient = to;
            ownerClaim2.amount = amount;
            ownerClaim2.active = true;
            ownerClaim2.witnessApprove1 = false;
            ownerClaim2.witnessApprove2 = false;
        }
        NewClaim(msg.sender, amount);
    }

    // Deactivate active claim
    function deactivateClaim() onlyOwners {
        if (msg.sender == owner1) {
            ownerClaim1.active = false;
            return;
        }
        ownerClaim2.active = false;
    }

    // Distribute ether according to the plan and destroy the contract processed by owners
    function JustifyClaim(address to) onlyOwners {
        if (msg.sender == owner1) {
            require(ownerClaim2.active);
            if (ownerClaim2.amount > this.balance) {
                ownerClaim2.amount = this.balance;
            }
            // Send ether
            ownerClaim2.active = false;
            ownerClaim2.recipient.transfer(ownerClaim2.amount);
            to.transfer(this.balance);
        } else {
            require(ownerClaim1.active);
            if (ownerClaim1.amount > this.balance) {
                ownerClaim1.amount = this.balance;
            }
            // Send ether
            ownerClaim1.active = false;
            ownerClaim1.recipient.transfer(ownerClaim1.amount);
            to.transfer(this.balance);
        }
        require(this.balance == 0);
        suicide(msg.sender);
    }
    
    // Any owner can justify their climes if it has 2 witness approves
    // If witness wants to approve the claim he or she need to set claimNumber  
    function JustifyClaimWithWitness(uint8 claimNumber) onlyParticipants {
        // First witness case
        if (msg.sender == witness1) {
            if (claimNumber == 1) {
                ownerClaim1.witnessApprove1 = true;
            }
            if (claimNumber == 2) {
                ownerClaim2.witnessApprove1 = true;
            }
            return;
        }
        // Second witness case
        if (msg.sender == witness2) {
            if (claimNumber == 1) {
                ownerClaim1.witnessApprove2 = true;
            }
            if (claimNumber == 2) {
                ownerClaim2.witnessApprove2 = true;
            }
            return;
        }
        // First owner wants to justify
        if (msg.sender == owner1) {
            require(ownerClaim1.active);
            require(ownerClaim2.witnessApprove1 && ownerClaim2.witnessApprove2);
            if (ownerClaim1.amount > this.balance) {
                ownerClaim1.amount = this.balance;
            }
            // Send ether
            ownerClaim1.active = false;
            ownerClaim1.recipient.transfer(ownerClaim1.amount);
            owner2.transfer(this.balance);
        }
        // Second owner wants to justify
        if (msg.sender == owner2) {
            require(ownerClaim2.active);
            require(ownerClaim2.witnessApprove1 && ownerClaim2.witnessApprove2);
            if (ownerClaim2.amount > this.balance) {
                ownerClaim2.amount = this.balance;
            }
            // Send ether
            ownerClaim2.active = false;
            ownerClaim2.recipient.transfer(ownerClaim2.amount);
            owner1.transfer(this.balance);
        }
        require(this.balance == 0);
        suicide(msg.sender);
    }

    // Mist reset function for DEBUG mode
    function resetMistCallLoad() payable {
        require(msg.value == 0);
    }
}