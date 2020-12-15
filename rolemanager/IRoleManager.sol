// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;

/**
 * @title Role Manager for Block Sat
 * @author Taurai Ushewokunze 
 * @dev This is the Role Manager interface. This is executed  by a smart contract to enact Role Based Security on Smart Contract Operations. 
 * The caller should have an address instance of RoleManager see 'IRoleManagerGateway.sol'
 * 
 */
interface IRoleManager { 
    
    /**
     * @dev This function limits code execution of the '_caller' to the addresses associated with the given '_role'
     * if the '_caller' is not on the list the operation will 'revert'
     * @return _message success message for the permission request
     */
    function roleOnly(string memory _role, address _caller) external view returns (string memory _message);

}