/*
    publisher.sol
    1.0.0
    
    Rajci 'iFA' Andor @ ifa@corion.io / ifa@ethereumlottery.net
    CORION Platform
*/
pragma solidity ^0.4.15;

import "./announcementTypes.sol";
import "./module.sol";
import "./moduleHandler.sol";
import "./safeMath.sol";
import "./multiOwner.sol";

contract publisher is announcementTypes, module, safeMath, moduleMultiOwner {
    /* module callbacks */
    function transferEvent(address from, address to, uint256 value) external onlyForModuleHandler returns (bool success) {
        /*
            Transaction completed. This function is available only for moduleHandler
            If a transaction is carried out from or to an address which participated in the objection of an announcement, its objection purport is automatically set
        */
        uint256 announcementID;
		uint256 a;
		// need reverse lookup
        for ( a=0 ; a<opponents[from].length ; a++ ) {
            announcementID = opponents[from][a];
            if ( announcements[announcementID].end < block.number && announcements[announcementID].open ) {
                announcements[announcementID].oppositionWeight = safeSub(announcements[announcementID].oppositionWeight, value);
            }
        }
        for ( a=0 ; a<opponents[to].length ; a++ ) {
            announcementID = opponents[to][a];
            if ( announcements[announcementID].end < block.number && announcements[announcementID].open ) {
                announcements[announcementID].oppositionWeight = safeAdd(announcements[announcementID].oppositionWeight, value);
            }
        }
        super._transferEvent(from, to, value);
        return true;
    }
    /* Structures */
    struct announcements_s {
        announcementType Type;
        uint256 start;
        uint256 end;
        bool open;
        string announcement;
        string link;
        bool oppositable;
        uint256 oppositionWeight;
        bool result;
        
        string _str;
        uint256 _uint;
        address _addr;
    }
    /* Variables */
    uint256 public minAnnouncementDelay = 40320;
    uint8 public oppositeRate = 33;
    uint256 public announcementsLength;
    mapping(uint256 => announcements_s) public announcements;
    mapping (address => uint256[]) public opponents;
    /* Constructor */
    function publisher(address moduleHandlerAddr) moduleMultiOwner(moduleHandlerAddress) module(moduleHandlerAddr) {
        /*
            Installation function. The installer will be registered in the admin list automatically.
            
            @moduleHandlerAddr      Address of moduleHandler
        */
    }
    /* Externals */
    function newAnnouncement(announcementType Type, string Announcement, string Link, bool Oppositable,
        string _str, uint256 _uint, address _addr) external {
        /*
            New announcement. Can be called  only by those in the admin list
            
            @Type           Topic of announcement
            @Start          height of announcement block
            @End            planned completion of announcement
            @Closed         Completed or not
            @Announcement   Announcement text
            @Link           link to a Forum 
            @Opposition     opposed or not
            @_str           text box
            @_uint          number box
            @_addr          address box
        */
        require( block.number < moduleHandler(moduleHandlerAddress).debugModeUntil() );
        if ( ! super.insertAndCheckDo(super.calcDoHash("newAnnouncement", sha3(Type, Announcement, Link, Oppositable, _str, _uint, _addr))) ) {
            return;
        }
        announcementsLength++;
        announcements[announcementsLength].Type = Type;
        announcements[announcementsLength].start = block.number;
        announcements[announcementsLength].end = block.number + minAnnouncementDelay;
        announcements[announcementsLength].open = true;
        announcements[announcementsLength].announcement = Announcement;
        announcements[announcementsLength].link = Link;
        announcements[announcementsLength].oppositable = Oppositable;
        announcements[announcementsLength].oppositionWeight = 0;
        announcements[announcementsLength].result = false;
        announcements[announcementsLength]._str = _str;
        announcements[announcementsLength]._uint = _uint;
        announcements[announcementsLength]._addr = _addr;
        ENewAnnouncement(announcementsLength, Type);
    }
    function closeAnnouncement(uint256 id) onlyOwner external {
        /*
            Close announcement. It can be closed only by those in the admin list. Windup is allowed only after the announcement is completed.
            
            @id     Announcement identification
        */
        require( announcements[id].open && announcements[id].end < block.number );
        if ( ! checkOpposited(announcements[id].oppositionWeight, announcements[id].oppositable) ) {
            announcements[id].result = true;
            if ( announcements[id].Type == announcementType.newModule ) {
                require( moduleHandler(moduleHandlerAddress).newModule(announcements[id]._str, announcements[id]._addr, true, true) );
            } else if ( announcements[id].Type == announcementType.dropModule ) {
                require( moduleHandler(moduleHandlerAddress).dropModule(announcements[id]._str, true) );
            } else if ( announcements[id].Type == announcementType.replaceModule ) {
                require( moduleHandler(moduleHandlerAddress).replaceModule(announcements[id]._str, announcements[id]._addr, true) );
            } else if ( announcements[id].Type == announcementType.replaceModuleHandler) {
                require( moduleHandler(moduleHandlerAddress).replaceModuleHandler(announcements[id]._addr) );
            } else if ( announcements[id].Type == announcementType.transactionFeeRate || 
                        announcements[id].Type == announcementType.transactionFeeMin || 
                        announcements[id].Type == announcementType.transactionFeeMax || 
                        announcements[id].Type == announcementType.transactionFeeBurn ) {
                require( moduleHandler(moduleHandlerAddress).configureModule("token", announcements[id].Type, announcements[id]._uint, announcements[id]._addr) );
            } else if ( announcements[id].Type == announcementType.providerPublicFunds || 
                        announcements[id].Type == announcementType.providerPrivateFunds || 
                        announcements[id].Type == announcementType.providerPrivateClientLimit || 
                        announcements[id].Type == announcementType.providerPublicMinRate || 
                        announcements[id].Type == announcementType.providerPublicMaxRate || 
                        announcements[id].Type == announcementType.providerPrivateMinRate || 
                        announcements[id].Type == announcementType.providerPrivateMaxRate || 
                        announcements[id].Type == announcementType.providerGasProtect || 
                        announcements[id].Type == announcementType.providerInterestMinFunds || 
                        announcements[id].Type == announcementType.providerRentRate ) {
                require( moduleHandler(moduleHandlerAddress).configureModule("provider", announcements[id].Type, announcements[id]._uint, announcements[id]._addr) );
            } else if ( announcements[id].Type == announcementType.schellingRoundBlockDelay || 
                        announcements[id].Type == announcementType.schellingCheckRounds || 
                        announcements[id].Type == announcementType.schellingCheckAboves || 
                        announcements[id].Type == announcementType.schellingRate ) {
                require( moduleHandler(moduleHandlerAddress).configureModule("schelling", announcements[id].Type, announcements[id]._uint, announcements[id]._addr) );
            } else if ( announcements[id].Type == announcementType.publisherMinAnnouncementDelay) {
                minAnnouncementDelay = announcements[id]._uint;
            } else if ( announcements[id].Type == announcementType.publisherOppositeRate) {
                oppositeRate = uint8(announcements[id]._uint);
            }
        }
        announcements[id].end = block.number;
        announcements[id].open = false;
    }
    function oppositeAnnouncement(uint256 id) external {
        /*
            Opposition of announcement
            If announcement is opposable, anyone owning a token can oppose it
            Opposition is automatically with the total amount of tokens
            If the quantity of his tokens changes, the purport of his opposition changes automatically
            The prime time is the windup  of the announcement, because this is the moment when the number of tokens in opposition are counted.
            One address is entitled to be in oppositon only once. An opposition cannot be withdrawn. 
            Running announcements can be opposed only.
            
            @id     Announcement identification
        */
        uint256 emptyArrayID = 0;
        bool foundEmptyArrayID = false;
        require( announcements[id].open );
        require( announcements[id].oppositable );
        for ( uint256 a=0 ; a<opponents[msg.sender].length ; a++ ) {
            require( opponents[msg.sender][a] != id );
            if ( ! announcements[opponents[msg.sender][a]].open) {
                delete opponents[msg.sender][a];
                if ( ! foundEmptyArrayID ) {
                    foundEmptyArrayID = true;
                    emptyArrayID = a;
                }
            }
        }
        if ( ! foundEmptyArrayID ) {
            opponents[msg.sender].push(id);
        } else {
            opponents[msg.sender][emptyArrayID] = id;
        }
        var (_success, _balance) = moduleHandler(moduleHandlerAddress).balanceOf(msg.sender);
        require( _success );
        require( _balance > 0);
        announcements[id].oppositionWeight += _balance;
        EOppositeAnnouncement(id, msg.sender, _balance);
    }
    function invalidateAnnouncement(uint256 id) onlyOwner external {
        /*
            Withdraw announcement. Only those in the admin list can withdraw it.
            
            @id     Announcement identification
        */
        require( announcements[id].open );
        announcements[id].end = block.number;
        announcements[id].open = false;
        EInvalidateAnnouncement(id);
    }
    /* Constants */
    function Announcements(uint256 id) public constant returns (announcementType Type, uint256 Start, uint256 End,
        bool Closed, string Announcement, string Link, bool Opposited, string _str, uint256 _uint, address _addr) {
        /*
            Announcement data query
            
            @id             Its identification
            
            @Type           Subject of announcement
            @Start          Height of announcement block
            @End            Planned completion of announcement
            @Closed         Closed or not
            @Announcement   Announcement text
            @Link           Link  perhaps to a Forum 
            @Opposited      Objected or not
            @_str           Text value
            @_uint          Number value
            @_addr          Address value
        */
        Type = announcements[id].Type;
        Start = announcements[id].start;
        End = announcements[id].end;
        Closed = ! announcements[id].open;
        Announcement = announcements[id].announcement;
        Link = announcements[id].link;
        if ( checkOpposited(announcements[id].oppositionWeight, announcements[id].oppositable) ) {
            Opposited = true;
        }
        _str = announcements[id]._str;
        _uint = announcements[id]._uint;
        _addr = announcements[id]._addr;
    }
    function checkOpposited(uint256 weight, bool oppositable) public constant returns (bool success) {
        /*
            Veto check
            
            @weight         Purport of objections so far
            @oppositable    Opposable at all
            
            @success        Opposed or not
        */
        if ( ! oppositable ) { return false; }
        var (_success, _amount) = moduleHandler(moduleHandlerAddress).totalSupply();
        require( _success );
        return _amount * oppositeRate / 100 > weight;
    }
    /* Events */
    event ENewAnnouncement(uint256 id, announcementType typ);
    event EOppositeAnnouncement(uint256 id, address addr, uint256 value);
    event EInvalidateAnnouncement(uint256 id);
    event ECloseAnnouncement(uint256 id);
}
