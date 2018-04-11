
contract Simple {
    int counter;
    
    function getCounter() returns(int) {
        return counter;
    }
    
    function setCounter(int value) {
        counter = value;
    }
}

