pragma solidity ^0.4.0;


//An instantiation of UserAccount which stands for a user.
contract UserAccount {
    bytes32 public MyNickname;

    bytes32[4] private MyPubKey;

    bytes32 private identity_hash;

    SocialAccount[] private SocialAccounts;//This is a dynamic arraylist of struct SocialAccount.
    mapping (bytes32 => mapping (bytes32 => Index)) private SocialAccountIndex;

    Contact[] private Contacts;//This is a dynamic arraylist of struct Contact.
    mapping (address => Index) private ContactIndex;

    SharedAccount[] private SharedAccounts;//This is a dynamic arraylist of struct SharedAccount.
    mapping (bytes32 => mapping (bytes32 => Index)) private SharedAccountIndex;

    event Log(string description);

    struct Index {
    uint index;
    bool initialized;
    }

    struct Contact {
    address ConAddress;
    bytes32 ConName;
    bytes32[4] ConPubKey;
    }

    struct SocialAccount {
    bytes32 App;
    bytes32 Username;
    bytes32 Password;
    }

    struct SharedAccount {
    bytes32 SharedApp;
    bytes32 SharedUsername;
    bytes32 SharedPassword;
    address SenderAddress;
    uint time;//time is for time limitation
    }


    //constructor
    function UserAccount(bytes32 Name, bytes32 PubKey_x1, bytes32 PubKey_x2, bytes32 PubKey_y1, bytes32 PubKey_y2) payable {
        MyNickname = Name;
        MyPubKey[0] = PubKey_x1;
        MyPubKey[1] = PubKey_x2;
        MyPubKey[2] = PubKey_y1;
        MyPubKey[3] = PubKey_y2;
    }

    function setName(bytes32 newName) payable {
        MyNickname = newName;
    }

    function setPublicKey(bytes32 PubKey_x1, bytes32 PubKey_x2, bytes32 PubKey_y1, bytes32 PubKey_y2) payable {
        MyPubKey[0] = PubKey_x1;
        MyPubKey[1] = PubKey_x2;
        MyPubKey[2] = PubKey_y1;
        MyPubKey[3] = PubKey_y2;
    }

    function getPublicKey() constant returns (bytes32 x1, bytes32 x2, bytes32 y1, bytes32 y2){
        x1 = MyPubKey[0];
        x2 = MyPubKey[1];
        y1 = MyPubKey[2];
        y2 = MyPubKey[3];
    }

    function getBalance() constant returns (uint256 balance){
        balance = this.balance;
    }

    //Functions about SocialAccount.
    function AddSocialAccount(bytes32 newApp, bytes32 newUsername, bytes32 newPassword) payable {
        if (!SocialAccountIndex[newApp][newUsername].initialized) {
            SocialAccounts.push(SocialAccount(newApp, newUsername, newPassword));
            SocialAccountIndex[newApp][newUsername].index = SocialAccounts.length - 1;
            SocialAccountIndex[newApp][newUsername].initialized = true;
            Log("Successfully added a record of social account.");}
        else {
            Log("Failed! There existing such record.");}
    }

    function AltSocialAccountPw(bytes32 targetApp, bytes32 targetUsername, bytes32 newPassword) payable {
        if (!SocialAccountIndex[targetApp][targetUsername].initialized) {
            Log("Failed! There is no such record.");}
        else {
            SocialAccounts[SocialAccountIndex[targetApp][targetUsername].index].Password = newPassword;
            Log("Successfully modified the password.");}
    }

    function DelSocialAccount(bytes32 delApp, bytes32 delUsername) payable {
        if (SocialAccountIndex[delApp][delUsername].initialized) {
            uint targetIndex = SocialAccountIndex[delApp][delUsername].index;
            delete SocialAccounts[targetIndex];
            delete SocialAccountIndex[delApp][delUsername];
            SocialAccounts[targetIndex] = SocialAccounts[SocialAccounts.length - 1];
            bytes32 lastApp = SocialAccounts[SocialAccounts.length - 1].App;
            bytes32 lastUsername = SocialAccounts[SocialAccounts.length - 1].Username;
            SocialAccountIndex[lastApp][lastUsername].index = targetIndex;
            delete SocialAccounts[SocialAccounts.length - 1];
            SocialAccounts.length--;
            Log("Successfully deleted that account.");}
        else {
            Log("Failed! There is no such record.");}
    }

    function getSocialAccountPw(bytes32 targetApp, bytes32 targetUsername) constant returns (bytes32 Password, bool isFound){
        if (SocialAccountIndex[targetApp][targetUsername].initialized) {//There existing a record.
            Password = SocialAccounts[SocialAccountIndex[targetApp][targetUsername].index].Password;
            isFound = true;}
        else {//There is no such record.
            isFound = false;}
    }

    function getSocialAccountByIndex(uint index) constant returns (bytes32 App, bytes32 Username){
        App = SocialAccounts[index].App;
        Username = SocialAccounts[index].Username;
    }

    function getSocialAccountsLength() constant returns (uint length){
        length = SocialAccounts.length;
    }



    //Functions about Contacts.
    function AddContact(address newCAddress, bytes32 newCName, bytes32 PubKey_x1, bytes32 PubKey_x2, bytes32 PubKey_y1, bytes32 PubKey_y2) payable {
        if (!ContactIndex[newCAddress].initialized) {
            bytes32[4] memory newCPubkey;
            newCPubkey[0] = PubKey_x1;
            newCPubkey[1] = PubKey_x2;
            newCPubkey[2] = PubKey_y1;
            newCPubkey[3] = PubKey_y2;
            Contacts.push(Contact(newCAddress, newCName, newCPubkey));
            ContactIndex[newCAddress].index = Contacts.length - 1;
            ContactIndex[newCAddress].initialized = true;
            Log("Successfully added the contact.");}
        else {
            Log("Failed! There existing such contact!");}
    }

    function AlterContactName(address targetAddress, bytes32 altCName) payable {
        if (!ContactIndex[targetAddress].initialized) {
            Log("Failed! There is no such record.");}
        else {
            Contacts[ContactIndex[targetAddress].index].ConName = altCName;
            Log("Successfully modified the contact name.");}
    }

    function AlterContactPubkey(address targetAddress, bytes32 PubKey_x1, bytes32 PubKey_x2, bytes32 PubKey_y1, bytes32 PubKey_y2) payable {
        if (!ContactIndex[targetAddress].initialized) {
            Log("Failed! There is no such record.");}
        else {
            Contacts[ContactIndex[targetAddress].index].ConPubKey = [PubKey_x1, PubKey_x2, PubKey_y1, PubKey_y2];
            Log("Successfully modified the contact public key.");}
    }

    function deleteContact(address targetAddress) payable {
        if (!ContactIndex[targetAddress].initialized) {
            Log("Failed! There is no such contact to delete!");}
        else {
            uint targetIndex = ContactIndex[targetAddress].index;
            delete Contacts[targetIndex];
            delete ContactIndex[targetAddress];
            Contacts[targetIndex] = Contacts[Contacts.length - 1];
            address lastAddress = Contacts[Contacts.length - 1].ConAddress;
            ContactIndex[lastAddress].index = targetIndex;
            delete Contacts[Contacts.length - 1];
            Contacts.length--;
            Log("Successfully deleted the contact.");}
    }

    function getTargetContactPubKey(address targetAddress) constant returns (bytes32 PubKey_x1, bytes32 PubKey_x2, bytes32 PubKey_y1, bytes32 PubKey_y2, bool isFound){
        if (!ContactIndex[targetAddress].initialized) {//There is no existing record.
            isFound = false;}
        else {//There existing target record.
            uint targetIndex = ContactIndex[targetAddress].index;
            bytes32[4] resPubKey = Contacts[targetIndex].ConPubKey;
            PubKey_x1 = resPubKey[0];
            PubKey_x2 = resPubKey[1];
            PubKey_y1 = resPubKey[2];
            PubKey_y2 = resPubKey[3];
            isFound = true;}
    }

    function getContactByIndex(uint index) constant returns (address resAddress, bytes32 resName){
        resAddress = Contacts[index].ConAddress;
        resName = Contacts[index].ConName;
    }

    function getContactAddressByIndex(uint index) constant returns (address resAddress){
        resAddress = Contacts[index].ConAddress;
    }

    function getContactsLength() constant returns (uint length){
        length = Contacts.length;
    }



    //Functions about SharedAccounts.

    function AddSharedAccount(bytes32 newApp, bytes32 newUsername, bytes32 newPassword, address SenderAddress) payable {
        if (SharedAccountIndex[newApp][newUsername].initialized) {//There existing a record. This function will update password as well as time.
            if (!(newPassword == SharedAccounts[SharedAccountIndex[newApp][newUsername].index].SharedPassword)) {
                SharedAccounts[SharedAccountIndex[newApp][newUsername].index].SharedPassword = newPassword;}
            SharedAccounts[SharedAccountIndex[newApp][newUsername].index].time = now;
        }
        else {
            SharedAccounts.push(SharedAccount(newApp, newUsername, newPassword, SenderAddress, now));
            SharedAccountIndex[newApp][newUsername].initialized = true;
            SharedAccountIndex[newApp][newUsername].index = SharedAccounts.length - 1;
        }
    }


    function deleteSharedAccount(bytes32 delApp, bytes32 delUsername, uint timeLimited) payable {
        if (SharedAccountIndex[delApp][delUsername].initialized) {
            uint targetIndex = SharedAccountIndex[delApp][delUsername].index;
            uint targetTime = SharedAccounts[targetIndex].time;
            uint currentTime = now;
            if ((currentTime - targetTime) >= timeLimited) {
                delete SharedAccounts[targetIndex];
                delete SharedAccountIndex[delApp][delUsername];
                SharedAccounts[targetIndex] = SharedAccounts[SharedAccounts.length - 1];
                bytes32 lastApp = SharedAccounts[SharedAccounts.length - 1].SharedApp;
                bytes32 lastUsername = SharedAccounts[SharedAccounts.length - 1].SharedUsername;
                SharedAccountIndex[lastApp][lastUsername].index = targetIndex;
                delete SharedAccounts[SharedAccounts.length - 1];
                SharedAccounts.length--;
                Log("The target shared account is invalid since it is overdue.");}
            else {
                Log("The target shared account is valid, thus it can be used.");}
        }
        else {
            Log("Failed! There is no such record.");}
    }


    function getSharedAccountPw(bytes32 targetApp, bytes32 targetUsername) constant returns (bytes32 Password, bool isFound){
        if (SharedAccountIndex[targetApp][targetUsername].initialized) {//There existing a record.
            Password = SharedAccounts[SharedAccountIndex[targetApp][targetUsername].index].SharedPassword;
            isFound = true;}
        else {//There is no such record.
            isFound = false;}
    }

    function getSharedAccounByIndex(uint index) constant returns (bytes32 SharedApp, bytes32 SharedUsername, address SenderAddress, uint time){
        SharedApp = SharedAccounts[index].SharedApp;
        SharedUsername = SharedAccounts[index].SharedUsername;
        SenderAddress = SharedAccounts[index].SenderAddress;
        time = SharedAccounts[index].time;
    }

    function getSharedAccountsLength() constant returns (uint length){
        length = SharedAccounts.length;
    }

}