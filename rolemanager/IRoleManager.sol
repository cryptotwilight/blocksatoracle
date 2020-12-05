pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;

//// @author: Taurai Ushewokunze 

/**
 * This is the Role Manager interface. This is executed  by a smart contract to enact Role Based Security on Smart Contract Operations. 
 * The caller should have an address instance of RoleManager 
 * See: RoleManager.sol
 */
interface IRoleManager { 
    /**
     *  This function limits code execution of the 'msg.sender' to the addresses associated with the given '_role'
     *  NOTE: this is 
     */
     //// return success message for the permission request
    function roleOnly(string memory _role) external view returns (string memory _message);

}