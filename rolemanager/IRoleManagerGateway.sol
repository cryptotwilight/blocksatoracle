// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 

/**
 * @title Role Manager 
 * @author Taurai Ushewokunze
 * @dev This interface provides access to the latest version of the IRoleManager.  
 * A fee is charged for the issuance of an instance of IRoleManager. Access to this instance is restricted to the '_roleManagerAadministrator' address provided on issuance
 */ 
interface IRoleManagerGateway { 
    
    /**
     * This function returns the fee required for an instance of RoleManager to be issued to the 'caller'     
     *
     * @return _fee fee for an instance of RoleManager
     */
    function getRoleManagerFee() external view returns(uint256 _fee);
    
    /**
     * This function returns the address of an instance of RoleManager issued according to the fee paid by the 'msg.sender'
     *
     * @param _roleManagerAadministrator administrator for the RoleManager instance 
     * @return _roleManagerAddress the address of the role manager instance
     */
    function getRoleManager(address _roleManagerAadministrator) payable external returns (address _roleManagerAddress);
    
    /**
     * This operation returns the addres of the instance of the RoleManager created by the _roleManagerAdministrator see 'getRoleManager'
     * @param _roleManagerAdministrator administrator for this role manager instance 
     * @return _roleManagerAddress address of the role manager 
     */ 
    function getRoleManagerAddress(address _roleManagerAdministrator) external view returns (address _roleManagerAddress);

}
