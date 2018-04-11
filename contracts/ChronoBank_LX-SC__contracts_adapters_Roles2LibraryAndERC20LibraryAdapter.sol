/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;


import './Roles2LibraryAdapter.sol';


contract ERC20LibraryInterface {
    function includes(address _contract) public view returns(bool);
}


contract Roles2LibraryAndERC20LibraryAdapter is Roles2LibraryAdapter {

    ERC20LibraryInterface erc20Library;

    uint constant ROLES_2_LIBRARY_AND_ERC20_LIBRARY_ADAPTER_SCOPE = 14000;
    uint constant ROLES_2_LIBRARY_AND_ERC20_LIBRARY_ADAPTER_UNSUPPORTED_CONTRACT = ROLES_2_LIBRARY_AND_ERC20_LIBRARY_ADAPTER_SCOPE + 1;

    modifier onlySupportedContract(address _contract) {
        if (!erc20Library.includes(_contract)) {
            assembly {
                mstore(0, 14001) // ROLES_2_LIBRARY_AND_ERC20_LIBRARY_ADAPTER_UNSUPPORTED_CONTRACT
                return(0, 32)
            }
        }
        _;
    }

    function Roles2LibraryAndERC20LibraryAdapter(
        address _roles2Library,
        address _erc20Library
    )
    Roles2LibraryAdapter(_roles2Library)
    public
    {
        erc20Library = ERC20LibraryInterface(_erc20Library);
    }

    function setERC20Library(ERC20LibraryInterface _erc20Library) public auth returns (uint) {
        erc20Library = _erc20Library;
        return OK;
    }

}
