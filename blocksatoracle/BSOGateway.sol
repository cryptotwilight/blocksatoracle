// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4; 
pragma experimental ABIEncoderV2; 

import "../rolemanager/Administered.sol";
import "./IBSOGateway.sol";
/**
 * @author Taurai Ushewokunze
 */
contract BSOGateway is Administered, IBSOGateway { 
    
    
    address oracle; 
    string oracleVersion; 
    address dispatch; 
    string dispatchVersion;
    
    
    constructor(address _administrator, 
                address _oracle, 
                string memory _oracleVersion, 
                address _dispatch, 
                string memory _dispatchVersion) Administered(_administrator) {
        oracle = _oracle; 
        oracleVersion = _oracleVersion; 
        dispatch = _dispatch;
        dispatchVersion = _dispatchVersion; 
        
    }
    
    
    function getOracle() override external view returns (address _bsoAddress, string memory _version) {
        return (oracle, oracleVersion); 
    }
       
     
    function getDispatch() override external view returns (address _bsoDispatchAddress, string memory _dispatchVersion)  {
        return (dispatch, dispatchVersion);
    }
      
       
    function setBSODispatchAddress(address _newAddress, string memory  _newVersion)  external returns (bool _success) {
        administratorOnly(); 
        dispatch = _newAddress; 
        dispatchVersion = _newVersion;
        return true; 
    }
       
    function setBSOAddress(address _newAddress, string memory _newVersion) external returns (bool _success) { 
        administratorOnly(); 
        oracle = _newAddress; 
        oracleVersion = _newVersion; 
        return true; 
    }
}
