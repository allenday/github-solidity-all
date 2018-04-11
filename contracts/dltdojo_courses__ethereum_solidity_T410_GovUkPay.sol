pragma solidity ^0.4.14;
//
// UK Government's Payment Infrastructure Is Now Open Source
// https://www.reddit.com/r/programming/comments/6v9xu5/uk_governments_payment_infrastructure_is_now_open/
// GOV.UK Pay
// Dao
// https://github.com/alphagov/pay-publicauth/blob/master/src/test/java/uk/gov/pay/publicauth/dao/AuthTokenDaoTest.java
//
// Token
// https://github.com/alphagov/pay-publicauth/blob/master/src/test/java/uk/gov/pay/publicauth/service/TokenServiceTest.java#L79
// HMAC https://en.wikipedia.org/wiki/Hash-based_message_authentication_code
// bcrypt - Wikipedia https://en.wikipedia.org/wiki/Bcrypt
//
contract FooPayToken {
    
    Account public lastInsertedAccount;
    
    struct Account {
        bytes32 tokenHash;
        string tokenLink;
        uint accountId;
        string username;
        string description;
    }
    
    function insertAccount(bytes32 _tokenHash, string _tokenLink, uint _accountId, string _username, string _description ) {
        lastInsertedAccount = Account(_tokenHash,_tokenLink,_accountId, _username, _description);
    }
}

contract PayTest {
    FooPayToken public pt = new FooPayToken();
    function testInsert(){
        pt.insertAccount(sha3('abc'), 'link', 1, 'foouser', 'foo accunt');
    }
}