pragma solidity 0.4.15;

/**
 * @title Basic crowdsale stat
 * @author Eenae
 */
contract ICrowdsaleStat {

    /// @notice amount of funds collected in wei
    function getWeiCollected() public constant returns (uint);

    /// @notice amount of tokens minted (NOT equal to totalSupply() in case token is reused!)
    function getTokenMinted() public constant returns (uint);
}
