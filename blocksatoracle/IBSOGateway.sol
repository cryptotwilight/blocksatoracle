// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 
/**
 * @title Block Sat Oracle Gateway interface.
 * @author Taurai Ushewokunze
 * @dev this gateway provides an instance of the Block Sat Oracle for user clients and and instance of the Block Sat Dispatch for nodes. 
 * The versions provided of both Oracle and Dispatch are usually backwards compatible. 
 */ 
interface IBSOGateway { 
    /**
     * @dev an address to an instance of IBSO.sol along with the implementation version. 
     * NOTE: the address to Oracle may not be the same as the address to Dispatch
     */ 
    function getOracle() external view returns (address _bsoAddress, string memory _version);  
    
    /**
     * @dev returns an address to an instance of IBSODispatch.sol along with the implementation version. 
     * NOTE: the address to Dispatch may not be the same as the address to Oracle
     */
    function getDispatch() external view returns (address _bsoDispatchAddress, string memory _version);
}