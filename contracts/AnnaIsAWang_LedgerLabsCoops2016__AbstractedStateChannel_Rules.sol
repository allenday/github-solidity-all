import "Adjudicator.sol";
import "LockedState.sol";

/**
 * Rules
 *
 * The rules of the state channel. Will be further implemented by any inheriting contracts.
 */
contract Rules {

    // Event triggered when a new state channel is created (this contract is initialised)
    event StateChannelCreated(address Adjudicator, address LockedState);

    Adjudicator adjudicator;

    // Creates a new Rules
    function Rules() {
        StateChannelCreated(adjudicator, adjudicator.getLockedStateAddress());
    }

    // Gets the address of the Adjudicator
    function getAdjudicatorAddress() constant external returns (address) {
        return adjudicator;
    }

    // An abstract method which create and return an Adjudicator. The Adjudicator will be owned by this contract.
    function createAdjudicator() internal returns (Adjudicator);

    // you may define the rules and exposure conditions of the state channel
    // in a subcontract that inherits from this contract
}
