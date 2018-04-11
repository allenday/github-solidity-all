import 'dapple/test.sol';

import 'factory.sol';

contract TheTAOFactoryTest is Test {
    TheTAOFactory _factory;

    function setUp() {
        var authFactory = new DSAuthFactory();
        var dataFactory = new DSDataFactory();
        var tokenFactory = new DSTokenFactory();
        var tokenInstaller = new DSTokenInstaller(authFactory, dataFactory,
                                                  tokenFactory);
        var msFactory = new DSMultisigFactory();

        var factory = new DSFactory1(authFactory, dataFactory,
                                     msFactory, tokenFactory, tokenInstaller);
        _factory = new TheTAOFactory(factory);
    }

    function testCreateAuthority() logs_gas {
        _factory.createAuthority();
    }

    function testCreateToken() logs_gas {
        _factory.createToken(_factory.createAuthority());
    }

    function testSetupMultisig() logs_gas {
        var authority = _factory.createAuthority();
        var (token, manager) = _factory.createToken(authority);
        _factory.setupMultisig(DSBasicAuthority(authority), 2, 3, 72 hours);
    }
}
