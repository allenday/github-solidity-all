import 'dappsys/factory/factory.sol';
import 'dappsys/token/supply_manager.sol';

contract TheTAOFactory is DSAuthModesEnum {
    DSFactory _factory;

    function TheTAOFactory(DSFactory factory) {
        _factory = factory;
    }

    function createAuthority() returns (DSBasicAuthority) {
        return _factory.buildDSBasicAuthority();
    }

    function createToken(DSBasicAuthority authority)
             returns (DSTokenFrontend, DSTokenSupplyManager)
    {
        authority.updateAuthority(_factory, DSAuthModes.Owner);

        DSTokenFrontend token = _factory.installDSTokenBasicSystem(authority);
        DSBalanceDB db = token.getController().getBalanceDB();
        DSTokenSupplyManager manager = new DSTokenSupplyManager(db);
        authority.setCanCall(
          manager, db, bytes4(sha3('addBalance(address,uint256)')), true);
        authority.setCanCall(
          manager, db, bytes4(sha3('subBalance(address,uint256)')), true);
        manager.updateAuthority(authority, DSAuthModes.Authority);

        authority.updateAuthority(this, DSAuthModes.Owner);

        return (token, manager);
    }

    function giveOwnership(DSBasicAuthority authority) {
        authority.updateAuthority(msg.sender, DSAuthModes.Owner);
    }

    function setupMultisig(DSBasicAuthority authority, uint n, uint m, uint exp)
             returns (address)
    {
        DSEasyMultisig multisig = _factory.buildDSEasyMultisig(n, m, exp);
        authority.updateAuthority(multisig, DSAuthModes.Owner);

        return multisig;
    }
}
