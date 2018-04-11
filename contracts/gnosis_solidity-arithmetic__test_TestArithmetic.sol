pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Arithmetic.sol";
import "./ThrowProxy.sol";

contract ArithmeticThrower {
    function doNotThrowOnValidDiv() {
        Arithmetic.div256_128By256(
            0xc14e772707388bb8558b1b24b0dd11f6cf50f61fcc9ad3e671189b2bc28270a7,
            0x4ad41f3028d19ee5b1058090facc4f6a,
            0xc21d87c491ba579f4cfbd2a65e868eca4e7f0ac566709f92998f26fdb0777c7);
    }

    function doThrowOnDivByZero() {
        Arithmetic.div256_128By256(
            0xc14e772707388bb8558b1b24b0dd11f6cf50f61fcc9ad3e671189b2bc28270a7,
            0x4ad41f3028d19ee5b1058090facc4f6a, 0);
    }
}

contract TestArithmetic {
    using Assert for *;

    uint constant a = 0xcafef00dcafef00dcafef00dcafef00dcafef00dcafef00dcafef00dcafef00d;
    uint constant b = 0xf7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bdef7bde0000;

    function testMul256By256() {
        var (ab32, ab1, ab0) = Arithmetic.mul256By256(a, b);
        ab32.equal(0xc47295bac47295bac47295bac47295bac47295bac47295bac47295bac471d147, "high 256 bits of product wrong");
        ab1.equal(0x6a453b8d6a453b8d6a453b8d6a453b8d, "next 128 bits of product wrong");
        ab0.equal(0x6a453b8d6a453b8d6a453b8d6a460000, "low 128 bits of product wrong");

        (ab32, ab1, ab0) = Arithmetic.mul256By256(2**256-1, 2**256-1);
        ab32.equal(2**256-2, "high 256 bits of max product wrong");
        ab1.equal(0, "next 128 bits of max product wrong");
        ab0.equal(1, "low 128 bits of max product wrong");

        (ab32, ab1, ab0) = Arithmetic.mul256By256(
            0x9014f6307009d2d5df0cb71c7f97859a04b335daea24bdf92e515f149837a8e6,
            0xd72618b69d8c48d5d775dc419ecfc219551e515f3af0963ad4688920ce79c269
        );
        ab32.equal(0x79170bc7f7f041e813f86c6c7852db20d88f13727f2e083410a19526a57f22ba, "high bits of some product wrong");
        ab1.equal(0x4f96f469620c8051bfc75631846830fb, "next bits of some product wrong");
        ab0.equal(0x0b08e4d8c0c1fde6126e89c485889256, "next bits of some product wrong");
    }

    function testdiv256_128By256() {
        var (q, r) = Arithmetic.div256_128By256(
            0xc47295bac47295bac47295bac47295bac47295bac47295bac47295bac471d147,
            0x6a453b8d6a453b8d6a453b8d6a453b8d,
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000);

        q.equal(0xc47295bac47295bac47295bac47295ba, "wrong quotient");
        r.equal(0xc47295bac47295bac47295bac47295b9ffffffffffffffffffffffffffff3b8d, "wrong remainder");

        (q, r) = Arithmetic.div256_128By256(2**256-1, 2**128-1, 2**256-1);

        q.equal(2**128, "wrong quotient for maximal division args");
        r.equal(2**128-1, "wrong remainder for maximal division args");

        (q, r) = Arithmetic.div256_128By256(
            0xc14e772707388bb8558b1b24b0dd11f6cf50f61fcc9ad3e671189b2bc28270a7,
            0x4ad41f3028d19ee5b1058090facc4f6a,
            0xc21d87c491ba579f4cfbd2a65e868eca4e7f0ac566709f92998f26fdb0777c7);

        q.equal(0xfeeeec0de9b8e3642b7e41db43cd76305, "wrong quotient for some division");
        r.equal(0x4cb9d73e6c7e49b14dde63623d22354587735d56d2be2a21ff30c6994340387, "wrong remainder for some division");

        (q, r) = Arithmetic.div256_128By256(
            0xc14e772707388bb8558b1b24b0dd11f6cf50f61fcc9ad3e671189b2bc28270a7,
            0x4ad41f3028d19ee5b1058090facc4f6a,
            0x1a4e7f0ac566709f92998f26fdb0777c7);

        q.equal(0x75924065957af22f3caef35d592d3e6387fa560075ec52525de8eea7216708e5, "wrong quotient for dividing some 384-bit by 129-bit");
        r.equal(0x16a825313ed69004e12d1e866f94ef267, "wrong remainder for dividing some 384-bit by 129-bit");

        ArithmeticThrower thrower = new ArithmeticThrower();
        ThrowProxy throwProxy = new ThrowProxy(address(thrower));

        ArithmeticThrower(address(throwProxy)).doNotThrowOnValidDiv();
        throwProxy.execute.gas(200000)().isTrue("should not throw when dividing normally");

        ArithmeticThrower(address(throwProxy)).doThrowOnDivByZero();
        throwProxy.execute.gas(200000)().isFalse("should throw on zero division");
    }

    function testOverflowResistantFraction() {
        // a * b / d = c
        uint c = 0xc47295bac47295bac47295bac47295bac47295bac47295bac47295bac47295ba;
        uint d = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000;

        c.equal(Arithmetic.overflowResistantFraction(a, b, d), "lolwut");
    }
}
