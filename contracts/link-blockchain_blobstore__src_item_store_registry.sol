pragma solidity ^0.4.21;

import "./item_store_interface.sol";


/**
 * @title ItemStoreRegistry
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Contract that every ItemStore implementation must register with.
 */
contract ItemStoreRegistry {

    /**
     * @dev Mapping of contractIds to contract addresses.
     */
    mapping (bytes8 => ItemStoreInterface) contracts;

    /**
     * @dev A ItemStore contract has been registered.
     * @param contractId Id of the contract.
     * @param contractAddress Address of the contract.
     */
    event Register(bytes8 indexed contractId, ItemStoreInterface indexed contractAddress);

    /**
     * @dev Register the calling ItemStore contract.
     * @return contractId Id of the ItemStore contract.
     */
    function register() external returns (bytes8 contractId) {
        // Create contractId.
        contractId = bytes8(msg.sender);
        // Make sure this contractId has not been used before (highly unlikely).
        require (contracts[contractId] == ItemStoreInterface(0));
        // Record the calling contract address.
        contracts[contractId] = ItemStoreInterface(msg.sender);
        // Log the registration.
        emit Register(contractId, ItemStoreInterface(msg.sender));
    }

    /**
     * @dev Lookup the itemStore contract for an item.
     * @param itemId itemId of the item to determine the itemStore contract of.
     * @return itemStore itemStore contract of the item.
     */
    function getItemStore(bytes32 itemId) external view returns (ItemStoreInterface itemStore) {
        itemStore = contracts[bytes8(itemId)];
        require (address(itemStore) != 0);
    }

}
