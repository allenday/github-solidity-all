pragma solidity ^0.4.0;

contract PillowCoin {
    struct Employee {
        bytes32 firstName;
        bytes32 lastName;
        uint startDate;
        uint balance;
    }

    mapping ( address => Employee ) public employees;
    address[] public addresses;

    bytes32[] firstNames;
    bytes32[] lastNames;
    uint[] startDates;
    uint[] balances;

    function PillowCoin() {
        Employee memory pillowEmployee;
        pillowEmployee.firstName = "Pillow";
        pillowEmployee.lastName = "Bank";
        pillowEmployee.startDate = 1;
        pillowEmployee.balance = 1000;

        employees[msg.sender] = pillowEmployee;
        addresses.push(msg.sender);
    }

    function getEmployees() constant returns( bytes32[], bytes32[], uint[], uint[]) {

        for (uint i = 0; i < addresses.length; i++) {
            Employee storage employee = employees[addresses[i]];

            firstNames.push(employee.firstName);
            lastNames.push(employee.lastName);
            startDates.push(employee.startDate);
            balances.push(employee.balance);
        }

        return (firstNames, lastNames, startDates, balances);
    }

    function addEmployee( address wallet, bytes32 firstName, bytes32 lastName, uint startDate, uint balance ) returns ( bool success ) {
        Employee memory pillowEmployee;

        pillowEmployee.firstName = firstName;
        pillowEmployee.lastName = lastName;
        pillowEmployee.startDate = startDate;
        pillowEmployee.balance = balance;

        employees[wallet] = pillowEmployee;
        addresses.push(wallet);

        return true;
    }

    function sendCoin(address receiver, uint amount) returns(bool sufficient) {
        Employee memory pillowEmployee;
        pillowEmployee = employees[msg.sender];

        if ( pillowEmployee.balance < amount) {
            return false;
        }
        pillowEmployee.balance -= amount;
        employees[receiver].balance += amount + 10;

        return true;
    }
}
