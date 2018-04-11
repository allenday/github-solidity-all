pragma solidity 0.4.15;

import '../../contracts/crowdsale/FixedTimeBonuses.sol';
import '../helpers/ThrowProxy.sol';
import 'truffle/Assert.sol';


contract Bonuses {
    using FixedTimeBonuses for FixedTimeBonuses.Data;

    function add(uint endTime, uint bonus) {
        m_bonuses.bonuses.push(FixedTimeBonuses.Bonus(endTime, bonus));
    }

    function validate(bool shouldDecrease) constant {
        m_bonuses.validate(shouldDecrease);
    }

    function getLastTime() constant returns (uint) {
        return m_bonuses.getLastTime();
    }

    function getBonus(uint time) constant returns (uint) {
        return m_bonuses.getBonus(time);
    }

    FixedTimeBonuses.Data m_bonuses;
}

contract TestFixedTimeBonuses {

    function testValidation() {
        Bonuses b = new Bonuses();
        assertInvalid(b, false);
        assertInvalid(b, true);

        b.add(1000000000, 50);
        b.validate(false);
        b.validate(true);

        b.add(1000000010, 40);
        b.validate(false);
        b.validate(true);

        b.add(999999, 60);
        assertInvalid(b, false);
        assertInvalid(b, true);
    }

    function testValidationOfDoubles() {
        Bonuses b = new Bonuses();
        b.add(1000000000, 50);
        b.add(1000000000, 40);
        assertInvalid(b, false);
        assertInvalid(b, true);

        b = new Bonuses();
        b.add(1000, 60);
        b.add(1000000000, 50);
        b.add(1000000000, 40);
        b.add(1000000010, 0);
        assertInvalid(b, false);
        assertInvalid(b, true);

        // the same bonuses
        b = new Bonuses();
        b.add(1000000000, 50);
        b.add(1000000001, 50);
        b.validate(false);
        assertInvalid(b, true);

        b = new Bonuses();
        b.add(1000, 60);
        b.add(1000000000, 50);
        b.add(1000000001, 50);
        b.add(1000000010, 0);
        b.validate(false);
        assertInvalid(b, true);
    }

    function testValidationOfDecrease() {
        Bonuses b = new Bonuses();
        b.add(1000000000, 50);
        b.add(1000000010, 60);
        b.validate(false);
        assertInvalid(b, true);

        b = new Bonuses();
        b.add(1000, 60);
        b.add(1000000000, 50);
        b.add(1000000010, 60);
        b.add(1000000020, 0);
        b.validate(false);
        assertInvalid(b, true);
    }

    function testGetLastTime() {
        Bonuses b = new Bonuses();

        b.add(1000000000, 50);
        b.validate(true);
        Assert.equal(b.getLastTime(), 1000000000, "not eq");

        b.add(1000000010, 0);
        b.validate(true);
        Assert.equal(b.getLastTime(), 1000000010, "not eq");
    }

    function testGetBonus() {
        Bonuses b = new Bonuses();
        b.add(1000000000, 50);
        b.add(1000000010, 30);
        b.add(1000000020, 10);
        b.add(1000000030, 0);

        Assert.equal(b.getBonus(0), 50, "not eq");
        Assert.equal(b.getBonus(1000000000 - 1), 50, "not eq");
        Assert.equal(b.getBonus(1000000000), 50, "not eq");

        Assert.equal(b.getBonus(1000000001), 30, "not eq");
        Assert.equal(b.getBonus(1000000009), 30, "not eq");
        Assert.equal(b.getBonus(1000000010), 30, "not eq");

        Assert.equal(b.getBonus(1000000011), 10, "not eq");

        Assert.equal(b.getBonus(1000000029), 0, "not eq");
        Assert.equal(b.getBonus(1000000030), 0, "not eq");

        ThrowProxy proxy = new ThrowProxy(b);
        Bonuses(proxy).getBonus(1000000333);
        Assert.isTrue(proxy.thrown(), "must throw");
    }


    function assertInvalid(Bonuses b, bool shouldDecrease) private constant {
        ThrowProxy proxy = new ThrowProxy(b);
        Bonuses(proxy).validate(shouldDecrease);
        Assert.isTrue(proxy.thrown(), "must throw");
    }
}
