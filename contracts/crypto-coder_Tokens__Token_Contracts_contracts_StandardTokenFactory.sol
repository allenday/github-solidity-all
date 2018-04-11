
import "TokenFactory.sol";
import "Token.sol";

contract StandardTokenFactory is TokenFactory {

    bool internal useRegistry = false;
    address internal registry;
    address internal DEFAULT_REGISTRY;
    
    
    event TokenRegistryChanged(address currentRegistry, bool registryUseON);
    
    
    
    function useDefaultRegistry() internal returns (bool usingDefaultRegistrySuccess){
        if(setUseRegistry(true)){
            if(setRegistry(DEFAULT_REGISTRY)){
                //Successfully set the token registry to the default
                TokenRegistryChanged(getRegistry(), getUseRegistry());
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }
    }
    function getUseRegistry() constant public returns (bool){
	    return useRegistry;
    }
    function setUseRegistry(bool _useRegistry) internal returns (bool registrySetSuccess){
	    useRegistry = _useRegistry;
	    return true;
    }
    function setRegistry(address _newRegistryAddress) public returns (bool registrationSuccess){
        if(setUseRegistry(true)){
            registry = _newRegistryAddress;
            return true;
        }else{
            return false;
        }
    }
    function getRegistry() constant public returns (address registry){
	    return registry;
    }
    
    function registerNewToken(Token _newToken) returns (bool){
        
    }
    
    function deregisterToken(Token _token) returns (bool){
        
    }



}