import "StandardToken.sol";

contract TokenFactory {

    event TokenRegistryChanged(address currentRegistry, bool registryUseON);     
    
    function useDefaultRegistry() internal returns (bool usingDefaultRegistrySuccess);
    
    function getUseRegistry() constant public returns (bool);
    function setUseRegistry(bool _useRegistry) internal returns (bool registrySetSuccess);
    function setRegistry(address _newRegistryAddress) public returns (bool registrationSuccess);
    function getRegistry() constant public returns (address registry);
    
    function registerNewToken(Token _newToken) returns (bool);
    
    function deregisterToken(Token _token) returns (bool);

}