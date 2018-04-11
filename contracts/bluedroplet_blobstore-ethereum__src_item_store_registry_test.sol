pragma solidity ^0.4.21;

import "ds-test/test.sol";

import "./item_store_registry.sol";
import "./item_store_ipfs_sha256.sol";


/**
 * @title ItemStoreRegistryTest
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Testing contract for ItemStoreRegistry.
 */
contract ItemStoreRegistryTest is DSTest {

    ItemStoreRegistry itemStoreRegistry;
    ItemStoreIpfsSha256 itemStore;

    function setUp() public {
        itemStoreRegistry = new ItemStoreRegistry();
        itemStore = new ItemStoreIpfsSha256(itemStoreRegistry);
    }

    function testControlRegisterContractIdAgain() public {
        itemStoreRegistry.register();
    }

    function testFailRegisterContractIdAgain() public {
        itemStoreRegistry.register();
        itemStoreRegistry.register();
    }

    function testControlItemStoreNotRegistered() public view {
        itemStoreRegistry.getItemStore(itemStore.getContractId());
    }

    function testFailItemStoreNotRegistered() public view {
        itemStoreRegistry.getItemStore(0);
    }

    function testGetItemStore() public {
        assertEq(itemStoreRegistry.getItemStore(itemStore.getContractId()), itemStore);
    }

}
