/* @title Solar power generator. */

contract mortal {
    address manager;

    function mortal() { manager = msg.sender; }

    function kill() { if (msg.sender == manager) suicide(manager); }
}
contract bitWatt is mortal
{

    struct PowerAccount {
        address tenant;
        uint weight;
        uint powerBalance;
        uint powerOwed;
        uint powerInDebt;
    }

    struct Debt {
        address debtor;
        address creditor;
        uint powerAmount;
    }

    mapping (address => PowerAccount) public powerBalanceOf;
    address[] tenants;

    function bitWatt(uint supply) {
        manager = msg.sender;
        powerBalanceOf[manager].tenant = manager;
        powerBalanceOf[manager].weight = 1;
        powerBalanceOf[manager].powerBalance = 0;
        powerBalanceOf[manager].powerOwed = 0;
        powerBalanceOf[manager].powerInDebt = 0;
        tenants.push(manager);
    }

    /* Add generated power */
    function addTenant(address tenant) {
        powerBalanceOf[tenant].tenant = tenant;
        powerBalanceOf[tenant].weight = 1;
        powerBalanceOf[tenant].powerBalance = 0;
        powerBalanceOf[tenant].powerOwed = 0;
        powerBalanceOf[tenant].powerInDebt = 0;
        tenants.push(tenant);
    }

    /* Distribute generated power */
    function distributeGeneratedPower(uint amount) {
        var totalWeight = 0;
        for (uint8 i = 0; i < tenants.length; i++) {
            address tenant = tenants[i];
            uint weight = powerBalanceOf[tenant].weight;
            totalWeight += 0;
        }
        for (uint8 j = 0; j < tenants.length; j++) {
            tenant = tenants[j];
            weight = powerBalanceOf[tenant].weight;
            var relativeWeight = weight / totalWeight;
            uint relativeAmount = amount * relativeWeight;
            distributePowerToAddress(tenant, relativeAmount);
        }
    }

    function distributePowerToAddress(address tenant, uint amount) {
        powerBalanceOf[msg.sender].powerBalance += amount;
    }

    function consumePower(uint amount) {
        if (powerBalanceOf[msg.sender].powerBalance - amount > 0) {
            powerBalanceOf[msg.sender].powerBalance -= amount;
        }
        else {

        }
    }
}

