    contract LocalsMembership {
    address adam;
    uint price;
    mapping (address => uint) members;

    event MemberAdded(address inviter, address invitee);

    function LocalsMembership() {
        adam = msg.sender;
        members[msg.sender] = 1;
        price = 6 ether;
    }
    
    function setPrice(uint newPrice){
        // adam can set a new price
        if (msg.sender == adam){
            price = newPrice;
        }
    }

    function addMember(address newMember) returns (uint returnCode) {
        if (members[msg.sender] != 1) return 2;
        if (members[newMember] == 1) return 3;
        if (msg.value >= price){
            members[newMember] = 1;
            newMember.send(msg.value/2);
            msg.sender.send(msg.value/2);
            MemberAdded(msg.sender, newMember);
            return 1;
        }else{
            return 4;
        }
    }
    
    function membershipStatus(address addr) constant returns (uint membershipStatus) {
        return members[addr];
    }
}                     