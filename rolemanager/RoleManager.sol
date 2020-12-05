pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;


import "./Administered.sol";
import "./IRoleManager.sol";

contract RoleManager is Administered, IRoleManager { 
    
    string[] roles; 
    mapping(string=>address[]) allowedAddressesByRole; 
 
    constructor(address _administrator) Administered(_administrator){
    }
 
    function getRoles() external view returns (string[] memory _roles) {
        administratorOnly();
        return roles; 
    }
    
    function getAllowedAddressesForRole(string memory _role) external view returns (address[] memory _roles) {
        administratorOnly(); 
        return allowedAddressesByRole[_role];
    }
    
    function setAllowedAddressForRole(address _roleAddress, string memory _role) external returns (bool _set) { 
        administratorOnly(); 
        if(!isRoleFound(_role)){
            roles.push(_role);
        }
        allowedAddressesByRole[_role].push(_roleAddress);
        return true;
    }
    
    function roleOnly(string memory _role) override external view returns (string memory _message) {
        require(isRoleFound(_role), '00 - unknown role'); // check that the role is a known role
        address[] memory allowedAddresses = allowedAddressesByRole[_role];
        bool found = false; 
        for(uint x = 0 ; x < allowedAddresses.length; x++) {
            if(allowedAddresses[x] == msg.sender) {
                found = true; 
            }
        }
        require(found, '01 - invalid permissions presented'); // if the sender is not allowed for the role return invalid permissions
        return ('role allowed');
    }

    function isRoleFound(string memory _role)  internal view returns ( bool _isFound) {
        for(uint x; x < roles.length; x++) {
            if(isEqual(roles[x], _role)) {
                return true; 
            } 
        }
        return false; 
    }
    
    
    function deleteRole(string memory _role)  external returns (bool _roleDeleted) {
        administratorOnly();
        delete allowedAddressesByRole[_role];
        
        bool deleted = false; 
        uint rolesLength = roles.length-1; 
        string[] memory n_roles = new string[](rolesLength);
        for(uint x=0; x < roles.length; x++){
            uint index = x; 
            if(deleted) {
                index = x-1; 
            }
            
            string memory l_entry = roles[x];
            
            if(!isEqual(l_entry, _role)) {
                n_roles[index] = l_entry;
            }
            else {
                deleted = true;
            }
        }
        roles = n_roles; 
        return true;
    }
    
    function disAllowAddressForRole(address _roleAddress, string memory _role) external returns (bool _unset) {
        administratorOnly(); 
        bool deleted = false; 
        address[] memory l_roleAddresses = allowedAddressesByRole[_role];
        uint addressesLength = l_roleAddresses.length-1; 
        address[] memory n_roleAddresses = new address[](addressesLength);
        for(uint x=0; x < l_roleAddresses.length; x++){
            uint index = x; 
            if(deleted) {
                index = x-1; 
            }
            
            address l_entry = l_roleAddresses[x];
            
            if(l_entry != _roleAddress) {
                n_roleAddresses[index] = l_entry;
            }
            else {
                deleted = true;
            }
        }
        allowedAddressesByRole[_role] = n_roleAddresses;
        return deleted; 
    }
    
    function isEqual(string memory a, string memory b ) internal pure returns (bool _isEqual) {
       return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }   



}