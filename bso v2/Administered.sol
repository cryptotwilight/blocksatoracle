pragma solidity >=0.4.0 <0.7.4; 
pragma experimental ABIEncoderV2;

contract Administered { 
    
    address administrator; 
    
    constructor(address _administrator) {
        administrator = _administrator;
    }
    
    
    function administratorOnly() internal view returns (bool){ 
        require(msg.sender == administrator);
        return true; 
    }
    
    function setAdministrator(address _newAdministrator) external returns (bool) {
        administratorOnly(); 
        administrator = _newAdministrator; 
    }

}