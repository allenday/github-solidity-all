pragma solidity ^0.4.18;

// Minimal token interface
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Interacting is ERC20Basic {
    uint256 public conversionRate;
    Interacting public interactWith;

    function convert(uint256 amount) internal returns (uint256);

    function burn(uint256 amount) public {
        // Implement business logic / validation etc.
        totalSupply = totalSupply - amount;
        interactWith.mint(convert(amount));
    }

    function mint(uint256 amount) external {
        // Implement business logic / validation etc.
        totalSupply = totalSupply + amount;
    }
}

contract InteractingTokenA is Interacting {
    function InteractingTokenA(uint256 supply, uint256 rate) public {
        totalSupply = supply;
        conversionRate = rate;
    }

    // A little bit clumsy, but I'm not sure of a better solution for linking the two contract instances
    function setInteractingWith(Interacting contractAddy) public {
        interactWith = Interacting(contractAddy);
    }

    function convert(uint256 amount) internal returns (uint256) {
        // Obviously checks have been made and necessary rounding would be done here
        return amount / conversionRate;
    }
}

contract InteractingTokenB is Interacting {
    function InteractingTokenB(Interacting contractAddy, uint256 rate) public {
        totalSupply = 0;
        conversionRate = rate;
        interactWith = Interacting(contractAddy);
    }

    function convert(uint256 amount) internal returns (uint256) {
        // Obviously checks have been made and necessary rounding would be done here
        return amount * conversionRate;
    }
}