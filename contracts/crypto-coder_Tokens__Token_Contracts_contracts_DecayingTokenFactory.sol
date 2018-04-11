
import "StandardTokenFactory.sol";
import "DecayingTokenFunction.sol";
import "SuddenDecayingTokenFunction.sol";
import "LinearDecayingTokenFunction.sol";
import "StairStepDecayingTokenFunction.sol";
import "ExponentialDecayingTokenFunction.sol";


import "Logger.sol";
import "Logable.sol";


contract DecayingTokenFactory is StandardTokenFactory, Logable {

  mapping (uint8 => address) internal tokenFunctions;
  bool internal tokenFunctionsSet;
  
  
  
  function createTokenFunctions() internal returns (bool success){
      if(tokenFunctionsSet){
	  return true;
      }else{
	  ExponentialDecayingTokenFunction exponentialTokenFunction = new ExponentialDecayingTokenFunction();
	  LinearDecayingTokenFunction linearTokenFunction = new LinearDecayingTokenFunction();
	  StairStepDecayingTokenFunction stairStepTokenFunction = new StairStepDecayingTokenFunction();
	  SuddenDecayingTokenFunction suddenTokenFunction = new SuddenDecayingTokenFunction();
      
	  tokenFunctions[uint8(exponentialTokenFunction.getFunctionType())] = address(exponentialTokenFunction);
	  tokenFunctions[uint8(linearTokenFunction.getFunctionType())] = address(linearTokenFunction);
	  tokenFunctions[uint8(stairStepTokenFunction.getFunctionType())] = address(stairStepTokenFunction);
	  tokenFunctions[uint8(suddenTokenFunction.getFunctionType())] = address(suddenTokenFunction);
      
	  tokenFunctionsSet = true;
	  return true;
      }
  }
  
  
  function getTokenFunction(uint8 _functionType) constant public returns (DecayingTokenFunction tokenFunction){
      if(!tokenFunctionsSet){
	  createTokenFunctions();
      }      
      
      DecayingTokenFunction returnTokenFunction = DecayingTokenFunction(tokenFunctions[_functionType]);
      return returnTokenFunction;
  }
    

}