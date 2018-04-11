pragma solidity ^0.4.15;


contract OLCommonConfigure {
    /*
    global error code on OuLianMarket
    */
    uint constant public errorCode_success = 0;

    uint constant public errorCode_feeIsNotEnough = 1;

    uint constant public errorCode_parameterError = 2;

    uint constant public errorCode_versionIsOld = 3;

    uint constant public errorCode_noPermitAccess = 4;

    uint constant public errorCode_serverIsFreezed = 5;

    uint constant public errorCode_serverNoExistent = 6;

    uint constant public errorCode_addressIsEmpty = 7;

    /*
    random contract
    */
    uint constant public errorCode_noHashSeedNeeded = 201;

    uint constant public errorCode_hashSeedProvided = 202;

    uint constant public errorCode_hashSeedCountNotEnough = 203;

    uint constant public errorCode_hashSeedNotPair = 204;

    uint constant public errorCode_seedProvided = 205;

    uint constant public errorCode_hashNotProvided = 206;

    /*
    server status on OuLianMarket
    */
    uint constant serverStatusFreezed = 0;

    uint constant serverStatusNormal = 1;

    uint constant serverStatusRemoved = 2;

    /*
    addr weather or not work in white or black list
    */
    uint constant  notinuse = 2;

    uint constant  inuse = 1;

    /*
    contrant white or black list check way
    */
    uint notCheck = 0;

    uint onlyCheckWhiteList = 1;

    uint onlyCheckNotInBlackList = 2;

    uint checkWhiteAndBlackList = 3;

    /*
    fee
    */
    uint errorCode_cannotTransMoreThanYouHave = 301;
    uint errorCode_cannotTransNegativeValue = 302;
    uint errorCode_allowedValueIsNotEnough = 303;
}