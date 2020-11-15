pragma solidity ^0.7.4; 
pragma experimental ABIEncoderV2; 

import "./Administered.sol";

contract BSOGateway is Administered { 
    
    
    address oracle; 
    string version; 
    
    constructor(address _administrator, address _oracle, string _version) Administered(_administrator) {
        oracle = _oracle; 
        version = _version; 
    }
    
    
    function getOracle() external view returns (address _bsoAddress, string memory _version) {
        return (oracle, version); 
    }
       
       
    function setBSOAddress(address _newAddress, string memory _newVersion) external returns (bool _success) { 
        administratorOnly(); 
        _oracle = _newAddress; 
        _version = _newVersion; 
        return true; 
    }
}