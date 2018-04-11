contract SingleValidator {
    function validate(address addr) constant returns (bool);
}


contract SingleValidator is AccountValidator {

    address public owner = msg.sender;

    function validate(address addr) constant returns (bool) {
        return addr == owner;
    }

    function setOwner(address owner_) {
        if(msg.sender == owner)
            owner = owner_;
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
