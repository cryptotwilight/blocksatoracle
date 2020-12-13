// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0;
pragma experimental ABIEncoderV2;

/**
 * @title Tellor price oracle interface.
 * @author Taurai Ushewokunze
 * @dev this is for internal use by the implementation of IBSO.sol
 * 
 */
interface ITellorManager {  
    
    /**
     * @dev this function will resolve the 'assetPairCode' in the form "BASE/QUOTE"  and retrieve the associated asset price from the Tellor oracle
     * @param _assetPairCode for which price is sought
     * @param _timestamp for which price is sought 
     * @return _assetPairPrice price of the asset 
     */
    function getPrice(string memory _assetPairCode, uint256 _timestamp) external returns (uint256 _assetPairPrice);
    
    /**
     * @dev this function will return all the valid asset pair codes supported by the ITellorManager implementation in the form "BASE/QUOTE"
     * @return _assetPairCodes that can be used with the implementation
     */
    function getAllAssetCodes() external returns (string [] memory _assetPairCodes);
    
}