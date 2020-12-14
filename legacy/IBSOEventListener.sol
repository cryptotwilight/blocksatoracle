// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 


interface IBSOEventListener {
    
    function getListenerId() external returns(string memory _name);
    
    function getAssetCode() external returns (uint256 _assetCode);
    
    function onEvent( string calldata _eventName, uint256 _eventTimeStamp) external returns (bool); 
    
}