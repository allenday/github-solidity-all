contract Factory {

    event created(address addr);
    event found(address addr);

    address[] private parties;
    
    mapping(address => address) private walletAccess;

    function getParties() constant returns (address[]){
        return parties;
    }

    function createParty() returns (address addr){
        var party = new Party();
        parties.push(party);
        created(party);
        return party;
    }

    function createPasswordChallenge(bytes20 response, bytes32 salt) returns (address addr){
        var challenge = new PasswordChallenge(response, salt);
        created(challenge);
        return challenge;
    }
    
    function findAccess(address wallet) returns(address addr){
        var access = walletAccess[wallet];
        if(access == 0){
            access = new Access();
            walletAccess[wallet] = address(access);
            created(address(access));
        }
        found(address(access));
        return access;
    }
}