import "std.sol";

contract Copyright is named("Copyright") {

    struct copyright {
        address author;      //address on blockchain of current copyright owner
        string name;         //name of legal owner of the work (creative expression)
        address expression;  //link (address?) to iPFS file of registered work 
        uint publication;    //publication date
        uint expiration;     //date when copyright expires
        string reservations; //e.g. All rights reserved, Creative Commons License
        string contact;      //email, physical address, phone, etc.
        string trademark;    //publishers trademark
        uint edition;        //major modifications
        uint printings;      //array of printings
    }

    function createCopyright(string Name, address Expression, uint Publication, uint Expiration,string Reservations, string Contact, string Trademark, uint Edition, uint Printings) returns(bool outcome){
        //creator of copyright
        //this is confusing, do I need to store address of Author, or is the contract the Author
        //what if I want to maintain original author?

        copyright cp = copyrights[msg.sender];
        
        cp.author = msg.sender;

        //if (Name == '') {
        cp.name = Name;
        //} else {
            //need to log or display that an author's name is required.
        //    return false;
        //}
        if (Publication == 0) {
            //log that current datetime is being used as publication date
            cp.publication = block.timestamp;
        } else {
            cp.publication = Publication;
        }
        if (Expiration != 0) {
            //Note that copyrights expire at an undetermined time at publication 
            //70 years after authors death
            //120?? years for institutions
            cp.expiration = Expiration;
        }
        cp.reservations = Reservations;
        cp.contact = Contact;
        cp.trademark = Trademark;
        cp.edition = Edition;
        cp.printings = Printings;
        return true;
    }
    
    function getName() returns(string name){
        return copyrights[msg.sender].name;
    }
    function register(address addr) returns (bool success){
        return false;
    }
    function assign(address a) returns(bool success){
        return false;
    }
    function grantPermission(address a) returns(bool success){
        return false;
    }
    function revokePermission(address a) returns(bool success){
        return false;
    }
    function kill(address a) returns(address addr){
        if(msg.sender == a){
            suicide(a);
        }
    }
    function setBirthDate(address addr) returns (bool success){
        return false;
    }
    function setExpirationDate(address addr) returns (bool success){
        return false;
    }
    mapping (address => copyright) copyrights;
}
