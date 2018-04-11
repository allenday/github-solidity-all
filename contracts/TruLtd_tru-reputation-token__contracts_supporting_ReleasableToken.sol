/// @title ReleasableToken
/// @notice Abstract token contract to allow tokens to only be transferable after a release event.
/// This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
/// Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
/// Updated by Tru Ltd November 2017 to comply with Solidity 0.4.18 syntax and Best Practices
/// @author TokenMarket Ltd/Updated by Ian Bray, Tru Ltd
pragma solidity 0.4.18;

import "./Ownable.sol";
import "./StandardToken.sol";


contract ReleasableToken is StandardToken, Ownable {

    address public releaseAgent;

    bool public released = false;

    /// @notice Event when a Token is released
    event Released();

    /// @notice Event when a Release Agent is set for the token
    /// @param releaseAgent Address of Release Agent
    event ReleaseAgentSet(address releaseAgent);

    /// @notice Event when a Transfer Agent is set or updated for the token
    /// @param transferAgent Address of new Transfer Agent
    /// @param status Whether Transfer Agent is enabled or disabled
    event TransferAgentSet(address transferAgent, bool status);

    /** Map of agents that are allowed to transfer tokens regardless of the lock down period. 
    * These are crowdsale contracts and possible the team multisig itself. 
    */
    mapping (address => bool) public transferAgents;

    /// @notice Limit token transfer until the crowdsale is over.
    modifier canTransfer(address _sender) {
        require(released || transferAgents[_sender]);
        _;
    }

    /// @notice The function can be called only before or after the tokens have been released
    modifier inReleaseState(bool releaseState) {
        require(releaseState == released);
        _;
    }

    /// @notice The function can be called only by a whitelisted release agent.
    modifier onlyReleaseAgent() {
        require(msg.sender == releaseAgent);
        _;
    }

    /// @notice Set the contract that can call release and make the token transferable.
    /// @dev Design choice. Allow reset the release agent to fix fat finger mistakes.
    function setReleaseAgent(address addr) public onlyOwner inReleaseState(false) {
        ReleaseAgentSet(addr);
        // We don't do interface check here as we might want to a normal wallet address to act as a release agent
        releaseAgent = addr;
    }

    /// @notice Owner can allow a particular address (a crowdsale contract) to transfer tokens despite the lock up period.
    function setTransferAgent(address addr, bool state) public onlyOwner inReleaseState(false) {
        TransferAgentSet(addr, state);
        transferAgents[addr] = state;
    }
    /// @notice One way function to release the tokens to the wild.
    /// @dev Can be called only from the release agent that is the final Crowdsale contract. 
    /// It is only called if the crowdsale has been success (first milestone reached).
    function releaseTokenTransfer() public onlyReleaseAgent {
        Released();
        released = true;
    }

    /// @notice override of StandardToken transfer function to include canTransfer modifier
    /// @param _to address to send _value of tokens to
    /// @param _value Value of tokens to send to _to address
    function transfer(address _to, 
                      uint _value) public canTransfer(msg.sender) returns (bool success) {
        // Call StandardToken.transfer()
        return super.transfer(_to, _value);
    }

    /// @notice override of StandardToken transferFrom function to include canTransfer modifier
    /// @param _from address to send _value of tokens from
    /// @param _to address to send _value of tokens to
    /// @param _value Value of tokens to send to _to address
    function transferFrom(address _from, 
                          address _to, 
                          uint _value) public canTransfer(_from) returns (bool success) {
        // Call StandardToken.transferFrom()
        return super.transferFrom(_from, _to, _value);
    }
}