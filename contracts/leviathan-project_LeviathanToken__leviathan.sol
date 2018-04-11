// ------------------------------------------------------------
// leviathan.sol
//
// Core token smart contract for the Leviathan Ethereum
// platform which implements the ERC-20 token standard
// as well as functions for the Leviathan marketplace
// and consensus functions for nodes running dapps
// ------------------------------------------------------------

pragma solidity ^0.4.0;

// ------------------------------------------------------------

contract LeviathanToken {
    
    // ------------------------------------------------------------
    // Contract creation and distribution functions for testing
    // ------------------------------------------------------------
    
    address creator;
    
    function LeviathanToken( ) {
        creator = msg.sender;
    }
    
    // ------------------------------------------------------------
    
    function distributeTokens( address to, uint256 amount ) returns ( bool success ) {
        if ( msg.sender != creator ) {
            throw;
        } else {
            if ( totalSupply >= amount && amount > 0 ) {
                totalSupply -= amount;
                accounts[ to ].liquidBalance += amount;
                return true;
            } else {
                return false;
            }
        }
    }
    
    // ------------------------------------------------------------
    // Contract State
    // ------------------------------------------------------------
    
    mapping ( address => Account ) accounts;
    
    // ------------------------------------------------------------
    
    mapping ( address => mapping ( address => uint256 ) ) allowed;
    
    // ------------------------------------------------------------
    
    struct Dapp {
        string name;
        bytes32 dappHash;
        Release[ ] releases; // perhaps this should be a pointer to another Dapp? and 0x0 means latest version? include block for datestamp of release?
    }
    
    // ------------------------------------------------------------
    
    struct Release {
        uint16 version;
        bytes32 versionHash;
    }
    
    // ------------------------------------------------------------
    
    struct Account {
        bool compromised;
        uint256 liquidBalance;
        uint256 stakedBalance;
        uint256 stakeReleaseBlock;
        Resolver resolver;
        Dapp[ ] dapps; // perhaps an array of hashes that point to a global Dapp array and mapping? Maybe other contract even?
    }
    
    // ------------------------------------------------------------
    // How to locate the node, methods could be IP, DNS, TOR, 
    // whisper, etc... and location is the IP address, url, etc...
    
    struct Resolver {
        string method; // TODO for now we're assuming IP, add method func later
        string location;
    }
    
    // ------------------------------------------------------------
    // Modifiers
    // ------------------------------------------------------------
    
    modifier ifNotCompromised( ) {
        if ( accounts[ msg.sender ].compromised ) {
            throw;
        }
        _;
    }
    
    // ------------------------------------------------------------
    // Leviathan specific functions
    // ------------------------------------------------------------
    
    function updateLocation( string location ) ifNotCompromised( ) returns ( bool success ) {
        // TODO for now just checking if there exists some staked balance
        // need to determine what that balance needs to be later
        if ( accounts[ msg.sender ].stakedBalance > 0 ) {
            accounts[ msg.sender ].resolver.location = location;
            return true;
        } else {
            return false;
        }
    }
    
    // ------------------------------------------------------------
    
    function isCompromised( address owner ) constant returns ( bool compromised ) {
        if ( accounts[ owner ].compromised ) {
            return true;
        } else {
            return false;
        }
    }
    
    // ------------------------------------------------------------
    
    function getLocation( address owner ) constant returns ( string location ) {
        return accounts[ owner ].resolver.location;
    }
    
    // ------------------------------------------------------------
    
    function stake( uint256 value ) ifNotCompromised( ) returns ( bool success ) {
        if ( accounts[ msg.sender ].liquidBalance >= value && value > 0 ) {
            accounts[ msg.sender ].liquidBalance -= value;
            accounts[ msg.sender ].stakedBalance += value;
            return true;
        } else {
            return false;
        }
    }
    
    // ------------------------------------------------------------
    
    function markCompromised( ) returns ( bool success ) {
        accounts[ msg.sender ].compromised = true;
        return true;
    }
    
    // ------------------------------------------------------------
    // ERC-20 specs/functions
    // ------------------------------------------------------------
    
    uint public totalSupply = 1000000;
    
    // ------------------------------------------------------------
    
    function balanceOf( address owner ) constant returns ( uint256 balance ) {
        return accounts[ owner ].liquidBalance;
    }
    
    // ------------------------------------------------------------
    
    function transfer( address to, uint256 value ) returns ( bool success ) {
        if ( accounts[ msg.sender ].liquidBalance >= value && value > 0 ) {
            accounts[ msg.sender ].liquidBalance -= value;
            accounts[ to ].liquidBalance += value;
            Transfer( msg.sender, to, value );
            return true;
        } else {
            return false;
        }
    }
    
    // ------------------------------------------------------------
    
    function transferFrom( address from, address to, uint256 value ) returns ( bool success ); // TODO
    
    function approve( address spender, uint256 value ) returns ( bool success ); // TODO
    
    function allowance( address owner, address spender ) constant returns ( uint256 remaining ); // TODO
    
    event Transfer( address indexed from, address indexed to, uint256 value );
    
    event Approval( address indexed owner, address indexed spender, uint256 value );
    
    // ------------------------------------------------------------
    
}

// ------------------------------------------------------------
