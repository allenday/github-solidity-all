// test new contract / import here (1, 0)


contract TestContract {
    // test types here (5, 4)
    
    
    address owner;
    uint amount;
    
    enum SomeEnum {
        One,
        Two
    }
    
    event SomeEvent(address indexed addr);
    
    mapping (address => bool) someMapping;
    
    modifier onlyowner() {
        if (msg.sender == owner) {
            _
        }
    }
    
    struct SomeStruct {
        address addr;
        SomeEnum someEnum;
    }
    SomeStruct myStruct;
    
    function TestContract(address _owner, uint _amount) {
        // test variable / parameter autocompletion here (33, 8)
        
        
        // test calls to anotherFunction / SomeEvent here (36, 8)
        
        
        // test autocompletions of struct properties / enum properties here (39, 8)
        
    }
    
    function anotherFunction() {
        
    }
    
    // test enum / event / function / modifier snippets here (47, 4)
    
}

contract SomeContract {
    function someFunction() {
        // test autocompletions of contracts here (53, 8)
        
    }
}
