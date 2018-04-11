contract HelloSystem {

    address owner;

    // Constructor
    function HelloSystem(){
        owner = msg.sender;
    }

    function remove() {
        if (msg.sender == owner){
            selfdestruct(owner);
        }
    }

}