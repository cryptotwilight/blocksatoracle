pragma solidity >0.4.0 <0.8.0; 
//// @author: Taurai Ushewokunze

/**
 * This interface provides access to the latest version of the IRoleManager.  
 * A fee is charged for the issuance of an instance of IRoleManager. Access to this instance is restricted to the '_roleManagerAadministrator' address provided on issuance
 */ 
interface IRoleManagerGateway { 
    
    
    /**
     * This function returns the fee required for an instance of RoleManager to be issued to the 'caller'     
     */
      //// @return _fee fee for an instance of RoleManager
    function getRoleManagerFee() external view returns(uint256 _fee);
    
    /**
     * This function returns the address of an instance of RoleManager issued according to the fee paid by the 'caller'
     */
     //// @param _roleManagerAadministrator administrator for the RoleManager instance 
     //// @return _roleManagerAddress the address of the role manager 
    function getRoleManager(address _roleManagerAadministrator) payable external returns (address _roleManagerAddress);

}
