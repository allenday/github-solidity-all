pragma solidity ^0.4.21;

import "ds-test/test.sol";

import "./item_store_registry.sol";
import "./item_store_ipfs_sha256.sol";
import "./item_store_ipfs_sha256_proxy.sol";


/**
 * @title ItemStoreIpfsSha256Test
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Testing contract for ItemStoreIpfsSha256.
 */
contract ItemStoreIpfsSha256Test is DSTest {

    byte constant UPDATABLE = 0x01;           // True if the item is updatable. After creation can only be disabled.
    byte constant ENFORCE_REVISIONS = 0x02;   // True if the item is enforcing revisions. After creation can only be enabled.
    byte constant RETRACTABLE = 0x04;         // True if the item can be retracted. After creation can only be disabled.
    byte constant TRANSFERABLE = 0x08;        // True if the item can be transfered to another user or disowned. After creation can only be disabled.
    byte constant DISOWN = 0x10;              // True if the item should not have an owner at creation.

    ItemStoreRegistry itemStoreRegistry;
    ItemStoreIpfsSha256 itemStore;
    ItemStoreIpfsSha256Proxy itemStoreProxy;

    function setUp() public {
        itemStoreRegistry = new ItemStoreRegistry();
        itemStore = new ItemStoreIpfsSha256(itemStoreRegistry);
        itemStoreProxy = new ItemStoreIpfsSha256Proxy(itemStore);
    }

    function testControlCreateSameItemId() public {
        itemStore.create(0x1234, 0x1234);
        itemStore.getNewItemId(0x2345);
    }

    function testFailCreateSameItemId() public {
        itemStore.create(0x1234, 0x1234);
        itemStore.getNewItemId(0x1234);
    }

    function testGetNewItemId() public {
        assertEq(itemStore.getNewItemId(0x1234) & bytes32(uint64(-1)) << 192, itemStore.getContractId());
        assertEq(itemStore.getNewItemId(0x1234), itemStore.getNewItemId(0x1234));
        assertTrue(itemStore.getNewItemId(0x1234) != itemStore.getNewItemId(0x2345));
        assertTrue(itemStore.getNewItemId(0x1234) != itemStoreProxy.getNewItemId(0x1234));
    }

    function testCreate() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), 0x1234);
        assertTrue(itemStore.getInUse(itemId0));
        assertEq(itemStore.getFlags(itemId0), 0);
        assertEq(itemStore.getOwner(itemId0), this);
        assertEq(itemStore.getChildCount(itemId0), 0);
        assertTrue(!itemStore.getUpdatable(itemId0));
        assertTrue(!itemStore.getEnforceRevisions(itemId0));
        assertTrue(!itemStore.getRetractable(itemId0));
        assertTrue(!itemStore.getTransferable(itemId0));
        assertEq(itemStore.getRevisionIpfsHash(itemId0, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId0, 0), block.timestamp);
        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getRevisionCount(itemId0), 1);

        bytes32 itemId1 = itemStore.create(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN | bytes32(0x01), 0x1234);
        assertTrue(itemStore.getInUse(itemId1));
        assertEq(itemStore.getFlags(itemId1), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN);
        assertEq(itemStore.getOwner(itemId1), 0);
        assertEq(itemStore.getRevisionCount(itemId1), 1);
        assertTrue(itemStore.getUpdatable(itemId1));
        assertTrue(itemStore.getEnforceRevisions(itemId1));
        assertTrue(itemStore.getRetractable(itemId1));
        assertTrue(itemStore.getTransferable(itemId1));
        assertEq(itemStore.getRevisionIpfsHash(itemId1, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId1, 0), block.timestamp);
        assertEq(itemStore.getParentCount(itemId1), 0);
        assertEq(itemStore.getRevisionCount(itemId1), 1);

        bytes32 itemId2 = itemStore.create(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN | bytes32(0x02), 0x2345);
        assertTrue(itemStore.getInUse(itemId2));
        assertEq(itemStore.getFlags(itemId2), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN);
        assertEq(itemStore.getOwner(itemId2), 0);
        assertEq(itemStore.getChildCount(itemId2), 0);
        assertEq(itemStore.getRevisionCount(itemId2), 1);
        assertTrue(itemStore.getUpdatable(itemId2));
        assertTrue(itemStore.getEnforceRevisions(itemId2));
        assertTrue(itemStore.getRetractable(itemId2));
        assertTrue(itemStore.getTransferable(itemId2));
        assertEq(itemStore.getRevisionIpfsHash(itemId2, 0), 0x2345);
        assertEq(itemStore.getRevisionTimestamp(itemId2, 0), block.timestamp);
        assertEq(itemStore.getParentCount(itemId2), 0);
        assertEq(itemStore.getRevisionCount(itemId2), 1);

        assertTrue(itemId0 != itemId1);
        assertTrue(itemId0 != itemId2);
        assertTrue(itemId1 != itemId2);
    }

    function testControlCreateWithParentSameItemId() public {
        itemStore.create(bytes2(0x0000), 0x1234);
        bytes32 parent = itemStore.create(bytes2(0x0001), 0x1234);
        itemStore.createWithParent(bytes2(0x0002), 0x1234, parent);
    }

    function testFailCreateWithParentSameItemId() public {
        itemStore.create(bytes2(0x0000), 0x1234);
        bytes32 parent = itemStore.create(bytes2(0x0001), 0x1234);
        itemStore.createWithParent(bytes2(0x0000), 0x1234, parent);
    }

    function testControlCreateWithParentParentSameItemId() public {
        bytes32 parent = itemStore.create(bytes2(0x0000), 0x1234);
        itemStore.createWithParent(bytes2(0x0001), 0x1234, parent);
    }

    function testFailCreateWithParentParentSameItemId() public {
        itemStore.createWithParent(bytes2(0x0001), 0x1234, 0x27f0627239c077bd4a85416f92f30529ad279852466bfc94c449a2ef0a72f358);
    }

    function testControlCreateWithParentParentNotInUse() public {
        bytes32 parent = itemStore.create(bytes2(0x0000), 0x1234);
        itemStore.createWithParent(bytes2(0x0001), 0x1234, parent);
    }

    function testFailCreateWithParentParentNotInUse() public {
        itemStore.createWithParent(bytes2(0x0001), 0x1234, itemStore.getContractId());
    }

    function testCreateWithParent() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), 0x1234);
        assertTrue(itemStore.getInUse(itemId0));
        assertEq(itemStore.getFlags(itemId0), 0);
        assertEq(itemStore.getOwner(itemId0), this);
        assertEq(itemStore.getRevisionCount(itemId0), 1);
        assertTrue(!itemStore.getUpdatable(itemId0));
        assertTrue(!itemStore.getEnforceRevisions(itemId0));
        assertTrue(!itemStore.getRetractable(itemId0));
        assertTrue(!itemStore.getTransferable(itemId0));
        assertEq(itemStore.getRevisionIpfsHash(itemId0, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId0, 0), block.timestamp);
        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 0);

        bytes32 itemId1 = itemStore.createWithParent(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN | bytes32(0x01), 0x1234, itemId0);
        assertTrue(itemStore.getInUse(itemId1));
        assertEq(itemStore.getFlags(itemId1), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN);
        assertEq(itemStore.getOwner(itemId1), 0);
        assertEq(itemStore.getRevisionCount(itemId1), 1);
        assertTrue(itemStore.getUpdatable(itemId1));
        assertTrue(itemStore.getEnforceRevisions(itemId1));
        assertTrue(itemStore.getRetractable(itemId1));
        assertTrue(itemStore.getTransferable(itemId1));
        assertEq(itemStore.getRevisionIpfsHash(itemId1, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId1, 0), block.timestamp);
        assertEq(itemStore.getParentCount(itemId1), 1);
        assertEq(itemStore.getParentId(itemId1, 0), itemId0);
        assertEq(itemStore.getChildCount(itemId1), 0);
        assertEq(itemStore.getChildCount(itemId0), 1);
        assertEq(itemStore.getChildId(itemId0, 0), itemId1);

        bytes32 itemId2 = itemStore.createWithParent(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN | bytes32(0x02), 0x2345, itemId0);
        assertTrue(itemStore.getInUse(itemId2));
        assertEq(itemStore.getFlags(itemId2), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN);
        assertEq(itemStore.getOwner(itemId2), 0);
        assertEq(itemStore.getChildCount(itemId2), 0);
        assertEq(itemStore.getRevisionCount(itemId2), 1);
        assertTrue(itemStore.getUpdatable(itemId2));
        assertTrue(itemStore.getEnforceRevisions(itemId2));
        assertTrue(itemStore.getRetractable(itemId2));
        assertTrue(itemStore.getTransferable(itemId2));
        assertEq(itemStore.getRevisionIpfsHash(itemId2, 0), 0x2345);
        assertEq(itemStore.getRevisionTimestamp(itemId2, 0), block.timestamp);
        assertEq(itemStore.getParentCount(itemId2), 1);
        assertEq(itemStore.getParentId(itemId2, 0), itemId0);
        assertEq(itemStore.getChildCount(itemId2), 0);
        assertEq(itemStore.getChildCount(itemId0), 2);
        assertEq(itemStore.getChildId(itemId0, 1), itemId2);

        assertTrue(itemId0 != itemId1);
        assertTrue(itemId0 != itemId2);
        assertTrue(itemId1 != itemId2);
    }

    function testControlCreateWithParentForeignNotInUse() public {
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32 parent = itemStore2.create(bytes2(0x0000), 0x1234);
        itemStore.createWithParent(bytes2(0x0001), 0x1234, parent);
    }

    function testFailCreateWithParentForeignNotInUse() public {
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        itemStore.createWithParent(bytes2(0x0000), 0x1234, itemStore2.getContractId());
    }

    function testCreateWithParentForeign() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), 0x1234);
        assertTrue(itemStore.getInUse(itemId0));
        assertEq(itemStore.getFlags(itemId0), 0);
        assertEq(itemStore.getOwner(itemId0), this);
        assertEq(itemStore.getRevisionCount(itemId0), 1);
        assertTrue(!itemStore.getUpdatable(itemId0));
        assertTrue(!itemStore.getEnforceRevisions(itemId0));
        assertTrue(!itemStore.getRetractable(itemId0));
        assertTrue(!itemStore.getTransferable(itemId0));
        assertEq(itemStore.getRevisionIpfsHash(itemId0, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId0, 0), block.timestamp);
        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 0);

        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32 itemId1 = itemStore2.createWithParent(bytes2(0x0000), 0x1234, itemId0);
        assertTrue(itemStore2.getInUse(itemId1));
        assertEq(itemStore2.getFlags(itemId1), 0);
        assertEq(itemStore2.getOwner(itemId1), this);
        assertEq(itemStore2.getRevisionCount(itemId1), 1);
        assertTrue(!itemStore2.getUpdatable(itemId1));
        assertTrue(!itemStore2.getEnforceRevisions(itemId1));
        assertTrue(!itemStore2.getRetractable(itemId1));
        assertTrue(!itemStore2.getTransferable(itemId1));
        assertEq(itemStore2.getRevisionIpfsHash(itemId1, 0), 0x1234);
        assertEq(itemStore2.getRevisionTimestamp(itemId1, 0), block.timestamp);
        assertEq(itemStore2.getParentCount(itemId1), 1);
        assertEq(itemStore2.getParentId(itemId1, 0), itemId0);
        assertEq(itemStore2.getChildCount(itemId1), 0);

        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 1);
        assertEq(itemStore.getChildId(itemId0, 0), itemId1);
    }

    function testControlCreateWithParentsSameItemId() public {
        itemStore.create(bytes2(0x0000), 0x1234);
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore.create(bytes2(0x0001), 0x1234);
        parents[1] = itemStore.create(bytes2(0x0002), 0x1234);
        itemStore.createWithParents(bytes2(0x0003), 0x1234, parents);
    }

    function testFailCreateWithParentsSameItemId() public {
        itemStore.create(bytes2(0x0000), 0x1234);
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore.create(bytes2(0x0001), 0x1234);
        parents[1] = itemStore.create(bytes2(0x0002), 0x1234);
        itemStore.createWithParents(bytes2(0x0000), 0x1234, parents);
    }

    function testControlCreateWithParentsParentSameItemId() public {
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore.create(bytes2(0x0000), 0x1234);
        parents[1] = itemStore.create(bytes2(0x0001), 0x1234);
        itemStore.createWithParents(bytes2(0x0002), 0x1234, parents);
    }

    function testFailCreateWithParentsParentSameItemId0() public {
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = 0x27f0627239c077bd4a85416f92f30529ad279852466bfc94c449a2ef0a72f358;
        parents[1] = itemStore.create(bytes2(0x0002), 0x1234);
        itemStore.createWithParents(bytes2(0x0001), 0x1234, parents);
    }

    function testFailCreateWithParentsParentSameItemId1() public {
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore.create(bytes2(0x0002), 0x1234);
        parents[1] = 0x27f0627239c077bd4a85416f92f30529ad279852466bfc94c449a2ef0a72f358;
        itemStore.createWithParents(bytes2(0x0001), 0x1234, parents);
    }

    function testControlCreateWithParentsParentNotInUse() public {
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore.create(bytes2(0x0000), 0x1234);
        parents[1] = itemStore.create(bytes2(0x0001), 0x1234);
        itemStore.createWithParents(bytes2(0x0002), 0x1234, parents);
    }

    function testFailCreateWithParentsParentNotInUse0() public {
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore.getContractId();
        parents[1] = itemStore.create(bytes2(0x0001), 0x1234);
        itemStore.createWithParents(bytes2(0x0002), 0x1234, parents);
    }

    function testFailCreateWithParentsParentNotInUse1() public {
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore.create(bytes2(0x0000), 0x1234);
        parents[1] = itemStore.getContractId();
        itemStore.createWithParents(bytes2(0x0002), 0x1234, parents);
    }

    function testCreateWithParents() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), 0x1234);
        assertTrue(itemStore.getInUse(itemId0));
        assertEq(itemStore.getFlags(itemId0), 0);
        assertEq(itemStore.getOwner(itemId0), this);
        assertEq(itemStore.getRevisionCount(itemId0), 1);
        assertTrue(!itemStore.getUpdatable(itemId0));
        assertTrue(!itemStore.getEnforceRevisions(itemId0));
        assertTrue(!itemStore.getRetractable(itemId0));
        assertTrue(!itemStore.getTransferable(itemId0));
        assertEq(itemStore.getRevisionIpfsHash(itemId0, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId0, 0), block.timestamp);
        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 0);

        bytes32 itemId1 = itemStore.create(bytes2(0x0001), 0x1234);
        assertTrue(itemStore.getInUse(itemId1));
        assertEq(itemStore.getFlags(itemId1), 0);
        assertEq(itemStore.getOwner(itemId1), this);
        assertEq(itemStore.getRevisionCount(itemId1), 1);
        assertTrue(!itemStore.getUpdatable(itemId1));
        assertTrue(!itemStore.getEnforceRevisions(itemId1));
        assertTrue(!itemStore.getRetractable(itemId1));
        assertTrue(!itemStore.getTransferable(itemId1));
        assertEq(itemStore.getRevisionIpfsHash(itemId1, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId1, 0), block.timestamp);
        assertEq(itemStore.getParentCount(itemId1), 0);
        assertEq(itemStore.getChildCount(itemId1), 0);

        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemId0;
        parents[1] = itemId1;
        bytes32 itemId2 = itemStore.createWithParents(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN | bytes32(0x01), 0x1234, parents);
        assertTrue(itemStore.getInUse(itemId2));
        assertEq(itemStore.getFlags(itemId2), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN);
        assertEq(itemStore.getOwner(itemId2), 0);
        assertEq(itemStore.getRevisionCount(itemId2), 1);
        assertTrue(itemStore.getUpdatable(itemId2));
        assertTrue(itemStore.getEnforceRevisions(itemId2));
        assertTrue(itemStore.getRetractable(itemId2));
        assertTrue(itemStore.getTransferable(itemId2));
        assertEq(itemStore.getRevisionIpfsHash(itemId2, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId2, 0), block.timestamp);
        assertEq(itemStore.getParentCount(itemId2), 2);
        assertEq(itemStore.getParentId(itemId2, 0), itemId0);
        assertEq(itemStore.getParentId(itemId2, 1), itemId1);
        assertEq(itemStore.getChildCount(itemId0), 1);
        assertEq(itemStore.getChildCount(itemId1), 1);
        assertEq(itemStore.getChildCount(itemId2), 0);
        assertEq(itemStore.getChildId(itemId0, 0), itemId2);
        assertEq(itemStore.getChildId(itemId1, 0), itemId2);

        bytes32 itemId3 = itemStore.createWithParents(UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN | bytes32(0x02), 0x2345, parents);
        assertTrue(itemStore.getInUse(itemId3));
        assertEq(itemStore.getFlags(itemId3), UPDATABLE | ENFORCE_REVISIONS | RETRACTABLE | TRANSFERABLE | DISOWN);
        assertEq(itemStore.getOwner(itemId3), 0);
        assertEq(itemStore.getChildCount(itemId3), 0);
        assertEq(itemStore.getRevisionCount(itemId3), 1);
        assertTrue(itemStore.getUpdatable(itemId3));
        assertTrue(itemStore.getEnforceRevisions(itemId3));
        assertTrue(itemStore.getRetractable(itemId3));
        assertTrue(itemStore.getTransferable(itemId3));
        assertEq(itemStore.getRevisionIpfsHash(itemId3, 0), 0x2345);
        assertEq(itemStore.getRevisionTimestamp(itemId3, 0), block.timestamp);
        assertEq(itemStore.getParentCount(itemId3), 2);
        assertEq(itemStore.getParentId(itemId3, 0), itemId0);
        assertEq(itemStore.getParentId(itemId3, 1), itemId1);
        assertEq(itemStore.getChildCount(itemId0), 2);
        assertEq(itemStore.getChildCount(itemId1), 2);
        assertEq(itemStore.getChildCount(itemId2), 0);
        assertEq(itemStore.getChildCount(itemId3), 0);
        assertEq(itemStore.getChildId(itemId0, 0), itemId2);
        assertEq(itemStore.getChildId(itemId1, 0), itemId2);
        assertEq(itemStore.getChildId(itemId0, 1), itemId3);
        assertEq(itemStore.getChildId(itemId1, 1), itemId3);

        assertTrue(itemId0 != itemId1);
        assertTrue(itemId0 != itemId2);
        assertTrue(itemId0 != itemId3);
        assertTrue(itemId1 != itemId2);
        assertTrue(itemId1 != itemId3);
        assertTrue(itemId2 != itemId3);
    }

    function testControlCreateWithParentsForeignNotInUse() public {
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore2.create(bytes2(0x0000), 0x1234);
        parents[1] = itemStore2.create(bytes2(0x0001), 0x1234);
        itemStore.createWithParents(bytes2(0x0002), 0x1234, parents);
    }

    function testFailCreateWithParentsForeignNotInUse0() public {
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore2.getContractId();
        parents[1] = itemStore2.create(bytes2(0x0001), 0x1234);
        itemStore.createWithParents(bytes2(0x0002), 0x1234, parents);
    }

    function testFailCreateWithParentsForeignNotInUse1() public {
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemStore2.create(bytes2(0x0000), 0x1234);
        parents[1] = itemStore2.getContractId();
        itemStore.createWithParents(bytes2(0x0002), 0x1234, parents);
    }

    function testCreateWithParentsForeign0() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), 0x1234);
        assertTrue(itemStore.getInUse(itemId0));
        assertEq(itemStore.getFlags(itemId0), 0);
        assertEq(itemStore.getOwner(itemId0), this);
        assertEq(itemStore.getRevisionCount(itemId0), 1);
        assertTrue(!itemStore.getUpdatable(itemId0));
        assertTrue(!itemStore.getEnforceRevisions(itemId0));
        assertTrue(!itemStore.getRetractable(itemId0));
        assertTrue(!itemStore.getTransferable(itemId0));
        assertEq(itemStore.getRevisionIpfsHash(itemId0, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId0, 0), block.timestamp);
        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 0);

        bytes32 itemId1 = itemStore.create(bytes2(0x0001), 0x1234);
        assertTrue(itemStore.getInUse(itemId1));
        assertEq(itemStore.getFlags(itemId1), 0);
        assertEq(itemStore.getOwner(itemId1), this);
        assertEq(itemStore.getRevisionCount(itemId1), 1);
        assertTrue(!itemStore.getUpdatable(itemId1));
        assertTrue(!itemStore.getEnforceRevisions(itemId1));
        assertTrue(!itemStore.getRetractable(itemId1));
        assertTrue(!itemStore.getTransferable(itemId1));
        assertEq(itemStore.getRevisionIpfsHash(itemId1, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId1, 0), block.timestamp);
        assertEq(itemStore.getParentCount(itemId1), 0);
        assertEq(itemStore.getChildCount(itemId1), 0);

        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemId0;
        parents[1] = itemId1;
        bytes32 itemId2 = itemStore2.createWithParents(bytes2(0x0000), 0x1234, parents);
        assertTrue(itemStore2.getInUse(itemId2));
        assertEq(itemStore2.getFlags(itemId2), 0);
        assertEq(itemStore2.getOwner(itemId2), this);
        assertEq(itemStore2.getRevisionCount(itemId2), 1);
        assertTrue(!itemStore2.getUpdatable(itemId2));
        assertTrue(!itemStore2.getEnforceRevisions(itemId2));
        assertTrue(!itemStore2.getRetractable(itemId2));
        assertTrue(!itemStore2.getTransferable(itemId2));
        assertEq(itemStore2.getRevisionIpfsHash(itemId2, 0), 0x1234);
        assertEq(itemStore2.getRevisionTimestamp(itemId2, 0), block.timestamp);
        assertEq(itemStore2.getParentCount(itemId2), 2);
        assertEq(itemStore2.getParentId(itemId2, 0), itemId0);
        assertEq(itemStore2.getParentId(itemId2, 1), itemId1);
        assertEq(itemStore2.getChildCount(itemId2), 0);

        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 1);
        assertEq(itemStore.getChildId(itemId0, 0), itemId2);

        assertEq(itemStore.getParentCount(itemId1), 0);
        assertEq(itemStore.getChildCount(itemId1), 1);
        assertEq(itemStore.getChildId(itemId1, 0), itemId2);
    }

    function testCreateWithParentsForeign1() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), 0x1234);
        assertTrue(itemStore.getInUse(itemId0));
        assertEq(itemStore.getFlags(itemId0), 0);
        assertEq(itemStore.getOwner(itemId0), this);
        assertEq(itemStore.getRevisionCount(itemId0), 1);
        assertTrue(!itemStore.getUpdatable(itemId0));
        assertTrue(!itemStore.getEnforceRevisions(itemId0));
        assertTrue(!itemStore.getRetractable(itemId0));
        assertTrue(!itemStore.getTransferable(itemId0));
        assertEq(itemStore.getRevisionIpfsHash(itemId0, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId0, 0), block.timestamp);
        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 0);

        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32 itemId1 = itemStore2.create(bytes2(0x0001), 0x1234);
        assertTrue(itemStore2.getInUse(itemId1));
        assertEq(itemStore2.getFlags(itemId1), 0);
        assertEq(itemStore2.getOwner(itemId1), this);
        assertEq(itemStore2.getRevisionCount(itemId1), 1);
        assertTrue(!itemStore2.getUpdatable(itemId1));
        assertTrue(!itemStore2.getEnforceRevisions(itemId1));
        assertTrue(!itemStore2.getRetractable(itemId1));
        assertTrue(!itemStore2.getTransferable(itemId1));
        assertEq(itemStore2.getRevisionIpfsHash(itemId1, 0), 0x1234);
        assertEq(itemStore2.getRevisionTimestamp(itemId1, 0), block.timestamp);
        assertEq(itemStore2.getParentCount(itemId1), 0);
        assertEq(itemStore2.getChildCount(itemId1), 0);

        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemId0;
        parents[1] = itemId1;
        bytes32 itemId2 = itemStore2.createWithParents(bytes2(0x0000), 0x1234, parents);
        assertTrue(itemStore2.getInUse(itemId2));
        assertEq(itemStore2.getFlags(itemId2), 0);
        assertEq(itemStore2.getOwner(itemId2), this);
        assertEq(itemStore2.getRevisionCount(itemId2), 1);
        assertTrue(!itemStore2.getUpdatable(itemId2));
        assertTrue(!itemStore2.getEnforceRevisions(itemId2));
        assertTrue(!itemStore2.getRetractable(itemId2));
        assertTrue(!itemStore2.getTransferable(itemId2));
        assertEq(itemStore2.getRevisionIpfsHash(itemId2, 0), 0x1234);
        assertEq(itemStore2.getRevisionTimestamp(itemId2, 0), block.timestamp);
        assertEq(itemStore2.getParentCount(itemId2), 2);
        assertEq(itemStore2.getParentId(itemId2, 0), itemId0);
        assertEq(itemStore2.getParentId(itemId2, 1), itemId1);
        assertEq(itemStore2.getChildCount(itemId2), 0);

        assertEq(itemStore.getParentCount(itemId0), 0);
        assertEq(itemStore.getChildCount(itemId0), 1);
        assertEq(itemStore.getChildId(itemId0, 0), itemId2);

        assertEq(itemStore2.getParentCount(itemId1), 0);
        assertEq(itemStore2.getChildCount(itemId1), 1);
        assertEq(itemStore2.getChildId(itemId1, 0), itemId2);
    }

    function testCreateWithParentsForeign2() public {
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32 itemId0 = itemStore2.create(bytes2(0x0001), 0x1234);
        assertTrue(itemStore2.getInUse(itemId0));
        assertEq(itemStore2.getFlags(itemId0), 0);
        assertEq(itemStore2.getOwner(itemId0), this);
        assertEq(itemStore2.getRevisionCount(itemId0), 1);
        assertTrue(!itemStore2.getUpdatable(itemId0));
        assertTrue(!itemStore2.getEnforceRevisions(itemId0));
        assertTrue(!itemStore2.getRetractable(itemId0));
        assertTrue(!itemStore2.getTransferable(itemId0));
        assertEq(itemStore2.getRevisionIpfsHash(itemId0, 0), 0x1234);
        assertEq(itemStore2.getRevisionTimestamp(itemId0, 0), block.timestamp);
        assertEq(itemStore2.getParentCount(itemId0), 0);
        assertEq(itemStore2.getChildCount(itemId0), 0);

        bytes32 itemId1 = itemStore.create(bytes2(0x0001), 0x1234);
        assertTrue(itemStore.getInUse(itemId1));
        assertEq(itemStore.getFlags(itemId1), 0);
        assertEq(itemStore.getOwner(itemId1), this);
        assertEq(itemStore.getRevisionCount(itemId1), 1);
        assertTrue(!itemStore.getUpdatable(itemId1));
        assertTrue(!itemStore.getEnforceRevisions(itemId1));
        assertTrue(!itemStore.getRetractable(itemId1));
        assertTrue(!itemStore.getTransferable(itemId1));
        assertEq(itemStore.getRevisionIpfsHash(itemId1, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId1, 0), block.timestamp);
        assertEq(itemStore.getParentCount(itemId1), 0);
        assertEq(itemStore.getChildCount(itemId1), 0);

        bytes32[] memory parents = new bytes32[](2);
        parents[0] = itemId0;
        parents[1] = itemId1;
        bytes32 itemId2 = itemStore2.createWithParents(bytes2(0x0000), 0x1234, parents);
        assertTrue(itemStore2.getInUse(itemId2));
        assertEq(itemStore2.getFlags(itemId2), 0);
        assertEq(itemStore2.getOwner(itemId2), this);
        assertEq(itemStore2.getRevisionCount(itemId2), 1);
        assertTrue(!itemStore2.getUpdatable(itemId2));
        assertTrue(!itemStore2.getEnforceRevisions(itemId2));
        assertTrue(!itemStore2.getRetractable(itemId2));
        assertTrue(!itemStore2.getTransferable(itemId2));
        assertEq(itemStore2.getRevisionIpfsHash(itemId2, 0), 0x1234);
        assertEq(itemStore2.getRevisionTimestamp(itemId2, 0), block.timestamp);
        assertEq(itemStore2.getParentCount(itemId2), 2);
        assertEq(itemStore2.getParentId(itemId2, 0), itemId0);
        assertEq(itemStore2.getParentId(itemId2, 1), itemId1);
        assertEq(itemStore2.getChildCount(itemId2), 0);

        assertEq(itemStore2.getParentCount(itemId0), 0);
        assertEq(itemStore2.getChildCount(itemId0), 1);
        assertEq(itemStore2.getChildId(itemId0, 0), itemId2);

        assertEq(itemStore.getParentCount(itemId1), 0);
        assertEq(itemStore.getChildCount(itemId1), 1);
        assertEq(itemStore.getChildId(itemId1, 0), itemId2);
    }

    function testFailAddForeignChildNotInUse() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), 0x1234);
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        itemStore.addForeignChild(itemId0, itemStore2.getContractId());
    }

    function testFailAddForeignChildNotChild() public {
        bytes32 itemId0 = itemStore.create(bytes2(0x0000), 0x1234);
        ItemStoreIpfsSha256 itemStore2 = new ItemStoreIpfsSha256(itemStoreRegistry);
        bytes32 itemId1 = itemStore2.create(bytes2(0x0000), 0x1234);
        itemStore.addForeignChild(itemId0, itemId1);
    }

    function testControlCreateNewRevisionNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.createNewRevision(itemId, 0x2345);
    }

    function testFailCreateNewRevisionNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStoreProxy.createNewRevision(itemId, 0x2345);
    }

    function testControlCreateNewRevisionNotUpdatable() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.createNewRevision(itemId, 0x2345);
    }

    function testFailCreateNewRevisionNotUpdatable() public {
        bytes32 itemId = itemStore.create(0, 0x1234);
        itemStore.createNewRevision(itemId, 0x2345);
    }

    function testCreateNewRevision() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0);
        uint revisionId = itemStore.createNewRevision(itemId, 1);
        assertEq(revisionId, 1);
        revisionId = itemStore.createNewRevision(itemId, 2);
        assertEq(revisionId, 2);
        revisionId = itemStore.createNewRevision(itemId, 3);
        assertEq(revisionId, 3);
        revisionId = itemStore.createNewRevision(itemId, 4);
        assertEq(revisionId, 4);
        revisionId = itemStore.createNewRevision(itemId, 5);
        assertEq(revisionId, 5);
        revisionId = itemStore.createNewRevision(itemId, 6);
        assertEq(revisionId, 6);
        revisionId = itemStore.createNewRevision(itemId, 7);
        assertEq(revisionId, 7);
        revisionId = itemStore.createNewRevision(itemId, 8);
        assertEq(revisionId, 8);
        revisionId = itemStore.createNewRevision(itemId, 9);
        assertEq(revisionId, 9);
        revisionId = itemStore.createNewRevision(itemId, 10);
        assertEq(revisionId, 10);
        revisionId = itemStore.createNewRevision(itemId, 11);
        assertEq(revisionId, 11);
        revisionId = itemStore.createNewRevision(itemId, 12);
        assertEq(revisionId, 12);
        revisionId = itemStore.createNewRevision(itemId, 13);
        assertEq(revisionId, 13);
        assertEq(itemStore.getRevisionCount(itemId), 14);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 1), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 2), 2);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 3), 3);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 4), 4);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 5), 5);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 6), 6);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 7), 7);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 8), 8);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 9), 9);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 10), 10);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 11), 11);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 12), 12);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 13), 13);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 1), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 2), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 3), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 4), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 5), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 6), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 7), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 8), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 9), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 10), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 11), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 12), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 13), block.timestamp);
    }

    function testControlUpdateLatestRevisionNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.updateLatestRevision(itemId, 0x2345);
    }

    function testFailUpdateLatestRevisionNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStoreProxy.updateLatestRevision(itemId, 0x2345);
    }

    function testControlUpdateLatestRevisionNotUpdatable() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.updateLatestRevision(itemId, 0x2345);
    }

    function testFailUpdateLatestRevisionNotUpdatable() public {
        bytes32 itemId = itemStore.create(0, 0x1234);
        itemStore.updateLatestRevision(itemId, 0x2345);
    }

    function testControlUpdateLatestRevisionEnforceRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.updateLatestRevision(itemId, 0x2345);
    }

    function testFailUpdateLatestRevisionEnforceRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE | ENFORCE_REVISIONS, 0x1234);
        itemStore.updateLatestRevision(itemId, 0x2345);
    }

    function testUpdateLatestRevision() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
        itemStore.updateLatestRevision(itemId, 0x2345);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x2345);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
    }

    function testControlRetractLatestRevisionNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStoreProxy.retractLatestRevision(itemId);
    }

    function testControlRetractLatestRevisionNotUpdatable() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionNotUpdatable() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.setNotUpdatable(itemId);
        itemStore.retractLatestRevision(itemId);
    }

    function testControlRetractLatestRevisionEnforceRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionEnforceRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE | ENFORCE_REVISIONS, 0x1234);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.retractLatestRevision(itemId);
    }

    function testControlRetractLatestRevisionDoesntHaveAdditionalRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.retractLatestRevision(itemId);
    }

    function testFailRetractLatestRevisionDoesntHaveAdditionalRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.retractLatestRevision(itemId);
    }

    function testRetractLatestRevision() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.createNewRevision(itemId, 0x3456);
        assertEq(itemStore.getRevisionCount(itemId), 3);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 1), 0x2345);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 2), 0x3456);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 1), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 2), block.timestamp);
        itemStore.retractLatestRevision(itemId);
        assertEq(itemStore.getRevisionCount(itemId), 2);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 1), 0x2345);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 1), block.timestamp);
        itemStore.retractLatestRevision(itemId);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
    }

    function testControlRestartNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.restart(itemId, 0x2345);
    }

    function testFailRestartNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStoreProxy.restart(itemId, 0x2345);
    }

    function testControlRestartNotUpdatable() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.restart(itemId, 0x2345);
    }

    function testFailRestartNotUpdatable() public {
        bytes32 itemId = itemStore.create(0, 0x1234);
        itemStore.restart(itemId, 0x2345);
    }

    function testControlRestartEnforceRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.restart(itemId, 0x2345);
    }

    function testFailRestartEnforceRevisions() public {
        bytes32 itemId = itemStore.create(UPDATABLE | ENFORCE_REVISIONS, 0x1234);
        itemStore.restart(itemId, 0x2345);
    }

    function testRestart() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.createNewRevision(itemId, 0x2345);
        itemStore.createNewRevision(itemId, 0x3456);
        assertEq(itemStore.getRevisionCount(itemId), 3);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 1), 0x2345);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 2), 0x3456);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 1), block.timestamp);
        assertEq(itemStore.getRevisionTimestamp(itemId, 2), block.timestamp);
        itemStore.restart(itemId, 0x4567);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x4567);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
    }

    function testControlRetractNotOwner() public {
        bytes32 itemId = itemStore.create(RETRACTABLE, 0x1234);
        itemStore.retract(itemId);
    }

    function testFailRetractNotOwner() public {
        bytes32 itemId = itemStore.create(RETRACTABLE, 0x1234);
        itemStoreProxy.retract(itemId);
    }

    function testControlRetractNotRetractable() public {
        bytes32 itemId = itemStore.create(RETRACTABLE, 0x1234);
        itemStore.retract(itemId);
    }

    function testFailRetractNotRetractable() public {
        bytes32 itemId = itemStore.create(0, 0x1234);
        itemStore.retract(itemId);
    }

    function testRetract() public {
        bytes32 itemId = itemStore.create(RETRACTABLE, 0x1234);
        assertTrue(itemStore.getInUse(itemId));
        assertEq(itemStore.getOwner(itemId), this);
        assertTrue(!itemStore.getUpdatable(itemId));
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
        itemStore.retract(itemId);
        assertTrue(itemStore.getInUse(itemId));
        assertEq(itemStore.getOwner(itemId), 0);
        assertTrue(!itemStore.getUpdatable(itemId));
        assertEq(itemStore.getRevisionCount(itemId), 0);
    }

    function testControlTransferEnableNotTransferable() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        itemStoreProxy.transferEnable(itemId);
    }

    function testFailTransferEnableNotTransferable() public {
        bytes32 itemId = itemStore.create(0, 0x1234);
        itemStoreProxy.transferEnable(itemId);
    }

    function testControlTransferDisableNotEnabled() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        itemStoreProxy.transferEnable(itemId);
        itemStoreProxy.transferDisable(itemId);
    }

    function testFailTransferDisableNotEnabled() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        itemStoreProxy.transferDisable(itemId);
    }

    function testControlTransferNotTransferable() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, itemStoreProxy);
    }

    function testFailTransferNotTransferable() public {
        bytes32 itemId = itemStore.create(0, 0x1234);
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, itemStoreProxy);
    }

    function testControlTransferNotEnabled() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, itemStoreProxy);
    }

    function testFailTransferNotEnabled() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        itemStore.transfer(itemId, itemStoreProxy);
    }

    function testControlTransferDisabled() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, itemStoreProxy);
    }

    function testFailTransferDisabled() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        itemStoreProxy.transferEnable(itemId);
        itemStoreProxy.transferDisable(itemId);
        itemStore.transfer(itemId, itemStoreProxy);
    }

    function testTransfer() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        assertEq(itemStore.getOwner(itemId), this);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
        itemStoreProxy.transferEnable(itemId);
        itemStore.transfer(itemId, itemStoreProxy);
        assertEq(itemStore.getOwner(itemId), itemStoreProxy);
        assertEq(itemStore.getRevisionCount(itemId), 1);
        assertEq(itemStore.getRevisionIpfsHash(itemId, 0), 0x1234);
        assertEq(itemStore.getRevisionTimestamp(itemId, 0), block.timestamp);
    }

    function testControlDisownNotOwner() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        itemStore.disown(itemId);
    }

    function testFailDisownNotOwner() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        itemStoreProxy.disown(itemId);
    }

    function testControlDisownNotTransferable() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        itemStore.disown(itemId);
    }

    function testFailDisownNotTransferable() public {
        bytes32 itemId = itemStore.create(0, 0x1234);
        itemStore.disown(itemId);
    }

    function testDisown() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        assertEq(itemStore.getOwner(itemId), this);
        itemStore.disown(itemId);
        assertEq(itemStore.getOwner(itemId), 0);
    }

    function testControlSetNotUpdatableNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStore.setNotUpdatable(itemId);
    }

    function testFailSetNotUpdatableNotOwner() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        itemStoreProxy.setNotUpdatable(itemId);
    }

    function testSetNotUpdatable() public {
        bytes32 itemId = itemStore.create(UPDATABLE, 0x1234);
        assertTrue(itemStore.getUpdatable(itemId));
        itemStore.setNotUpdatable(itemId);
        assertTrue(!itemStore.getUpdatable(itemId));
    }

    function testControlSetEnforceRevisionsNotOwner() public {
        bytes32 itemId = itemStore.create(0, 0x1234);
        itemStore.setEnforceRevisions(itemId);
    }

    function testFailSetEnforceRevisionsNotOwner() public {
        bytes32 itemId = itemStore.create(0, 0x1234);
        itemStoreProxy.setEnforceRevisions(itemId);
    }

    function testSetEnforceRevisions() public {
        bytes32 itemId = itemStore.create(0, 0x1234);
        assertTrue(!itemStore.getEnforceRevisions(itemId));
        itemStore.setEnforceRevisions(itemId);
        assertTrue(itemStore.getEnforceRevisions(itemId));
    }

    function testControlSetNotRetractableNotOwner() public {
        bytes32 itemId = itemStore.create(RETRACTABLE, 0x1234);
        itemStore.setNotRetractable(itemId);
    }

    function testFailSetNotRetractableNotOwner() public {
        bytes32 itemId = itemStore.create(RETRACTABLE, 0x1234);
        itemStoreProxy.setNotRetractable(itemId);
    }

    function testSetNotRetractable() public {
        bytes32 itemId = itemStore.create(RETRACTABLE, 0x1234);
        assertTrue(itemStore.getRetractable(itemId));
        itemStore.setNotRetractable(itemId);
        assertTrue(!itemStore.getRetractable(itemId));
    }

    function testControlSetNotTransferableNotOwner() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        itemStore.setNotTransferable(itemId);
    }

    function testFailSetNotTransferableNotOwner() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        itemStoreProxy.setNotTransferable(itemId);
    }

    function testSetNotTransferable() public {
        bytes32 itemId = itemStore.create(TRANSFERABLE, 0x1234);
        assertTrue(itemStore.getTransferable(itemId));
        itemStore.setNotTransferable(itemId);
        assertTrue(!itemStore.getTransferable(itemId));
    }

    function testGetAbiVersion() public {
        assertEq(itemStore.getAbiVersion(), 0);
    }

}
