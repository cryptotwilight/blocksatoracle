// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;
/**
 * @title Administered 
 * @author Taurai Ushewokunze 
 * @dev This contract provides the basis of administration through out Block Sat 
 */ 
abstract contract  Administered { 
    
    address administrator; 
    
    constructor(address _administrator) {
        administrator = _administrator;
    }
    
    function administratorOnly() internal view returns (string memory _message){ 
        require(msg.sender == administrator,'00 - invalid administration permissions');
        return 'administrator ok'; 
    }
    
    function setAdministrator(address _newAdministrator) external returns (string memory _message) {
        administratorOnly(); 
        administrator = _newAdministrator; 
        return 'administrator changed.';
    }
    
}