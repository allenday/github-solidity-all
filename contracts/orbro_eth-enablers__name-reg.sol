contract Users {
    // Here we store the names. Make it public to automatically generate an
    // accessor function named 'users' that takes a fixed-length string as argument.
    mapping (bytes32 => address) public users;

    // Register the provided name with the caller address.
    // Also, we don't want them to register "" as their name.
    function register(bytes32 name) {
        if(users[name] == 0 && name != ""){
            users[name] = msg.sender;
        }
    }

    // Unregister the provided name with the caller address.
    function unregister(bytes32 name) {
        if(users[name] != 0 && name != ""){
            users[name] = 0x0;
        }
    }
}
