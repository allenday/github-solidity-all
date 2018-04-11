pragma solidity ^0.4.0;


import "./UserAccount.sol";
import "./DateTime.sol";


contract TokenFunctions {
    //It records user "Identity" with related "address".
    mapping (bytes32 => address) private UserMappingList;

    mapping (address => bool) private isAddressUsed;

    mapping (bytes32 => address) private AddressNaming;

    bytes32[4] private ManagerPubkey;

    address private DateTimeAddress = "0xA47965a03542F82EcaB56C596D8754fF8D2114D3";

    event Log(string description);

    uint public timeLimited;//This is for SharedAccounts. When the difference between timestamp of target and current time is larger than this "timeLimited", it should be deleted from record.


    function TokenFunctions() payable {
        timeLimited = 100;
        ManagerPubkey[0] = "d6ba59b23cb2b710e69df73e77480170";
        ManagerPubkey[1] = "ce853095111a9b178c12972cceeca84d";
        ManagerPubkey[2] = "aad04b7bc289a834e417b844290cdd95";
        ManagerPubkey[3] = "42e708321db97ebf484f1091e32e7669";
    }

    function setTimeLimited(uint newTimeLimited){
        timeLimited = newTimeLimited;
        Log("Successfully set timeLimited.");
    }

    function getManagerPubkey() constant returns (bytes32 x1, bytes32 x2, bytes32 y1, bytes32 y2){
        x1 = ManagerPubkey[0];
        x2 = ManagerPubkey[1];
        y1 = ManagerPubkey[2];
        y2 = ManagerPubkey[3];
    }
    //Hint:It temporarily used Name&PubKey to generate a user.
    //In the further implementation, input parameters should be "Identity" and "Name".
    //The pair of "private key" and "public key" are generated from "Identity".
    //"Name"and"public key" are parameters to new a contract to express a user,constructor may return the related "address"..
    //"private key"&"public key"&"address" are then recorded on physical Token, and "Identity" and "address" are kept in UserMappingList for usage of checking.
    function newUserAccount(bytes32 Identity, bytes32 Name, bytes32 PubKey_x1, bytes32 PubKey_x2, bytes32 PubKey_y1, bytes32 PubKey_y2){
        address target = UserMappingList[sha256(Identity)];
        if (!isAddressUsed[target]) {
            address addr = AddressNaming[Name];
            if (!isAddressUsed[addr]) {
                UserAccount newAccount = new UserAccount(Name, PubKey_x1, PubKey_x2, PubKey_y1, PubKey_y2);
                address newAddress = newAccount;
                UserMappingList[sha256(Identity)] = newAddress;
                isAddressUsed[newAddress] = true;
                AddressNaming[Name] = newAddress;
                Log("Successfully added a UserAccount!");}
            else {
                Log("Failed! This name has been occupied. Please use another one.");
            }
        }
        else {
            Log("Failed! Identity is occupied!");}
    }

    function LoginCheck(bytes32 Identity) constant returns (bool valid, address AccountAddress){
        address target = UserMappingList[sha256(Identity)];
        if (isAddressUsed[target]) {
            valid = true;
            AccountAddress = target;}
    }

    function getAddress(bytes32 Identity) constant returns (address addr){
        addr = UserMappingList[sha256(Identity)];
    }

    //Functions to interact with attributes of UserAccount:MyName,MyPubKey
    function getMyName(bytes32 Identity) constant returns (bytes32 MyName) {
        address target = UserMappingList[sha256(Identity)];
        MyName = UserAccount(target).MyNickname();
    }

    function getMyPubKey(bytes32 Identity) constant returns (bytes32 PubKey_x1, bytes32 PubKey_x2, bytes32 PubKey_y1, bytes32 PubKey_y2) {
        address target = UserMappingList[sha256(Identity)];
        (PubKey_x1, PubKey_x2, PubKey_y1, PubKey_y2) = UserAccount(target).getPublicKey();
    }

    function setMyName(bytes32 Identity, bytes32 newName){
        address addr = AddressNaming[newName];
        if (isAddressUsed[addr]) {
            Log("Failed! This name has been occupied. Please use another one.");}
        else {
            address target = UserMappingList[sha256(Identity)];
            UserAccount targetAccount = UserAccount(target);
            bytes32 prename = targetAccount.MyNickname();
            delete AddressNaming[prename];
            targetAccount.setName(newName);
            AddressNaming[newName] = target;
            Log("Successfully modified MyName.");}
    }

    //function: get address from name. This is for mapping contact address-readable name.
    function getAddressFromName(bytes32 name) constant returns (address addr, bool found){
        addr = AddressNaming[name];
        if (isAddressUsed[addr]) {
            found = true;
        }
    }

    function checkNameOccupied(bytes32 name) constant returns (bool occupied){
        address addr = AddressNaming[name];
        if (isAddressUsed[addr]) {
            occupied = true;
        }
    }

    function setMyPubKey(bytes32 Identity, bytes32 PubKey_x1, bytes32 PubKey_x2, bytes32 PubKey_y1, bytes32 PubKey_y2){
        address target = UserMappingList[sha256(Identity)];
        UserAccount targetAccount = UserAccount(target);
        targetAccount.setPublicKey(PubKey_x1, PubKey_x2, PubKey_y1, PubKey_y2);
        Log("Successfully modified My PublicKey.");
        uint ContactLength = targetAccount.getContactsLength();
        address ContactAddresses;
        UserAccount AccountI;
        for (uint i = 0; i < ContactLength; i++) {
            ContactAddresses = targetAccount.getContactAddressByIndex(i);
            if (isAddressUsed[ContactAddresses]) {
                AccountI = UserAccount(ContactAddresses);
                AccountI.AlterContactPubkey(target, PubKey_x1, PubKey_x2, PubKey_y1, PubKey_y2);}
        }
        Log("Successfully update the value of public key in contacts' lists.");
    }

    //Functions to interact with mappinglist of SocialAccount.
    function AddSocialAccount(bytes32 Identity, bytes32 newApp, bytes32 newUsername, bytes32 newPassword){
        address target = UserMappingList[sha256(Identity)];
        UserAccount targetAccount = UserAccount(target);
        targetAccount.AddSocialAccount(newApp, newUsername, newPassword);
    }

    function AltSocialAccountPw(bytes32 Identity, bytes32 targetApp, bytes32 targetUsername, bytes32 newPassword) {
        address target = UserMappingList[sha256(Identity)];
        UserAccount targetAccount = UserAccount(target);
        targetAccount.AltSocialAccountPw(targetApp, targetUsername, newPassword);
    }

    function DelSocialAccount(bytes32 Identity, bytes32 delApp, bytes32 delUsername){
        address target = UserMappingList[sha256(Identity)];
        UserAccount targetAccount = UserAccount(target);
        targetAccount.DelSocialAccount(delApp, delUsername);
    }

    function getSocialAccountPw(bytes32 Identity, bytes32 targetApp, bytes32 targetUsername) constant returns (bytes32 Password, bool Successful){
        address target = UserMappingList[sha256(Identity)];
        UserAccount targetAccount = UserAccount(target);
        (Password, Successful) = targetAccount.getSocialAccountPw(targetApp, targetUsername);}//If it is false, it means that there is no such record to get.

    function getAllSocialAccounts(bytes32 Identity) constant returns (bytes32[] Apps, bytes32[] Usernames){
        address target = UserMappingList[sha256(Identity)];
        UserAccount targetAccount = UserAccount(target);
        uint length = targetAccount.getSocialAccountsLength();
        Apps = new bytes32[](length);
        Usernames = new bytes32[](length);
        for (uint i = 0; i < length; i++) {
            (Apps[i], Usernames[i]) = targetAccount.getSocialAccountByIndex(i);}
    }

    //Functions to interact with mappinglist of Contact.
    function AddContact(bytes32 Identity, address newCAddress){
        address target = UserMappingList[sha256(Identity)];
        if (isAddressUsed[newCAddress]) {
            if (target == newCAddress) {
                Log("Failed! You cannot add yourself as contact.");
            }
            else {
                UserAccount AccountOne = UserAccount(target);
                UserAccount AccountTwo = UserAccount(newCAddress);
                bytes32[4] memory PubKey_one;
                bytes32[4] memory PubKey_two;
                bytes32 AccountOneName = AccountOne.MyNickname();
                (PubKey_one[0], PubKey_one[1], PubKey_one[2], PubKey_one[3]) = AccountOne.getPublicKey();
                bytes32 AccountTwoName = AccountTwo.MyNickname();
                (PubKey_two[0], PubKey_two[1], PubKey_two[2], PubKey_two[3]) = AccountTwo.getPublicKey();
                AccountOne.AddContact(newCAddress, AccountTwoName, PubKey_two[0], PubKey_two[1], PubKey_two[2], PubKey_two[3]);
                AccountTwo.AddContact(target, AccountOneName, PubKey_one[0], PubKey_one[1], PubKey_one[2], PubKey_one[3]);}}
        else {
            Log("Failed! Address of contact is incorrect!");}
    }

    function AlterContactName(bytes32 Identity, address targetAddress, bytes32 altCName) {
        address target = UserMappingList[sha256(Identity)];
        UserAccount targetAccount = UserAccount(target);
        targetAccount.AlterContactName(targetAddress, altCName);
    }


    function deleteContact(bytes32 Identity, address targetAddress){
        address target = UserMappingList[sha256(Identity)];
        if (isAddressUsed[targetAddress]) {
            UserAccount AccountOne = UserAccount(target);
            UserAccount AccountTwo = UserAccount(targetAddress);
            AccountOne.deleteContact(targetAddress);
            AccountTwo.deleteContact(target);}
        else {
            Log("Failed! Address of contact is incorrect!");}
    }

    function getTargetContactPubKey(bytes32 Identity, address targetAddress) constant returns (bytes32 PubKey_x1, bytes32 PubKey_x2, bytes32 PubKey_y1, bytes32 PubKey_y2, bool isFound){
        address target = UserMappingList[sha256(Identity)];
        UserAccount targetAccount = UserAccount(target);
        (PubKey_x1, PubKey_x2, PubKey_y1, PubKey_y2, isFound) = targetAccount.getTargetContactPubKey(targetAddress);
        //If it is false, it means that there is no such record to get.
    }

    function getAllContact(bytes32 Identity) constant returns (address[] resAddress, bytes32[] resName){
        address target = UserMappingList[sha256(Identity)];
        UserAccount targetAccount = UserAccount(target);
        uint length = targetAccount.getContactsLength();
        resAddress =new address[](length);
        resName = new bytes32[](length);
        for (uint i = 0; i < length; i++) {
            (resAddress[i], resName[i]) = targetAccount.getContactByIndex(i);}
    }


    //Functions to interact with mappinglist of Shared SocialAccount.
    //Hint:this function is for sender, not receiver(user).
    function AddSharedAccount(bytes32 Identity, address receiverAddress, bytes32 targetApp, bytes32 targetUsername, bytes32 targetPassword) {
        address sender = UserMappingList[sha256(Identity)];
        if (isAddressUsed[receiverAddress]) {
            UserAccount receiverAccount = UserAccount(receiverAddress);
            receiverAccount.AddSharedAccount(targetApp, targetUsername, targetPassword, sender);
            Log("Successfully added a record for receiver as a shared account.");}
        else {
            Log("Failed! There is no such account with receiverAddress.");}

    }

    function deleteSharedAccount(bytes32 Identity, bytes32 targetApp, bytes32 targetUsername){
        address target = UserMappingList[sha256(Identity)];
        UserAccount targetAccount = UserAccount(target);
        targetAccount.deleteSharedAccount(targetApp, targetUsername, timeLimited);
    }

    function getSharedAccountPw(bytes32 Identity, bytes32 targetApp, bytes32 targetUsername) constant returns (bytes32 Password, bool isFound){
        address target = UserMappingList[sha256(Identity)];
        UserAccount targetAccount = UserAccount(target);
        (Password, isFound) = targetAccount.getSharedAccountPw(targetApp, targetUsername);
    }

    function getAllSharedAccounts(bytes32 Identity) constant returns (bytes32[] SharedApps, bytes32[] SharedUsernames, address[] SenderAddresses, uint16[] Years, uint8[5][] RestTimes){
        address target = UserMappingList[sha256(Identity)];
        UserAccount targetAccount = UserAccount(target);
        uint length = targetAccount.getSharedAccountsLength();
        SharedApps = new bytes32[](length);
        SharedUsernames = new bytes32[](length);
        SenderAddresses =new address[](length);
        uint[] memory times = new uint[](length);
        Years = new uint16[](length);
        RestTimes = new uint8[5][](length);

        for (uint i = 0; i < length; i++) {
            (SharedApps[i], SharedUsernames[i], SenderAddresses[i], times[i]) = targetAccount.getSharedAccounByIndex(i);
            (Years[i], RestTimes[i]) = DateTime(DateTimeAddress).getReadableTime(times[i]);
        }
    }}