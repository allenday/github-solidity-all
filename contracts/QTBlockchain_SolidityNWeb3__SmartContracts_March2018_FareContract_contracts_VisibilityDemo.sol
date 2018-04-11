pragma solidity ^0.4.4;

contract VisibilityDemo {
  function VisibilityDemo() public {
    // constructor
  }

   uint  state;

  function IsThisPublic() public {
    IsThisPrivate();
  }

  function IsThisPrivate() private {
    this.IsThisExternal();
  }

  function IsThisExternal() external {
    
  }

  function IsThisInternal() internal {
    
  }

}
