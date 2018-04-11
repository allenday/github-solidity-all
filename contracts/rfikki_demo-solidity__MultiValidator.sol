contract MultiValidator is AccountValidator {

    mapping(address => bool) public owners;

    function MultiValidator() {
        owners[msg.sender] = true;
    }

    function validate(address addr) constant returns (bool) {
        return owners[addr];
    }

    function addOwner(address addr) {
        if(owners[msg.sender])
            owners[addr] = true;
    }
}

contract DataExternalValidation {

    uint public data;

    AccountValidator _validator;

    function DataExternalValidation(address validator) {
        _validator = AccountValidator(validator);
    }

    function addData(uint data_) {
        if(_validator.validate(msg.sender))
            data = data_;
    }

    function setValidator(address validator) {
        if(_validator.validate(msg.sender))
            _validator = AccountValidator(validator);
    }
}
