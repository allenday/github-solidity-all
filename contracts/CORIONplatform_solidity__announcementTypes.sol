/*
    announcementTypes.sol
    1.0.0
    
    Rajci 'iFA' Andor @ ifa@corion.io / ifa@ethereumlottery.net
    CORION Platform
*/
pragma solidity ^0.4.15;

contract announcementTypes {
    /*
        Type of announcements
    */
    enum announcementType {
        newModule,
        dropModule,
        replaceModule,
        replaceModuleHandler,
        question,
        transactionFeeRate,
        transactionFeeMin,
        transactionFeeMax,
        transactionFeeBurn,
        providerPublicFunds,
        providerPrivateFunds,
        providerPrivateClientLimit,
        providerPublicMinRate,
        providerPublicMaxRate,
        providerPrivateMinRate,
        providerPrivateMaxRate,
        providerGasProtect,
        providerInterestMinFunds,
        providerRentRate,
        schellingRoundBlockDelay,
        schellingCheckRounds,
        schellingCheckAboves,
        schellingRate,
        publisherMinAnnouncementDelay,
        publisherOppositeRate
    }
}
