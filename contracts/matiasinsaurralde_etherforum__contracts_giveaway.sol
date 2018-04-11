contract GiveawayContract {

    mapping ( uint => address ) public addresses;
    uint public addressCount;

    function registerAddress() returns ( uint addressID ) {
      addressID = addressCount++;
      addresses[ addressID ] = msg.sender;
    }

    function registerForeignAddress( address foreignAddress ) returns { uint addressID ) {
      addressID = addressCount++;
      addresses[ addressID ] = foreignAddress;
    }

}
