contract LocalsValidation {
    uint validationcount;
    address owner;
    mapping (address => uint) public validators;

    event ValidationAdded(address validator);

    function LocalsValidation() {
        validationcount = 0;
        owner = msg.sender;
    }
    
    function addValidation() returns (uint returnCode) {
        // reeds gevalideerd ? dan niks doen..
        if (validators[msg.sender] == 1) return 1;
        validators[msg.sender]= 1;
        validationcount++;
        
        owner.send(msg.value);
        ValidationAdded(msg.sender);
        return 0;
    }
    
    function countValidations() constant returns (uint count) {
        return validationcount;
    }
}                               