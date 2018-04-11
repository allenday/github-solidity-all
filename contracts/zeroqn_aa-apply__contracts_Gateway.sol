pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";


contract Gateway is Ownable {

    address public payroll;

    modifier onlyPayroll() {
        require(msg.sender == payroll);
        _;
    }

    modifier onlyPayrollOrOwner() {
        require(msg.sender == payroll || msg.sender == owner);
        _;
    }

    function setPayrollAddress(address _payroll)
        external
    {
        require(_payroll != 0x0);

        payroll = _payroll;
    }

}
