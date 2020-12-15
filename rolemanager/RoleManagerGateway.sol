// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;


import "../bank/IBank.sol";
import "./Administered.sol";
import "./RoleManager.sol";
import "./IRoleManagerGateway.sol";
/**
 * @author Taurai Ushewokunze 
 */
contract RoleManagerGateway is Administered, IRoleManagerGateway {
        
    
    mapping(address=>address) roleManagerAddressByRoleManagerAdministratorAddress; 
    mapping(address=>address) roleManagerAdministratorAddressByRoleManagerAddress; 
    address [] deployedRoleManagers; 
    uint256 roleManagerIssuanceFee; 
    IBank bank; 
        
    constructor(address _administrator, address _bankAddress) Administered(_administrator){
        bank = IBank(_bankAddress);
    }

    function getRoleManagerFee() override external view returns(uint256 _fee) {
        return roleManagerIssuanceFee; 
    }
    
    function setRoleManagerFee(uint256 _roleManagerIssuanceFee) external returns(bool _set) {
        administratorOnly(); 
        roleManagerIssuanceFee = _roleManagerIssuanceFee;
        return true; 
    }   

    function getRoleManager(address _roleManagerAdministrator) override payable external returns (address _roleManagerAddress) {
        require(msg.value >= roleManagerIssuanceFee, 'insuffiencent role manager issuance fee'); 
        RoleManager rm = new RoleManager(_roleManagerAdministrator);
        bank.deposit{value : roleManagerIssuanceFee}(roleManagerIssuanceFee, msg.sender, address(this), 'getRoleManager', block.timestamp);
        address l_rmAddress = address(rm);
        roleManagerAddressByRoleManagerAdministratorAddress[_roleManagerAdministrator] = l_rmAddress; 
        roleManagerAdministratorAddressByRoleManagerAddress[l_rmAddress] = _roleManagerAdministrator;
        deployedRoleManagers.push(l_rmAddress);
        return l_rmAddress;
    }
    
    function getRoleManagerAddress(address _roleManagerAdministrator) override external view returns (address _roleManagerAddress) {
        return roleManagerAddressByRoleManagerAdministratorAddress[_roleManagerAdministrator];
    }
    

}