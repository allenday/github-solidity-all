import "test.sol";

contract AnotherTest is Test {
    function shouldFail() {
       Assert(false);
    }

    function shouldPass() {
       Assert(true);
    }
}
