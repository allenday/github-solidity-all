pragma solidity ^0.4.17;

import "ds-test/test.sol";
import "ds-exec/exec.sol";
import "ds-token/token.sol";

import "./sale.sol";

contract SaleUser is DSExec {

    StandardSale sale;
    DSToken token;

    function SaleUser(StandardSale sale_) public {
        sale = sale_;
        token = sale.token();
    }

    function() public payable {}

    function doBuy(uint wad) public {
        exec(sale, wad);
    }

    function doTransfer(address to, uint256 amount) public returns (bool) {
        return token.transfer(to, amount);
    }
}

contract TokenOwner {

    DSToken token;

    function setToken(DSToken token_) public {
        token = token_;
    }

    function doStop() public {
        token.stop();
    }

    function() public payable {}
}

contract TestableStandardSale is StandardSale {

    function TestableStandardSale(
        bytes32 symbol, 
        uint total, 
        uint forSale, 
        uint cap, 
        uint softCap, 
        uint timeLimit, 
        uint softCapTimeLimit,
        uint startTime,
        address multisig)
    StandardSale(
        symbol, 
        total, 
        forSale, 
        cap, 
        softCap, 
        timeLimit, 
        softCapTimeLimit,
        startTime,
        multisig) public {
        localTime = now;
    }

    uint public localTime;

    function time() internal returns (uint) {
        return localTime;
    }

    function addTime(uint extra) public {
        localTime += extra;
    }
}

contract StandardSaleTest is DSTest, DSExec {
    TestableStandardSale sale;
    DSToken token;
    TokenOwner owner;

    SaleUser user1;
    SaleUser user2;


    function setUp() {
        owner = new TokenOwner();
        sale = new TestableStandardSale(
            "TKN",
            10000 ether,
            8000 ether,
            1000 ether,
            900 ether,
            5 days,
            1 days,
            now,
            owner);
        token = sale.token();

        owner.setToken(token);

        user1 = new SaleUser(sale);
        exec(user1, 600 ether);

        user2 = new SaleUser(sale);
        exec(user2, 600 ether);

    }

    function testSaleToken() public {
        assertEq(token.balanceOf(sale), 8000 ether);
    }

    function testOwnerToken() public {
        assertEq(token.balanceOf(owner), 2000 ether);
    }


    function testPublicBuy() public {
        user1.doBuy(19 ether);
        assertEq(token.balanceOf(user1), 152 ether);
        assertEq(owner.balance, 19 ether);

        exec(sale, 11 ether);
        assertEq(token.balanceOf(this), 88 ether);
        assertEq(owner.balance, 30 ether);
    }

    function testClaimTokens() public {
        DSToken test = new DSToken("TST");
        test.mint(1 ether);
        test.push(sale, 1 ether);
        assertEq(test.balanceOf(this), 0);
        sale.transferTokens(test, this, 1 ether);
    }

    // TODO: testFailClaimTokens

    function testBuyManyTimes() public {
        exec(sale, 100 ether);
        assertEq(token.balanceOf(this), 800 ether);

        exec(sale, 200 ether);
        assertEq(token.balanceOf(this), 2400 ether);

        exec(sale, 200 ether);
        assertEq(token.balanceOf(this), 4000 ether);
    }


    function testPostpone() public {
        sale = new TestableStandardSale(
            "TKN",
            10000 ether,
            8000 ether,
            1000 ether,
            900 ether,
            5 days,
            1 days,
            now + 1,
            owner);

        assertEq(sale.startTime(), now + 1 );
        assertEq(sale.endTime(), now + 1 + 5 days);

        sale.postpone(now + 2 days);

        assertEq(sale.startTime(), now + 2 days);
        assertEq(sale.endTime(), now + 7 days);
    }

    function testHitSoftCap() public {
        exec(sale, 800 ether);

        assertEq(sale.endTime(), now + 5 days);

        exec(sale, 100 ether);

        assertEq(sale.endTime(), now + 24 hours);
    }

    function testFinalize() public {

        exec(sale, 900 ether);

        sale.addTime(6 days);

        assertEq(token.balanceOf(sale), 800 ether);
        assertEq(token.balanceOf(owner), 2000 ether);

        sale.finalize();

        assertEq(token.balanceOf(sale), 0 );
        assertEq(token.balanceOf(owner), 2800 ether);

        assertEq(owner.balance, 900 ether);

    }

    function testTokenOwnershipAfterFinalize() public {

        sale.addTime(6 days);

        sale.finalize();
        owner.doStop();
    }

    function testTransferAfterFinalize() public {
        user1.doBuy(1 ether);
        assertEq(token.balanceOf(user1), 8 ether);

        sale.addTime(6 days);
        sale.finalize();

        assert(user1.doTransfer(user2, 8 ether));

        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 8 ether);

    }

    function testBuyExceedHardLimit() public {

        exec(sale, 900 ether);

        // one 100 ether left, 200 ether will return
        user1.doBuy(300 ether);

        assertEq(token.balanceOf(user1), 800 ether);
        assertEq(user1.balance, 500 ether);

        assertEq(sale.endTime(), now);
    }

    function testFailTransferBeforeFinalize() public {
        user1.doBuy(1 ether);
        user1.doTransfer(user2, 8 ether);
    }

    function testFailSoftLimit() public {

        exec(sale, 900 ether);

        sale.addTime(24 hours);

        // sell is finished
        exec(sale, 1 ether);
    }

    function testFailHardLimit() public {

        // hit hard limit
        exec(sale, 1000 ether);

        // sell is finished
        exec(sale, 1 ether);
    }


    function testFailStartTooEarly() public {
        sale = new TestableStandardSale(
            "TKN",
            10000 ether,
            8000 ether,
            1000 ether,
            900 ether,
            5 days,
            1 days,
            now + 1,
            owner);
        exec(sale, 10 ether);
    }

    function testFailBuyAfterClose() public {
        sale.addTime(6 days);
        exec(sale, 10 ether);
    }
}

contract TestableTwoStageSale is TwoStageSale {
    
    function TestableTwoStageSale(
        bytes32 symbol, 
        uint total_, 
        uint forSale_, 
        uint cap_, 
        uint softCap_, 
        uint timeLimit_, 
        uint softCapTimeLimit_,
        uint startTime_,
        address multisig_,
        uint presaleStartTime_,
        uint initPresaleRate,
        uint preSaleCap_)
    TwoStageSale(
        symbol, 
        total_, 
        forSale_, 
        cap_, 
        softCap_, 
        timeLimit_, 
        softCapTimeLimit_,
        startTime_,
        multisig_,
        presaleStartTime_,
        initPresaleRate,
        preSaleCap_) public {
        localTime = now;
    }

    uint public localTime;

    function time() internal returns (uint) {
        return localTime;
    }

    function addTime(uint extra) public {
        localTime += extra;
    }
}

contract TwoStageSaleTest is DSTest, DSExec {
    TestableTwoStageSale sale;
    DSToken token;
    TokenOwner owner;

    SaleUser user1;
    SaleUser user2;


    function setUp() {
        owner = new TokenOwner();
        sale = new TestableTwoStageSale(
            "TKN",
            10000 ether,
            8000 ether,
            1000 ether,
            900 ether,
            5 days,
            1 days,
            now + 1 days,
            owner,
            now + 1,
            8.08 ether,
            500 ether);

        token = sale.token();

        owner.setToken(token);

        user1 = new SaleUser(sale);
        exec(user1, 10000 ether);

        user2 = new SaleUser(sale);
        exec(user2, 10000 ether);

    }

    function testSetPresale() public {
        assertTrue(!sale.presale(user1));
        sale.setPresale(user1, true);
        assertTrue(sale.presale(user1));
    }

    function testAppendTranch() public {
        var (floor, rate) = sale.tranches(0);
        assertEq(rate, 8.08 ether);
        sale.appendTranch(2 ether, 8.16 ether);
        (floor, rate) = sale.tranches(0);
        assertEq(rate, 8.08 ether);
        (floor, rate) = sale.tranches(1);
        assertEq(floor, 2 ether);
        assertEq(rate, 8.16 ether);
    }

    function testFailAppendTranch() public {
        sale.appendTranch(2 ether, 8.16 ether);
        sale.appendTranch(1 ether, 8.32 ether);
    }

    function testPreDistribute() public {
        assertEq(sale.preCollected(), 0);
        sale.preDistribute(user1, 100 ether);
        assertEq(sale.preCollected(), 100 ether);
        assertEq(token.balanceOf(user1), 808 ether);
    }

    function testFailPreDistribute() public {
        sale.addTime(1);
        sale.preDistribute(user1, 100 ether);
    }

    function testHitSoftCapPreDistribute() public {
        sale = new TestableTwoStageSale(
            "TKN",
            10000 ether,
            8000 ether,
            1000 ether,
            900 ether,
            5 days,
            1 days,
            now + 1 days,
            owner,
            now + 1,
            8.08 ether,
            900 ether);

        assertEq(sale.startTime(), now + 1 days);
        assertEq(sale.endTime(), now + 6 days);
        sale.preDistribute(user1, 900 ether);
        assertEq(sale.endTime(), now + 2 days);
    }

    function testHitPresaleCapPreDistribute() public {
        sale.preDistribute(user1, 500 ether);
        assertEq(sale.preCollected(), 500 ether);
        assertEq(sale.collected(), 500 ether);
    }

    function testFailHitPresaleCapPreDistribute() public {
        sale.preDistribute(user1, 501 ether);
        assertEq(sale.preCollected(), 500 ether);
        assertEq(sale.collected(), 500 ether);
    }

    function testHighestTranch() public {
        sale.appendTranch(2 ether, 8.16 ether);
        sale.appendTranch(4 ether, 8.32 ether);
        sale.setPresale(this, true);
        sale.addTime(1);
        exec(sale, 4 ether);
        assertEq(token.balanceOf(this), 33.28 ether);
    }

    function testHighestTranchNotExact() public {
        sale.appendTranch(2 ether, 8.16 ether);
        sale.appendTranch(4 ether, 8.32 ether);
        sale.setPresale(this, true);
        sale.addTime(1);
        exec(sale, 4.01 ether);
        assertEq(token.balanceOf(this), 33.3632 ether);
    }

    function testMiddleTranch() public {
        sale.appendTranch(2 ether, 8.16 ether);
        sale.appendTranch(4 ether, 8.32 ether);
        sale.setPresale(this, true);
        sale.addTime(1);
        exec(sale, 2 ether);
        assertEq(token.balanceOf(this), 16.32 ether);
    }

    function testMiddleTranchNotExact() public {
        sale.appendTranch(2 ether, 8.16 ether);
        sale.appendTranch(4 ether, 8.32 ether);
        sale.setPresale(this, true);
        sale.addTime(1);
        exec(sale, 2.01 ether);
        assertEq(token.balanceOf(this), 16.4016 ether);
    }

    function testLowestTranch() public {
        sale.appendTranch(2 ether, 8.16 ether);
        sale.appendTranch(4 ether, 8.32 ether);
        sale.setPresale(this, true);
        sale.addTime(1);
        exec(sale, 1 ether);
        assertEq(token.balanceOf(this), 8.08 ether);
    }

    function testHitSoftCapPresale() public {
        sale = new TestableTwoStageSale(
            "TKN",
            10000 ether,
            8000 ether,
            1000 ether,
            900 ether,
            5 days,
            1 days,
            now + 1 days,
            owner,
            now + 1,
            8.08 ether,
            900 ether);

        sale.addTime(1);
        sale.setPresale(this, true);
        exec(sale, 900 ether);
        assertEq(sale.endTime(), now + 2 days);
    }

    function testHitPresaleCapPresale() public {
        sale.addTime(1);
        sale.setPresale(user1, true);
        user1.doBuy(500 ether);
        assertEq(sale.collected(), 500 ether);
        assertEq(sale.preCollected(), 500 ether);
        assertEq(token.balanceOf(user1), 4040 ether);

        user1.doBuy(500 ether);
        assertEq(sale.collected(), 500 ether);
        assertEq(sale.preCollected(), 500 ether);
        assertEq(token.balanceOf(user1), 4040 ether);
    }

    function testPresaleRefund() public {
        sale.addTime(1);
        sale.setPresale(user1, true);
        user1.doBuy(1000 ether);
        assertEq(sale.collected(), 500 ether);
        assertEq(sale.preCollected(), 500 ether);
        assertEq(token.balanceOf(user1), 4040 ether);
        assertEq(user1.balance, 9500 ether);
    }

    function testRegularBuy() public {
        sale.addTime(1 days);
        user1.doBuy(19 ether);
        assertEq(token.balanceOf(user1), 152 ether);
        assertEq(owner.balance, 19 ether);

        exec(sale, 11 ether);
        assertEq(token.balanceOf(this), 88 ether);
        assertEq(owner.balance, 30 ether);
    }

    function testUnsyncedRate() public {
        sale.addTime(1);

        sale.setPresale(user1, true);

        user1.doBuy(200 ether);
        assertEq(token.balanceOf(user1), 1616 ether);
        assertEq(owner.balance, 200 ether);

        sale.addTime(1 days);

        user2.doBuy(800 ether);
        assertEq(token.balanceOf(user2), 6384 ether);
        assertEq(owner.balance, 998 ether);
    }


}
